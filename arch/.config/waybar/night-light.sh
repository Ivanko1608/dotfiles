#!/bin/sh
# Night light for the waybar button, via the running hyprsunset's IPC.
# hyprsunset.conf's schedule still applies; this just overrides until the
# next profile change.
#
#   night-light.sh toggle   neutral <-> warm
#   night-light.sh status   JSON for the waybar custom module

warm=4000
signal=9

on() { [ "$(hyprctl hyprsunset temperature)" -lt 6000 ] 2>/dev/null; }

case "$1" in
  status)
    if on; then
      printf '{"text":"󰖔","class":"on","tooltip":"Night light on (%sK)"}\n' "$(hyprctl hyprsunset temperature)"
    else
      printf '{"text":"󰖙","class":"off","tooltip":"Night light off"}\n'
    fi
    ;;
  toggle)
    if on; then
      # identity alone leaves the reported temperature at the warm value
      hyprctl hyprsunset temperature 6000 >/dev/null
      hyprctl hyprsunset identity >/dev/null
    else
      hyprctl hyprsunset temperature $warm >/dev/null
    fi
    pkill -RTMIN+$signal waybar
    ;;
esac
