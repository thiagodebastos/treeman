# zsh completions for treeman — source from ~/.zshrc

# Load shared wrapper
_source_dir="${${(%):-%x}:a:h}"
# shellcheck source=/dev/null
source "${_source_dir}/treeman.sh"

_tm_completions() {
    local -a commands worktrees branches

    commands=(
        'init:Clone bare repo and set up treeman structure'
        'clone:Alias for init'
        'add:Add worktree (fzf if no arg)'
        'a:Alias for add'
        'list:List worktrees'
        'ls:Alias for list'
        'l:Alias for list'
        'remove:Remove worktree (fzf if no arg)'
        'rm:Alias for remove'
        'switch:Switch to worktree (fzf if no arg)'
        's:Alias for switch'
        '--help:Show help'
        '--version:Show version'
    )

    if (( CURRENT == 1 )); then
        _describe 'command' commands
        return
    fi

    case "${words[1]}" in
        switch|s|remove|rm)
            worktrees=( ${(f)"$(command treeman list --names-only 2>/dev/null)"} )
            [[ ${#worktrees} -gt 0 ]] && _describe 'worktree' worktrees
            ;;
        add|a)
            branches=( ${(f)"$(command treeman _complete-branches 2>/dev/null)"} )
            [[ ${#branches} -gt 0 ]] && _describe 'branch' branches
            ;;
    esac
}

compdef _tm_completions tm
compdef _tm_completions treeman
