#!/bin/bash
# Colors for the bar and its plugins (0xAARRGGBB). Defaults are tokyo-night;
# `theme-set <name>` writes the generated override sourced below.
# Sourced by sketchybarrc and plugins, hence no local uses:
# shellcheck disable=SC2034
BAR_COLOR=0xff1a1b26
FG_COLOR=0xffa9b1d6
MUTED_COLOR=0xff565f89
ACCENT_COLOR=0xff7aa2f7
ON_ACCENT_COLOR=0xff1a1b26

theme_file="$HOME/.local/state/omarchy-macos/theme/sketchybar.sh"
# shellcheck source=/dev/null
[ -r "$theme_file" ] && . "$theme_file"
