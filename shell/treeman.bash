# treeman shell integration — source this from ~/.bashrc
# Provides the `tm` wrapper (for cd on switch) and bash completions.

tm() {
    if [[ "${1:-}" == "switch" || "${1:-}" == "s" ]]; then
        local target
        target="$(command treeman switch "${@:2}")" || return $?
        [[ -n "$target" ]] && builtin cd "$target"
    else
        command treeman "$@"
    fi
}

_tm_completions() {
    local cur prev words cword
    _init_completion 2>/dev/null || {
        cur="${COMP_WORDS[COMP_CWORD]:-}"
        prev="${COMP_WORDS[COMP_CWORD-1]:-}"
        cword="${COMP_CWORD:-0}"
    }

    if (( cword == 1 )); then
        COMPREPLY=( $(compgen -W "init clone add list remove switch ls rm a l s --help --version" -- "$cur") )
        return
    fi

    case "${COMP_WORDS[1]}" in
        switch|s|remove|rm)
            local names
            names="$(command treeman list --names-only 2>/dev/null)" || return
            COMPREPLY=( $(compgen -W "$names" -- "$cur") )
            ;;
        add|a)
            local branches
            branches="$(command treeman _complete-branches 2>/dev/null)" || return
            COMPREPLY=( $(compgen -W "$branches" -- "$cur") )
            ;;
    esac
}

complete -F _tm_completions tm
complete -F _tm_completions treeman
