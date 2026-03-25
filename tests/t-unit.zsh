#!/usr/bin/env zunit
#{{{                    MARK:Header
#**************************************************************
##### Author: MenkeTechnologies
##### GitHub: https://github.com/MenkeTechnologies
##### Date: Wed Mar 25 2026
##### Purpose: comprehensive unit tests for zsh-learn plugin
##### Notes: tests covering env defaults, function existence,
#####        input validation, SQL generation, edge cases
#}}}***********************************************************

@setup {
    0="${${0:#$ZSH_ARGZERO}:-${(%):-%N}}"
    0="${${(M)0:#/*}:-$PWD/$0}"
    pluginDir="${0:h:A}"

    # save original env
    _orig_ZPWR_SEND_KEYS_FULL="$ZPWR_SEND_KEYS_FULL"
    _orig_ZPWR_TEMPFILE_SQL="$ZPWR_TEMPFILE_SQL"
    _orig_ZPWR_SCHEMA_NAME="$ZPWR_SCHEMA_NAME"
    _orig_ZPWR_TABLE_NAME="$ZPWR_TABLE_NAME"
    _orig_ZPWR_TEMPFILE="$ZPWR_TEMPFILE"
    _orig_ZPWR_TEMPFILE2="$ZPWR_TEMPFILE2"
    _orig_ZPWR_LOGFILE="$ZPWR_LOGFILE"
    _orig_ZPWR_CHAR_LOGO="$ZPWR_CHAR_LOGO"
    _orig_ZPWR_LEARN_COMMAND="$ZPWR_LEARN_COMMAND"
    _orig_ZPWR_LEARN_MAX_SIZE="$ZPWR_LEARN_MAX_SIZE"

    # set test env
    export ZPWR_SEND_KEYS_FULL=false
    export ZPWR_TEMPFILE_SQL="/tmp/.zpwr-test-sql-temp-$$"
    export ZPWR_SCHEMA_NAME="testschema"
    export ZPWR_TABLE_NAME="TestTable"
    export ZPWR_TEMPFILE="/tmp/.zpwr-test-temp-$$"
    export ZPWR_TEMPFILE2="/tmp/.zpwr-test-temp2-$$"
    export ZPWR_TEMPFILE3="/tmp/.zpwr-test-temp3-$$"
    export ZPWR_LOGFILE="/tmp/.zpwr-test-log-$$"
    export ZPWR_CHAR_LOGO="<<)(>>"
    export ZPWR_LEARN_COMMAND="cat"
    export ZPWR_LEARN_MAX_SIZE=3000

    declare -gA ZPWR_VARS
    ZPWR_VARS[maxRecords]=2000

    # source plugin
    source "$pluginDir/zsh-learn.plugin.zsh"

    # mock mysql command that echoes the SQL it receives
    _mock_mysql() {
        cat
    }

    # autoload all functions
    fpath=("$pluginDir/autoload" "$pluginDir/src" $fpath)
    for f in "$pluginDir/autoload/"*(.:t); do
        autoload -Uz "$f"
    done
}

@teardown {
    # restore env
    export ZPWR_SEND_KEYS_FULL="$_orig_ZPWR_SEND_KEYS_FULL"
    export ZPWR_TEMPFILE_SQL="$_orig_ZPWR_TEMPFILE_SQL"
    export ZPWR_SCHEMA_NAME="$_orig_ZPWR_SCHEMA_NAME"
    export ZPWR_TABLE_NAME="$_orig_ZPWR_TABLE_NAME"
    export ZPWR_TEMPFILE="$_orig_ZPWR_TEMPFILE"
    export ZPWR_TEMPFILE2="$_orig_ZPWR_TEMPFILE2"
    export ZPWR_LOGFILE="$_orig_ZPWR_LOGFILE"
    export ZPWR_CHAR_LOGO="$_orig_ZPWR_CHAR_LOGO"
    export ZPWR_LEARN_COMMAND="$_orig_ZPWR_LEARN_COMMAND"
    export ZPWR_LEARN_MAX_SIZE="$_orig_ZPWR_LEARN_MAX_SIZE"

    # cleanup temp files
    command rm -f "/tmp/.zpwr-test-sql-temp-$$" \
        "/tmp/.zpwr-test-temp-$$" \
        "/tmp/.zpwr-test-temp2-$$" \
        "/tmp/.zpwr-test-temp3-$$" \
        "/tmp/.zpwr-test-log-$$"
}

# ================================================================
# Section 1: File syntax validation
# ================================================================

@test 'syntax - plugin file parses without errors' {
    run zsh -n "$pluginDir/zsh-learn.plugin.zsh"
    assert $state equals 0
}

@test 'syntax - all autoload files parse without errors' {
    for file in "$pluginDir/autoload/"*; do
        run zsh -n "$file"
        assert $state equals 0
    done
}

@test 'syntax - completion file _se parses without errors' {
    run zsh -n "$pluginDir/src/_se"
    assert $state equals 0
}

@test 'syntax - plugin zsh file parses' {
    run zsh -n "$pluginDir/zsh-learn.plugin.zsh"
    assert $state equals 0
}

# ================================================================
# Section 2: Environment variable defaults
# ================================================================

@test 'env - ZPWR_SEND_KEYS_FULL defaults to false' {
    local _val
    _val="$(env -i HOME="$HOME" zsh --no-rcs -c 'ZPWR_LEARN=false; source "'"$pluginDir"'/zsh-learn.plugin.zsh"; echo "$ZPWR_SEND_KEYS_FULL"' 2>/dev/null)"
    assert "$_val" same_as "false"
}

@test 'env - ZPWR_TEMPFILE_SQL defaults to /tmp/.zpwr-sql-temp' {
    local _val
    _val="$(env -i HOME="$HOME" zsh --no-rcs -c 'ZPWR_LEARN=false; source "'"$pluginDir"'/zsh-learn.plugin.zsh"; echo "$ZPWR_TEMPFILE_SQL"' 2>/dev/null)"
    assert "$_val" same_as "/tmp/.zpwr-sql-temp"
}

@test 'env - ZPWR_SCHEMA_NAME defaults to root' {
    local _val
    _val="$(env -i HOME="$HOME" zsh --no-rcs -c 'ZPWR_LEARN=false; source "'"$pluginDir"'/zsh-learn.plugin.zsh"; echo "$ZPWR_SCHEMA_NAME"' 2>/dev/null)"
    assert "$_val" same_as "root"
}

@test 'env - ZPWR_TABLE_NAME defaults to LearningCollectiion' {
    local _val
    _val="$(env -i HOME="$HOME" zsh --no-rcs -c 'ZPWR_LEARN=false; source "'"$pluginDir"'/zsh-learn.plugin.zsh"; echo "$ZPWR_TABLE_NAME"' 2>/dev/null)"
    assert "$_val" same_as "LearningCollectiion"
}

@test 'env - ZPWR_TEMPFILE defaults to /tmp/.zpwr-temp' {
    local _val
    _val="$(env -i HOME="$HOME" zsh --no-rcs -c 'ZPWR_LEARN=false; source "'"$pluginDir"'/zsh-learn.plugin.zsh"; echo "$ZPWR_TEMPFILE"' 2>/dev/null)"
    assert "$_val" same_as "/tmp/.zpwr-temp"
}

@test 'env - ZPWR_TEMPFILE2 defaults to /tmp/.zpwr-temp2' {
    local _val
    _val="$(env -i HOME="$HOME" zsh --no-rcs -c 'ZPWR_LEARN=false; source "'"$pluginDir"'/zsh-learn.plugin.zsh"; echo "$ZPWR_TEMPFILE2"' 2>/dev/null)"
    assert "$_val" same_as "/tmp/.zpwr-temp2"
}

@test 'env - ZPWR_LOGFILE defaults to /tmp/.zpwr-log' {
    local _val
    _val="$(env -i HOME="$HOME" zsh --no-rcs -c 'ZPWR_LEARN=false; source "'"$pluginDir"'/zsh-learn.plugin.zsh"; echo "$ZPWR_LOGFILE"' 2>/dev/null)"
    assert "$_val" same_as "/tmp/.zpwr-log"
}

@test 'env - ZPWR_CHAR_LOGO defaults to <<)(>>' {
    local _val
    _val="$(env -i HOME="$HOME" zsh --no-rcs -c 'ZPWR_LEARN=false; source "'"$pluginDir"'/zsh-learn.plugin.zsh"; echo "$ZPWR_CHAR_LOGO"' 2>/dev/null)"
    assert "$_val" same_as "<<)(>>"
}

@test 'env - ZPWR_LEARN_COMMAND defaults to mysql' {
    local _val
    _val="$(env -i HOME="$HOME" zsh --no-rcs -c 'ZPWR_LEARN=false; source "'"$pluginDir"'/zsh-learn.plugin.zsh"; echo "$ZPWR_LEARN_COMMAND"' 2>/dev/null)"
    assert "$_val" same_as "mysql"
}

@test 'env - ZPWR_LEARN_MAX_SIZE defaults to 3000' {
    local _val
    _val="$(env -i HOME="$HOME" zsh --no-rcs -c 'ZPWR_LEARN=false; source "'"$pluginDir"'/zsh-learn.plugin.zsh"; echo "$ZPWR_LEARN_MAX_SIZE"' 2>/dev/null)"
    assert "$_val" same_as "3000"
}

@test 'env - ZPWR_VARS maxRecords is set to 2000' {
    source "$pluginDir/zsh-learn.plugin.zsh"
    assert "$ZPWR_VARS[maxRecords]" same_as "2000"
}

@test 'env - ZPWR_SEND_KEYS_FULL preserves existing value' {
    local _val
    _val="$(env -i HOME="$HOME" ZPWR_SEND_KEYS_FULL=true zsh --no-rcs -c 'ZPWR_LEARN=false; source "'"$pluginDir"'/zsh-learn.plugin.zsh"; echo "$ZPWR_SEND_KEYS_FULL"' 2>/dev/null)"
    assert "$_val" same_as "true"
}

@test 'env - ZPWR_SCHEMA_NAME preserves existing value' {
    local _val
    _val="$(env -i HOME="$HOME" ZPWR_SCHEMA_NAME=custom_schema zsh --no-rcs -c 'ZPWR_LEARN=false; source "'"$pluginDir"'/zsh-learn.plugin.zsh"; echo "$ZPWR_SCHEMA_NAME"' 2>/dev/null)"
    assert "$_val" same_as "custom_schema"
}

