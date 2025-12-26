#!/usr/bin/env bash
set -euo pipefail

# Simple Chromium kiosk launcher for PiKaraoke splash screen
# Optional environment variables:
#   PIKARAOKE_URL             - URL to load (default: http://localhost:5555/splash)
#   PIKARAOKE_BROWSER         - Browser executable (default: chromium-browser or chromium fallback)
#   PIKARAOKE_BROWSER_FLAGS   - Extra flags appended to the browser command
#   PIKARAOKE_BROWSER_PROFILE - Directory for browser profile (default: /tmp/pikaraoke-browser)

URL=${PIKARAOKE_URL:-http://localhost:5555/splash}
BROWSER_DEFAULT=$(command -v chromium-browser >/dev/null 2>&1 && echo "chromium-browser" || echo "chromium")
BROWSER=${PIKARAOKE_BROWSER:-$BROWSER_DEFAULT}
PROFILE_DIR=${PIKARAOKE_BROWSER_PROFILE:-/tmp/pikaraoke-browser}
BROWSER_FLAGS=${PIKARAOKE_BROWSER_FLAGS:-}
WAIT_TIMEOUT=${PIKARAOKE_BROWSER_WAIT:-60}

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

wait_for_url

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
