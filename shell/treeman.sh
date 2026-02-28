# treeman shell integration — source from ~/.bashrc or ~/.zshrc
# Provides the `tm` wrapper for cd on switch.

tm() {
    if [[ $# -eq 0 ]]; then
        cat <<'EOF'
tm v0.1.0 — treeman shell wrapper

Usage:
  tm <command> [args]

Commands:
  switch [name]    Switch to worktree (fzf if no arg)
  s [name]        Alias for switch
  add [branch]    Add worktree (fzf if no arg)
  list            List worktrees
  remove [name]   Remove worktree (fzf if no arg)
  init <url>      Clone bare repo and set up treeman structure

Aliases:
  clone = init    a = add    ls, l = list    rm = remove    s = switch

Note: Use 'tm switch' or 'tm s' to actually cd into a worktree.
      Other commands pass through to treeman.
EOF
        return 0
    fi

    if [[ "${1:-}" == "switch" || "${1:-}" == "s" ]]; then
        local target
        target="$(command treeman switch "${@:2}")" || return $?
        [[ -n "$target" ]] && builtin cd "$target"
    else
        command treeman "$@"
    fi
}
