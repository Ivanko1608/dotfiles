#!/usr/bin/env bash
# Link the shared Claude Code config into a config dir (per-file symlinks).
# Usage: install.sh [config-dir], default ~/.claude (e.g. ~/.claude-work).
# Existing non-symlink files are moved to <config-dir>/backups/pre-dotfiles/
# (not left beside the original, where a copied skill dir would still load).
set -euo pipefail

src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dst="${1:-$HOME/.claude}"

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

git -C "$src" submodule update --init mods/claude-code-playground

link settings.json
link CLAUDE.md
link hooks/caveman-statusline.sh
link hooks/subagent-ultracave.sh
link skills/graphify
link mods/claude-code-playground
