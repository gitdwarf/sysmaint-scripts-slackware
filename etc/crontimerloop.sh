#!/bin/sh
#
# crontimerloop - this script: root retry-with-timeout helper
#
# Provides:
#   timeoutloop <commandname> <timeout_seconds> <max_attempts> <command...>
#
# Optional user-defined hooks:
#   on_timeout <attempt> <max_attempts> <command...>
#   on_failure <attempt> <exit_code> <command...>
#
# Hooks:
#   - Called automatically when defined.
#   - Not required; crontimeloop checks before calling.
#   - Never interfere with retry logic unless you choose to exit inside them.
#
# Exit codes:
#   0   — success
#   1   — all attempts failed
#   124 — timeout (from `timeout`)
#   *   — underlying command’s exit code (non-timeout failure)
#

ctl-fn_timeoutloop() {
  name="$1"
  timeout_secs="$2"
  max_attempts="$3"
  shift 3

  # Invalid usage
  [ -z "$name" ] || [ -z "$timeout_secs" ] || [ -z "$max_attempts" ] || [ $# -eq 0 ] && return 1

  # Detect string vs argv mode
  if [ $# -eq 1 ]; then
    mode="string"
    cmd_string="$1"
  else
    mode="argv"
  fi

  attempt=1
  while [ "$attempt" -le "$max_attempts" ]; do

    tmpfile="$(mktemp)"

    if [ "$mode" = "string" ]; then
      # STREAM output live, CAPTURE via tee, PRESERVE exit code
      timeout "$timeout_secs" sh -c "$cmd_string" 2>&1 | tee "$tmpfile"
      rc=${PIPESTATUS[0]}
    else
      timeout "$timeout_secs" "$@" 2>&1 | tee "$tmpfile"
      rc=${PIPESTATUS[0]}
    fi

    output="$(cat "$tmpfile")"
    rm -f "$tmpfile"

    case "$rc" in
      0)
        # SUCCESS — output already streamed live
        return 0
        ;;

      124)
        # TIMEOUT
        if command -v on_timeout >/dev/null 2>&1; then
          on_timeout "$name" "$attempt" "$max_attempts" "$@"
        fi

        if [ "$attempt" -eq "$max_attempts" ]; then
          echo "ERROR: $name timed out after $max_attempts attempts" >&2
          return 124
        fi
        ;;

      *)
        # NON-TIMEOUT FAILURE
        if command -v on_failure >/dev/null 2>&1; then
          on_failure "$name" "$attempt" "$rc" "$@"
        fi

        echo "ERROR: $name failed with exit code $rc" >&2
        return "$rc"
        ;;
    esac

    attempt=$((attempt + 1))
  done

  return 1
}
