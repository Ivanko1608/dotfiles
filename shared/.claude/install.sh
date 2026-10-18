#!/usr/bin/env bash
# Link the shared Claude Code config into ~/.claude (per-file symlinks).
# Existing non-symlink files are moved aside as <name>.pre-dotfiles.
set -euo pipefail

src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dst="$HOME/.claude"

link() {
	local rel="$1"
	mkdir -p "$(dirname "$dst/$rel")"
	if [ -e "$dst/$rel" ] && [ ! -L "$dst/$rel" ]; then
		mv "$dst/$rel" "$dst/$rel.pre-dotfiles"
	fi
	ln -sfn "$src/$rel" "$dst/$rel"
	echo "linked $dst/$rel"
}

link settings.json
link CLAUDE.md
link hooks/caveman-statusline.sh
link skills/graphify
