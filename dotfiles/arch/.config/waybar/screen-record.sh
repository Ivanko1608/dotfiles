#!/bin/sh
# Screen recorder for the waybar record button. No audio.
#
#   screen-record.sh toggle         start (whole screen) / stop
#   screen-record.sh toggle region  start (slurp selection) / stop
#   screen-record.sh status         JSON for the waybar custom module
#
# Output is edit-friendly for Kdenlive: H.264 yuv420p at a constant 60 fps
# (wf-recorder is variable-frame-rate by default, which Kdenlive handles badly),
# a keyframe every second for smooth scrubbing, and MKV so a crash or dead
# battery still leaves a playable file.

dir="${XDG_VIDEOS_DIR:-$HOME/Videos}/Screencasts"
state="${XDG_RUNTIME_DIR:-/tmp}/waybar-screen-record"
signal=8

refresh() { pkill -RTMIN+$signal waybar; }

recording() { [ -f "$state" ] && kill -0 "$(sed -n 1p "$state")" 2>/dev/null; }

case "$1" in
  status)
    if recording; then
      elapsed=$(($(date +%s) - $(sed -n 2p "$state")))
      printf '{"text":"󰻃 %02d:%02d","class":"recording","tooltip":"Recording: %s\\nClick to stop"}\n' \
        $((elapsed / 60)) $((elapsed % 60)) "$(sed -n 3p "$state")"
    else
      printf '{"text":"󰑊","class":"idle","tooltip":"Record screen (left)\\nRecord region (right)"}\n'
    fi
    ;;
  toggle)
    if recording; then
      pid=$(sed -n 1p "$state")
      file=$(sed -n 3p "$state")
      kill -INT "$pid"
      while kill -0 "$pid" 2>/dev/null; do sleep 0.1; done
      rm -f "$state"
      refresh
      notify-send -i video-x-generic "Recording saved" "$file"
      exit 0
    fi

    if [ "$2" = region ]; then
      geometry=$(slurp -d) || exit 0
    fi

    mkdir -p "$dir"
    file="$dir/$(date +%Y-%m-%d_%H-%M-%S).mkv"

    wf-recorder ${geometry:+-g "$geometry"} -f "$file" -y \
      -c libx264 -x yuv420p -r 60 \
      -F scale=out_range=tv:out_color_matrix=bt709 -p color_range=tv \
      -p colorspace=bt709 -p color_primaries=bt709 -p color_trc=bt709 \
      -p preset=superfast -p crf=18 -p g=60 \
      >/dev/null 2>&1 &
    printf '%s\n%s\n%s\n' "$!" "$(date +%s)" "$file" >"$state"
    refresh
    ;;
esac
