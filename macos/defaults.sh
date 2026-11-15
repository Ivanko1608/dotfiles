#!/usr/bin/env bash
# macos/defaults.sh apply|restore
#
# apply:   save the current value of every setting below (once: re-running
#          never overwrites the originals), then write the new values.
# restore: put the saved values back (deleting keys that were unset before)
#          and forget them.
# User-level `defaults` only: no sudo.
set -euo pipefail

state="$HOME/.local/state/omarchy-macos"
saved="$state/defaults.saved"

# domain <TAB> key <TAB> type <TAB> value
SETTINGS="$(
	cat <<'EOF'
com.apple.dock	expose-group-apps	bool	true
com.apple.spaces	spans-displays	bool	true
NSGlobalDomain	KeyRepeat	int	2
NSGlobalDomain	InitialKeyRepeat	int	15
com.apple.dock	autohide	bool	true
com.apple.dock	launchanim	bool	false
NSGlobalDomain	NSAutomaticWindowAnimationsEnabled	bool	false
com.apple.universalaccess	reduceMotion	bool	true
EOF
)"
# expose-group-apps / spans-displays: recommended by AeroSpace's guide
#   (Mission Control grouping; "Displays have separate Spaces" off).
# KeyRepeat / InitialKeyRepeat: fastest values System Settings offers.
# launchanim / NSAutomaticWindowAnimationsEnabled / reduceMotion: less motion.

TAB="$(printf '\t')"

# Record "domain key type value" (or "domain key - __UNSET__") for keys not
# yet in the saved file.
save_current() {
	local domain="$1" key="$2" value type
	if grep -q "^${domain}${TAB}${key}${TAB}" "$saved" 2>/dev/null; then
		return 0
	fi
	if value="$(defaults read "$domain" "$key" 2>/dev/null)"; then
		type="$(defaults read-type "$domain" "$key" 2>/dev/null | sed 's/^Type is //')"
		printf '%s\t%s\t%s\t%s\n' "$domain" "$key" "$type" "$value" >>"$saved"
	else
		printf '%s\t%s\t-\t__UNSET__\n' "$domain" "$key" >>"$saved"
	fi
}

# write_value domain key saved-type value  (type as printed by read-type)
write_value() {
	local domain="$1" key="$2" type="$3" value="$4"
	case "$type" in
	boolean | bool)
		case "$value" in 1 | true | YES) value=true ;; *) value=false ;; esac
		defaults write "$domain" "$key" -bool "$value"
		;;
	integer | int) defaults write "$domain" "$key" -int "$value" ;;
	float) defaults write "$domain" "$key" -float "$value" ;;
	string) defaults write "$domain" "$key" -string "$value" ;;
	*)
		echo "  ! $domain $key: can't restore type '$type', skipped" >&2
		return 1
		;;
	esac
}

restart_ui() {
	killall Dock 2>/dev/null || true
	killall SystemUIServer 2>/dev/null || true
}

apply() {
	mkdir -p "$state"
	touch "$saved"
	local domain key type value manual=""
	while IFS="$TAB" read -r domain key type value; do
		save_current "$domain" "$key"
		if write_value "$domain" "$key" "$type" "$value" 2>/dev/null; then
			echo "  set $domain $key = $value"
		elif [ "$key" = reduceMotion ]; then
			manual=1
		else
			echo "  ! could not set $domain $key" >&2
		fi
	done <<<"$SETTINGS"
	restart_ui
	echo "Saved previous values to $saved (restore: $0 restore)."
	echo "Log out and back in for key repeat and 'Displays have separate Spaces'."
	if [ -n "$manual" ]; then
		echo "Reduce motion needs Full Disk Access to set from a script; turn it on in"
		echo "  System Settings > Accessibility > Display > Reduce motion"
	fi
}

restore() {
	if [ ! -s "$saved" ]; then
		echo "Nothing saved at $saved; leaving settings alone."
		return 0
	fi
	local domain key type value
	while IFS="$TAB" read -r domain key type value; do
		if [ "$value" = "__UNSET__" ]; then
			defaults delete "$domain" "$key" 2>/dev/null || true
			echo "  unset $domain $key"
		elif write_value "$domain" "$key" "$type" "$value" 2>/dev/null; then
			echo "  restored $domain $key = $value"
		else
			echo "  ! could not restore $domain $key (was $value)" >&2
		fi
	done <"$saved"
	mv "$saved" "$saved.restored.$(date +%Y%m%d-%H%M%S)"
	restart_ui
	echo "Restored. Log out and back in for every setting to take effect."
}

if [ "$(uname -s)" != "Darwin" ]; then
	echo "defaults.sh: macOS only." >&2
	exit 1
fi

case "${1:-}" in
apply) apply ;;
restore) restore ;;
*)
	echo "usage: $0 apply|restore" >&2
	exit 2
	;;
esac
