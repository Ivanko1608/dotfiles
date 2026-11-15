#!/bin/bash
# $INFO carries the volume (0-100) on volume_change. On the first run there is
# no event, so read it once via osascript's StandardAdditions. That queries
# this machine's own audio settings, not another app, so it needs no
# Automation permission.
vol="$INFO"
if [ "$SENDER" != "volume_change" ] || [ -z "$vol" ]; then
  vol="$(osascript -e 'output volume of (get volume settings)' 2>/dev/null)"
fi
case "$vol" in ''|*[!0-9]*) vol=0 ;; esac

if [ "$vol" -ge 60 ]; then icon=""
elif [ "$vol" -ge 1 ]; then icon=""
else icon=""
fi
sketchybar --set "$NAME" icon="$icon" label="${vol}%"