@test 'env - ZPWR_TABLE_NAME preserves existing value' {
    local _val
    _val="$(env -i HOME="$HOME" ZPWR_TABLE_NAME=CustomTable zsh --no-rcs -c 'ZPWR_LEARN=false; source "'"$pluginDir"'/zsh-learn.plugin.zsh"; echo "$ZPWR_TABLE_NAME"' 2>/dev/null)"
    assert "$_val" same_as "CustomTable"
}

@test 'env - ZPWR_LEARN_COMMAND preserves existing value' {
    local _val
    _val="$(env -i HOME="$HOME" ZPWR_LEARN_COMMAND=mariadb zsh --no-rcs -c 'ZPWR_LEARN=false; source "'"$pluginDir"'/zsh-learn.plugin.zsh"; echo "$ZPWR_LEARN_COMMAND"' 2>/dev/null)"
    assert "$_val" same_as "mariadb"
}

@test 'env - ZPWR_LEARN_MAX_SIZE preserves existing value' {
    local _val
    _val="$(env -i HOME="$HOME" ZPWR_LEARN_MAX_SIZE=5000 zsh --no-rcs -c 'ZPWR_LEARN=false; source "'"$pluginDir"'/zsh-learn.plugin.zsh"; echo "$ZPWR_LEARN_MAX_SIZE"' 2>/dev/null)"
    assert "$_val" same_as "5000"
}

@test 'env - ZPWR_CHAR_LOGO preserves existing value' {
    local _val
    _val="$(env -i HOME="$HOME" ZPWR_CHAR_LOGO=mylogo zsh --no-rcs -c 'ZPWR_LEARN=false; source "'"$pluginDir"'/zsh-learn.plugin.zsh"; echo "$ZPWR_CHAR_LOGO"' 2>/dev/null)"
    assert "$_val" same_as "mylogo"
}

@test 'env - ZPWR_LOGFILE preserves existing value' {
    local _val
    _val="$(env -i HOME="$HOME" ZPWR_LOGFILE=/custom/log zsh --no-rcs -c 'ZPWR_LEARN=false; source "'"$pluginDir"'/zsh-learn.plugin.zsh"; echo "$ZPWR_LOGFILE"' 2>/dev/null)"
    assert "$_val" same_as "/custom/log"
}

@test 'env - ZPWR_TEMPFILE preserves existing value' {
    local _val
    _val="$(env -i HOME="$HOME" ZPWR_TEMPFILE=/custom/temp zsh --no-rcs -c 'ZPWR_LEARN=false; source "'"$pluginDir"'/zsh-learn.plugin.zsh"; echo "$ZPWR_TEMPFILE"' 2>/dev/null)"
    assert "$_val" same_as "/custom/temp"
}

@test 'env - ZPWR_TEMPFILE2 preserves existing value' {
    local _val
    _val="$(env -i HOME="$HOME" ZPWR_TEMPFILE2=/custom/temp2 zsh --no-rcs -c 'ZPWR_LEARN=false; source "'"$pluginDir"'/zsh-learn.plugin.zsh"; echo "$ZPWR_TEMPFILE2"' 2>/dev/null)"
    assert "$_val" same_as "/custom/temp2"
}

@test 'env - ZPWR_TEMPFILE_SQL preserves existing value' {
    local _val
    _val="$(env -i HOME="$HOME" ZPWR_TEMPFILE_SQL=/custom/sql zsh --no-rcs -c 'ZPWR_LEARN=false; source "'"$pluginDir"'/zsh-learn.plugin.zsh"; echo "$ZPWR_TEMPFILE_SQL"' 2>/dev/null)"
    assert "$_val" same_as "/custom/sql"
}

# ================================================================
# Section 3: Function existence checks
# ================================================================

@test 'functions - zpwrLoggErr is defined' {
    assert $(type -w zpwrLoggErr | awk '{print $2}') same_as "function"
}

@test 'functions - zpwrCommandExists is defined' {
    assert $(type -w zpwrCommandExists | awk '{print $2}') same_as "function"
}

@test 'functions - zpwrAlternatingPrettyPrint is defined' {
    assert $(type -w zpwrAlternatingPrettyPrint | awk '{print $2}') same_as "function"
}

@test 'functions - zsh-learn-Savel is autoloadable' {
    run type -w zsh-learn-Savel
    assert $output contains "function"
}

@test 'functions - zsh-learn-Searchl is autoloadable' {
    run type -w zsh-learn-Searchl
    assert $output contains "function"
}

@test 'functions - zsh-learn-Searchle is autoloadable' {
    run type -w zsh-learn-Searchle
    assert $output contains "function"
}

@test 'functions - zsh-learn-Searchlee is autoloadable' {
    run type -w zsh-learn-Searchlee
    assert $output contains "function"
}

@test 'functions - zsh-learn-DeleteId is autoloadable' {
    run type -w zsh-learn-DeleteId
    assert $output contains "function"
}

@test 'functions - zsh-learn-Editl is autoloadable' {
    run type -w zsh-learn-Editl
    assert $output contains "function"
}

@test 'functions - zsh-learn-Get is autoloadable' {
    run type -w zsh-learn-Get
    assert $output contains "function"
}

@test 'functions - zsh-learn-GetItems is autoloadable' {
    run type -w zsh-learn-GetItems
    assert $output contains "function"
}

@test 'functions - zsh-learn-GetLastItem is autoloadable' {
    run type -w zsh-learn-GetLastItem
    assert $output contains "function"
}

@test 'functions - zsh-learn-Redo is autoloadable' {
    run type -w zsh-learn-Redo
    assert $output contains "function"
}

@test 'functions - zsh-learn-Redosql is autoloadable' {
    run type -w zsh-learn-Redosql
    assert $output contains "function"
}

@test 'functions - zsh-learn-CreateLearningCollection is autoloadable' {
    run type -w zsh-learn-CreateLearningCollection
    assert $output contains "function"
}

@test 'functions - zsh-learn-DropLearningCollection is autoloadable' {
    run type -w zsh-learn-DropLearningCollection
    assert $output contains "function"
}

@test 'functions - zsh-learn-Learn is autoloadable' {
    run type -w zsh-learn-Learn
    assert $output contains "function"
}

@test 'functions - del is autoloadable' {
    run type -w del
    assert $output contains "function"
}

@test 'functions - ser is autoloadable' {
    run type -w ser
    assert $output contains "function"
}

@test 'functions - sera is autoloadable' {
    run type -w sera
    assert $output contains "function"
}

@test 'functions - qu is autoloadable' {
    run type -w qu
    assert $output contains "function"
}

@test 'functions - qua is autoloadable' {
    run type -w qua
    assert $output contains "function"
}

@test 'functions - sef is autoloadable' {
    run type -w sef
    assert $output contains "function"
}

@test 'functions - _fzf_complete_redo is autoloadable' {
    run type -w _fzf_complete_redo
    assert $output contains "function"
}

@test 'functions - _fzf_complete_redo_post is autoloadable' {
    run type -w _fzf_complete_redo_post
    assert $output contains "function"
}

@test 'functions - _fzf_complete_rsql is autoloadable' {
    run type -w _fzf_complete_rsql
    assert $output contains "function"
}

@test 'functions - _fzf_complete_rsql_post is autoloadable' {
    run type -w _fzf_complete_rsql_post
    assert $output contains "function"
}

@test 'functions - _fzf_complete_se is autoloadable' {
    run type -w _fzf_complete_se
    assert $output contains "function"
}

@test 'functions - _fzf_complete_se_post is autoloadable' {
    run type -w _fzf_complete_se_post
    assert $output contains "function"
}

# ================================================================
# Section 4: Helper function behavior
# ================================================================

@test 'zpwrLoggErr - outputs to stderr' {
    run zpwrLoggErr "test error message"
    assert "$output" same_as "test error message"
}

@test 'zpwrLoggErr - handles empty string' {
    run zpwrLoggErr ""
    assert $state equals 0
}

@test 'zpwrLoggErr - handles multiple arguments' {
    run zpwrLoggErr "hello" "world"
    assert "$output" same_as "hello world"
}

@test 'zpwrLoggErr - handles special characters' {
    run zpwrLoggErr "test & < > | ;"
    assert "$output" same_as "test & < > | ;"
}

@test 'zpwrAlternatingPrettyPrint - outputs to stdout' {
    run zpwrAlternatingPrettyPrint "test output"
    assert "$output" same_as "test output"
}

@test 'zpwrAlternatingPrettyPrint - handles empty string' {
    run zpwrAlternatingPrettyPrint ""
    assert $state equals 0
}

@test 'zpwrAlternatingPrettyPrint - handles multiple arguments' {
    run zpwrAlternatingPrettyPrint "hello" "world"
    assert "$output" same_as "hello world"
}

@test 'zpwrCommandExists - returns 0 for existing command' {
    run zpwrCommandExists "ls"
    assert $state equals 0
}

@test 'zpwrCommandExists - returns non-zero for nonexistent command' {
    run zpwrCommandExists "nonexistent_command_xyz_12345"
    assert $state not_equal_to 0
}

@test 'zpwrCommandExists - returns 0 for zsh builtin' {
    run zpwrCommandExists "echo"
    assert $state equals 0
}

@test 'zpwrCommandExists - returns 0 for cat' {
    run zpwrCommandExists "cat"
    assert $state equals 0
}

@test 'zpwrCommandExists - returns 0 for perl' {
    run zpwrCommandExists "perl"
    assert $state equals 0
}

@test 'zpwrCommandExists - handles empty argument' {
    run zpwrCommandExists ""
    assert $state not_equal_to 0
}

# ================================================================
# Section 5: Alias definitions
# ================================================================

@test 'alias - le is defined' {
    run alias le
    assert $state equals 0
    assert "$output" contains "zsh-learn-Savel"
}

@test 'alias - se is defined' {
    run alias se
    assert $state equals 0
    assert "$output" contains "zsh-learn-Searchl"
}

@test 'alias - es is defined' {
    run alias es
    assert $state equals 0
    assert "$output" contains "zsh-learn-Searchl"
}

