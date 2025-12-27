#!/usr/bin/env bash
set -euo pipefail

# Simple Chromium kiosk launcher for PiKaraoke splash screen
# Optional environment variables:
#   PIKARAOKE_URL             - URL to load (default: http://diy.local:5555/splash)
#   PIKARAOKE_BROWSER         - Browser executable (default: chromium-browser or chromium fallback)
#   PIKARAOKE_BROWSER_FLAGS   - Extra flags appended to the browser command
#   PIKARAOKE_BROWSER_PROFILE - Directory for browser profile (default: /tmp/pikaraoke-browser)

URL=${PIKARAOKE_URL:-http://diy.local:5555/splash}
BROWSER_DEFAULT=$(command -v chromium-browser >/dev/null 2>&1 && echo "chromium-browser" || echo "chromium")
BROWSER=${PIKARAOKE_BROWSER:-$BROWSER_DEFAULT}
PROFILE_DIR=${PIKARAOKE_BROWSER_PROFILE:-/tmp/pikaraoke-browser}
BROWSER_FLAGS=${PIKARAOKE_BROWSER_FLAGS:-}
WAIT_TIMEOUT=${PIKARAOKE_BROWSER_WAIT:-60}
GRACE_PERIOD=${PIKARAOKE_BROWSER_GRACE_PERIOD:-30}
TERMINAL_BIN=${PIKARAOKE_BROWSER_TERMINAL:-x-terminal-emulator}

mkdir -p "$PROFILE_DIR"

wait_for_url() {
  end=$((SECONDS + WAIT_TIMEOUT))
  while (( SECONDS < end )); do
    if curl -sSf "$URL" >/dev/null 2>&1; then
      return 0
    fi
    sleep 2
  done
  echo "[PiKaraoke] Warning: $URL did not respond within ${WAIT_TIMEOUT}s, launching browser anyway." >&2
  return 1
}

show_abort_prompt() {
  local seconds=${1:-0}
  (( seconds <= 0 )) && return 0

  if [[ -n "${DISPLAY:-}" ]] && command -v "$TERMINAL_BIN" >/dev/null 2>&1; then
    local prompt_script abort_flag aborted=0
    prompt_script=$(mktemp /tmp/pikaraoke-browser-wait.XXXXXX)
    abort_flag=$(mktemp /tmp/pikaraoke-browser-abort.XXXXXX)
    cat >"$prompt_script" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
seconds=${PIKARAOKE_PROMPT_SECONDS:-30}
abort_flag=${PIKARAOKE_PROMPT_ABORT_FLAG:-}
mark_abort() {
  if [[ -n "${abort_flag:-}" ]]; then
    echo "aborted" >"$abort_flag"
  fi
}
cleanup_flag() {
  if [[ -n "${abort_flag:-}" && -f "$abort_flag" ]]; then
    rm -f "$abort_flag"
  fi
}
trap 'echo ""; echo "[PiKaraoke] Browser launch aborted."; mark_abort; exit 0' INT TERM
trap 'cleanup_flag' EXIT
echo "PiKaraoke browser launch paused."
echo "Press Ctrl+C to abort or wait for the countdown to finish."
while (( seconds > 0 )); do
  printf "\rStarting in %02d seconds..." "$seconds"
  sleep 1
  seconds=$((seconds - 1))
done
echo -e "\nLaunching browser..."
EOF
    chmod +x "$prompt_script"
    PIKARAOKE_PROMPT_SECONDS=$seconds \
    PIKARAOKE_PROMPT_ABORT_FLAG="$abort_flag" \
      "$TERMINAL_BIN" -e "$prompt_script"
    local status=$?
    if [[ -f "$abort_flag" ]]; then
      aborted=1
      rm -f "$abort_flag"
    fi
    rm -f "$prompt_script"
    if (( aborted )); then
      return 130
    fi
    return $status
  fi

  echo "[PiKaraoke] Grace period active. Press Ctrl+C to abort."
  trap 'echo ""; echo "[PiKaraoke] Browser launch aborted."; exit 0' INT TERM
  for ((i = seconds; i > 0; i--)); do
    printf "\rStarting in %02d seconds..." "$i"
    sleep 1
  done
  echo
  return 0
}

wait_for_url

# Offer a short grace period to abort the launch
if ! show_abort_prompt "$GRACE_PERIOD"; then
  echo "[PiKaraoke] Browser launch cancelled during grace period." >&2
  exit 0
fi

# Kill stray kiosk instances so we always have a single fullscreen window
if pgrep -f "$BROWSER.*$URL" >/dev/null 2>&1; then
  pkill -f "$BROWSER.*$URL" || true
fi

exec "$BROWSER" \
  --noerrdialogs \
  --disable-infobars \
  --incognito \
  --kiosk \
  --start-fullscreen \
  --window-position=0,0 \
  --window-size=1920,1080 \
  --user-data-dir="$PROFILE_DIR" \
  $BROWSER_FLAGS \
  "$URL"
