#!/bin/bash
# $INFO is the name of the frontmost app on front_app_switched.
if [ "$SENDER" = "front_app_switched" ]; then
  sketchybar --set "$NAME" label="$INFO"
fi