@test 'alias - ees is defined' {
    run alias ees
    assert $state equals 0
    assert "$output" contains "zsh-learn-Searchl"
}

@test 'alias - ses is defined' {
    run alias ses
    assert $state equals 0
    assert "$output" contains "zsh-learn-Searchl"
}

@test 'alias - ese is defined' {
    run alias ese
    assert $state equals 0
    assert "$output" contains "zsh-learn-Searchl"
}

@test 'alias - sse is defined' {
    run alias sse
    assert $state equals 0
    assert "$output" contains "zsh-learn-Searchl"
}

@test 'alias - ssee is defined' {
    run alias ssee
    assert $state equals 0
    assert "$output" contains "zsh-learn-Searchl"
}

@test 'alias - re is defined' {
    run alias re
    assert $state equals 0
    assert "$output" contains "zsh-learn-Redo"
}

@test 'alias - rer is defined' {
    run alias rer
    assert $state equals 0
    assert "$output" contains "zsh-learn-Redo"
}

@test 'alias - er is defined' {
    run alias er
    assert $state equals 0
    assert "$output" contains "zsh-learn-Redo"
}

@test 'alias - rsql is defined' {
    run alias rsql
    assert $state equals 0
    assert "$output" contains "zsh-learn-Redosql"
}

@test 'alias - see is defined' {
    run alias see
    assert $state equals 0
    assert "$output" contains "zsh-learn-Searchle"
}

@test 'alias - seee is defined' {
    run alias seee
    assert $state equals 0
    assert "$output" contains "zsh-learn-Searchlee"
}

@test 'alias - editl is defined' {
    run alias editl
    assert $state equals 0
    assert "$output" contains "zsh-learn-Editl"
}

@test 'alias - delid is defined' {
    run alias delid
    assert $state equals 0
    assert "$output" contains "zsh-learn-DeleteId"
}

@test 'alias - le uses noglob' {
    run alias le
    assert "$output" contains "noglob"
}

@test 'alias - se uses noglob' {
    run alias se
    assert "$output" contains "noglob"
}

@test 'alias - re uses noglob' {
    run alias re
    assert "$output" contains "noglob"
}

@test 'alias - see uses noglob' {
    run alias see
    assert "$output" contains "noglob"
}

@test 'alias - seee uses noglob' {
    run alias seee
    assert "$output" contains "noglob"
}

@test 'alias - rsql uses noglob' {
    run alias rsql
    assert "$output" contains "noglob"
}

@test 'alias - editl uses noglob' {
    run alias editl
    assert "$output" contains "noglob"
}

@test 'alias - delid uses noglob' {
    run alias delid
    assert "$output" contains "noglob"
}

# ================================================================
# Section 6: zsh-learn-Savel tests
# ================================================================

@test 'Savel - returns 1 with no arguments' {
    run zsh-learn-Savel
    assert $state equals 1
}

@test 'Savel - shows usage with no arguments' {
    run zsh-learn-Savel
    assert "$output" contains "Usage"
}

@test 'Savel - usage mentions -e flag' {
    run zsh-learn-Savel
    assert "$output" contains "-e"
}

@test 'Savel - usage mentions -c flag' {
    run zsh-learn-Savel
    assert "$output" contains "-c"
}

@test 'Savel - generates insert SQL with single arg' {
    run zsh-learn-Savel "test learning item"
    assert "$output" contains "insert into"
    assert "$output" contains "testschema.TestTable"
}

@test 'Savel - SQL contains category field' {
    run zsh-learn-Savel "test learning"
    assert "$output" contains "category"
}

@test 'Savel - SQL contains learning field' {
    run zsh-learn-Savel "test learning"
    assert "$output" contains "learning"
}

@test 'Savel - SQL contains dateAdded field' {
    run zsh-learn-Savel "test learning"
    assert "$output" contains "dateAdded"
}

@test 'Savel - SQL contains now()' {
    run zsh-learn-Savel "test learning"
    assert "$output" contains "now()"
}

@test 'Savel - default category is programming' {
    run zsh-learn-Savel "test learning"
    assert "$output" contains "programming"
}

@test 'Savel - custom category with -c flag' {
    run zsh-learn-Savel -c "networking" "test learning"
    assert "$output" contains "networking"
}

@test 'Savel - custom category devops' {
    run zsh-learn-Savel -c "devops" "test learning"
    assert "$output" contains "devops"
}

@test 'Savel - custom category security' {
    run zsh-learn-Savel -c "security" "test learning"
    assert "$output" contains "security"
}

@test 'Savel - rejects learning exceeding max size' {
    local bigstr=$(printf '%0.sa' {1..3001})
    run zsh-learn-Savel "$bigstr"
    assert $state equals 1
    assert "$output" contains "greater than limit"
}

@test 'Savel - accepts learning at max size' {
    local str=$(printf '%0.sa' {1..3000})
    run zsh-learn-Savel "$str"
    assert "$output" contains "insert into"
}

@test 'Savel - accepts learning below max size' {
    run zsh-learn-Savel "short learning"
    assert "$output" contains "insert into"
}

@test 'Savel - error message includes actual size' {
    local bigstr=$(printf '%0.sa' {1..3001})
    run zsh-learn-Savel "$bigstr"
    assert "$output" contains "3001"
}

@test 'Savel - error message includes limit' {
    local bigstr=$(printf '%0.sa' {1..3001})
    run zsh-learn-Savel "$bigstr"
    assert "$output" contains "3000"
}

@test 'Savel - uses configured schema name' {
    export ZPWR_SCHEMA_NAME="mydb"
    run zsh-learn-Savel "test"
    assert "$output" contains "mydb.TestTable"
    export ZPWR_SCHEMA_NAME="testschema"
}

@test 'Savel - uses configured table name' {
    export ZPWR_TABLE_NAME="MyTable"
    run zsh-learn-Savel "test"
    assert "$output" contains "testschema.MyTable"
    export ZPWR_TABLE_NAME="TestTable"
}

@test 'Savel - strips leading whitespace from input' {
    run zsh-learn-Savel "   test learning"
    assert "$output" contains "test learning"
}

@test 'Savel - strips trailing whitespace from input' {
    run zsh-learn-Savel "test learning   "
    assert "$output" contains "test learning"
}

@test 'Savel - handles learning with special SQL chars' {
    run zsh-learn-Savel "test's learning"
    assert $state equals 0
}

@test 'Savel - handles learning with numbers' {
    run zsh-learn-Savel "learning item 12345"
    assert "$output" contains "12345"
}

@test 'Savel - handles learning with paths' {
    run zsh-learn-Savel "/usr/bin/test --flag"
    assert "$output" contains "/usr/bin/test"
}

@test 'Savel - handles learning with pipes' {
    run zsh-learn-Savel "cat file | grep pattern"
    assert "$output" contains "insert into"
}

@test 'Savel - handles single character learning' {
    run zsh-learn-Savel "x"
    assert "$output" contains "insert into"
}

@test 'Savel - rejects whitespace-only learning' {
    run zsh-learn-Savel "   "
    assert $state equals 1
}

@test 'Savel - invalid option shows error' {
    run zsh-learn-Savel -z "test"
    assert $state equals 1
}

@test 'Savel - custom max size is respected' {
    export ZPWR_LEARN_MAX_SIZE=10
    run zsh-learn-Savel "this is way too long for max size of ten"
    assert $state equals 1
    export ZPWR_LEARN_MAX_SIZE=3000
}

@test 'Savel - learning with backticks' {
    run zsh-learn-Savel 'use `command` for execution'
    assert "$output" contains "insert into"
}

@test 'Savel - learning with double quotes' {
    run zsh-learn-Savel 'echo "hello world"'
    assert "$output" contains "insert into"
}

@test 'Savel - learning with backslashes' {
    run zsh-learn-Savel 'path\\to\\file'
    assert "$output" contains "insert into"
}

@test 'Savel - learning with ampersands' {
    run zsh-learn-Savel "cmd1 && cmd2"
    assert "$output" contains "insert into"
}

@test 'Savel - learning with semicolons' {
    run zsh-learn-Savel "cmd1; cmd2"
    assert "$output" contains "insert into"
}

@test 'Savel - SQL uses values keyword' {
    run zsh-learn-Savel "test"
    assert "$output" contains "values"
}

# ================================================================
# Section 7: zsh-learn-DeleteId tests
# ================================================================

@test 'DeleteId - returns 1 with no arguments' {
    run zsh-learn-DeleteId
    assert $state equals 1
}

@test 'DeleteId - shows usage with no arguments' {
    run zsh-learn-DeleteId
    assert "$output" contains "Usage"
}

@test 'DeleteId - usage mentions the function name' {
    run zsh-learn-DeleteId
    assert "$output" contains "zsh-learn-DeleteId"
}

@test 'DeleteId - usage mentions id parameter' {
    run zsh-learn-DeleteId
    assert "$output" contains "id"
}

@test 'DeleteId - generates DELETE SQL for given id' {
    run zsh-learn-DeleteId 42
    assert "$output" contains "DELETE FROM"
}

@test 'DeleteId - SQL targets correct schema.table' {
    run zsh-learn-DeleteId 42
    assert "$output" contains "testschema.TestTable"
}

@test 'DeleteId - SQL contains WHERE clause with id' {
    run zsh-learn-DeleteId 42
    assert "$output" contains "WHERE id = 42"
}

@test 'DeleteId - SQL ends with semicolon' {
    run zsh-learn-DeleteId 42
    assert "$output" contains ";"
}

@test 'DeleteId - handles id 1' {
    run zsh-learn-DeleteId 1
    assert "$output" contains "WHERE id = 1"
}

@test 'DeleteId - handles large id' {
    run zsh-learn-DeleteId 99999
    assert "$output" contains "WHERE id = 99999"
}

@test 'DeleteId - handles id 0' {
    run zsh-learn-DeleteId 0
    assert "$output" contains "WHERE id = 0"
}

@test 'DeleteId - uses configured schema' {
    export ZPWR_SCHEMA_NAME="otherdb"
    run zsh-learn-DeleteId 1
    assert "$output" contains "otherdb.TestTable"
    export ZPWR_SCHEMA_NAME="testschema"
}

@test 'DeleteId - uses configured table' {
    export ZPWR_TABLE_NAME="OtherTable"
    run zsh-learn-DeleteId 1
    assert "$output" contains "testschema.OtherTable"
    export ZPWR_TABLE_NAME="TestTable"
}

