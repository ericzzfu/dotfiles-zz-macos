#!/usr/bin/env bash
set -euo pipefail

# Require kitty
if [ "$TERM" != "xterm-kitty" ]; then
    echo "Error: This setup requires kitty terminal. Current TERM=$TERM"
    exit 1
fi

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Ensure kitty config directory exists
mkdir -p "$HOME/.config/kitty"

# source:target pairs
files="
zshrc:$HOME/.zshrc
tmux.conf:$HOME/.tmux.conf
kitty.conf:$HOME/.config/kitty/kitty.conf
"

for entry in $files; do
    src="${entry%%:*}"
    target="${entry#*:}"
    source_path="$DOTFILES_DIR/$src"

    # Back up existing file if it's not already a symlink to our dotfile
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo "Backing up $target -> ${target}.bak"
        mv "$target" "${target}.bak"
    elif [ -L "$target" ]; then
        echo "Removing old symlink $target"
        rm "$target"
    fi

    echo "Linking $source_path -> $target"
    ln -s "$source_path" "$target"
done

GREEN='\033[0;32m'
NC='\033[0m'
echo ""
echo -e "${GREEN}Done. Restart your shell or run: source ~/.zshrc${NC}"
echo -e "${GREEN}Reload kitty config with Ctrl+Shift+F5 or restart kitty.${NC}"
