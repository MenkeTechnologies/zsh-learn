#!/usr/bin/env zsh
#{{{ MARK:Header
#**************************************************************
##### Author: MenkeTechnologies
##### GitHub: https://github.com/MenkeTechnologies
##### Date: Wed Jan 29 10:00:34 EST 2020
##### Purpose: zsh script to learn
##### Notes:
#}}}***********************************************************


test -z "$ZPWR_SEND_KEYS_FULL" && export ZPWR_SEND_KEYS_FULL=false
test -z "$ZPWR_TEMPFILE_SQL" && export ZPWR_TEMPFILE_SQL="/tmp/.zpwr-sql-temp"
test -z "$ZPWR_SCHEMA_NAME" && export ZPWR_SCHEMA_NAME="root"
test -z "$ZPWR_TABLE_NAME" && export ZPWR_TABLE_NAME="LearningCollectiion"
test -z "$ZPWR_TEMPFILE_SQL" && export ZPWR_TEMPFILE_SQL="/tmp/.zpwr-sql-temp"
test -z "$ZPWR_TEMPFILE" && export ZPWR_TEMPFILE="/tmp/.zpwr-temp"
test -z "$ZPWR_TEMPFILE2" && export ZPWR_TEMPFILE2="/tmp/.zpwr-temp2"
test -z "$ZPWR_LOGFILE" && export ZPWR_LOGFILE="/tmp/.zpwr-log"
test -z "$ZPWR_CHAR_LOGO" && export ZPWR_CHAR_LOGO="<<)(>>"

# stop common typos
alias le='noglob savel'
alias es='noglob searchl'
alias ees='noglob searchl'
alias ses='noglob searchl'
alias ese='noglob searchl'
alias sse='noglob searchl'
alias ssee='noglob searchl'
alias re='noglob redo'
alias rsql='noglob redosql'
alias see='noglob searchle'
alias seee='noglob searchlee'
alias se='noglob searchl'

if (( ${+ZPWR_VERBS} )); then
    ZPWR_VERBS[se]='searchl=search the learning collection'
    ZPWR_VERBS[searchl]='searchl=search the learning collection'

    ZPWR_VERBS[see]='searchle=category search the learning collection'
    ZPWR_VERBS[searchle]='searchle=category search the learning collection'
    
    ZPWR_VERBS[seee]='searchlee=timestamp search the learning collection'
    ZPWR_VERBS[searchlee]='searchlee=timestamp search the learning collection'

    ZPWR_VERBS[re]='redo=redo the learning collection'
    ZPWR_VERBS[redo]='redo=redo the learning collection'

    ZPWR_VERBS[rsql]='redosql=redo into vim the learning collection'
    ZPWR_VERBS[redosql]='redosql=redo into vim the learning collection'

    ZPWR_VERBS[ser]='ser=random search the learning collection'

    ZPWR_VERBS[quiz]='qu=quiz from the learning collection'

    ZPWR_VERBS[sef]='sef=search into fzf the learning collection'
fi

compdef _se se see seee redo rsql re searchl searchle searchlee redosql
# to allow reverse numeric sort and numeric sort
# as opposed to lexicographic sort
zstyle ':completion:*:*:(se|see|seee|redo|rsql|re|searchl|searchle|searchlee|z|r):*:*' sort false



function savel(){

    test -z "$1" && return 1
    category="programming"
    learning="$(printf -- '%s' "$1" | sed 's@^[[:space:]]*@@;s@[[:space:]]*$@@')"

    if [[ -n "$2" ]]; then
        category="$2"
    fi
    echo "insert into $ZPWR_SCHEMA_NAME.$ZPWR_TABLE_NAME (category, learning, dateAdded) values ('"$category"', '""$learning""', now())" | mysql 2>> "$ZPWR_LOGFILE"
}


