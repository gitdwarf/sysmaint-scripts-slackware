#!/bin/sh

# windowlabelandmove.sh - safe/unsafe GUI opener + window mover
#
# Labels file manager window title and attempts to move it
# Note: will silently fail if unable to move window

### User Variables START ###
unsafemode=0 # Default: SAFE MODE
# DO NOT set this to 1 unlesss you are
# willing to accept having root-owned
# file manager windows open on users desktops

### User Variables END ###


## Script starts here ##

set -euo pipefail
wintomv=""


# --- Core window mover ---
wlm-fn_windowlabelandmove () {
  # --- MAIN MODESWITCH ---
  if [ "$unsafemode" -eq 1 ]; then
    wlm-fn_unsafe_mode
  else
    wlm-fn_safe_mode
  fi
}

# --- SAFE MODE: run GUI actions as logged-in user ---
wlm-fn_safe_mode () {
  users=$(who | awk '{print $1}' | sort -u)

  for user in $users; do
    runuser -u "$user" -- sh -c "
      export DISPLAY=:0
      xdg-open "$wintomv" >/dev/null 2>&1 &
    " >/dev/null 2>&1 || true
  done
}

# --- UNSAFE MODE: run GUI actions as root (dangerous) ---
wlm-fn_unsafe_mode () {
  export DISPLAY=:0

  # Adjust workspace index
  windowtomoveto=$((windowtomoveto - 1))
  # Open file manager
  xdg-open "$wintomv" >/dev/null 2>&1 &
  sleep 1

  WIN_NAME="$wintomv"

  # Move window using wmctrl (literal match)
  if WIN_ID=$(wmctrl -l | grep -F "$WIN_NAME" | awk '{print $1}' | tail -n 1); then
    wmctrl -i -r "$WIN_ID" -t "$windowtomoveto" 2>/dev/null || true
  fi
}


## Script ends ##
