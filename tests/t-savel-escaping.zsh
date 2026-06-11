#!/usr/bin/env zunit
#{{{                    MARK:Header
#**************************************************************
##### Author: MenkeTechnologies
##### GitHub: https://github.com/MenkeTechnologies
##### Purpose: pin two zsh-learn-Savel invariants that the
#####          existing suite leaves unasserted:
#####          (1) the single-quote -> \' escaping that the
#####              sed at autoload/zsh-learn-Savel:42 performs
#####              before interpolating into the INSERT VALUES
#####              clause. The existing 'special SQL chars' test
#####              only asserts the call returns 0; it never
#####              asserts the quote is actually escaped, so a
#####              regression that dropped the escape (a SQL
#####              break-out) would still pass.
#####          (2) the size guard at :49 counts CHARACTERS
#####              ($#learning), not bytes. Every existing
#####              boundary test uses ASCII where chars==bytes;
#####              a naive byte-based reimplementation (wc -c)
#####              would reject a 3-char multibyte string under
#####              a 3-char limit. This pins char semantics.
#}}}***********************************************************

@setup {
    0="${${0:#$ZSH_ARGZERO}:-${(%):-%N}}"
    0="${${(M)0:#/*}:-$PWD/$0}"
    pluginDir="${0:h:A}"

    # UTF-8 locale so $#string counts characters, matching the
    # daily-driver environment. Without this, $# may degrade to
    # bytes and the char-vs-byte distinction collapses.
    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8

    # echo the generated SQL back instead of piping to mysql
    export ZPWR_LEARN_COMMAND="cat"
    export ZPWR_SCHEMA_NAME="testschema"
    export ZPWR_TABLE_NAME="TestTable"
    export ZPWR_LOGFILE="/tmp/.zpwr-test-escaping-log-$$"

    autoload -Uz "$pluginDir/autoload/zsh-learn-Savel"
}

@teardown {
    command rm -f "/tmp/.zpwr-test-escaping-log-$$"
}

@test 'Savel - embedded single quote is escaped to backslash-quote in SQL' {
    # autoload/zsh-learn-Savel:42 runs sed 's/.../\\.../g' turning
    # each ' into \'. The escaped form MUST appear so the value
    # cannot terminate the surrounding '...' SQL literal early.
    # Plain glob: the literal two chars backslash + quote.
    export ZPWR_LEARN_MAX_SIZE=3000
    run zsh-learn-Savel "it's a test"

    assert $state equals 0
    # the escaped sequence must be present
    assert "$output" contains "it\\'s a test"
    # and the raw (unescaped) form must NOT survive: 'it's' would
    # be a break-out. Confirm the char before the s is a backslash.
    assert "$output" does_not_contain "values ('programming', 'it's"
}

@test 'Savel - leading and trailing quotes both escaped after trim' {
    # The trim (strip surrounding whitespace) happens in the SAME
    # sed before the quote-escape clause. A quote left exposed at
    # either boundary post-trim is the easiest break-out. Input has
    # quotes flush against the trimmed boundaries.
    export ZPWR_LEARN_MAX_SIZE=3000
    run zsh-learn-Savel "  'edge'  "

    assert $state equals 0
    # both quotes escaped: \'edge\'
    assert "$output" contains "\\'edge\\'"
}

@test 'Savel - size limit counts characters not bytes for multibyte input' {
    # Guard at autoload/zsh-learn-Savel:49 uses $#learning (chars).
    # 'eee' with combining/accented chars: 3 chars, 6 bytes.
    # Under a 3-char limit it MUST be accepted; a byte-based
    # reimplementation (6 > 3) would wrongly reject it.
    export ZPWR_LEARN_MAX_SIZE=3
    run zsh-learn-Savel "ééé"

    assert $state equals 0
    assert "$output" contains "insert into"
    assert "$output" does_not_contain "greater than limit"
}

@test 'Savel - size limit rejects one char over for multibyte input' {
    # Companion to the accept case: 4 multibyte chars under a
    # 3-char limit must be rejected, and the reported size must be
    # the CHARACTER count (4), not the byte count (8).
    export ZPWR_LEARN_MAX_SIZE=3
    run zsh-learn-Savel "éééé"

    assert $state equals 1
    assert "$output" contains "size 4 is greater than limit of 3"
}
