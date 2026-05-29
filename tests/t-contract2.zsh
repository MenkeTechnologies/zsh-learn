#!/usr/bin/env zunit
#{{{                    MARK:Header
##### Purpose: zsh-learn — second-tier contract pins covering the
#####          widget registration, multi-keymap bindkey wiring,
#####          ZPWR_VERBS dictionary population, and fpath wiring
#####          surfaces that t-unit.zsh does not yet cover.
#}}}***********************************************************

@setup {
    0="${${0:#$ZSH_ARGZERO}:-${(%):-%N}}"
    0="${${(M)0:#/*}:-$PWD/$0}"
    pluginDir="${0:h:A}"
    pluginFile="$pluginDir/zsh-learn.plugin.zsh"
}

@test 'zle -N zsh-learn-Learn is bound under ZPWR_LEARN!=false (widget contract)' {
    # Pin: zsh-learn-Learn is registered as a ZLE widget under the
    # ZPWR_LEARN guard. Removing zle -N silently kills the C-k binding.
    grep -qE '^[[:space:]]*zle -N zsh-learn-Learn' "$pluginFile"
    assert $? equals 0
}

@test 'bindkey wires C-k on all three editor keymaps (viins, vicmd, emacs)' {
    # Pin: zsh-learn binds C-k on viins, vicmd, AND emacs so the user's
    # muscle memory works regardless of which keymap is active. Dropping
    # one keymap means the user hits C-k and it silently fails in that
    # mode.
    local viins vicmd emacs
    viins=$(grep -c "bindkey -M viins '^k'" "$pluginFile")
    vicmd=$(grep -c "bindkey -M vicmd '^k'" "$pluginFile")
    emacs=$(grep -c "bindkey -M emacs '^k'" "$pluginFile")
    assert "$viins" same_as '1'
    assert "$vicmd" same_as '1'
    assert "$emacs" same_as '1'
}

@test 'ZPWR_LEARN=false skips zle/bindkey AND fpath augmentation (full opt-out)' {
    # Pin: the user explicitly opting out via ZPWR_LEARN=false must
    # silence ALL side effects — no widget, no key binding, no fpath
    # mutation. A partial opt-out (e.g. fpath still grows) is a leak.
    local out
    out=$(ZPWR_LEARN=false zsh -c "
        emulate zsh
        autoload zsh-learn-Learn 2>/dev/null
        before=\$#fpath
        source '$pluginFile' 2>/dev/null
        after=\$#fpath
        if zle -l zsh-learn-Learn 2>/dev/null; then print 'WIDGET-LEAK'
        elif (( after > before )); then print 'FPATH-LEAK'
        else print 'CLEAN'
        fi
    ")
    assert "$out" same_as 'CLEAN'
}

@test 'ZPWR_VERBS population is guarded by (( ${+ZPWR_VERBS} )) (caller-opt-in)' {
    # Pin: ZPWR_VERBS is a zpwr-the-shell-helper-suite construct. zsh-learn
    # only populates it when the caller has already declared it. Dropping
    # the guard would create the variable on every shell start, polluting
    # environments where zpwr isn't loaded.
    grep -qE '^if \(\( \$\{\+ZPWR_VERBS\}' "$pluginFile"
    assert $? equals 0
}

@test 'ZPWR_VERBS is populated when caller pre-declares it' {
    # End-to-end: pre-declare ZPWR_VERBS, source the plugin, verify a
    # representative key (qu = quiz from collection) is present.
    local out
    out=$(zsh -c "
        emulate zsh
        typeset -gA ZPWR_VERBS
        source '$pluginFile' 2>/dev/null
        print \"\${ZPWR_VERBS[qu]}\"
    ")
    assert "$out" contains 'quiz'
}

@test 'autoload directive uses (.:t) tail-only modifier (autoload contract)' {
    # Pin: the autoload line iterates autoload/* and strips the dir
    # via (.:t) — feeding bare names to autoload -Uz. Dropping :t would
    # feed full paths, which autoload accepts but is non-idiomatic AND
    # complicates fpath relocation. Pin the canonical pattern.
    grep -qE "autoload -Uz \"\\\$\{0:h\}/autoload/\"\\*\(\\.:t\)" "$pluginFile"
    assert $? equals 0
}
