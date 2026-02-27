# treeman

A git worktree manager that keeps everything in one folder.

Treeman wraps `git worktree` using the **bare repo strategy** — instead of scattering worktrees across your filesystem, all branches live as sibling directories inside a single project folder. It adds interactive branch selection via fzf and post-create script support.

## Why

The default `git worktree add` experience has friction:

- **Scattered directories** — worktrees end up as siblings of your project (`../feature-x`), cluttering your workspace
- **No setup hooks** — after creating a worktree you manually run `npm install`, copy `.env` files, etc.
- **Path memorization** — switching between worktrees means remembering or typing full paths

Treeman solves this with a bare repo layout where every worktree is a named directory inside one project folder:

```
my-project/
├── .bare/              # Bare git repository
├── .git                # Pointer file: "gitdir: ./.bare"
├── .treeman            # Post-create script config
├── main/               # Default branch worktree
├── feature-x/          # Feature worktree
└── phase-4/main/       # Worktree from branch with slash
```

## Requirements

- **git** (any recent version)
- **bash** (4.0+)
- **[fzf](https://github.com/junegunn/fzf)** — for interactive branch/worktree selection

## Install

```bash
git clone https://github.com/dharmadev/treeman.git
cd treeman
./install.sh
```

This does two things:

1. Symlinks `bin/treeman` to `~/.local/bin/treeman`
2. Adds `source .../shell/treeman.bash` to your `~/.bashrc`

Then restart your shell or run `source ~/.bashrc`.

Make sure `~/.local/bin` is in your `PATH`.

## Quick Start

```bash
# Clone a repo into the treeman layout
treeman init https://github.com/you/your-project.git
cd your-project/main

# List worktrees
treeman list
#   * main                 main [clean]

# Add a worktree for an existing remote branch
treeman add feature-x

# Add a worktree for a new branch (branched from default branch)
treeman add my-new-feature

# List again
treeman list
#   * main                 main [clean]
#     feature-x            feature-x [clean]
#     my-new-feature       my-new-feature [clean]
#     phase-4/main         phase-4/main [clean]

# Add a worktree from a branch with a slash
treeman add phase-4/main

# Switch to a worktree (use the tm shell wrapper)
tm switch feature-x

# Interactive selection — omit the name to get an fzf picker
tm s

# Remove a worktree
treeman remove my-new-feature
```

## Commands

| Command | Alias | Description |
|---------|-------|-------------|
| `treeman init <url> [name]` | `clone` | Clone bare repo and set up treeman structure |
| `treeman add [branch]` | `a` | Add worktree (fzf if no arg) |
| `treeman list` | `ls`, `l` | List worktrees with status |
| `treeman remove [name]` | `rm` | Remove worktree (fzf if no arg) |
| `tm switch [name]` | `tm s` | Switch to worktree (fzf if no arg) |

### `init` / `clone`

```
treeman init <url> [dirname]
```

Clones a repository as a bare repo and sets up the treeman structure. The directory name defaults to the repo name (stripped of `.git`).

What it creates:
- `.bare/` — the bare git repository
- `.git` — a pointer file (`gitdir: ./.bare`) so tools recognize the project
- `<default-branch>/` — a worktree for the default branch (auto-detected, usually `main` or `master`)
- `.treeman` — a template config file for post-create scripts

The default branch name is cached in `.bare/treeman-default-branch` to avoid network calls later.

### `add` / `a`

```
treeman add [branch]
```

**With a branch name:**
- If the branch exists on the remote, it checks it out as a worktree
- If the branch doesn't exist, it creates a new branch from `origin/<default-branch>`

**Without arguments (interactive):**
- Fetches remote branches (`git fetch --prune`)
- Opens an fzf picker showing remote branches not already checked out
- Type a name that doesn't match any branch to create a new one

After creating the worktree, any commands in `.treeman` are executed inside it (see [Post-Create Scripts](#post-create-scripts)).

### `list` / `ls` / `l`

```
treeman list
```

Shows all worktrees with:
- `*` marker for the current worktree
- Branch name
- `[dirty]` or `[clean]` status (uncommitted changes + untracked files)
- Ahead/behind upstream count (e.g. `+2`, `-1`, `+3/-1`)

Example output:

```
  * main                 main [clean]
    phase-4/main         phase-4/main [clean]
    feature-x            feature-x [dirty] +2
    hotfix               hotfix [clean] -1
```

Use `treeman list --names-only` to get just the worktree names (one per line), useful for scripting.

### `remove` / `rm`

```
treeman remove [name] [-f|--force]
```

**Without a name:** opens an fzf picker (excludes the current worktree).

Safety checks:
- Refuses to remove a dirty worktree unless `-f`/`--force` is passed
- Warns if you're currently inside the worktree being removed

### `switch` / `s`

```
tm switch [name]
```

**Without a name:** opens an fzf picker.

**Important:** You **must** use the `tm` shell wrapper — not `treeman switch` directly. A subprocess cannot change the parent shell's directory, so `treeman switch` only prints the path. The `tm` wrapper captures it and runs `cd`. See [Shell Integration](#shell-integration).

## Shell Integration

The install script sources `shell/treeman.bash` in your `.bashrc`, which provides:

### The `tm` wrapper

```bash
tm switch main     # actually cd's to the main worktree
tm s               # interactive picker, then cd's
tm list            # same as treeman list (passes through)
tm add feature     # same as treeman add feature (passes through)
tm                 # shows tm help
```

The `tm` function intercepts `switch` and `s` to capture the path and `cd` into it. All other commands are passed directly to `treeman`.

**Note:** Running `tm` with no arguments shows help. Use `tm switch` (or `tm s`) to switch worktrees — running `treeman switch` directly will not change your directory.

### Tab completion

Both `tm` and `treeman` have bash completions:

- **Position 1:** subcommands (`init`, `add`, `list`, `remove`, `switch`, and their aliases)
- **`switch`/`remove`:** completes worktree names
- **`add`:** completes remote branch names

## Post-Create Scripts

The `.treeman` file at the project root contains commands that run inside every new worktree after creation. Each non-empty, non-comment line is executed as a shell command.

```
# Post-create scripts (run in new worktree directory)
pnpm install
cp ../.dev.vars .
cp -r ../.wrangler .
```

Lines starting with `#` are comments. The file is created with all examples commented out during `treeman init`.

Typical uses:
- Install dependencies (`npm install`, `pnpm install`, `pip install -r requirements.txt`)
- Copy environment files (`cp ../.env .`, `cp ../.dev.vars .`)
- Copy local tool state (`cp -r ../.wrangler .`)

## Environment

- **`NO_COLOR`** — set this env var to disable colored output ([no-color.org](https://no-color.org))
- Non-TTY stderr automatically disables colors (e.g. when piping)
- All informational messages go to **stderr**, so stdout stays clean for scripting (important for `switch`)
