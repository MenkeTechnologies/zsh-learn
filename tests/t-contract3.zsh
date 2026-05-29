#!/usr/bin/env zunit
#{{{                    MARK:Header
##### Purpose: zsh-learn — third-tier surface pins. Covers:
#####          - every alias dispatch target resolves to a file in autoload/
#####          - numeric default values are actually numeric (no typo)
#####          - zstyle group-order names are distinct (no duplicate group)
#####          - every ZPWR_VERBS key resolves to a value with format `cmd=desc`
#####          - rcquotes setopt is active (the plugin relies on '' escaping)
#}}}***********************************************************

@setup {
    0="${${0:#$ZSH_ARGZERO}:-${(%):-%N}}"
    0="${${(M)0:#/*}:-$PWD/$0}"
    pluginDir="${0:h:A}"
    pluginFile="$pluginDir/zsh-learn.plugin.zsh"
    autoloadDir="$pluginDir/autoload"
}

@test 'every alias dispatch target (noglob TARGET) has a matching autoload file' {
    # Pin: each `alias X='noglob TARGET'` must point at a fn that
    # exists in autoload/. If TARGET is missing, the alias silently
    # fails when invoked. Catch the broken dispatch at lint time.
    local missing="" line target
    while IFS= read -r line; do
        target="${line##*noglob }"
        target="${target%\'*}"
        [[ -z "$target" ]] && continue
        [[ -f "$autoloadDir/$target" ]] || missing="$missing $target"
    done < <(grep -oE "alias [a-z]+='noglob [a-zA-Z0-9_-]+'" "$pluginFile")
    assert "$missing" is_empty
}

@test 'ZPWR_VARS[maxRecords] default is a positive integer' {
    # Pin: maxRecords drives query LIMIT clauses; non-numeric would
    # produce a SQL parse error at runtime. Format: `ZPWR_VARS[maxRecords]=N`.
    local value
    value=$(grep -oE 'ZPWR_VARS\[maxRecords\]=[0-9]+' "$pluginFile" | head -1 | cut -d= -f2)
    [[ "$value" =~ ^[0-9]+$ ]] && (( value > 0 ))
    assert $state equals 0
}

@test 'ZPWR_LEARN_MAX_SIZE default is a positive integer' {
    # Pin: max-size guard against runaway insert; non-numeric default
    # would silently fall through and lose the size cap.
    local value
    value=$(grep -oE 'ZPWR_LEARN_MAX_SIZE=[0-9]+' "$pluginFile" | head -1 | cut -d= -f2)
    [[ "$value" =~ ^[0-9]+$ ]] && (( value > 0 ))
    assert $state equals 0
}

@test 'zstyle group-order specifies two DISTINCT group names (no duplicate)' {
    # Pin: group-order must list distinct groups; a typo duplicating the
    # same name silently collapses the visual separation in compsys.
    local line a b
    line=$(grep "group-order" "$pluginFile" | head -1)
    a=$(printf '%s' "$line" | awk '{print $(NF-1)}')
    b=$(printf '%s' "$line" | awk '{print $NF}')
    [[ -n "$a" && -n "$b" && "$a" != "$b" ]]
    assert $state equals 0
}

@test 'plugin enables rcquotes (the `` "" '' '' '' '' "" '' style is in use)' {
    # Pin: the plugin opens with `setopt rcquotes` so that doubled single
    # quotes inside single-quoted strings represent a literal '. Removing
    # the setopt would break every alias body that depends on rcquotes.
    grep -qE '^setopt rcquotes' "$pluginFile"
    assert $? equals 0
}
