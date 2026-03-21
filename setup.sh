#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Require kitty
if [ "$TERM" != "xterm-kitty" ]; then
    echo -e "${RED}Error: This setup requires kitty terminal. Current TERM=$TERM${NC}"
    exit 1
fi

# --- Check and install dependencies ---
echo "Checking dependencies..."

# Homebrew is required for everything
if ! command -v brew &>/dev/null; then
    echo -e "${RED}Error: Homebrew is required. Install from https://brew.sh${NC}"
    exit 1
fi

# Brew packages
brew_deps="fzf tmux"
for dep in $brew_deps; do
    if ! command -v "$dep" &>/dev/null; then
        echo -e "${YELLOW}Installing $dep...${NC}"
        brew install "$dep"
    else
        echo -e "${GREEN}$dep already installed${NC}"
    fi
done

# Brew packages (sourced, not commands)
brew_source_deps="zsh-autosuggestions zsh-syntax-highlighting"
for dep in $brew_source_deps; do
    if [ ! -d "$(brew --prefix)/share/$dep" ] 2>/dev/null; then
        echo -e "${YELLOW}Installing $dep...${NC}"
        brew install "$dep"
    else
        echo -e "${GREEN}$dep already installed${NC}"
    fi
done

# Claude Code
if ! command -v claude &>/dev/null; then
    echo -e "${YELLOW}Installing Claude Code...${NC}"
    brew install claude
else
    echo -e "${GREEN}Claude Code already installed${NC}"
fi

# Maccy
if [ ! -d "/Applications/Maccy.app" ] && ! brew list --cask maccy &>/dev/null 2>&1; then
    echo -e "${YELLOW}Installing Maccy...${NC}"
    brew install --cask maccy
else
    echo -e "${GREEN}Maccy already installed${NC}"
fi

# Claude Usage Tracker
if [ ! -d "/Applications/Claude Usage.app" ]; then
    echo -e "${YELLOW}Claude Usage Tracker not found.${NC}"
    echo -e "${YELLOW}Install from: https://github.com/hamed-elfayome/Claude-Usage-Tracker${NC}"
else
    echo -e "${GREEN}Claude Usage Tracker already installed${NC}"
fi

echo ""

# --- Symlink config files ---
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Ensure config directories exist
mkdir -p "$HOME/.config/kitty"
mkdir -p "$HOME/.claude"

# source:target pairs
files="
zshrc:$HOME/.zshrc
tmux.conf:$HOME/.tmux.conf
kitty.conf:$HOME/.config/kitty/kitty.conf
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

# --- Configure Claude Usage Tracker statusline ---
STATUSLINE_TARGET="$HOME/.claude/statusline-config.txt"
cp "$DOTFILES_DIR/statusline-config.txt" "$STATUSLINE_TARGET"
echo "PROFILE_NAME=\"$(whoami)\"" >> "$STATUSLINE_TARGET"
echo -e "${GREEN}Claude Usage Tracker statusline configured${NC}"

# --- Configure Maccy ---
echo "Configuring Maccy..."
defaults write org.p0deje.Maccy historySize -int 999
defaults write org.p0deje.Maccy pasteByDefault -bool true
defaults write org.p0deje.Maccy KeyboardShortcuts_popup -string '{"carbonKeyCode":8,"carbonModifiers":2304}'
echo -e "${GREEN}Maccy configured (history: 999, paste by default, Opt+Cmd+C)${NC}"

# Reload configs (failures are non-fatal)
set +e
kitty @ load-config 2>/dev/null && echo -e "${GREEN}Reloaded kitty config${NC}" || echo -e "${GREEN}Press Ctrl+Shift+F5 or restart kitty to apply kitty config${NC}"
tmux source-file "$HOME/.tmux.conf" 2>/dev/null && echo -e "${GREEN}Reloaded tmux config${NC}" || echo -e "${GREEN}No active tmux session — config will apply on next tmux start${NC}"

echo ""
echo -e "${GREEN}Done! Run 'source ~/.zshrc' or restart your shell to apply zsh changes.${NC}"
