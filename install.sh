#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Symlink binary
mkdir -p "$HOME/.local/bin"
ln -sf "$SCRIPT_DIR/bin/treeman" "$HOME/.local/bin/treeman"
echo "Linked treeman -> ~/.local/bin/treeman"

# Shell integration for bash
BASHRC="$HOME/.bashrc"
BASH_LINE="source \"$SCRIPT_DIR/shell/treeman.bash\""

if [[ -f "$BASHRC" ]]; then
    if ! grep -qF "treeman.bash" "$BASHRC" 2>/dev/null; then
        printf '\n# treeman shell integration\n%s\n' "$BASH_LINE" >> "$BASHRC"
        echo "Added shell integration to ~/.bashrc"
    else
        echo "Shell integration already in ~/.bashrc"
    fi
fi

# Shell integration for zsh
ZSHRC="$HOME/.zshrc"
ZSH_LINE="source \"$SCRIPT_DIR/shell/treeman.zsh\""

if [[ -f "$ZSHRC" ]]; then
    if ! grep -qF "treeman.zsh" "$ZSHRC" 2>/dev/null; then
        printf '\n# treeman shell integration\n%s\n' "$ZSH_LINE" >> "$ZSHRC"
        echo "Added shell integration to ~/.zshrc"
    else
        echo "Shell integration already in ~/.zshrc"
    fi
fi

echo "Done. Restart your shell or run: source ~/.bashrc (or ~/.zshrc)"