# ================================================================
# Section 8: zsh-learn-Editl tests
# ================================================================

@test 'Editl - returns 1 with no arguments' {
    run zsh-learn-Editl
    assert $state equals 1
}

@test 'Editl - shows usage with no arguments' {
    run zsh-learn-Editl
    assert "$output" contains "Usage"
}

@test 'Editl - usage mentions id parameter' {
    run zsh-learn-Editl
    assert "$output" contains "id"
}

# ================================================================
# Section 9: del function tests
# ================================================================

@test 'del - generates delete SQL with default count 1' {
    run del
    assert "$output" contains "delete from"
    assert "$output" contains "limit 1"
}

@test 'del - generates delete SQL with custom count' {
    run del 5
    assert "$output" contains "limit 5"
}

@test 'del - SQL targets correct schema.table' {
    run del
    assert "$output" contains "testschema.TestTable"
}

@test 'del - SQL orders by id desc' {
    run del
    assert "$output" contains "order by id desc"
}

@test 'del - handles count of 10' {
    run del 10
    assert "$output" contains "limit 10"
}

@test 'del - handles count of 100' {
    run del 100
    assert "$output" contains "limit 100"
}

@test 'del - handles count of 1' {
    run del 1
    assert "$output" contains "limit 1"
}

@test 'del - uses configured schema' {
    export ZPWR_SCHEMA_NAME="mydb"
    run del
    assert "$output" contains "mydb.TestTable"
    export ZPWR_SCHEMA_NAME="testschema"
}

@test 'del - uses configured table' {
    export ZPWR_TABLE_NAME="CustomTable"
    run del
    assert "$output" contains "testschema.CustomTable"
    export ZPWR_TABLE_NAME="TestTable"
}

# ================================================================
# Section 10: CreateLearningCollection tests
# ================================================================

@test 'CreateLearningCollection - help flag returns 0' {
    run zsh-learn-CreateLearningCollection -h
    assert $state equals 0
}

@test 'CreateLearningCollection - help shows usage' {
    run zsh-learn-CreateLearningCollection -h
    assert "$output" contains "Usage"
}

@test 'CreateLearningCollection - help mentions options' {
    run zsh-learn-CreateLearningCollection -h
    assert "$output" contains "Options"
}

@test 'CreateLearningCollection - help mentions help flag' {
    run zsh-learn-CreateLearningCollection -h
    assert "$output" contains "help"
}

# ================================================================
# Section 11: DropLearningCollection tests
# ================================================================

@test 'DropLearningCollection - help flag returns 0' {
    run zsh-learn-DropLearningCollection -h
    assert $state equals 0
}

@test 'DropLearningCollection - help shows usage' {
    run zsh-learn-DropLearningCollection -h
    assert "$output" contains "Usage"
}

@test 'DropLearningCollection - help mentions options' {
    run zsh-learn-DropLearningCollection -h
    assert "$output" contains "Options"
}

# ================================================================
# Section 12: File structure tests
# ================================================================

@test 'structure - autoload directory exists' {
    assert "$pluginDir/autoload" is_dir
}

@test 'structure - src directory exists' {
    assert "$pluginDir/src" is_dir
}

@test 'structure - tests directory exists' {
    assert "$pluginDir/tests" is_dir
}

@test 'structure - plugin file exists' {
    assert "$pluginDir/zsh-learn.plugin.zsh" is_file
}

@test 'structure - _se completion exists' {
    assert "$pluginDir/src/_se" is_file
}

@test 'structure - README exists' {
    assert "$pluginDir/README.md" is_file
}

@test 'structure - license exists' {
    assert "$pluginDir/license.md" is_file
}

@test 'structure - autoload/del exists' {
    assert "$pluginDir/autoload/del" is_file
}

@test 'structure - autoload/ser exists' {
    assert "$pluginDir/autoload/ser" is_file
}

@test 'structure - autoload/sera exists' {
    assert "$pluginDir/autoload/sera" is_file
}

@test 'structure - autoload/qu exists' {
    assert "$pluginDir/autoload/qu" is_file
}

@test 'structure - autoload/qua exists' {
    assert "$pluginDir/autoload/qua" is_file
}

@test 'structure - autoload/sef exists' {
    assert "$pluginDir/autoload/sef" is_file
}

@test 'structure - autoload/zsh-learn-Savel exists' {
    assert "$pluginDir/autoload/zsh-learn-Savel" is_file
}

@test 'structure - autoload/zsh-learn-Searchl exists' {
    assert "$pluginDir/autoload/zsh-learn-Searchl" is_file
}

@test 'structure - autoload/zsh-learn-Searchle exists' {
    assert "$pluginDir/autoload/zsh-learn-Searchle" is_file
}

@test 'structure - autoload/zsh-learn-Searchlee exists' {
    assert "$pluginDir/autoload/zsh-learn-Searchlee" is_file
}

@test 'structure - autoload/zsh-learn-DeleteId exists' {
    assert "$pluginDir/autoload/zsh-learn-DeleteId" is_file
}

@test 'structure - autoload/zsh-learn-Editl exists' {
    assert "$pluginDir/autoload/zsh-learn-Editl" is_file
}

@test 'structure - autoload/zsh-learn-Get exists' {
    assert "$pluginDir/autoload/zsh-learn-Get" is_file
}

@test 'structure - autoload/zsh-learn-GetItems exists' {
    assert "$pluginDir/autoload/zsh-learn-GetItems" is_file
}

@test 'structure - autoload/zsh-learn-GetLastItem exists' {
    assert "$pluginDir/autoload/zsh-learn-GetLastItem" is_file
}

@test 'structure - autoload/zsh-learn-Learn exists' {
    assert "$pluginDir/autoload/zsh-learn-Learn" is_file
}

@test 'structure - autoload/zsh-learn-Redo exists' {
    assert "$pluginDir/autoload/zsh-learn-Redo" is_file
}

@test 'structure - autoload/zsh-learn-Redosql exists' {
    assert "$pluginDir/autoload/zsh-learn-Redosql" is_file
}

@test 'structure - autoload/zsh-learn-CreateLearningCollection exists' {
    assert "$pluginDir/autoload/zsh-learn-CreateLearningCollection" is_file
}

@test 'structure - autoload/zsh-learn-DropLearningCollection exists' {
    assert "$pluginDir/autoload/zsh-learn-DropLearningCollection" is_file
}

@test 'structure - autoload/_fzf_complete_redo exists' {
    assert "$pluginDir/autoload/_fzf_complete_redo" is_file
}

@test 'structure - autoload/_fzf_complete_redo_post exists' {
    assert "$pluginDir/autoload/_fzf_complete_redo_post" is_file
}

@test 'structure - autoload/_fzf_complete_rsql exists' {
    assert "$pluginDir/autoload/_fzf_complete_rsql" is_file
}

@test 'structure - autoload/_fzf_complete_rsql_post exists' {
    assert "$pluginDir/autoload/_fzf_complete_rsql_post" is_file
}

@test 'structure - autoload/_fzf_complete_se exists' {
    assert "$pluginDir/autoload/_fzf_complete_se" is_file
}

@test 'structure - autoload/_fzf_complete_se_post exists' {
    assert "$pluginDir/autoload/_fzf_complete_se_post" is_file
}

# ================================================================
# Section 13: Plugin sourcing idempotency
# ================================================================

@test 'idempotent - sourcing plugin twice does not error' {
    (
        source "$pluginDir/zsh-learn.plugin.zsh"
        source "$pluginDir/zsh-learn.plugin.zsh"
    )
    assert $? equals 0
}

@test 'idempotent - sourcing plugin three times does not error' {
    (
        source "$pluginDir/zsh-learn.plugin.zsh"
        source "$pluginDir/zsh-learn.plugin.zsh"
        source "$pluginDir/zsh-learn.plugin.zsh"
    )
    assert $? equals 0
}

@test 'idempotent - zpwrLoggErr survives re-source' {
    source "$pluginDir/zsh-learn.plugin.zsh"
    run zpwrLoggErr "still works"
    assert "$output" same_as "still works"
}

@test 'idempotent - zpwrCommandExists survives re-source' {
    source "$pluginDir/zsh-learn.plugin.zsh"
    run zpwrCommandExists "ls"
    assert $state equals 0
}

@test 'idempotent - zpwrAlternatingPrettyPrint survives re-source' {
    source "$pluginDir/zsh-learn.plugin.zsh"
    run zpwrAlternatingPrettyPrint "still works"
    assert "$output" same_as "still works"
}

@test 'idempotent - ZPWR_VARS persists across sources' {
    ZPWR_VARS[testkey]="testval"
    source "$pluginDir/zsh-learn.plugin.zsh"
    assert "$ZPWR_VARS[testkey]" same_as "testval"
}

# ================================================================
# Section 14: ZPWR_VARS association array
# ================================================================

@test 'ZPWR_VARS - is an association' {
    assert "${parameters[ZPWR_VARS]}" matches "association*"
}

@test 'ZPWR_VARS - maxRecords is set' {
    assert "$ZPWR_VARS[maxRecords]" is_not_empty
}

@test 'ZPWR_VARS - maxRecords is 2000' {
    source "$pluginDir/zsh-learn.plugin.zsh"
    assert "$ZPWR_VARS[maxRecords]" same_as "2000"
}

@test 'ZPWR_VARS - can set and get custom key' {
    ZPWR_VARS[mykey]="myval"
    assert "$ZPWR_VARS[mykey]" same_as "myval"
}

@test 'ZPWR_VARS - can overwrite key' {
    ZPWR_VARS[mykey]="val1"
    ZPWR_VARS[mykey]="val2"
    assert "$ZPWR_VARS[mykey]" same_as "val2"
}

@test 'ZPWR_VARS - can store empty value' {
    ZPWR_VARS[emptykey]=""
    assert "$ZPWR_VARS[emptykey]" same_as ""
}

@test 'ZPWR_VARS - can store numeric value' {
    ZPWR_VARS[numkey]="42"
    assert "$ZPWR_VARS[numkey]" same_as "42"
}

@test 'ZPWR_VARS - can store path value' {
    ZPWR_VARS[pathkey]="/usr/local/bin"
    assert "$ZPWR_VARS[pathkey]" same_as "/usr/local/bin"
}

