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
  if [ -z "$name" ] || [ -z "$timeout_secs" ] || [ -z "$max_attempts" ] || [ $# -eq 0 ]; then
    return 1
  fi

  # Detect string vs argv mode
  if [ $# -eq 1 ]; then
    mode="string"
    cmd_string="$1"
  else
    mode="argv"
  fi

  attempt=1
  while [ "$attempt" -le "$max_attempts" ]; do

    if [ "$mode" = "string" ]; then
      output=$(timeout "$timeout_secs" sh -c "$cmd_string" 2>&1)
      rc=$?
    else
      output=$(timeout "$timeout_secs" "$@" 2>&1)
      rc=$?
    fi

    case "$rc" in
      0)
        # SUCCESS: print wrapped command output to stdout
        printf "%s\n" "$output"
        return 0
        ;;

      124)
        # TIMEOUT
        if command -v on_timeout >/dev/null 2>&1; then
          on_timeout "$name" "$attempt" "$max_attempts" "$@"
        fi

        if [ "$attempt" -eq "$max_attempts" ]; then
          # Print wrapped command output to stdout
          printf "%s\n" "$output"
          # Print timeoutloop's own error to stderr
          echo "ERROR: $name timed out after $max_attempts attempts" >&2
          return 124
        fi
        ;;

      *)
        # NON-TIMEOUT FAILURE
        if command -v on_failure >/dev/null 2>&1; then
          on_failure "$name" "$attempt" "$rc" "$@"
        fi

        # Print wrapped command output to stdout
        printf "%s\n" "$output"
        # Print timeoutloop's own error to stderr
        echo "ERROR: $name failed with exit code $rc" >&2
        return "$rc"
        ;;
    esac

    attempt=$((attempt + 1))
  done

  return 1
}

