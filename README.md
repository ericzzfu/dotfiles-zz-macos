# Dotfiles

Personal dotfiles for macOS with kitty, zsh, tmux, and Claude Code.

## Setup

### Fresh Mac (bootstrap)

Run the standalone bootstrap script — no git clone needed:

```bash
curl -fsSL https://raw.githubusercontent.com/ericzzfu/dotfiles/main/bootstrap.sh | bash
```

This creates `~/dotfiles/`, writes all config files, installs dependencies, and runs `setup.sh`.

### Existing clone

```bash
cd ~/repos/dotfiles && ./setup.sh
```

### Regenerating bootstrap

After modifying config files, regenerate the standalone script:

```bash
./generate-bootstrap.sh > bootstrap.sh
```

This happens automatically on `git commit` via a pre-commit hook.

### What setup.sh does

- Installs Homebrew if missing, then installs all dependencies
- Symlinks config files to their expected locations
- Copies configs that need path substitution (e.g., `claude-settings.json`)
- Backs up any existing configs (to `.bak`)
- Configures Maccy and Claude Usage Tracker preferences
- Auto-reloads kitty and tmux configs

## Dependencies

Installed automatically by `setup.sh` if missing:

| Tool | Type | Description |
|---|---|---|
| [kitty](https://sw.kovidgoyal.net/kitty/) | Terminal | GPU-accelerated terminal emulator |
| [tmux](https://github.com/tmux/tmux) | CLI | Terminal multiplexer |
| [gh](https://cli.github.com/) | CLI | GitHub CLI |
| [fzf](https://github.com/junegunn/fzf) | CLI | Fuzzy finder for history, files |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | Plugin | Fish-like command suggestions |
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | Plugin | Command syntax coloring |
| [Claude Code](https://claude.com/claude-code) | CLI | Anthropic's CLI for Claude |
| [Maccy](https://maccy.app/) | App | Clipboard manager |
| [Claude Usage Tracker](https://github.com/hamed-elfayome/Claude-Usage-Tracker) | App | Usage monitoring for Claude |

## What's Included

| File | Target | Description |
|---|---|---|
| `zshrc` | `~/.zshrc` | oh-my-zsh config with keybindings, fzf, autosuggestions, syntax highlighting |
| `kitty.conf` | `~/.config/kitty/kitty.conf` | Copy-on-select, Cmd+Arrow line nav, tmux shortcut mappings |
| `tmux.conf` | `~/.tmux.conf` | Tokyo Night theme, mouse support, kitty-style shortcuts via user-keys |
| `claude-settings.json` | `~/.claude/settings.json` | Claude Code settings |
| `statusline-config.txt` | `~/.claude/statusline-config.txt` | Claude Usage Tracker statusline preferences (copied, not symlinked) |

## Keyboard Shortcuts

### Shell (zsh)

| Shortcut | Action |
|---|---|
| Option+Left/Right | Jump between words |
| Cmd+Left/Right | Beginning/end of line |
| Ctrl+A / Ctrl+E | Beginning/end of line (works everywhere) |
| Ctrl+R | fzf history search |
| Ctrl+T | fzf file search |
| Right arrow | Accept autosuggestion |

### Kitty

| Shortcut | Action |
|---|---|
| Ctrl+Shift+F5 | Reload kitty config |
| Select text | Auto-copies to clipboard |
| Double-click | Select word |
| Triple-click | Select line |

Double-click treats `-`, `_`, `.` as part of a word (e.g., `source-file` selects whole thing).

### Tmux - Tabs (windows)

| Shortcut | Action |
|---|---|
| Opt+Shift+T | New tab |
| Opt+Shift+Left/Right | Switch tabs |
| Ctrl+Opt+Left/Right | Move tab left/right |

### Tmux - Panes (splits)

| Shortcut | Action |
|---|---|
| Opt+Shift+\\ | Split vertically |
| Opt+Shift+- | Split horizontally |
| Opt+Shift+[/] | Cursor to prev/next pane |
| Opt+Shift+,/. | Move pane left/right |
| Opt+Shift+S | Toggle pane zoom |
| Opt+Shift+L | Cycle pane layouts |
| Ctrl+Opt+Shift+Arrow | Resize pane |

### Tmux - Other

| Shortcut | Action |
|---|---|
| Ctrl+B | Tmux prefix |
| prefix + r | Reload tmux config |
| `tmux ls` | List sessions |
| `tmux a -t <name>` | Attach to session |
| `tmux new -s <name>` | New named session |

## App Preferences

### Maccy
- History size: 999
- Paste by default: on
- Popup shortcut: Opt+Cmd+C

### Claude Usage Tracker
Statusline configured via `statusline-config.txt` — shows model, directory, branch, context, usage, progress bar, pace marker, and reset time.
