#!/usr/bin/env zsh
#{{{ MARK:Header
#**************************************************************
##### Author: MenkeTechnologies
##### GitHub: https://github.com/MenkeTechnologies
##### Date: Wed Jan 29 10:00:34 EST 2020
##### Purpose: zsh script to learn
##### Notes:
#}}}***********************************************************
#
setopt rcquotes

if ! (( $+ZPWR_VARS )) || [[ ${parameters[ZPWR_VARS]} != association ]]; then
    # global map to containerize global variables
    declare -gA ZPWR_VARS
fi

if ! (( $+functions[zpwrLoggErr] )); then
zpwrLoggErr () {
    echo "$@" >&2
}
fi

if ! (( $+functions[zpwrCommandExists] )); then
zpwrCommandExists () {
    type -ap -- "$1" > /dev/null 2>&1
}
fi

if ! (( $+functions[zpwrAlternatingPrettyPrint] )); then
zpwrAlternatingPrettyPrint() {
    echo "$@" >&1
}
fi


ZPWR_VARS[maxRecords]=2000

test -z "$ZPWR_SEND_KEYS_FULL" && export ZPWR_SEND_KEYS_FULL=false
test -z "$ZPWR_TEMPFILE_SQL" && export ZPWR_TEMPFILE_SQL="/tmp/.zpwr-sql-temp"
test -z "$ZPWR_SCHEMA_NAME" && export ZPWR_SCHEMA_NAME="root"
test -z "$ZPWR_TABLE_NAME" && export ZPWR_TABLE_NAME="LearningCollectiion"
test -z "$ZPWR_TEMPFILE_SQL" && export ZPWR_TEMPFILE_SQL="/tmp/.zpwr-sql-temp"
test -z "$ZPWR_TEMPFILE" && export ZPWR_TEMPFILE="/tmp/.zpwr-temp"
test -z "$ZPWR_TEMPFILE2" && export ZPWR_TEMPFILE2="/tmp/.zpwr-temp2"
test -z "$ZPWR_LOGFILE" && export ZPWR_LOGFILE="/tmp/.zpwr-log"
test -z "$ZPWR_CHAR_LOGO" && export ZPWR_CHAR_LOGO="<<)(>>"
test -z "$ZPWR_LEARN_COMMAND" && export ZPWR_LEARN_COMMAND='mysql'
test -z "$ZPWR_LEARN_MAX_SIZE" && export ZPWR_LEARN_MAX_SIZE=3000

# stop common typos
alias le='noglob zsh-learn-Savel'
alias es='noglob zsh-learn-Searchl'
alias ees='noglob zsh-learn-Searchl'
alias ses='noglob zsh-learn-Searchl'
alias ese='noglob zsh-learn-Searchl'
alias sse='noglob zsh-learn-Searchl'
alias ssee='noglob zsh-learn-Searchl'
alias re='noglob zsh-learn-Redo'
alias rer='noglob zsh-learn-Redo'
alias er='noglob zsh-learn-Redo'
alias rsql='noglob zsh-learn-Redosql'
alias see='noglob zsh-learn-Searchle'
alias seee='noglob zsh-learn-Searchlee'
alias se='noglob zsh-learn-Searchl'
alias editl='noglob zsh-learn-Editl'
alias delid='noglob zsh-learn-DeleteId'

