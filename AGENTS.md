# AGENTS.md - Treeman Development Guide

Guidelines for agentic coding agents working on treeman, a bash-based git worktree manager.

## Project Structure

- `bin/treeman` - CLI entry point (439 lines)
- `shell/treeman.bash` - Shell wrapper for cd (66 lines)
- `install.sh` - Installation script
- `version.txt` - Version file

## Build/Lint/Test Commands

### Running

```bash
./bin/treeman <command>   # local
treeman <command>          # after install
```

### Testing

No automated test suite. Manual testing:

```bash
treeman init https://github.com/user/repo.git test-project
cd test-project/main
treeman list
treeman add feature-branch
treeman remove feature-branch
```

### Linting

```bash
bash -n bin/treeman    # syntax check
bash -n install.sh
```

### Release

```bash
git tag v0.x.x && git push origin v0.x.x
```

---

## Code Style Guidelines

### Shell Options

```bash
#!/usr/bin/env bash
set -euo pipefail
```

### Section Comments

```bash
# --- Colors ---
# --- Messaging ---
# --- Utility ---
# --- Commands ---
# --- Dispatch ---
```

### Function Naming

- Commands: `cmd_<name>` (e.g., `cmd_init`, `cmd_add`)
- Getters: `get_<name>` (e.g., `get_default_branch`)
- Runners: `run_<name>` (e.g., `run_post_create_scripts`)
- Requirements: `require_<name>` (e.g., `require_fzf`)

### Variables

Always use `local`. Use uppercase for globals: `SCRIPT_DIR`, `VERSION`.

### Error Handling

```bash
die()  { printf '%s\n' "${RED}error:${RESET} $*" >&2; exit 1; }
info() { printf '%s\n' "${GREEN}::${RESET} $*" >&2; }
warn() { printf '%s\n' "${YELLOW}warning:${RESET} $*" >&2; }
```

All go to **stderr**; stdout reserved for data.

### Conditionals

Use `[[ ]]`, not `[ ]`:

```bash
[[ -z "$branch" ]] && die "message"
[[ -d "$dir/.bare" ]]
[[ "$line" =~ ^worktree\ (.+) ]]
```

### Colors

```bash
setup_colors() {
    if [[ -n "${NO_COLOR:-}" ]] || [[ ! -t 2 ]]; then
        RED="" GREEN="" YELLOW="" BLUE="" CYAN="" BOLD="" DIM="" RESET=""
    else
        RED=$'\033[31m' GREEN=$'\033[32m' YELLOW=$'\033[33m'
        BLUE=$'\033[34m' CYAN=$'\033[36m' BOLD=$'\033[1m'
        DIM=$'\033[2m' RESET=$'\033[0m'
    fi
}
```

### Command Substitution

Use `$(...)`, not backticks. Use `local` for all variables.

### Argument Parsing

```bash
cmd_init() {
    local url="${1:-}"
    [[ -z "$url" ]] && die "usage: treeman init <url>"
}
```

With flags:

```bash
while [[ $# -gt 0 ]]; do
    case "$1" in
        -f|--force) force=true; shift ;;
        -h|--help) usage; exit 0 ;;
        *) name="$1"; shift ;;
    esac
done
```

### Traps

```bash
trap 'rm -rf "$abs_dir"' ERR
# ... operations ...
trap - ERR
```

### Interactive fzf

```bash
require_fzf
branch="$(printf '%s' "$candidates" \
    | fzf --height=50% --border --layout=reverse --pointer='▸' \
        --prompt="branch> " --header="Select branch" --margin=10% \
    2>/dev/tty)" || true
[[ -z "$branch" ]] && die "no branch selected"
```

---

## Common Patterns

### Find Project Root

```bash
find_project_root() {
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        [[ -d "$dir/.bare" ]] && { printf '%s' "$dir"; return 0; }
        dir="$(dirname "$dir")"
    done
    die "not inside a treeman project"
}
```

### Parse Git Porcelain

```bash
porcelain="$(git -C "$root/.bare" worktree list --porcelain)"
porcelain+=$'\n\n'
while IFS= read -r line; do
    [[ "$line" =~ ^worktree\ (.+) ]] && wt_path="${BASH_REMATCH[1]}"
    [[ "$line" =~ ^branch\ refs/heads/(.+) ]] && wt_branch="${BASH_REMATCH[1]}"
    [[ -z "$line" && -n "$wt_path" ]] && { /* process */ wt_path=""; }
done <<< "$porcelain"
```

### Shell Wrapper for cd

```bash
tm() {
    if [[ "${1:-}" == "switch" || "${1:-}" == "s" ]]; then
        local target
        target="$(command treeman switch "${@:2}")" || return $?
        [[ -n "$target" ]] && builtin cd "$target"
    else
        command treeman "$@"
    fi
}
```

---

## Contributing

1. Test all commands manually
2. Verify with `bash -n`
3. Ensure colors work with/without `NO_COLOR`
4. Test fzf flow or graceful fallback
5. Preserve stdout/stderr separation