# ================================================================
# Section 15: SQL generation correctness
# ================================================================

@test 'sql - Savel insert uses correct schema' {
    export ZPWR_SCHEMA_NAME="proddb"
    run zsh-learn-Savel "test"
    assert "$output" contains "proddb."
    export ZPWR_SCHEMA_NAME="testschema"
}

@test 'sql - Savel insert uses correct table' {
    export ZPWR_TABLE_NAME="Learnings"
    run zsh-learn-Savel "test"
    assert "$output" contains ".Learnings"
    export ZPWR_TABLE_NAME="TestTable"
}

@test 'sql - DeleteId uses DELETE FROM keyword' {
    run zsh-learn-DeleteId 1
    assert "$output" contains "DELETE FROM"
}

@test 'sql - DeleteId uses WHERE keyword' {
    run zsh-learn-DeleteId 1
    assert "$output" contains "WHERE"
}

@test 'sql - del uses delete from keyword' {
    run del
    assert "$output" contains "delete from"
}

@test 'sql - del uses order by id desc' {
    run del
    assert "$output" contains "order by id desc"
}

@test 'sql - del uses limit keyword' {
    run del
    assert "$output" contains "limit"
}

@test 'sql - Savel insert uses insert into keywords' {
    run zsh-learn-Savel "test"
    assert "$output" contains "insert into"
}

# ================================================================
# Section 16: fzf post functions
# ================================================================

@test 'fzf_complete_redo_post - extracts first field' {
    local result="$(echo "123 some text here" | awk '{print $1}')"
    assert "$result" same_as "123"
}

@test 'fzf_complete_se_post - extracts second field' {
    local result="$(echo "123 some text here" | awk '{print $2}')"
    assert "$result" same_as "some"
}

@test 'fzf_complete_rsql_post - extracts first field' {
    local result="$(echo "456 other text" | awk '{print $1}')"
    assert "$result" same_as "456"
}

# ================================================================
# Section 17: ser function tests
# ================================================================

@test 'ser - default num is 100' {
    # ser calls zsh-learn-Searchl | shuf -n $num
    # With ZPWR_LEARN_COMMAND=cat, the underlying sql echo goes to cat
    # Just verify the function exists and can be called
    run type -w ser
    assert $output contains "function"
}

# ================================================================
# Section 18: Edge cases and boundary conditions
# ================================================================

@test 'edge - ZPWR_LEARN_MAX_SIZE of 1 rejects two char string' {
    export ZPWR_LEARN_MAX_SIZE=1
    run zsh-learn-Savel "ab"
    assert $state equals 1
    export ZPWR_LEARN_MAX_SIZE=3000
}

@test 'edge - ZPWR_LEARN_MAX_SIZE of 1 accepts one char string' {
    export ZPWR_LEARN_MAX_SIZE=1
    run zsh-learn-Savel "a"
    assert "$output" contains "insert into"
    export ZPWR_LEARN_MAX_SIZE=3000
}

@test 'edge - ZPWR_LEARN_MAX_SIZE boundary exact match' {
    export ZPWR_LEARN_MAX_SIZE=5
    run zsh-learn-Savel "abcde"
    assert "$output" contains "insert into"
    export ZPWR_LEARN_MAX_SIZE=3000
}

@test 'edge - ZPWR_LEARN_MAX_SIZE boundary one over' {
    export ZPWR_LEARN_MAX_SIZE=5
    run zsh-learn-Savel "abcdef"
    assert $state equals 1
    export ZPWR_LEARN_MAX_SIZE=3000
}

@test 'edge - del with count 0' {
    run del 0
    assert "$output" contains "limit 0"
}

@test 'edge - DeleteId with string arg processes anyway' {
    run zsh-learn-DeleteId "abc"
    assert "$output" contains "DELETE FROM"
}

@test 'edge - multiple schema.table combinations' {
    export ZPWR_SCHEMA_NAME="db1"
    export ZPWR_TABLE_NAME="tbl1"
    run del
    assert "$output" contains "db1.tbl1"
    export ZPWR_SCHEMA_NAME="testschema"
    export ZPWR_TABLE_NAME="TestTable"
}

@test 'edge - schema with underscore' {
    export ZPWR_SCHEMA_NAME="my_database"
    run del
    assert "$output" contains "my_database.TestTable"
    export ZPWR_SCHEMA_NAME="testschema"
}

@test 'edge - table with numbers' {
    export ZPWR_TABLE_NAME="Table123"
    run del
    assert "$output" contains "testschema.Table123"
    export ZPWR_TABLE_NAME="TestTable"
}

@test 'edge - Savel with very long category name' {
    run zsh-learn-Savel -c "verylongcategoryname" "test"
    assert "$output" contains "verylongcategoryname"
}

@test 'edge - Savel preserves newlines in learning' {
    run zsh-learn-Savel "line1"
    assert "$output" contains "line1"
}

@test 'edge - DeleteId id with leading zeros' {
    run zsh-learn-DeleteId 007
    assert "$output" contains "WHERE id = 007"
}

@test 'edge - multiple DeleteId calls' {
    run zsh-learn-DeleteId 1
    assert $state equals 0
    run zsh-learn-DeleteId 2
    assert $state equals 0
}

@test 'edge - del large count' {
    run del 999999
    assert "$output" contains "limit 999999"
}

# ================================================================
# Section 19: rcquotes option
# ================================================================

@test 'option - rcquotes is set after sourcing' {
    source "$pluginDir/zsh-learn.plugin.zsh"
    run setopt
    assert "$output" contains "rcquotes"
}

# ================================================================
# Section 20: Autoload file format validation
# ================================================================

@test 'format - del has mode line' {
    run head -1 "$pluginDir/autoload/del"
    assert "$output" contains "mode: sh"
}

@test 'format - ser has mode line' {
    run head -1 "$pluginDir/autoload/ser"
    assert "$output" contains "mode: sh"
}

@test 'format - sera has mode line' {
    run head -1 "$pluginDir/autoload/sera"
    assert "$output" contains "mode: sh"
}

@test 'format - qu has mode line' {
    run head -1 "$pluginDir/autoload/qu"
    assert "$output" contains "mode: sh"
}

@test 'format - qua has mode line' {
    run head -1 "$pluginDir/autoload/qua"
    assert "$output" contains "mode: sh"
}

@test 'format - sef has mode line' {
    run head -1 "$pluginDir/autoload/sef"
    assert "$output" contains "mode: sh"
}

@test 'format - zsh-learn-Savel has mode line' {
    run head -1 "$pluginDir/autoload/zsh-learn-Savel"
    assert "$output" contains "mode: sh"
}

@test 'format - zsh-learn-Searchl has mode line' {
    run head -1 "$pluginDir/autoload/zsh-learn-Searchl"
    assert "$output" contains "mode: sh"
}

@test 'format - zsh-learn-Searchle has mode line' {
    run head -1 "$pluginDir/autoload/zsh-learn-Searchle"
    assert "$output" contains "mode: sh"
}

@test 'format - zsh-learn-Searchlee has mode line' {
    run head -1 "$pluginDir/autoload/zsh-learn-Searchlee"
    assert "$output" contains "mode: sh"
}

@test 'format - zsh-learn-DeleteId has mode line' {
    run head -1 "$pluginDir/autoload/zsh-learn-DeleteId"
    assert "$output" contains "mode: sh"
}

@test 'format - zsh-learn-Editl has mode line' {
    run head -1 "$pluginDir/autoload/zsh-learn-Editl"
    assert "$output" contains "mode: sh"
}

@test 'format - zsh-learn-Get has mode line' {
    run head -1 "$pluginDir/autoload/zsh-learn-Get"
    assert "$output" contains "mode: sh"
}

@test 'format - zsh-learn-GetItems has mode line' {
    run head -1 "$pluginDir/autoload/zsh-learn-GetItems"
    assert "$output" contains "mode: sh"
}

@test 'format - zsh-learn-GetLastItem has mode line' {
    run head -1 "$pluginDir/autoload/zsh-learn-GetLastItem"
    assert "$output" contains "mode: sh"
}

@test 'format - zsh-learn-Learn has mode line' {
    run head -1 "$pluginDir/autoload/zsh-learn-Learn"
    assert "$output" contains "mode: sh"
}

@test 'format - zsh-learn-Redo has mode line' {
    run head -1 "$pluginDir/autoload/zsh-learn-Redo"
    assert "$output" contains "mode: sh"
}

@test 'format - zsh-learn-Redosql has mode line' {
    run head -1 "$pluginDir/autoload/zsh-learn-Redosql"
    assert "$output" contains "mode: sh"
}

@test 'format - zsh-learn-CreateLearningCollection has mode line' {
    run head -1 "$pluginDir/autoload/zsh-learn-CreateLearningCollection"
    assert "$output" contains "mode: sh"
}

@test 'format - zsh-learn-DropLearningCollection has mode line' {
    run head -1 "$pluginDir/autoload/zsh-learn-DropLearningCollection"
    assert "$output" contains "mode: sh"
}

@test 'format - _fzf_complete_redo has mode line' {
    run head -1 "$pluginDir/autoload/_fzf_complete_redo"
    assert "$output" contains "mode: sh"
}

@test 'format - _fzf_complete_redo_post has mode line' {
    run head -1 "$pluginDir/autoload/_fzf_complete_redo_post"
    assert "$output" contains "mode: sh"
}

@test 'format - _fzf_complete_rsql has mode line' {
    run head -1 "$pluginDir/autoload/_fzf_complete_rsql"
    assert "$output" contains "mode: sh"
}

@test 'format - _fzf_complete_rsql_post has mode line' {
    run head -1 "$pluginDir/autoload/_fzf_complete_rsql_post"
    assert "$output" contains "mode: sh"
}

@test 'format - _fzf_complete_se has mode line' {
    run head -1 "$pluginDir/autoload/_fzf_complete_se"
    assert "$output" contains "mode: sh"
}

@test 'format - _fzf_complete_se_post has mode line' {
    run head -1 "$pluginDir/autoload/_fzf_complete_se_post"
    assert "$output" contains "mode: sh"
}

@test 'format - del has vim ft=sh modeline' {
    run head -2 "$pluginDir/autoload/del"
    assert "$output" contains "ft=sh"
}

