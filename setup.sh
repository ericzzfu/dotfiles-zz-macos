#!/usr/bin/env bash
set -euo pipefail

# Require kitty
if [ "$TERM" != "xterm-kitty" ]; then
    echo "Error: This setup requires kitty terminal. Current TERM=$TERM"
    exit 1
fi

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Ensure config directories exist
mkdir -p "$HOME/.config/kitty"
mkdir -p "$HOME/.claude"

# source:target pairs
files="
zshrc:$HOME/.zshrc
tmux.conf:$HOME/.tmux.conf
kitty.conf:$HOME/.config/kitty/kitty.conf
statusline.sh:$HOME/.claude/statusline.sh
claude-settings.json:$HOME/.claude/settings.json
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

# Reload configs (failures are non-fatal)
set +e
kitty @ load-config 2>/dev/null && echo -e "${GREEN}Reloaded kitty config${NC}" || echo -e "${GREEN}Press Ctrl+Shift+F5 or restart kitty to apply kitty config${NC}"
tmux source-file "$HOME/.tmux.conf" 2>/dev/null && echo -e "${GREEN}Reloaded tmux config${NC}" || echo -e "${GREEN}No active tmux session — config will apply on next tmux start${NC}"

echo ""
echo -e "${GREEN}Done! Run 'source ~/.zshrc' or restart your shell to apply zsh changes.${NC}"
