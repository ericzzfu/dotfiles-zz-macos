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
