#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"

if [ -d "$DOTFILES_DIR" ]; then
    echo "Error: $DOTFILES_DIR already exists. Remove it first or use setup.sh directly."
    exit 1
fi

mkdir -p "$DOTFILES_DIR"
echo "Creating dotfiles in $DOTFILES_DIR..."

cat > "$DOTFILES_DIR/setup.sh" <<'__EOF__'
#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
YELLOW='\033[0;33m'
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

# source:target pairs (symlinked)
files="
zshrc:$HOME/.zshrc
tmux.conf:$HOME/.tmux.conf
kitty.conf:$HOME/.config/kitty/kitty.conf
"

for entry in $files; do
    src="${entry%%:*}"
    target="${entry#*:}"
    source_path="$DOTFILES_DIR/$src"

    if [ -e "$target" ] && [ ! -L "$target" ]; then
        mv "$target" "${target}.bak"
    elif [ -L "$target" ]; then
        rm "$target"
    fi

    ln -s "$source_path" "$target"
done

# Claude settings (copied with HOME path substituted)
CLAUDE_SETTINGS="$HOME/.claude/settings.json"
[ -e "$CLAUDE_SETTINGS" ] && [ ! -L "$CLAUDE_SETTINGS" ] && mv "$CLAUDE_SETTINGS" "${CLAUDE_SETTINGS}.bak"
[ -L "$CLAUDE_SETTINGS" ] && rm "$CLAUDE_SETTINGS"
sed "s|__HOME__|$HOME|g" "$DOTFILES_DIR/claude-settings.json" > "$CLAUDE_SETTINGS"

echo -e " $CHECK Config files installed"

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
echo "Symlinked:"
echo "  $DOTFILES_DIR/zshrc -> ~/.zshrc"
echo "  $DOTFILES_DIR/tmux.conf -> ~/.tmux.conf"
echo "  $DOTFILES_DIR/kitty.conf -> ~/.config/kitty/kitty.conf"
echo "Copied:"
echo "  $DOTFILES_DIR/claude-settings.json -> ~/.claude/settings.json"
echo "  $DOTFILES_DIR/statusline-config.txt -> ~/.claude/statusline-config.txt"
echo ""
echo -e "${GREEN} $CHECK Done! Run 'source ~/.zshrc' or restart your shell to apply zsh changes.${NC}"


__EOF__

cat > "$DOTFILES_DIR/zshrc" <<'__EOF__'
# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(git)

source $ZSH/oh-my-zsh.sh

# --- User configuration ---

export PATH="$HOME/.local/bin:$PATH"

# Option+Left/Right to jump between words (kitty)
bindkey "\e[1;3D" backward-word     # Option+Left
bindkey "\e[1;3C" forward-word      # Option+Right

# Cmd+Left/Right handled by kitty.conf sending Ctrl-A/Ctrl-E directly

# fzf integration (Ctrl+R history search, Ctrl+T file search, Alt+C cd)
source <(fzf --zsh)

# Autosuggestions (accept with Right arrow)
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Syntax highlighting (must be last)
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

__EOF__

cat > "$DOTFILES_DIR/tmux.conf" <<'__EOF__'
# Prefix: Ctrl-b (default)

# Enable mouse support (scroll, select panes, resize)
set -g mouse on

# Copy-on-select handled by kitty (copy_on_select clipboard)

# Word separators: removed - _ . / so double-click selects paths/identifiers
set -g word-separators "!\"#$%&'()*+,:;<=>?@[\\]^`{|}~"

# Use vi-style keys in copy mode
setw -g mode-keys vi

# Start window/pane numbering at 1
set -g base-index 1
setw -g pane-base-index 1

# Reload config
bind r source-file ~/.tmux.conf \; display "Config reloaded"

# --- Modern theme ---

# True color support
set -g default-terminal "tmux-256color"
set -ag terminal-overrides ",xterm-kitty:RGB"

# Pane borders
set -g pane-border-style "fg=#3b4261"
set -g pane-active-border-style "fg=#7aa2f7"

# Status bar
set -g status-position top
set -g status-style "bg=#1a1b26,fg=#a9b1d6"
set -g status-left-length 40
set -g status-right-length 80
set -g status-left "#[fg=#1a1b26,bg=#7aa2f7,bold] #S #[fg=#7aa2f7,bg=#1a1b26] "
set -g status-right "#[fg=#3b4261]#[fg=#a9b1d6,bg=#3b4261] %H:%M #[fg=#7aa2f7,bg=#3b4261]#[fg=#1a1b26,bg=#7aa2f7,bold] %b %d "

# Window tabs
set -g window-status-format "#[fg=#3b4261,bg=#1a1b26]#[fg=#545c7e,bg=#3b4261] #I: #W #[fg=#3b4261,bg=#1a1b26]"
set -g window-status-current-format "#[fg=#7aa2f7,bg=#1a1b26]#[fg=#1a1b26,bg=#7aa2f7,bold] #I: #W #[fg=#7aa2f7,bg=#1a1b26]"
set -g window-status-separator " "

# Message style
set -g message-style "fg=#7aa2f7,bg=#1a1b26,bold"
set -g message-command-style "fg=#a9b1d6,bg=#1a1b26"

# Copy mode highlight
setw -g mode-style "fg=#1a1b26,bg=#7aa2f7"

# --- Kitty-style shortcuts via user-keys ---
# These map to escape sequences sent by kitty.conf

