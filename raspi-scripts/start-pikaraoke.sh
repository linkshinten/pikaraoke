#!/usr/bin/env bash
set -euo pipefail

# PiKaraoke Docker launcher for Raspberry Pi login sessions.
#
# Optional environment variables:
#   PIKARAOKE_IMAGE   - Docker image/tag to run (default: pikaraoke-local:latest)
#   SONG_DIR          - Host directory for downloaded songs (default: ~/pikaraoke-songs)
#   CONTAINER_NAME    - Override docker container name (default: pikaraoke)
#   EXTRA_DOCKER_ARGS - Extra flags passed to docker run
#   PIKARAOKE_URL    - URL shown on the splash screen (default: http://<hostname>.local:<PORT>)
#   PIKARAOKE_FLAGS  - CLI flags passed to the pikaraoke process (default: --score-sequence 161 1312 100 99 1337 --volume 1 --url <hostname>.local)

IMAGE="${PIKARAOKE_IMAGE:-pikaraoke-local:latest}"
FALLBACK_IMAGE="vicwomg/pikaraoke:latest"
CONTAINER="${CONTAINER_NAME:-pikaraoke}"
SONG_DIR="${SONG_DIR:-$HOME/pikaraoke-songs}"
PORT="${PORT:-5555}"
EXTRA_DOCKER_ARGS="${EXTRA_DOCKER_ARGS:-}"
HOSTNAME_LABEL=$(hostname -s 2>/dev/null || hostname)
PIKARAOKE_URL_DEFAULT="http://${HOSTNAME_LABEL}.local:${PORT}"
PIKARAOKE_URL="${PIKARAOKE_URL:-$PIKARAOKE_URL_DEFAULT}"
DEFAULT_PIKARAOKE_FLAGS="--score-sequence 161 1312 100 99 1337 --volume 1 --url $PIKARAOKE_URL"
PIKARAOKE_FLAGS="${PIKARAOKE_FLAGS:-$DEFAULT_PIKARAOKE_FLAGS}"
read -r -a PIKARAOKE_ARGS <<< "$PIKARAOKE_FLAGS"

ensure_image() {
  if docker image inspect "$IMAGE" >/dev/null 2>&1; then
    return 0
  fi

  echo "[PiKaraoke] Docker image '$IMAGE' not found locally." >&2

  if docker image inspect "$FALLBACK_IMAGE" >/dev/null 2>&1; then
    echo "[PiKaraoke] Falling back to '$FALLBACK_IMAGE'." >&2
    IMAGE="$FALLBACK_IMAGE"
    return 0
  fi

  echo "[PiKaraoke] Pulling official image '$FALLBACK_IMAGE'." >&2
  docker pull "$FALLBACK_IMAGE"
  IMAGE="$FALLBACK_IMAGE"
}

stop_existing() {
  if docker ps -a --format '{{.Names}}' | grep -qx "$CONTAINER"; then
    echo "[PiKaraoke] Stopping existing container $CONTAINER" >&2
    docker stop "$CONTAINER" >/dev/null 2>&1 || true
    docker rm "$CONTAINER" >/dev/null 2>&1 || true
  fi
}

prepare_host() {
  mkdir -p "$SONG_DIR"
}

run_container() {
  echo "[PiKaraoke] Launching Docker container from image '$IMAGE'." >&2
  exec docker run \
    --name "$CONTAINER" \
    --restart unless-stopped \
    -p "${PORT}:5555" \
    -v "$SONG_DIR:/app/pikaraoke-songs" \
    $EXTRA_DOCKER_ARGS \
    "$IMAGE" \
    "${PIKARAOKE_ARGS[@]}"
}

ensure_image
stop_existing
prepare_host
run_container
