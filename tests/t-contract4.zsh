#!/usr/bin/env zunit
#{{{                    MARK:Header
##### Purpose: zsh-learn — fourth-tier contracts.
#####          Pins for default values: ZPWR_LEARN_MAX_SIZE,
#####          ZPWR_VARS[maxRecords], schema/table defaults, and
#####          tempfile path defaults. These act as the public
#####          knobs; renumbering or renaming silently breaks user
#####          scripts that read them.
#}}}***********************************************************

@setup {
    0="${${0:#$ZSH_ARGZERO}:-${(%):-%N}}"
    0="${${(M)0:#/*}:-$PWD/$0}"
    pluginDir="${0:h:A}"
    pluginFile="$pluginDir/zsh-learn.plugin.zsh"
}

@test 'ZPWR_LEARN_MAX_SIZE defaults to 3000 when unset (caller-overridable)' {
    # Pin: the `test -z` / export pattern means a caller can set
    # ZPWR_LEARN_MAX_SIZE=10000 before sourcing to lift the cap.
    # Unset must default to 3000. Bumping this silently changes
    # what the Savel guard rejects.
    local out
    out=$(zsh -c "
        emulate zsh
        unset ZPWR_LEARN_MAX_SIZE
        source '$pluginFile' 2>/dev/null
        print \$ZPWR_LEARN_MAX_SIZE
    ")
    assert "$out" same_as '3000'
}

@test 'ZPWR_LEARN_MAX_SIZE caller-pre-set value is preserved' {
    # Pin: pre-set value must not be clobbered by the `test -z` guard.
    local out
    out=$(zsh -c "
        emulate zsh
        export ZPWR_LEARN_MAX_SIZE=12345
        source '$pluginFile' 2>/dev/null
        print \$ZPWR_LEARN_MAX_SIZE
    ")
    assert "$out" same_as '12345'
}

@test 'ZPWR_VARS[maxRecords] defaults to 2000 (unconditional, not env-overridable)' {
    # Pin: maxRecords lives in the global ZPWR_VARS assoc array, set
    # unconditionally. This is the in-shell cap (separate from
    # ZPWR_LEARN_MAX_SIZE which guards Savel input length). Pin the
    # literal 2000 default.
    local out
    out=$(zsh -c "
        emulate zsh
        source '$pluginFile' 2>/dev/null
        print \${ZPWR_VARS[maxRecords]}
    ")
    assert "$out" same_as '2000'
}

@test 'ZPWR_SCHEMA_NAME defaults to "root" and ZPWR_TABLE_NAME to "LearningCollectiion"' {
    # Pin: the SQL backend reads these as the FROM clause. Renaming
    # either breaks every running mysql client that targets the
    # collection. Yes, the upstream typo "LearningCollectiion" is
    # the persistent identifier — DO NOT "fix" it without a migration.
    local schema table
    schema=$(zsh -c "emulate zsh; unset ZPWR_SCHEMA_NAME; source '$pluginFile' 2>/dev/null; print \$ZPWR_SCHEMA_NAME")
    table=$(zsh -c "emulate zsh; unset ZPWR_TABLE_NAME; source '$pluginFile' 2>/dev/null; print \$ZPWR_TABLE_NAME")
    assert "$schema" same_as 'root'
    assert "$table" same_as 'LearningCollectiion'
}

@test 'ZPWR_LEARN_COMMAND defaults to "mysql" (backend dispatch contract)' {
    # Pin: zsh-learn shells out to whatever ZPWR_LEARN_COMMAND names.
    # Changing this default would silently route to a different binary
    # (e.g. sqlite3, mariadb) and produce different syntax errors. The
    # caller can override before sourcing.
    local out
    out=$(zsh -c "
        emulate zsh
        unset ZPWR_LEARN_COMMAND
        source '$pluginFile' 2>/dev/null
        print \$ZPWR_LEARN_COMMAND
    ")
    assert "$out" same_as 'mysql'
}
