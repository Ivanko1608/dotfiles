#!/bin/bash
# Battery percent + charging state from pmset (no permissions needed).
batt="$(pmset -g batt)"
percent="$(printf '%s' "$batt" | grep -Eo '[0-9]+%' | head -n1 | tr -d '%')"

# Desktops / no battery: hide the item.
if [ -z "$percent" ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

if [ "$percent" -ge 90 ]; then icon=""
elif [ "$percent" -ge 60 ]; then icon=""
elif [ "$percent" -ge 30 ]; then icon=""
elif [ "$percent" -ge 10 ]; then icon=""
else icon=""
fi
case "$batt" in *"AC Power"*) icon="" ;; esac

sketchybar --set "$NAME" drawing=on icon="$icon" label="${percent}%"