# Register user-keys (escape sequences from kitty)
set -s user-keys[0]  "\e[300~"   # opt+shift+t
set -s user-keys[1]  "\e[301~"   # opt+shift+backslash
set -s user-keys[2]  "\e[302~"   # opt+shift+-
set -s user-keys[3]  "\e[303~"   # opt+shift+left
set -s user-keys[4]  "\e[304~"   # opt+shift+right
set -s user-keys[5]  "\e[305~"   # opt+shift+s
set -s user-keys[6]  "\e[306~"   # opt+shift+l
set -s user-keys[7]  "\e[307~"   # opt+shift+,
set -s user-keys[8]  "\e[308~"   # opt+shift+.
set -s user-keys[9]  "\e[309~"   # opt+shift+[
set -s user-keys[10] "\e[310~"   # opt+shift+]
set -s user-keys[11] "\e[311~"   # ctrl+opt+shift+up
set -s user-keys[12] "\e[312~"   # ctrl+opt+shift+down
set -s user-keys[13] "\e[313~"   # ctrl+opt+shift+left
set -s user-keys[14] "\e[314~"   # ctrl+opt+shift+right
set -s user-keys[15] "\e[315~"   # ctrl+opt+left
set -s user-keys[16] "\e[316~"   # ctrl+opt+right

# Bind user-keys to actions (prefix-free with -n)
bind -n User0  new-window -c "#{pane_current_path}"           # new tab
bind -n User1  split-window -h -c "#{pane_current_path}"      # split vertical
bind -n User2  split-window -v -c "#{pane_current_path}"      # split horizontal
bind -n User3  previous-window                                 # left tab
bind -n User4  next-window                                     # right tab
bind -n User5  resize-pane -Z                                  # toggle pane zoom
bind -n User6  next-layout                                     # cycle layouts
bind -n User7  swap-pane -U                                    # move pane left
bind -n User8  swap-pane -D                                    # move pane right
bind -n User9  select-pane -t :.-                              # cursor to prev pane
bind -n User10 select-pane -t :.+                              # cursor to next pane
bind -n User11 resize-pane -U 2                                # resize up
bind -n User12 resize-pane -D 2                                # resize down
bind -n User13 resize-pane -L 2                                # resize left
bind -n User14 resize-pane -R 2                                # resize right
bind -n User15 swap-window -d -t -1                            # move tab left
bind -n User16 swap-window -d -t +1                            # move tab right

__EOF__

cat > "$DOTFILES_DIR/kitty.conf" <<'__EOF__'
# Allow remote control (needed for kitty @ load-config)
allow_remote_control yes

# Cmd+Left/Right: send Ctrl-A / Ctrl-E for beginning/end of line
map cmd+left  send_text all \x01
map cmd+right send_text all \x05

# Option+Left/Right: send standard Alt+Arrow for word jumping
map opt+left  send_text all \x1b[1;3D
map opt+right send_text all \x1b[1;3C

# Copy on select
copy_on_select clipboard

# --- Tmux shortcuts (Option+Shift = tab/pane management) ---
# Each combo sends a unique escape sequence that tmux binds via user-keys

# Option+Shift+T: new tab
map opt+shift+t send_text all \x1b[300~
# Option+Shift+\: split vertically
map opt+shift+backslash send_text all \x1b[301~
# Option+Shift+-: split horizontally
map opt+shift+minus send_text all \x1b[302~
# Option+Shift+Left: switch to left tab
map opt+shift+left send_text all \x1b[303~
# Option+Shift+Right: switch to right tab
map opt+shift+right send_text all \x1b[304~
# Option+Shift+S: toggle pane zoom
map opt+shift+s send_text all \x1b[305~
# Option+Shift+L: cycle pane layouts
map opt+shift+l send_text all \x1b[306~
# Option+Shift+,: move pane left
map opt+shift+, send_text all \x1b[307~
# Option+Shift+.: move pane right
map opt+shift+. send_text all \x1b[308~
# Option+Shift+[: cursor to prev pane
map opt+shift+[ send_text all \x1b[309~
# Option+Shift+]: cursor to next pane
map opt+shift+] send_text all \x1b[310~
# Ctrl+Option+Shift+Arrow: resize pane
map ctrl+opt+shift+up    send_text all \x1b[311~
map ctrl+opt+shift+down  send_text all \x1b[312~
map ctrl+opt+shift+left  send_text all \x1b[313~
map ctrl+opt+shift+right send_text all \x1b[314~
# Ctrl+Option+Left: move tab left
map ctrl+opt+left send_text all \x1b[315~
# Ctrl+Option+Right: move tab right
map ctrl+opt+right send_text all \x1b[316~

__EOF__

cat > "$DOTFILES_DIR/claude-settings.json" <<'__EOF__'
{
  "statusLine" : {
    "type" : "command",
    "command" : "bash __HOME__/.claude/statusline-command.sh"
  },
  "extraKnownMarketplaces" : {
    "claude-plugins-official" : {
      "source" : {
        "repo" : "anthropics\/claude-plugins-official",
        "source" : "github"
      }
    }
  }
}
__EOF__

cat > "$DOTFILES_DIR/statusline-config.txt" <<'__EOF__'
SHOW_MODEL=1
SHOW_DIRECTORY=1
SHOW_BRANCH=1
SHOW_CONTEXT=1
CONTEXT_AS_TOKENS=1
SHOW_USAGE=1
SHOW_PROGRESS_BAR=1
SHOW_PACE_MARKER=1
PACE_MARKER_STEP_COLORS=0
SHOW_RESET_TIME=1
USE_24_HOUR_TIME=0
SHOW_CONTEXT_LABEL=1
SHOW_USAGE_LABEL=1
SHOW_RESET_LABEL=1
COLOR_MODE=colored
SINGLE_COLOR=#00BFFF
SHOW_PROFILE=0

__EOF__

chmod +x "$DOTFILES_DIR/setup.sh"
echo "Running setup.sh..."
echo ""
cd "$DOTFILES_DIR" && ./setup.sh
