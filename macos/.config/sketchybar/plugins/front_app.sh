#!/bin/bash
# App of the focused AeroSpace window. On an empty workspace macOS keeps the
# previous app frontmost, so front_app_switched's $INFO would be stale; ask
# AeroSpace instead, which returns nothing there.
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
app="$(aerospace list-windows --focused --format '%{app-name}' 2>/dev/null)"
sketchybar --set "$NAME" label="$app"
