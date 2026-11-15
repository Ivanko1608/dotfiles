#!/usr/bin/env bash
# macos/uninstall.sh [--remove-packages]
#
# Undo install.sh: stop the services, remove the symlinks it created, put
# backed-up files back, restore the saved macOS defaults and drop the
# generated theme. Homebrew packages stay unless --remove-packages is given.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
state="$HOME/.local/state/omarchy-macos"
manifest="$state/links.tsv"

remove_packages=0
case "${1:-}" in
"") ;;
--remove-packages) remove_packages=1 ;;
*)
	echo "usage: $0 [--remove-packages]" >&2
	exit 2
	;;
esac

if [ "$(uname -s)" != "Darwin" ]; then
	echo "uninstall.sh: macOS only." >&2
	exit 1
fi

if ! command -v brew >/dev/null 2>&1 && [ -x /opt/homebrew/bin/brew ]; then
	eval "$(/opt/homebrew/bin/brew shellenv)"
fi

echo "==> Stopping services"
if command -v brew >/dev/null 2>&1; then
	brew services stop sketchybar || true
	brew services stop borders || true
fi
pkill -x AeroSpace 2>/dev/null || true

echo "==> Removing links"
if [ -s "$manifest" ]; then
	# Newest first, so a path linked twice gets its oldest backup last.
	awk '{ line[NR] = $0 } END { for (i = NR; i > 0; i--) print line[i] }' "$manifest" |
		while IFS="$(printf '\t')" read -r dst src saved; do
			if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
				rm "$dst"
				echo "  removed $dst"
				# Drop the parent install.sh created, if nothing else is in it.
				rmdir "$(dirname "$dst")" 2>/dev/null || true
			fi
			if [ "$saved" != "-" ] && { [ -e "$saved" ] || [ -L "$saved" ]; }; then
				if [ -e "$dst" ] || [ -L "$dst" ]; then
					echo "  ! $dst exists; left its backup at $saved" >&2
				else
					mkdir -p "$(dirname "$dst")"
					mv "$saved" "$dst"
					echo "  restored $dst"
				fi
			fi
		done
	mv "$manifest" "$manifest.uninstalled.$(date +%Y%m%d-%H%M%S)"
else
	echo "  nothing recorded in $manifest"
fi

echo "==> macOS defaults"
"$here/defaults.sh" restore

echo "==> Generated theme"
if [ -d "$state/theme" ]; then
	rm -r "$state/theme"
	echo "  removed $state/theme"
fi

echo "==> Homebrew packages"
if [ "$remove_packages" = 1 ]; then
	# Only what the Brewfile lists; taps stay.
	sed -n 's/^brew "\([^"]*\)".*/\1/p' "$here/Brewfile" | while read -r f; do
		brew uninstall --formula "$f" || true
	done
	sed -n 's/^cask "\([^"]*\)".*/\1/p' "$here/Brewfile" | while read -r c; do
		brew uninstall --cask "$c" || true
	done
else
	echo "  left installed (pass --remove-packages to uninstall them)"
fi

cat <<'EOF'

==> Done. You may also want to:
  - remove AeroSpace from System Settings > General > Login Items
  - turn the native menu bar back on (System Settings > Control Center)
  - re-enable the Mission Control Ctrl+arrow shortcuts
  - log out and back in so every restored default takes effect
EOF
