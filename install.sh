#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Symlink binary
mkdir -p "$HOME/.local/bin"
ln -sf "$SCRIPT_DIR/bin/treeman" "$HOME/.local/bin/treeman"
echo "Linked treeman -> ~/.local/bin/treeman"

# Add shell integration to .bashrc
SHELL_LINE="source \"$SCRIPT_DIR/shell/treeman.bash\""
BASHRC="$HOME/.bashrc"

if ! grep -qF "treeman.bash" "$BASHRC" 2>/dev/null; then
    printf '\n# treeman shell integration\n%s\n' "$SHELL_LINE" >> "$BASHRC"
    echo "Added shell integration to ~/.bashrc"
else
    echo "Shell integration already in ~/.bashrc"
fi

echo "Done. Restart your shell or run: source ~/.bashrc"