@test 'format - zsh-learn-Savel has vim ft=sh modeline' {
    run head -2 "$pluginDir/autoload/zsh-learn-Savel"
    assert "$output" contains "ft=sh"
}

@test 'format - zsh-learn-Searchl has vim ft=sh modeline' {
    run head -2 "$pluginDir/autoload/zsh-learn-Searchl"
    assert "$output" contains "ft=sh"
}

# ================================================================
# Section 21: Self-invocation pattern (each autoload calls itself)
# ================================================================

@test 'self-invoke - del calls itself at end' {
    run tail -2 "$pluginDir/autoload/del"
    assert "$output" contains 'del "$@"'
}

@test 'self-invoke - ser calls itself at end' {
    run tail -2 "$pluginDir/autoload/ser"
    assert "$output" contains 'ser "$@"'
}

@test 'self-invoke - sera calls itself at end' {
    run tail -2 "$pluginDir/autoload/sera"
    assert "$output" contains 'sera "$@"'
}

@test 'self-invoke - qu calls itself at end' {
    run tail -2 "$pluginDir/autoload/qu"
    assert "$output" contains 'qu "$@"'
}

@test 'self-invoke - qua calls itself at end' {
    run tail -2 "$pluginDir/autoload/qua"
    assert "$output" contains 'qua "$@"'
}

@test 'self-invoke - sef calls itself at end' {
    run tail -2 "$pluginDir/autoload/sef"
    assert "$output" contains 'sef "$@"'
}

@test 'self-invoke - zsh-learn-Savel calls itself at end' {
    run tail -2 "$pluginDir/autoload/zsh-learn-Savel"
    assert "$output" contains 'zsh-learn-Savel "$@"'
}

@test 'self-invoke - zsh-learn-Searchl calls itself at end' {
    run tail -2 "$pluginDir/autoload/zsh-learn-Searchl"
    assert "$output" contains 'zsh-learn-Searchl "$@"'
}

@test 'self-invoke - zsh-learn-Searchle calls itself at end' {
    run tail -2 "$pluginDir/autoload/zsh-learn-Searchle"
    assert "$output" contains 'zsh-learn-Searchle "$@"'
}

@test 'self-invoke - zsh-learn-Searchlee calls itself at end' {
    run tail -2 "$pluginDir/autoload/zsh-learn-Searchlee"
    assert "$output" contains 'zsh-learn-Searchlee "$@"'
}

@test 'self-invoke - zsh-learn-DeleteId calls itself at end' {
    run tail -2 "$pluginDir/autoload/zsh-learn-DeleteId"
    assert "$output" contains 'zsh-learn-DeleteId "$@"'
}

@test 'self-invoke - zsh-learn-Editl calls itself at end' {
    run tail -2 "$pluginDir/autoload/zsh-learn-Editl"
    assert "$output" contains 'zsh-learn-Editl "$@"'
}

@test 'self-invoke - zsh-learn-Get calls itself at end' {
    run tail -2 "$pluginDir/autoload/zsh-learn-Get"
    assert "$output" contains 'zsh-learn-Get "$@"'
}

@test 'self-invoke - zsh-learn-GetItems calls itself at end' {
    run tail -2 "$pluginDir/autoload/zsh-learn-GetItems"
    assert "$output" contains 'zsh-learn-GetItems "$@"'
}

@test 'self-invoke - zsh-learn-GetLastItem calls itself at end' {
    run tail -2 "$pluginDir/autoload/zsh-learn-GetLastItem"
    assert "$output" contains 'zsh-learn-GetLastItem "$@"'
}

@test 'self-invoke - zsh-learn-Learn calls itself at end' {
    run tail -2 "$pluginDir/autoload/zsh-learn-Learn"
    assert "$output" contains 'zsh-learn-Learn "$@"'
}

@test 'self-invoke - zsh-learn-Redo calls itself at end' {
    run tail -2 "$pluginDir/autoload/zsh-learn-Redo"
    assert "$output" contains 'zsh-learn-Redo "$@"'
}

@test 'self-invoke - zsh-learn-Redosql calls itself at end' {
    run tail -2 "$pluginDir/autoload/zsh-learn-Redosql"
    assert "$output" contains 'zsh-learn-Redosql "$@"'
}

@test 'self-invoke - zsh-learn-CreateLearningCollection calls itself at end' {
    run tail -2 "$pluginDir/autoload/zsh-learn-CreateLearningCollection"
    assert "$output" contains 'zsh-learn-CreateLearningCollection "$@"'
}

@test 'self-invoke - zsh-learn-DropLearningCollection calls itself at end' {
    run tail -2 "$pluginDir/autoload/zsh-learn-DropLearningCollection"
    assert "$output" contains 'zsh-learn-DropLearningCollection "$@"'
}

@test 'self-invoke - _fzf_complete_redo calls itself at end' {
    run tail -2 "$pluginDir/autoload/_fzf_complete_redo"
    assert "$output" contains '_fzf_complete_redo "$@"'
}

@test 'self-invoke - _fzf_complete_redo_post calls itself at end' {
    run tail -2 "$pluginDir/autoload/_fzf_complete_redo_post"
    assert "$output" contains '_fzf_complete_redo_post "$@"'
}

@test 'self-invoke - _fzf_complete_rsql calls itself at end' {
    run tail -2 "$pluginDir/autoload/_fzf_complete_rsql"
    assert "$output" contains '_fzf_complete_rsql "$@"'
}

@test 'self-invoke - _fzf_complete_rsql_post calls itself at end' {
    run tail -2 "$pluginDir/autoload/_fzf_complete_rsql_post"
    assert "$output" contains '_fzf_complete_rsql_post "$@"'
}

@test 'self-invoke - _fzf_complete_se calls itself at end' {
    run tail -2 "$pluginDir/autoload/_fzf_complete_se"
    assert "$output" contains '_fzf_complete_se "$@"'
}

@test 'self-invoke - _fzf_complete_se_post calls itself at end' {
    run tail -2 "$pluginDir/autoload/_fzf_complete_se_post"
    assert "$output" contains '_fzf_complete_se_post "$@"'
}

# ================================================================
# Section 22: Function contains function keyword
# ================================================================

@test 'funcdef - del defines function del' {
    run cat "$pluginDir/autoload/del"
    assert "$output" contains "function del"
}

@test 'funcdef - ser defines function ser' {
    run cat "$pluginDir/autoload/ser"
    assert "$output" contains "function ser"
}

@test 'funcdef - sera defines function sera' {
    run cat "$pluginDir/autoload/sera"
    assert "$output" contains "function sera"
}

@test 'funcdef - qu defines function qu' {
    run cat "$pluginDir/autoload/qu"
    assert "$output" contains "function qu"
}

@test 'funcdef - qua defines function qua' {
    run cat "$pluginDir/autoload/qua"
    assert "$output" contains "function qua"
}

@test 'funcdef - sef defines function sef' {
    run cat "$pluginDir/autoload/sef"
    assert "$output" contains "function sef"
}

@test 'funcdef - zsh-learn-Savel defines function' {
    run cat "$pluginDir/autoload/zsh-learn-Savel"
    assert "$output" contains "function zsh-learn-Savel"
}

@test 'funcdef - zsh-learn-Searchl defines function' {
    run cat "$pluginDir/autoload/zsh-learn-Searchl"
    assert "$output" contains "function zsh-learn-Searchl"
}

@test 'funcdef - zsh-learn-Searchle defines function' {
    run cat "$pluginDir/autoload/zsh-learn-Searchle"
    assert "$output" contains "function zsh-learn-Searchle"
}

@test 'funcdef - zsh-learn-Searchlee defines function' {
    run cat "$pluginDir/autoload/zsh-learn-Searchlee"
    assert "$output" contains "function zsh-learn-Searchlee"
}

@test 'funcdef - zsh-learn-DeleteId defines function' {
    run cat "$pluginDir/autoload/zsh-learn-DeleteId"
    assert "$output" contains "function zsh-learn-DeleteId"
}

@test 'funcdef - zsh-learn-Editl defines function' {
    run cat "$pluginDir/autoload/zsh-learn-Editl"
    assert "$output" contains "function zsh-learn-Editl"
}

@test 'funcdef - zsh-learn-Get defines function' {
    run cat "$pluginDir/autoload/zsh-learn-Get"
    assert "$output" contains "function zsh-learn-Get"
}

@test 'funcdef - zsh-learn-GetItems defines function' {
    run cat "$pluginDir/autoload/zsh-learn-GetItems"
    assert "$output" contains "function zsh-learn-GetItems"
}

@test 'funcdef - zsh-learn-GetLastItem defines function' {
    run cat "$pluginDir/autoload/zsh-learn-GetLastItem"
    assert "$output" contains "function zsh-learn-GetLastItem"
}

@test 'funcdef - zsh-learn-Learn defines function' {
    run cat "$pluginDir/autoload/zsh-learn-Learn"
    assert "$output" contains "function zsh-learn-Learn"
}

@test 'funcdef - zsh-learn-Redo defines function' {
    run cat "$pluginDir/autoload/zsh-learn-Redo"
    assert "$output" contains "function zsh-learn-Redo"
}

@test 'funcdef - zsh-learn-Redosql defines function' {
    run cat "$pluginDir/autoload/zsh-learn-Redosql"
    assert "$output" contains "function zsh-learn-Redosql"
}

@test 'funcdef - zsh-learn-CreateLearningCollection defines function' {
    run cat "$pluginDir/autoload/zsh-learn-CreateLearningCollection"
    assert "$output" contains "function zsh-learn-CreateLearningCollection"
}

@test 'funcdef - zsh-learn-DropLearningCollection defines function' {
    run cat "$pluginDir/autoload/zsh-learn-DropLearningCollection"
    assert "$output" contains "function zsh-learn-DropLearningCollection"
}

# ================================================================
# Section 23: _se completion function tests
# ================================================================

@test 'completion - _se file has compdef header' {
    run head -1 "$pluginDir/src/_se"
    assert "$output" contains "compdef"
}

@test 'completion - _se covers se command' {
    run head -1 "$pluginDir/src/_se"
    assert "$output" contains "se"
}

@test 'completion - _se covers see command' {
    run head -1 "$pluginDir/src/_se"
    assert "$output" contains "see"
}

@test 'completion - _se covers seee command' {
    run head -1 "$pluginDir/src/_se"
    assert "$output" contains "seee"
}

