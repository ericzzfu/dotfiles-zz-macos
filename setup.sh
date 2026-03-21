#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
CHECK='\xE2\x9C\x93'

# --- Check and install dependencies ---
echo "Checking dependencies..."

# Homebrew
if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo -e " $CHECK Homebrew"
fi

# Kitty must be installed and used as the terminal
if ! command -v kitty &>/dev/null && [ ! -d "/Applications/kitty.app" ]; then
    echo "Installing kitty..."
    brew install --cask kitty
    echo -e "${GREEN}kitty installed. Please open kitty and rerun this script.${NC}"
    exit 0
fi
if [ "$TERM" != "xterm-kitty" ]; then
    echo -e "${RED}Please run this script from kitty terminal. Current TERM=$TERM${NC}"
    exit 1
fi

# Brew packages
brew_deps="fzf tmux gh"
for dep in $brew_deps; do
    if ! command -v "$dep" &>/dev/null; then
        echo "Installing $dep..."
        brew install "$dep"
    else
        echo -e " $CHECK $dep"
    fi
done

# Check gh auth
if ! gh auth status &>/dev/null; then
    echo -e "${YELLOW}gh is not logged in. Run 'gh auth login' to authenticate.${NC}"
fi

# Brew packages (sourced, not commands)
brew_source_deps="zsh-autosuggestions zsh-syntax-highlighting"
for dep in $brew_source_deps; do
    if [ ! -d "$(brew --prefix)/share/$dep" ] 2>/dev/null; then
        echo "Installing $dep..."
        brew install "$dep"
    else
        echo -e " $CHECK $dep"
    fi
done

# Claude Code
if ! command -v claude &>/dev/null; then
    echo "Installing Claude Code..."
    brew install claude
else
    echo -e " $CHECK Claude Code"
fi

# Maccy
if [ ! -d "/Applications/Maccy.app" ] && ! brew list --cask maccy &>/dev/null 2>&1; then
    echo "Installing Maccy..."
    brew install --cask maccy
else
    echo -e " $CHECK Maccy"
fi

# Claude Usage Tracker
if [ ! -d "/Applications/Claude Usage.app" ]; then
    echo "Installing Claude Usage Tracker..."
    brew install --cask hamed-elfayome/claude-usage/claude-usage-tracker
else
    echo -e " $CHECK Claude Usage Tracker"
fi

# Check if API keys are configured (profiles_v3 is binary data, check if it exists and has content)
profiles_len=$(defaults export HamedElfayome.Claude-Usage - 2>/dev/null | plutil -convert xml1 -o - - 2>/dev/null | grep -c "profiles_v3" || true)
if [ "$profiles_len" -eq 0 ]; then
    echo -e "${RED}Claude Usage Tracker is not configured.${NC}"
    echo -e "${RED}Open the app, sign in with your API keys, then rerun this script.${NC}"
    exit 0
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
        rm "$target"
    fi

    ln -s "$source_path" "$target"
done
echo -e " $CHECK Config files symlinked"

# --- Configure Claude Usage Tracker statusline ---
STATUSLINE_TARGET="$HOME/.claude/statusline-config.txt"
cp "$DOTFILES_DIR/statusline-config.txt" "$STATUSLINE_TARGET"
echo "PROFILE_NAME=\"$(whoami)\"" >> "$STATUSLINE_TARGET"
echo -e " $CHECK Claude Usage Tracker statusline configured"

# --- Configure Maccy ---
defaults write org.p0deje.Maccy historySize -int 999
defaults write org.p0deje.Maccy pasteByDefault -bool true
defaults write org.p0deje.Maccy KeyboardShortcuts_popup -string '{"carbonKeyCode":8,"carbonModifiers":2304}'
echo -e " $CHECK Maccy configured"

# Reload configs (failures are non-fatal)
set +e
kitty @ load-config 2>/dev/null && echo -e " $CHECK Kitty config reloaded" || echo -e "${GREEN}Press Ctrl+Shift+F5 or restart kitty to apply kitty config${NC}"
tmux source-file "$HOME/.tmux.conf" 2>/dev/null && echo -e " $CHECK Tmux config reloaded" || true

echo ""
echo -e "${GREEN} $CHECK Done! Run 'source ~/.zshrc' or restart your shell to apply zsh changes.${NC}"
