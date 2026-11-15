#!/bin/bash
# Show non-empty workspaces, highlight the focused one, hide the rest.
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
# shellcheck source=SCRIPTDIR/../colors.sh
. "$CONFIG_DIR/colors.sh"

focused="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused 2>/dev/null)}"
nonempty=" $(aerospace list-workspaces --monitor all --empty no 2>/dev/null | tr '\n' ' ') "

args=()
for sid in 1 2 3 4 5 6 7 8 9 10; do
  if [ "$sid" = "$focused" ]; then
    args+=(--set "space.$sid" drawing=on background.drawing=on label.color="$ON_ACCENT_COLOR")
  elif [ "${nonempty#* "$sid" }" != "$nonempty" ]; then
    args+=(--set "space.$sid" drawing=on background.drawing=off label.color="$FG_COLOR")
  else
    args+=(--set "space.$sid" drawing=off)
  fi
done
sketchybar "${args[@]}"
