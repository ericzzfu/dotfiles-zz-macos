# Dotfiles Cheat Sheet

## Setup

```bash
cd ~/repos/dotfiles && ./setup.sh
```

Requires kitty terminal. Creates symlinks for zshrc, tmux.conf, kitty.conf, and Claude Code configs.

## Shell (zsh)

| Shortcut | Action |
|---|---|
| Option+Left/Right | Jump between words |
| Cmd+Left/Right | Beginning/end of line |
| Ctrl+A / Ctrl+E | Beginning/end of line (works everywhere) |

## Kitty

| Shortcut | Action |
|---|---|
| Ctrl+Shift+F5 | Reload kitty config |
| Select text | Auto-copies to clipboard |
| Double-click | Select word (respects custom word separators) |
| Triple-click | Select line |

Custom word separators: `-`, `_`, `.` are treated as part of a word (e.g., double-clicking `source-file` selects the whole thing).

## Tmux

### Tabs (windows)

| Shortcut | Action |
|---|---|
| Opt+Shift+T | New tab |
| Opt+Shift+Left | Previous tab |
| Opt+Shift+Right | Next tab |
| Ctrl+Opt+Left | Move tab left |
| Ctrl+Opt+Right | Move tab right |

### Panes (splits)

| Shortcut | Action |
|---|---|
| Opt+Shift+\\ | Split vertically |
| Opt+Shift+- | Split horizontally |
| Opt+Shift+[ | Cursor to previous pane |
| Opt+Shift+] | Cursor to next pane |
| Opt+Shift+, | Move pane left |
| Opt+Shift+. | Move pane right |
| Opt+Shift+S | Toggle pane zoom |
| Opt+Shift+L | Cycle pane layouts |
| Ctrl+Opt+Shift+Arrow | Resize pane |

### Other

| Shortcut | Action |
|---|---|
| Ctrl+B | Tmux prefix |
| prefix + r | Reload tmux config |

## Claude Code

Status line shows: `Model [ctx: used/total (pct%)] repo:branch`

Context color: green (>75k free), yellow (<75k free), red (<50k free).