function searchlee(){

    if test -z "$1"; then
        echo "select id, dateAdded,learning,category from $ZPWR_SCHEMA_NAME.$ZPWR_TABLE_NAME order by dateAdded" | mysql 2>> $ZPWR_LOGFILE | cat -n
    else
        echo "select id, dateAdded, learning,category from $ZPWR_SCHEMA_NAME.$ZPWR_TABLE_NAME order by dateAdded" | mysql 2>> $ZPWR_LOGFILE | cat -n | perl -lanE 'print "$F[0])\t@F[1..$#F]" if (grep /'"$1"'/i, "@F[1..$#F]")' | ag -i -- "$1"
    fi
}

function ser(){

    local num=100
    if [[ -n "$1" ]]; then
        num=$1
    fi

    searchl | shuf -n $num
}

function sef(){

    searchl |
        tac |
        fzf --ansi -m |
        perl -ane 'BEGIN{$c=0} print "redo " if ++$c == 1;print $F[0]." "' |
        source /dev/stdin
}

function searchl(){

    if test -z "$1"; then
        if [[ "$ZPWR_COLORS" = true ]]; then
            echo "select learning from $ZPWR_SCHEMA_NAME.$ZPWR_TABLE_NAME order by dateAdded" |
                mysql 2>> $ZPWR_LOGFILE | nl -b a -n rn -s " $ZPWR_CHAR_LOGO " | perl -pe 's@(\s*)(\d+)\s+(.*)@$1\x1b[35m$2\x1b[0m \x1b[32m$3\x1b[0m@g'
        else
            echo "select learning from $ZPWR_SCHEMA_NAME.$ZPWR_TABLE_NAME" |
            mysql 2>> $ZPWR_LOGFILE | nl -b a -n rn -s " $ZPWR_CHAR_LOGO "
        fi

    else
        arg="$1"
        # escaping for perl $ and @ sigils
        argdollar=${arg//$/\\$}
        arg=${argdollar//@/\\@}
        echo "select learning from $ZPWR_SCHEMA_NAME.$ZPWR_TABLE_NAME order by dateAdded" | mysql 2>> "$ZPWR_LOGFILE" | nl -b a -n rz -s " $ZPWR_CHAR_LOGO " | perl -E 'open $fh, ">>", "'$ZPWR_TEMPFILE'"; open $fh2, ">>", "'$ZPWR_TEMPFILE2'";while (<>){my @F = split;if (grep m{'"$arg"'}i, "@F[1..$#F]"){say $fh "$F[0]   "; say $fh2 "@F[1..$#F]";}}';
        if [[ -z "$2" ]]; then
            if [[ "$ZPWR_COLORS" = true ]]; then
                paste -- $ZPWR_TEMPFILE <(cat -- $ZPWR_TEMPFILE2 | ag -i --color -- "$1") | perl -pe 's@\s*(\d+)\s+(.*)@\x1b[0;35m$1\x1b[0m \x1b[0;32m$2\x1b[0m@g' | perl -pe 's@\x1b\[0m@\x1b\[0;1;34m@g'
            else
            paste -- $ZPWR_TEMPFILE <(cat -- $ZPWR_TEMPFILE2 | ag -i --color -- "$1") | perl -pe 's@\s*(\d+)\s+(.*)@$1 $2@g'
            fi
        else
            if [[ "$ZPWR_COLORS" = true ]]; then
                paste -- $ZPWR_TEMPFILE <(cat -- $ZPWR_TEMPFILE2 | ag -i --color -- "$1") | perl -pe 's@\s*(\d+)\s+(.*)@\x1b[0;35m$1\x1b[0m \x1b[0;32m$2\x1b[0m@g' | perl -pe 's@\x1b\[0m@\x1b\[0;1;34m@g'
            else
            paste -- $ZPWR_TEMPFILE <(cat -- $ZPWR_TEMPFILE2 | ag -i --color -- "$1") | perl -pe 's@\s*(\d+)\s+(.*)@$1 $2@g'
            fi | command grep --color=always -i -E -- "$2"
        fi
        command rm $ZPWR_TEMPFILE $ZPWR_TEMPFILE2
    fi

}
function qu(){

    ser | fzf -m --ansi
}

function searchle(){

    if test -z "$1"; then
        if [[ "$ZPWR_COLORS" = true ]]; then
            echo "select learning,category from $ZPWR_SCHEMA_NAME.$ZPWR_TABLE_NAME order by dateAdded" |
        mysql 2>> $ZPWR_LOGFILE | nl -b a -n rn | perl -pe 's@(\s*)(\d+)\s+(.*)@$1\x1b[35m$2\x1b[0m \x1b[32m$3\x1b[0m@g'
        else
            echo "select learning,category from $ZPWR_SCHEMA_NAME.$ZPWR_TABLE_NAME" |
            mysql 2>> $ZPWR_LOGFILE | nl -b a -n rn
        fi

    else
        arg="$1"
        # escaping for perl $ and @ sigils
        argdollar=${arg//$/\\$}
        arg=${argdollar//@/\\@}
        echo "select learning,category from $ZPWR_SCHEMA_NAME.$ZPWR_TABLE_NAME order by dateAdded" | mysql 2>> "$ZPWR_LOGFILE" | nl -b a -n rz | perl -E 'open $fh, ">>", "'$ZPWR_TEMPFILE'"; open $fh2, ">>", "'$ZPWR_TEMPFILE2'";while (<>){my @F = split;if (grep m{'"$arg"'}i, "@F[1..$#F]"){say $fh "$F[0]   "; say $fh2 "@F[1..$#F]";}}';
        if [[ -z "$2" ]]; then
            if [[ "$ZPWR_COLORS" = true ]]; then
                paste -- $ZPWR_TEMPFILE <(cat -- $ZPWR_TEMPFILE2 | ag -i --color -- "$1") | perl -pe 's@\s*(\d+)\s+(.*)@\x1b[0;35m$1\x1b[0m \x1b[0;32m$2\x1b[0m@g' | perl -pe 's@\x1b\[0m@\x1b\[0;1;34m@g'
            else
            paste -- $ZPWR_TEMPFILE <(cat -- $ZPWR_TEMPFILE2 | ag -i --color -- "$1") | perl -pe 's@\s*(\d+)\s+(.*)@$1 $2@g'
            fi
        else
            if [[ "$ZPWR_COLORS" = true ]]; then
                paste -- $ZPWR_TEMPFILE <(cat -- $ZPWR_TEMPFILE2 | ag -i --color -- "$1") | perl -pe 's@\s*(\d+)\s+(.*)@\x1b[0;35m$1\x1b[0m \x1b[0;32m$2\x1b[0m@g' | perl -pe 's@\x1b\[0m@\x1b\[0;1;34m@g'
            else
            paste -- $ZPWR_TEMPFILE <(cat -- $ZPWR_TEMPFILE2 | ag -i --color -- "$1") | perl -pe 's@\s*(\d+)\s+(.*)@$1 $2@g'
            fi | command grep --color=always -i -E -- "$2"
        fi
        command rm $ZPWR_TEMPFILE $ZPWR_TEMPFILE2
    fi

}

function createLearningCollection(){

    alternatingPrettyPrint "Creating$ZPWR_DELIMITER_CHAR $ZPWR_SCHEMA_NAME.$ZPWR_TABLE_NAME$ZPWR_DELIMITER_CHAR with$ZPWR_DELIMITER_CHAR MySQL$ZPWR_DELIMITER_CHAR"
    if [[ -n "$1" ]]; then
        #use first arg as mysql password
        if ! echo "select * from information_schema.tables" | mysql -u root -p "$1" | command grep --color=always -q "$ZPWR_TABLE_NAME";then
            echo  "create schema $ZPWR_SCHEMA_NAME if not exists"
            echo  "create schema $ZPWR_SCHEMA_NAME if not exists" | mysql -u root -p "$1"

            echo 'CREATE TABLE `'"$ZPWR_TABLE_NAME"'` ( `category` varchar(20) DEFAULT NULL, `learning` varchar(200) DEFAULT NULL,`dateAdded` datetime DEFAULT NULL, `id` int(11) NOT NULL AUTO_INCREMENT,  PRIMARY KEY (`id`), KEY `'"$ZPWR_TABLE_NAME"'learning_index` (`learning`))'
            echo 'CREATE TABLE `'"$ZPWR_TABLE_NAME"'` ( `category` varchar(20) DEFAULT NULL, `learning` varchar(200) DEFAULT NULL,`dateAdded` datetime DEFAULT NULL, `id` int(11) NOT NULL AUTO_INCREMENT,  PRIMARY KEY (`id`), KEY `'"$ZPWR_TABLE_NAME"'learning_index` (`learning`))' | mysql -u root -D "$ZPWR_SCHEMA_NAME" -p "$1"
        else
            loggErr "$ZPWR_SCHEMA_NAME.$ZPWR_TABLE_NAME already exists"
        fi
    else
        #use my.cnf
        if ! echo "select * from information_schema.tables" | mysql | command grep --color=always -q "$ZPWR_TABLE_NAME";then
            echo  "create schema if not exists $ZPWR_SCHEMA_NAME"
            echo  "create schema if not exists $ZPWR_SCHEMA_NAME" | mysql

            echo 'CREATE TABLE `'"$ZPWR_TABLE_NAME"'` ( `category` varchar(20) DEFAULT NULL, `learning` varchar(200) DEFAULT NULL,`dateAdded` datetime DEFAULT NULL, `id` int(11) NOT NULL AUTO_INCREMENT,  PRIMARY KEY (`id`), KEY `'"$ZPWR_TABLE_NAME"'learning_index` (`learning`))'
            echo 'CREATE TABLE `'"$ZPWR_TABLE_NAME"'` ( `category` varchar(20) DEFAULT NULL, `learning` varchar(200) DEFAULT NULL,`dateAdded` datetime DEFAULT NULL, `id` int(11) NOT NULL AUTO_INCREMENT,  PRIMARY KEY (`id`), KEY `'"$ZPWR_TABLE_NAME"'learning_index` (`learning`))' | mysql -D "$ZPWR_SCHEMA_NAME"
        else
            loggErr "$ZPWR_SCHEMA_NAME.$ZPWR_TABLE_NAME already exists"
        fi
    fi
}

del(){

    [[ -z "$1" ]] && count=1 || count="$1"
    echo "delete from $ZPWR_SCHEMA_NAME.$ZPWR_TABLE_NAME order by id desc limit $count" | mysql
}



function _se(){

    eval "learn_ary=( $(echo "select learning from $ZPWR_SCHEMA_NAME.$ZPWR_TABLE_NAME order by dateAdded" | mysql | perl -e '@a=();$c=0;do{chomp;push(@ary,++$c.":".quotemeta($_))}for<>;$c=0;do{print "$_ " if $c++ < 1000}for reverse @ary') )"

    _describe -t zdir 'my learning' learn_ary
}

# rsql ;<tab>
function _fzf_complete_rsql() {

  FZF_COMPLETION_OPTS= _fzf_complete '-m --ansi' "$@" < <(
        searchl | tac
    )
}

function _fzf_complete_rsql_post() {

    awk '{print $1}'
}

# se ;<tab>
function _fzf_complete_se() {

  FZF_COMPLETION_OPTS= _fzf_complete '-m --ansi' "$@" < <(
        searchl | tac
    )
}

function _fzf_complete_se_post() {

    awk '{print $2}'
}

# redo ;<tab>
function _fzf_complete_redo() {

  FZF_COMPLETION_OPTS= _fzf_complete '-m --ansi' "$@" < <(
        searchl | tac
    )
}

function _fzf_complete_redo_post() {

    awk '{print $1}'
}


function learn(){

    if [[ ! -z "$BUFFER" ]]; then

        mywords=("${(z)BUFFER}")
        if [[ "${mywords[1]}" == le ]];then
            return 1
        fi

        learning="$(print -- "$BUFFER" | perl -pe 's@\x0a@\x20@' | perl -pe 's@^\x20+|\x20+$@@g;s@\x20+@\x20@g')"

        BUFFER="le '${learning//'/\''}'"

        if [[ $ZPWR_SEND_KEYS_FULL == false ]]; then
            type -- "keyClear" &>/dev/null && keyClear
            zle .accept-line
        fi
    else
        return 1
    fi
}
function getLastItem(){

    id=$(echo "select id from $ZPWR_SCHEMA_NAME.$ZPWR_TABLE_NAME order by dateAdded" | mysql | tail -n 1)
    if [[ -z $id ]]; then
        continue
    fi
    item=$(echo "select learning from $ZPWR_SCHEMA_NAME.$ZPWR_TABLE_NAME where id=$id" | mysql 2>> $ZPWR_LOGFILE | tail -n 1)
    item=${item//\'/\\\'}
}

function getItems(){

    if echo $num | grep -qsE '^\d+$'; then
        #int
        id=$(echo "select id from $ZPWR_SCHEMA_NAME.$ZPWR_TABLE_NAME order by dateAdded" | mysql | perl -ne "print if \$. == quotemeta('$num')")
        if [[ -z $id ]]; then
            continue
        fi
        item=$(echo "select learning from $ZPWR_SCHEMA_NAME.$ZPWR_TABLE_NAME where id=$id" | mysql 2>> $ZPWR_LOGFILE | tail -n 1)
        item=${item//\'/\\\'\'}

        echo "echo 'update $ZPWR_SCHEMA_NAME.$ZPWR_TABLE_NAME set learning = ""''"$item"''"" where id=$id' | mysql"
    else
        #regex
        ids=$(echo "select id,learning from $ZPWR_SCHEMA_NAME.$ZPWR_TABLE_NAME order by dateAdded" | mysql | perl -lne 'do{$id=$1;$l=$2;print "$id $l" if $l =~ m{'$num'}i} if m{^(\d+)\s(.*)$}')
        for item in ${(f)ids[@]}; do
            id=${item%% *}
            learn=${item#* }
            learn=${learn//\'/\\\'\'}
            echo "echo 'update $ZPWR_SCHEMA_NAME.$ZPWR_TABLE_NAME set learning = ""''"$learn"''"" where id=$id' | mysql"
        done
    fi
}

function redosql(){

    local id item ids learn
    printf ""> "$ZPWR_TEMPFILE_SQL"
    if [[ -z "$1" ]]; then
            getLastItem

            echo "update $ZPWR_SCHEMA_NAME.$ZPWR_TABLE_NAME set learning = '$item' where id=$id" >> "$ZPWR_TEMPFILE_SQL"
    else
        for num in $@; do
            getItems
        done >> "$ZPWR_TEMPFILE_SQL"
    fi

    if [[ $ZPWR_USE_NEOVIM == true ]]; then
        nvim "$ZPWR_TEMPFILE_SQL"
        cat "$ZPWR_TEMPFILE_SQL" | mysql
        command rm "$ZPWR_TEMPFILE_SQL"
    else
        vim "$ZPWR_TEMPFILE_SQL"
        cat "$ZPWR_TEMPFILE_SQL" | mysql
        command rm "$ZPWR_TEMPFILE_SQL"
    fi
}

function redo(){
    
    local id item ids learn
    echo > "$ZPWR_TEMPFILE"
    if [[ -z "$1" ]]; then
            getLastItem

            echo "echo 'update $ZPWR_SCHEMA_NAME.$ZPWR_TABLE_NAME set learning = ""''"$item"''"" where id=$id' | mysql" >> "$ZPWR_TEMPFILE"
    else
        for num in $@; do
            getItems
        done >> "$ZPWR_TEMPFILE"
    fi

    print -rz "$(cat "$ZPWR_TEMPFILE")"
    command rm "$ZPWR_TEMPFILE"
}


zle -N learn
bindkey -M viins '^k' learn
bindkey -M vicmd '^k' learn
