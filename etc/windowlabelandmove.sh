#!/bin/sh
#
# windowlabelandmove.sh - this script
#
# Provides:
#   Labels file manager window title and attempts to move it
#   Note: will silently fail if unable to move window

set -euo pipefail

wlm-fn_windowlabelandmove () {
  export DISPLAY=:0
  windowtomoveto=$((windowtomoveto-1))

  # Open the file manager for the target directory
  xdg-open "${wintomv}" > /dev/null 2>&1 &
  sleep 1  # ensure enough time for window to appear

  WIN_NAME="${wintomv}"

  # Try to move the window to the target workspace using wmctrl (X11)
  if WIN_ID=$(wmctrl -l | grep "$WIN_NAME" | awk '{print $1}' | tail -n 1); then
    wmctrl -i -r "${WIN_ID}" -t "${windowtomoveto}" 2>/dev/null
  fi

  # Fallback using xdotool (XWayland / Wayland via XWayland)
  if WIN_ID=$(wmctrl -l | grep "$WIN_NAME" | awk '{print $1}' | tail -n 1); then
    wmctrl -i -r "${WIN_ID}" -t "${windowtomoveto}" 2>/dev/null
  fi
}
