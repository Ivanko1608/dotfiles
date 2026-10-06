#!/bin/sh
# Run a Hyprland dispatcher in whichever config mode is active.
# Lua-config sessions take Lua expressions (`hl.dsp.dpms(...)`), legacy
# sessions take the old `dpms off` form. Try each candidate until one is accepted.
#
#   dispatch.sh dpms off|on
#   dispatch.sh exit

case "$1" in
  dpms)
    set -- "hl.dsp.dpms({ action = \"$2\" })" "hl.dsp.dpms(\"$2\")" "dpms $2" ;;
  exit)
    set -- "hl.dsp.exit()" "exit" ;;
  *)
    echo "usage: $0 dpms on|off | exit" >&2; exit 2 ;;
esac

for candidate in "$@"; do
  # shellcheck disable=SC2086 # legacy form must split into dispatcher + args
  case "$candidate" in
    hl.*) out=$(hyprctl dispatch "$candidate" 2>&1) ;;
    *) out=$(hyprctl dispatch $candidate 2>&1) ;;
  esac
  [ "$out" = "ok" ] && exit 0
done

echo "dispatch.sh: no form accepted: $out" >&2
exit 1
