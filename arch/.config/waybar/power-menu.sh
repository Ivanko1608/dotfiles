#!/bin/sh
# Power menu for the waybar battery module (stand-in for `omarchy-menu power`).

choice=$(printf '%s\n' "󰌾  Lock" "󰤄  Suspend" "󰜉  Reboot" "󰐥  Shutdown" "󰍃  Log out" |
  wofi --show dmenu --prompt "Power" --width 360 --lines 5 --insensitive)

case "$choice" in
  *Lock) hyprlock ;;
  *Suspend) systemctl suspend ;;
  *Reboot) hyprshutdown -t 'Rebooting...' -p 'systemctl reboot' ;;
  *Shutdown) hyprshutdown -t 'Shutting down...' -p 'systemctl poweroff' ;;
  *"Log out") hyprshutdown -t 'Logging out...' ;;
esac
