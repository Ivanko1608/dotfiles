#!/usr/bin/env bash
# macos/install.sh [--no-brew] [--no-defaults]
#
# Idempotent setup of the Omarchy-style macOS desktop:
#   1. brew bundle (macos/Brewfile)
#   2. symlink configs into $HOME (per-file/dir symlinks, same convention as
#      shared/.claude/install.sh); anything in the way is moved to
#      ~/.local/state/omarchy-macos/backup/<timestamp>/ and recorded so
#      uninstall.sh can put it back
#   3. generate the default theme (tokyo-night) if none is set
#   4. apply macOS defaults (saving the old values; see defaults.sh)
#   5. (re)start SketchyBar + JankyBorders (brew services) and AeroSpace
#   6. print the permissions and manual steps left to you
# No sudo. Set HOMEBREW_CASK_OPTS="--appdir=$HOME/Applications" first if you
# can't write to /Applications.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo="$(dirname "$here")"
state="$HOME/.local/state/omarchy-macos"
manifest="$state/links.tsv"
backup_dir="$state/backup/$(date +%Y%m%d-%H%M%S)"

do_brew=1
do_defaults=1
for arg in "$@"; do
	case "$arg" in
	--no-brew) do_brew=0 ;;
	--no-defaults) do_defaults=0 ;;
	*)
		echo "usage: $0 [--no-brew] [--no-defaults]" >&2
		exit 2
		;;
	esac
done

if [ "$(uname -s)" != "Darwin" ]; then
	echo "install.sh: macOS only." >&2
	exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
	if [ -x /opt/homebrew/bin/brew ]; then
		eval "$(/opt/homebrew/bin/brew shellenv)"
	else
		echo "Homebrew not found. Install it from https://brew.sh (or ask IT), then re-run." >&2
		exit 1
	fi
fi

# link <path relative to $HOME> <source path relative to repo>
link() {
	local rel="$1" src="$repo/$2" dst="$HOME/$1" saved="-"
	if [ ! -e "$src" ]; then
		echo "install.sh: missing $src" >&2
		exit 1
	fi
	if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
		echo "  ok      ~/$rel"
		return 0
	fi
	if [ -e "$dst" ] || [ -L "$dst" ]; then
		saved="$backup_dir/$rel"
		mkdir -p "$(dirname "$saved")"
		mv "$dst" "$saved"
		echo "  backup  ~/$rel -> $saved"
	fi
	mkdir -p "$(dirname "$dst")"
	ln -s "$src" "$dst"
	printf '%s\t%s\t%s\n' "$dst" "$src" "$saved" >>"$manifest"
	echo "  linked  ~/$rel"
}

echo "==> Homebrew packages"
if [ "$do_brew" = 1 ]; then
	prefix="$(brew --prefix)"
	if [ ! -w "$prefix" ]; then
		# Typically Homebrew was installed from another (admin) account.
		owner="$(stat -f %Su "$prefix")"
		cat >&2 <<EOF
Homebrew at $prefix belongs to '$owner', so this account can't install
into it. From the '$owner' account (or any admin account), run:

  sudo chown -R $(whoami) $prefix

then re-run this script. Or run it with --no-brew if everything in
macos/Brewfile is already installed.
EOF
		exit 1
	fi
	brew bundle --file "$here/Brewfile"
else
	echo "  skipped (--no-brew)"
fi

echo "==> Linking configs"
mkdir -p "$state"
touch "$manifest"
link .config/aerospace/aerospace.toml macos/.config/aerospace/aerospace.toml
link .config/sketchybar macos/.config/sketchybar
link .config/borders/bordersrc macos/.config/borders/bordersrc
link .config/ghostty/config.ghostty macos/.config/ghostty/config.ghostty
link .config/zsh/omarchy-macos.zsh macos/.config/zsh/omarchy-macos.zsh
link .config/omarchy-macos/themes macos/.config/omarchy-macos/themes
link .config/omarchy-macos/starship-base.toml macos/.config/omarchy-macos/starship-base.toml
link .local/bin/theme-set macos/.local/bin/theme-set
link .local/bin/omac-launch macos/.local/bin/omac-launch
link .zshrc ohmyzsh/.zshrc
link .config/nvim shared/.config/nvim

echo "==> Theme"
if [ -r "$state/theme/name" ]; then
	echo "  keeping $(cat "$state/theme/name")"
else
	"$HOME/.local/bin/theme-set" tokyo-night --no-reload
fi

echo "==> macOS defaults"
if [ "$do_defaults" = 1 ]; then
	"$here/defaults.sh" apply
else
	echo "  skipped (--no-defaults)"
fi

echo "==> Services"
brew services restart sketchybar
brew services restart borders
# AeroSpace registers itself as a login item (start-at-login = true).
open -a AeroSpace

cat <<'EOF'

==> Done. Left for you:

Permissions (System Settings > Privacy & Security > Accessibility):
  - AeroSpace: required to move and resize windows. It asks on first launch.
  - JankyBorders (borders): allow it if macOS asks; it tracks window positions.
  Nothing here needs Input Monitoring, Screen Recording, Location,
  Automation or Full Disk Access.

Manual steps:
  1. Hide the native menu bar (SketchyBar replaces it):
     System Settings > Control Center > "Automatically hide and show the
     menu bar" > Always.
  2. Free Ctrl+Left/Right for word movement in the shell:
     System Settings > Keyboard > Keyboard Shortcuts > Mission Control >
     untick "Move left a space" / "Move right a space".
  3. Raycast: set its hotkey to Option+Space (Raycast Settings > General).
     AeroSpace leaves alt-space unbound for it.
  4. Pick your main display (System Settings > Displays > Use as: Main
     display). Workspaces 1-5 live there, 6-10 on the other display.
  5. Log out and back in once (key repeat, Spaces setting).

Machine-specific overrides (gitignored, never committed):
  ~/.zshrc.local, ~/.config/omarchy-macos/apps.local.conf
EOF
