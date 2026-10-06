#!/bin/sh
# Power menu for the waybar battery module (stand-in for `omarchy-menu power`).

choice=$(printf '%s\n' "󰌾  Lock" "󰤄  Suspend" "󰜉  Reboot" "󰐥  Shutdown" "󰍃  Log out" |
  rofi -dmenu -i -p "Power" -theme-str 'window { width: 240px; } listview { lines: 5; }')

case "$choice" in
  *Lock) hyprlock ;;
  *Suspend) systemctl suspend ;;
  # hyprshutdown closes apps gracefully before exiting Hyprland
  *Reboot) hyprshutdown -t 'Rebooting...' -p 'systemctl reboot' ;;
  *Shutdown) hyprshutdown -t 'Shutting down...' -p 'systemctl poweroff' ;;
  *"Log out") hyprshutdown -t 'Logging out...' ;;
esac
