# Dotfiles

Personal dotfiles for macOS with kitty, zsh, tmux, and Claude Code.

## Requirements

- macOS
- [kitty](https://sw.kovidgoyal.net/kitty/) terminal
- [oh-my-zsh](https://ohmyz.sh/)
- [tmux](https://github.com/tmux/tmux) (`brew install tmux`)

## Setup

```bash
git clone git@github.com:ericzzfu/dotfiles.git ~/repos/dotfiles
cd ~/repos/dotfiles && ./setup.sh
```

The setup script:
- Symlinks all config files to their expected locations
- Backs up any existing configs (to `.bak`)
- Auto-reloads kitty and tmux configs
- Requires kitty terminal (checks `$TERM`)

## What's Included

| File | Target | Description |
|---|---|---|
| `zshrc` | `~/.zshrc` | oh-my-zsh config with word/line jumping keybindings |
| `kitty.conf` | `~/.config/kitty/kitty.conf` | Copy-on-select, Cmd+Arrow line nav, tmux shortcut mappings |
| `tmux.conf` | `~/.tmux.conf` | Modern theme, mouse support, kitty-style shortcuts via user-keys |
| `statusline.sh` | `~/.claude/statusline.sh` | Claude Code status bar: model, context usage, git info |
| `claude-settings.json` | `~/.claude/settings.json` | Claude Code settings |

## Keyboard Shortcuts

### Shell (zsh)

| Shortcut | Action |
|---|---|
| Option+Left/Right | Jump between words |
| Cmd+Left/Right | Beginning/end of line |
| Ctrl+A / Ctrl+E | Beginning/end of line (works everywhere) |

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

## Claude Code

Status line shows: `Model [ctx: used/total (pct%)] repo:branch`

Context usage color: green (>75k free), yellow (<75k free), red (<50k free).