if (( ${+ZPWR_VERBS} )); then

    ZPWR_VERBS[learn]='zsh-learn-Savel=save learning to $ZPWR_SCHEMA_NAME.$ZPWR_TABLE_NAME'
    ZPWR_VERBS[learndel]='del=delete learning from $ZPWR_SCHEMA_NAME.$ZPWR_TABLE_NAME'
    ZPWR_VERBS[editl]='zsh-learn-Editl=Edit learning by id from $ZPWR_SCHEMA_NAME.$ZPWR_TABLE_NAME'
    ZPWR_VERBS[del]='del=delete learning from $ZPWR_SCHEMA_NAME.$ZPWR_TABLE_NAME'
    ZPWR_VERBS[delete]='del=delete learning from $ZPWR_SCHEMA_NAME.$ZPWR_TABLE_NAME'
    ZPWR_VERBS[learndelete]='del=delete save learning from $ZPWR_SCHEMA_NAME.$ZPWR_TABLE_NAME'
    ZPWR_VERBS[delid]='zsh-learn-DeleteId=delete learning by id from $ZPWR_SCHEMA_NAME.$ZPWR_TABLE_NAME'
    ZPWR_VERBS[createlearningcollection]='zsh-learn-CreateLearningCollection=create $ZPWR_SCHEMA_NAME.$ZPWR_TABLE_NAME with mysql -u root'
    ZPWR_VERBS[droplearningcollection]='zsh-learn-DropLearningCollection=drop $ZPWR_SCHEMA_NAME.$ZPWR_TABLE_NAME with mysql -u root'
    ZPWR_VERBS[learnsearch]='se=search for learning in $ZPWR_SCHEMA_NAME.$ZPWR_TABLE_NAME'

    ZPWR_VERBS[se]='zsh-learn-Searchl=search the learning collection'
    ZPWR_VERBS[searchl]='zsh-learn-Searchl=search the learning collection'

    ZPWR_VERBS[see]='zsh-learn-Searchle=category search the learning collection'
    ZPWR_VERBS[searchle]='zsh-learn-Searchle=category search the learning collection'

    ZPWR_VERBS[seee]='zsh-learn-Searchlee=timestamp search the learning collection'
    ZPWR_VERBS[searchlee]='zsh-learn-Searchlee=timestamp search the learning collection'

    ZPWR_VERBS[learnget]='zsh-learn-Get=get learning items'
    ZPWR_VERBS[getlearn]='zsh-learn-Get=get learning items'
    ZPWR_VERBS[re]='zsh-learn-Redo=zsh-learn-Redo the learning collection'
    ZPWR_VERBS[redo]='zsh-learn-Redo=zsh-learn-Redo the learning collection'

    ZPWR_VERBS[rsql]='zsh-learn-Redosql=zsh-learn-Redo into vim the learning collection'
    ZPWR_VERBS[redosql]='zsh-learn-Redosql=zsh-learn-Redo into vim the learning collection'

    ZPWR_VERBS[ser]='ser=random search the learning collection'

    ZPWR_VERBS[quiz]='qu=quiz from the learning collection'
    ZPWR_VERBS[qu]='qu=quiz from the learning collection'
    ZPWR_VERBS[quizall]='qua=quiz all from the learning collection'
    ZPWR_VERBS[qua]='qua=quiz all from the learning collection'

    ZPWR_VERBS[sef]='sef=search into fzf the entire learning collection'
    ZPWR_VERBS[searchfull]='sef=search into fzf the entire learning collection'
    ZPWR_VERBS[searchall]='sef=search into fzf the entire learning collection'
fi

# to allow reverse numeric sort and numeric sort
# as opposed to lexicographic sort
if [[ $ZPWR_LEARN != false ]]; then
    zstyle ':completion:*:*:(se|see|seee|zsh-learn-Redo|rsql|re|zsh-learn-Searchl|zsh-learn-Searchle|zsh-learn-Searchlee|z|r|zsh-learn-Zsh-learn-get):*:*' sort false
    zstyle ':completion:*:*:(zpwr-se|zpwr-see|zpwr-seee|zpwr-redo|zpwr-rsql|zpwr-re|zpwr-searchl|zpwr-searchle|zpwr-searchlee|zpwr-r|zpwr-get):*:*' sort false

    zstyle ':completion:*:*:*:*:(zsh-learn-Zsh-learn-id|zsh-learn-Zsh-learn-text)' group-order zsh-learn-Zsh-learn-id zsh-learn-Zsh-learn-text

    zstyle ':completion:*:zsh-learn-Zsh-learn-id' list-colors '=(#b)(*)=1;30=1;36;44'
    zstyle ':completion:*:zsh-learn-Zsh-learn-text' list-colors '=(#b)(*)=1;30=1;34;43;4'


    zle -N zsh-learn-Learn
    bindkey -M viins '^k' zsh-learn-Learn
    bindkey -M vicmd '^k' zsh-learn-Learn
    bindkey -M emacs '^k' zsh-learn-Learn

    0="${${0:#$ZSH_ARGZERO}:-${(%):-%N}}"
    0="${${(M)0:#/*}:-$PWD/$0}"

    # comps
    fpath=("${0:h}/src" $fpath)

    # util fns
    fpath=("${0:h}/autoload" $fpath)
    autoload -Uz "${0:h}/autoload/"*(.:t)
fi
