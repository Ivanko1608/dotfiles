#!/usr/bin/env bash
# Link the shared Claude Code config into ~/.claude (per-file symlinks).
# Existing non-symlink files are moved to ~/.claude/backups/pre-dotfiles/
# (not left beside the original, where a copied skill dir would still load).
set -euo pipefail

src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dst="$HOME/.claude"

link() {
	local rel="$1"
	mkdir -p "$(dirname "$dst/$rel")"
	if [ -e "$dst/$rel" ] && [ ! -L "$dst/$rel" ]; then
		mkdir -p "$dst/backups/pre-dotfiles"
		mv "$dst/$rel" "$dst/backups/pre-dotfiles/$(basename "$rel").$(date +%s)"
	fi
	ln -sfn "$src/$rel" "$dst/$rel"
	echo "linked $dst/$rel"
}

link settings.json
link CLAUDE.md
link hooks/caveman-statusline.sh
link skills/graphify