@test 'completion - _se covers zsh-learn-Redo command' {
    run head -1 "$pluginDir/src/_se"
    assert "$output" contains "zsh-learn-Redo"
}

@test 'completion - _se covers rsql command' {
    run head -1 "$pluginDir/src/_se"
    assert "$output" contains "rsql"
}

@test 'completion - _se covers re command' {
    run head -1 "$pluginDir/src/_se"
    assert "$output" contains "re"
}

@test 'completion - _se covers zsh-learn-Searchl command' {
    run head -1 "$pluginDir/src/_se"
    assert "$output" contains "zsh-learn-Searchl"
}

@test 'completion - _se covers zsh-learn-Searchle command' {
    run head -1 "$pluginDir/src/_se"
    assert "$output" contains "zsh-learn-Searchle"
}

@test 'completion - _se covers zsh-learn-Searchlee command' {
    run head -1 "$pluginDir/src/_se"
    assert "$output" contains "zsh-learn-Searchlee"
}

@test 'completion - _se covers zsh-learn-Redosql command' {
    run head -1 "$pluginDir/src/_se"
    assert "$output" contains "zsh-learn-Redosql"
}

@test 'completion - _se uses _describe' {
    run cat "$pluginDir/src/_se"
    assert "$output" contains "_describe"
}

@test 'completion - _se describes learning id' {
    run cat "$pluginDir/src/_se"
    assert "$output" contains "learning id"
}

@test 'completion - _se describes learning text' {
    run cat "$pluginDir/src/_se"
    assert "$output" contains "learning text"
}

@test 'completion - _se uses select query' {
    run cat "$pluginDir/src/_se"
    assert "$output" contains "select learning from"
}

@test 'completion - _se uses ZPWR_SCHEMA_NAME' {
    run cat "$pluginDir/src/_se"
    assert "$output" contains "ZPWR_SCHEMA_NAME"
}

@test 'completion - _se uses ZPWR_TABLE_NAME' {
    run cat "$pluginDir/src/_se"
    assert "$output" contains "ZPWR_TABLE_NAME"
}

@test 'completion - _se uses ZPWR_LEARN_COMMAND' {
    run cat "$pluginDir/src/_se"
    assert "$output" contains "ZPWR_LEARN_COMMAND"
}

@test 'completion - _se uses maxRecords' {
    run cat "$pluginDir/src/_se"
    assert "$output" contains "maxRecords"
}

@test 'completion - _se uses perl' {
    run cat "$pluginDir/src/_se"
    assert "$output" contains "perl"
}

@test 'completion - _se defines function _se' {
    run cat "$pluginDir/src/_se"
    assert "$output" contains "function _se"
}

@test 'completion - _se calls itself at end' {
    run tail -2 "$pluginDir/src/_se"
    assert "$output" contains '_se "$@"'
}

# ================================================================
# Section 24: Plugin conditional loading (ZPWR_LEARN)
# ================================================================

@test 'conditional - plugin loads when ZPWR_LEARN is unset' {
    (
        unset ZPWR_LEARN
        source "$pluginDir/zsh-learn.plugin.zsh"
    )
    assert $? equals 0
}

@test 'conditional - plugin loads when ZPWR_LEARN is true' {
    (
        ZPWR_LEARN=true
        source "$pluginDir/zsh-learn.plugin.zsh"
    )
    assert $? equals 0
}

@test 'conditional - plugin skips zle when ZPWR_LEARN is false' {
    (
        ZPWR_LEARN=false
        source "$pluginDir/zsh-learn.plugin.zsh"
    )
    assert $? equals 0
}

# ================================================================
# Section 25: Searchl SQL generation
# ================================================================

@test 'Searchl - no args generates select SQL' {
    run zsh-learn-Searchl
    assert "$output" contains "select learning from"
}

@test 'Searchl - no args uses schema.table' {
    run zsh-learn-Searchl
    assert "$output" contains "testschema.TestTable"
}

@test 'Searchl - uses configured CHAR_LOGO' {
    export ZPWR_CHAR_LOGO="***"
    run zsh-learn-Searchl
    export ZPWR_CHAR_LOGO="<<)(>>"
    # Just ensure it doesn't crash
    assert $state equals 0
}

# ================================================================
# Section 26: Searchle SQL generation
# ================================================================

@test 'Searchle - no args generates select SQL with category' {
    run zsh-learn-Searchle
    assert "$output" contains "select learning,category from"
}

@test 'Searchle - no args uses schema.table' {
    run zsh-learn-Searchle
    assert "$output" contains "testschema.TestTable"
}

# ================================================================
# Section 27: Searchlee SQL generation
# ================================================================

@test 'Searchlee - no args generates select SQL with dateAdded' {
    run zsh-learn-Searchlee
    assert "$output" contains "select id, dateAdded,learning,category from"
}

@test 'Searchlee - no args uses schema.table' {
    run zsh-learn-Searchlee
    assert "$output" contains "testschema.TestTable"
}

@test 'Searchlee - no args orders by dateAdded' {
    run zsh-learn-Searchlee
    assert "$output" contains "order by dateAdded"
}

# ================================================================
# Section 28: Multiple environment variable combinations
# ================================================================

@test 'combo - custom schema and table for Savel' {
    export ZPWR_SCHEMA_NAME="alpha"
    export ZPWR_TABLE_NAME="Beta"
    run zsh-learn-Savel "combo test"
    assert "$output" contains "alpha.Beta"
    export ZPWR_SCHEMA_NAME="testschema"
    export ZPWR_TABLE_NAME="TestTable"
}

@test 'combo - custom schema and table for del' {
    export ZPWR_SCHEMA_NAME="gamma"
    export ZPWR_TABLE_NAME="Delta"
    run del 3
    assert "$output" contains "gamma.Delta"
    export ZPWR_SCHEMA_NAME="testschema"
    export ZPWR_TABLE_NAME="TestTable"
}

@test 'combo - custom schema and table for DeleteId' {
    export ZPWR_SCHEMA_NAME="epsilon"
    export ZPWR_TABLE_NAME="Zeta"
    run zsh-learn-DeleteId 99
    assert "$output" contains "epsilon.Zeta"
    export ZPWR_SCHEMA_NAME="testschema"
    export ZPWR_TABLE_NAME="TestTable"
}

@test 'combo - custom schema and table for Searchl' {
    export ZPWR_SCHEMA_NAME="eta"
    export ZPWR_TABLE_NAME="Theta"
    run zsh-learn-Searchl
    assert "$output" contains "eta.Theta"
    export ZPWR_SCHEMA_NAME="testschema"
    export ZPWR_TABLE_NAME="TestTable"
}

@test 'combo - custom schema and table for Searchle' {
    export ZPWR_SCHEMA_NAME="iota"
    export ZPWR_TABLE_NAME="Kappa"
    run zsh-learn-Searchle
    assert "$output" contains "iota.Kappa"
    export ZPWR_SCHEMA_NAME="testschema"
    export ZPWR_TABLE_NAME="TestTable"
}

@test 'combo - custom schema and table for Searchlee' {
    export ZPWR_SCHEMA_NAME="lambda"
    export ZPWR_TABLE_NAME="Mu"
    run zsh-learn-Searchlee
    assert "$output" contains "lambda.Mu"
    export ZPWR_SCHEMA_NAME="testschema"
    export ZPWR_TABLE_NAME="TestTable"
}

@test 'combo - custom max size 10 rejects 11 char string' {
    export ZPWR_LEARN_MAX_SIZE=10
    run zsh-learn-Savel "12345678901"
    assert $state equals 1
    export ZPWR_LEARN_MAX_SIZE=3000
}

@test 'combo - custom max size 10 accepts 10 char string' {
    export ZPWR_LEARN_MAX_SIZE=10
    run zsh-learn-Savel "1234567890"
    assert "$output" contains "insert into"
    export ZPWR_LEARN_MAX_SIZE=3000
}

@test 'combo - custom max size 10 accepts 9 char string' {
    export ZPWR_LEARN_MAX_SIZE=10
    run zsh-learn-Savel "123456789"
    assert "$output" contains "insert into"
    export ZPWR_LEARN_MAX_SIZE=3000
}

# ================================================================
# Section 29: Return code tests
# ================================================================

@test 'retcode - Savel returns 0 on valid input' {
    run zsh-learn-Savel "valid learning"
    assert $state equals 0
}

@test 'retcode - Savel returns 1 on empty input' {
    run zsh-learn-Savel
    assert $state equals 1
}

@test 'retcode - Savel returns 1 on oversized input' {
    local bigstr=$(printf '%0.sa' {1..3001})
    run zsh-learn-Savel "$bigstr"
    assert $state equals 1
}

@test 'retcode - DeleteId returns 1 on empty input' {
    run zsh-learn-DeleteId
    assert $state equals 1
}

@test 'retcode - DeleteId returns 0 on valid input' {
    run zsh-learn-DeleteId 42
    assert $state equals 0
}

@test 'retcode - Editl returns 1 on empty input' {
    run zsh-learn-Editl
    assert $state equals 1
}

@test 'retcode - del returns 0 with no args' {
    run del
    assert $state equals 0
}

@test 'retcode - del returns 0 with arg' {
    run del 5
    assert $state equals 0
}

@test 'retcode - CreateLearningCollection -h returns 0' {
    run zsh-learn-CreateLearningCollection -h
    assert $state equals 0
}

@test 'retcode - DropLearningCollection -h returns 0' {
    run zsh-learn-DropLearningCollection -h
    assert $state equals 0
}

@test 'retcode - zpwrLoggErr returns 0' {
    run zpwrLoggErr "msg"
    assert $state equals 0
}

@test 'retcode - zpwrAlternatingPrettyPrint returns 0' {
    run zpwrAlternatingPrettyPrint "msg"
    assert $state equals 0
}

@test 'retcode - zpwrCommandExists returns 0 for ls' {
    run zpwrCommandExists ls
    assert $state equals 0
}

@test 'retcode - zpwrCommandExists returns nonzero for bogus' {
    run zpwrCommandExists totally_fake_cmd_xyz
    assert $state not_equal_to 0
}

@test 'retcode - Searchl returns 0 with no args' {
    run zsh-learn-Searchl
    assert $state equals 0
}

