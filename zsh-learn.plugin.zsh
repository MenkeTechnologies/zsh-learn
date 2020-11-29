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

if ! (( $+ZPWR_VARS )); then
    # global contaner to hold globals
    declare -A ZPWR_VARS
fi

if ! (( $+function[commandExists] )); then
commandExists () {
    type -ap -- "$1" > /dev/null 2>&1
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

# stop common typos
alias le='noglob savel'
alias es='noglob searchl'
alias ees='noglob searchl'
alias ses='noglob searchl'
alias ese='noglob searchl'
alias sse='noglob searchl'
alias ssee='noglob searchl'
alias re='noglob redo'
alias rer='noglob redo'
alias er='noglob redo'
alias rsql='noglob redosql'
alias see='noglob searchle'
alias seee='noglob searchlee'
alias se='noglob searchl'

if (( ${+ZPWR_VERBS} )); then
    ZPWR_VERBS[learn]='savel=save learning to \$ZPWR_SCHEMA_NAME.\$ZPWR_TABLE_NAME'
    ZPWR_VERBS[learndel]='del=delete learning from \$ZPWR_SCHEMA_NAME.\$ZPWR_TABLE_NAME'
    ZPWR_VERBS[del]='del=delete learning from \$ZPWR_SCHEMA_NAME.\$ZPWR_TABLE_NAME'
    ZPWR_VERBS[delete]='del=delete learning from \$ZPWR_SCHEMA_NAME.\$ZPWR_TABLE_NAME'
    ZPWR_VERBS[learndelete]='del=delete save learning from \$ZPWR_SCHEMA_NAME.\$ZPWR_TABLE_NAME'
    ZPWR_VERBS[createlearningcollection]='createLearningCollection=create \$ZPWR_SCHEMA_NAME.\$ZPWR_TABLE_NAME with mysql -u root'
    ZPWR_VERBS[learnsearch]='se=search for learning in \$ZPWR_SCHEMA_NAME.\$ZPWR_TABLE_NAME'

    ZPWR_VERBS[se]='searchl=search the learning collection'
    ZPWR_VERBS[searchl]='searchl=search the learning collection'

    ZPWR_VERBS[see]='searchle=category search the learning collection'
    ZPWR_VERBS[searchle]='searchle=category search the learning collection'

    ZPWR_VERBS[seee]='searchlee=timestamp search the learning collection'
    ZPWR_VERBS[searchlee]='searchlee=timestamp search the learning collection'

    ZPWR_VERBS[get]='zsh-learn-get=get learning items'
    ZPWR_VERBS[re]='redo=redo the learning collection'
    ZPWR_VERBS[redo]='redo=redo the learning collection'

    ZPWR_VERBS[rsql]='redosql=redo into vim the learning collection'
    ZPWR_VERBS[redosql]='redosql=redo into vim the learning collection'

    ZPWR_VERBS[ser]='ser=random search the learning collection'

    ZPWR_VERBS[quiz]='qu=quiz from the learning collection'

    ZPWR_VERBS[sef]='sef=search into fzf the learning collection'
fi

# to allow reverse numeric sort and numeric sort
# as opposed to lexicographic sort
if [[ $ZPWR_LEARN != false ]]; then
    zstyle ':completion:*:*:(se|see|seee|redo|rsql|re|searchl|searchle|searchlee|z|r|zsh-learn-get):*:*' sort false
    zstyle ':completion:*:*:(zpwr-se|zpwr-see|zpwr-seee|zpwr-redo|zpwr-rsql|zpwr-re|zpwr-searchl|zpwr-searchle|zpwr-searchlee|zpwr-r|zpwr-get):*:*' sort false

    zstyle ':completion:*:*:*:*:(zsh-learn-id|zsh-learn-text)' group-order zsh-learn-id zsh-learn-text

    zstyle ':completion:*:zsh-learn-id' list-colors '=(#b)(*)=1;30=1;36;44'
    zstyle ':completion:*:zsh-learn-text' list-colors '=(#b)(*)=1;30=1;34;43;4'


    zle -N learn
    bindkey -M viins '^k' learn
    bindkey -M vicmd '^k' learn

    0="${${0:#$ZSH_ARGZERO}:-${(%):-%N}}"
    0="${${(M)0:#/*}:-$PWD/$0}"

    # comps
    fpath=("${0:h}/src" $fpath)

    # util fns
    fpath=("${0:h}/autoload" $fpath)
    autoload -Uz "${0:h}/autoload/"*(.:t)
fi
