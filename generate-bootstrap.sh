#!/usr/bin/env bash
set -euo pipefail

# Generates a standalone bootstrap.sh that recreates the dotfiles folder
# and runs setup.sh. Usage: ./generate-bootstrap.sh > bootstrap.sh

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

cat <<'HEADER'
#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"

if [ -d "$DOTFILES_DIR" ]; then
    echo "Error: $DOTFILES_DIR already exists. Remove it first or use setup.sh directly."
    exit 1
fi

mkdir -p "$DOTFILES_DIR"
echo "Creating dotfiles in $DOTFILES_DIR..."

HEADER

# Emit each file as a heredoc
for file in setup.sh zshrc tmux.conf kitty.conf claude-settings.json statusline-config.txt; do
    source_path="$DOTFILES_DIR/$file"
    [ -f "$source_path" ] || continue

    echo "cat > \"\$DOTFILES_DIR/$file\" <<'__EOF__'"
    cat "$source_path"
    echo "__EOF__"
    echo ""
done

# Make setup.sh executable and run it
cat <<'FOOTER'
chmod +x "$DOTFILES_DIR/setup.sh"
echo "Running setup.sh..."
echo ""
cd "$DOTFILES_DIR" && ./setup.sh
FOOTER