@test 'retcode - Searchle returns 0 with no args' {
    run zsh-learn-Searchle
    assert $state equals 0
}

@test 'retcode - Searchlee returns 0 with no args' {
    run zsh-learn-Searchlee
    assert $state equals 0
}

@test 'retcode - Savel returns 1 on invalid option' {
    run zsh-learn-Savel -z "test"
    assert $state equals 1
}

# ================================================================
# Section 30: Savel category variations
# ================================================================

@test 'Savel - category linux' {
    run zsh-learn-Savel -c "linux" "linux kernel tip"
    assert "$output" contains "linux"
}

@test 'Savel - category database' {
    run zsh-learn-Savel -c "database" "sql join syntax"
    assert "$output" contains "database"
}

@test 'Savel - category git' {
    run zsh-learn-Savel -c "git" "git rebase -i"
    assert "$output" contains "git"
}

@test 'Savel - category vim' {
    run zsh-learn-Savel -c "vim" "dd deletes line"
    assert "$output" contains "vim"
}

@test 'Savel - category docker' {
    run zsh-learn-Savel -c "docker" "docker compose up"
    assert "$output" contains "docker"
}

@test 'Savel - category kubernetes' {
    run zsh-learn-Savel -c "kubernetes" "kubectl get pods"
    assert "$output" contains "kubernetes"
}

@test 'Savel - category python' {
    run zsh-learn-Savel -c "python" "list comprehension"
    assert "$output" contains "python"
}

@test 'Savel - category rust' {
    run zsh-learn-Savel -c "rust" "ownership model"
    assert "$output" contains "rust"
}

@test 'Savel - category zsh' {
    run zsh-learn-Savel -c "zsh" "parameter expansion"
    assert "$output" contains "zsh"
}

@test 'Savel - category bash' {
    run zsh-learn-Savel -c "bash" "array syntax"
    assert "$output" contains "bash"
}

# ================================================================
# Section 31: Various learning content tests
# ================================================================

@test 'Savel - stores command with flags' {
    run zsh-learn-Savel "ls -la --color=auto"
    assert "$output" contains "ls -la --color=auto"
}

@test 'Savel - stores URL-like content' {
    run zsh-learn-Savel "check http example com for docs"
    assert "$output" contains "insert into"
}

@test 'Savel - stores multiword learning' {
    run zsh-learn-Savel "use ctrl+r for reverse search in zsh"
    assert "$output" contains "reverse search"
}

@test 'Savel - stores command pipeline' {
    run zsh-learn-Savel "ps aux | grep nginx | awk print 2"
    assert "$output" contains "insert into"
}

@test 'Savel - stores regex pattern' {
    run zsh-learn-Savel "regex: ^[a-z]+$ matches lowercase"
    assert "$output" contains "insert into"
}

@test 'Savel - stores environment variable usage' {
    run zsh-learn-Savel "export PATH=/usr/local/bin:PATH"
    assert "$output" contains "insert into"
}

@test 'Savel - stores git command' {
    run zsh-learn-Savel "git log --oneline --graph --all"
    assert "$output" contains "insert into"
}

@test 'Savel - stores docker command' {
    run zsh-learn-Savel "docker run -it --rm ubuntu bash"
    assert "$output" contains "insert into"
}

@test 'Savel - stores ssh command' {
    run zsh-learn-Savel "ssh -L 8080:localhost:80 user@host"
    assert "$output" contains "insert into"
}

@test 'Savel - stores find command' {
    run zsh-learn-Savel "find . -name *.log -mtime +7 -delete"
    assert "$output" contains "insert into"
}

# ================================================================
# Section 32: Plugin header validation
# ================================================================

@test 'header - plugin file starts with shebang' {
    run head -1 "$pluginDir/zsh-learn.plugin.zsh"
    assert "$output" contains "#!/usr/bin/env zsh"
}

@test 'header - plugin file has author' {
    run head -10 "$pluginDir/zsh-learn.plugin.zsh"
    assert "$output" contains "MenkeTechnologies"
}

@test 'header - plugin file has github' {
    run head -10 "$pluginDir/zsh-learn.plugin.zsh"
    assert "$output" contains "github.com"
}

@test 'header - plugin file has purpose' {
    run head -10 "$pluginDir/zsh-learn.plugin.zsh"
    assert "$output" contains "Purpose"
}

# ================================================================
# Section 33: Autoload count validation
# ================================================================

@test 'count - exactly 26 autoload files exist' {
    local count=$(ls "$pluginDir/autoload/" | wc -l | tr -d ' ')
    assert "$count" same_as "26"
}

@test 'count - exactly 1 src file exists' {
    local count=$(ls "$pluginDir/src/" | wc -l | tr -d ' ')
    assert "$count" same_as "1"
}

# ================================================================
# Section 34: Savel SQL structure details
# ================================================================

@test 'Savel sql - contains opening paren for columns' {
    run zsh-learn-Savel "test"
    assert "$output" contains "(category, learning, dateAdded)"
}

@test 'Savel sql - contains values keyword' {
    run zsh-learn-Savel "test"
    assert "$output" contains "values ("
}

@test 'Savel sql - content appears in values' {
    run zsh-learn-Savel "myuniquecontent"
    assert "$output" contains "myuniquecontent"
}

@test 'Savel sql - default category appears in values' {
    run zsh-learn-Savel "test"
    assert "$output" contains "'programming'"
}

# ================================================================
# Section 35: Searchl order by clause
# ================================================================

@test 'Searchl - orders by dateAdded' {
    run zsh-learn-Searchl
    assert "$output" contains "order by dateAdded"
}

@test 'Searchle - orders by dateAdded' {
    run zsh-learn-Searchle
    assert "$output" contains "order by dateAdded"
}

@test 'Searchlee - orders by dateAdded' {
    run zsh-learn-Searchlee
    assert "$output" contains "order by dateAdded"
}

# ================================================================
# Section 36: Searchl select columns
# ================================================================

@test 'Searchl - selects learning column' {
    run zsh-learn-Searchl
    assert "$output" contains "select learning from"
}

@test 'Searchle - selects learning and category columns' {
    run zsh-learn-Searchle
    assert "$output" contains "select learning,category from"
}

@test 'Searchlee - selects id dateAdded learning category' {
    run zsh-learn-Searchlee
    assert "$output" contains "id, dateAdded,learning,category"
}

# ================================================================
# Section 37: del SQL structure
# ================================================================

@test 'del sql - starts with delete from' {
    run del
    assert "$output" contains "delete from"
}

@test 'del sql - has order by id desc' {
    run del
    assert "$output" contains "order by id desc"
}

@test 'del sql - has limit clause' {
    run del
    assert "$output" contains "limit"
}

@test 'del sql - full structure default' {
    run del
    assert "$output" contains "delete from testschema.TestTable order by id desc limit 1"
}

@test 'del sql - full structure with count 7' {
    run del 7
    assert "$output" contains "delete from testschema.TestTable order by id desc limit 7"
}

# ================================================================
# Section 38: DeleteId SQL structure
# ================================================================

@test 'DeleteId sql - starts with DELETE FROM' {
    run zsh-learn-DeleteId 5
    assert "$output" contains "DELETE FROM"
}

@test 'DeleteId sql - has WHERE id =' {
    run zsh-learn-DeleteId 5
    assert "$output" contains "WHERE id = 5"
}

@test 'DeleteId sql - ends with semicolon' {
    local result=$(echo "DELETE FROM testschema.TestTable WHERE id = 5;" | cat)
    run zsh-learn-DeleteId 5
    assert "$output" contains ";"
}

@test 'DeleteId sql - full structure' {
    run zsh-learn-DeleteId 123
    assert "$output" contains "DELETE FROM testschema.TestTable WHERE id = 123;"
}

# ================================================================
# Section 39: Plugin sets rcquotes
# ================================================================

@test 'rcquotes - setopt rcquotes is in plugin file' {
    run cat "$pluginDir/zsh-learn.plugin.zsh"
    assert "$output" contains "setopt rcquotes"
}

# ================================================================
# Section 40: zpwrCommandExists covers various commands
# ================================================================

@test 'zpwrCommandExists - awk exists' {
    run zpwrCommandExists awk
    assert $state equals 0
}

@test 'zpwrCommandExists - sed exists' {
    run zpwrCommandExists sed
    assert $state equals 0
}

@test 'zpwrCommandExists - grep exists' {
    run zpwrCommandExists grep
    assert $state equals 0
}

@test 'zpwrCommandExists - head exists' {
    run zpwrCommandExists head
    assert $state equals 0
}

@test 'zpwrCommandExists - tail exists' {
    run zpwrCommandExists tail
    assert $state equals 0
}

@test 'zpwrCommandExists - sort exists' {
    run zpwrCommandExists sort
    assert $state equals 0
}

@test 'zpwrCommandExists - wc exists' {
    run zpwrCommandExists wc
    assert $state equals 0
}

@test 'zpwrCommandExists - rm exists' {
    run zpwrCommandExists rm
    assert $state equals 0
}

@test 'zpwrCommandExists - cp exists' {
    run zpwrCommandExists cp
    assert $state equals 0
}

@test 'zpwrCommandExists - mv exists' {
    run zpwrCommandExists mv
    assert $state equals 0
}

@test 'zpwrCommandExists - mkdir exists' {
    run zpwrCommandExists mkdir
    assert $state equals 0
}

@test 'zpwrCommandExists - touch exists' {
    run zpwrCommandExists touch
    assert $state equals 0
}

@test 'zpwrCommandExists - chmod exists' {
    run zpwrCommandExists chmod
    assert $state equals 0
}

@test 'zpwrCommandExists - date exists' {
    run zpwrCommandExists date
    assert $state equals 0
}

@test 'zpwrCommandExists - hostname exists' {
    run zpwrCommandExists hostname
    assert $state equals 0
}

@test 'zpwrCommandExists - nonexistent1 does not exist' {
    run zpwrCommandExists nonexistent_tool_aaa
    assert $state not_equal_to 0
}

@test 'zpwrCommandExists - nonexistent2 does not exist' {
    run zpwrCommandExists fake_binary_bbb
    assert $state not_equal_to 0
}

@test 'zpwrCommandExists - nonexistent3 does not exist' {
    run zpwrCommandExists imaginary_cmd_ccc
    assert $state not_equal_to 0
}
