# Raspberry Pi Autostart scripts

This directory contains helper scripts for launching PiKaraoke as a Docker container on a Raspberry Pi automatically.

## Files

- `start-pikaraoke.sh` – Launcher script that can run on every login (or via systemd). Prefers the locally built image `pikaraoke-local:latest` and falls back to `vicwomg/pikaraoke:latest`. Configurable via environment variables such as `PIKARAOKE_IMAGE`, `SONG_DIR`, `PORT`, or `EXTRA_DOCKER_ARGS`.
- `start-browser.sh` – Launches Chromium in kiosk mode against the PiKaraoke splash page.
- `pikaraoke-server.service` – systemd user service that runs the Docker container.
- `pikaraoke-browser.service` – systemd user service that launches the Chromium kiosk window *after* the server is up.

## Configuration knobs

The launcher inspects the following environment variables (all optional):

| Variable            | Default value                                           | Purpose                                                                                   |
| ------------------- | ------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| `PIKARAOKE_IMAGE`   | `pikaraoke-local:latest` (falls back to `vicwomg/...`)  | Selects the Docker image/tag to run                                                       |
| `SONG_DIR`          | `~/pikaraoke-songs`                                     | Host path that is bind-mounted into the container                                         |
| `CONTAINER_NAME`    | `pikaraoke`                                             | Overrides the Docker container name                                                       |
| `PORT`              | `5555`                                                  | Host port exposed as `PORT:5555`                                                          |
| `EXTRA_DOCKER_ARGS` | _(empty)_                                               | Additional flags passed straight to `docker run`                                          |
| `PIKARAOKE_FLAGS`   | `--score-sequence 161 1312 100 99 1337 --volume 1`      | CLI flags forwarded to the `pikaraoke` process (default keeps score bias + max volume)    |

Example: set a different volume and disable background music

```bash
export PIKARAOKE_FLAGS="--score-sequence 161 1312 100 99 1337 --volume 0.8 --disable-bg-music"
```

To make this persistent with systemd, extend the user unit (after copying it into `~/.config/systemd/user/`):

```
[Service]
Environment="PIKARAOKE_FLAGS=--score-sequence 42 42 42 --volume 1"
Environment="PIKARAOKE_IMAGE=pikaraoke-local:dev"
```

## How to use

1. **Build your local Docker image (optional if you have local changes):**
   ```bash
   docker build -t pikaraoke-local:latest .
   ```
2. **Make the script executable:**
   ```bash
   chmod +x raspi-scripts/start-pikaraoke.sh
   ```
3. **Install the systemd user services:**
   ```bash
   mkdir -p ~/.config/systemd/user
   cp raspi-scripts/pikaraoke-server.service ~/.config/systemd/user/
   cp raspi-scripts/pikaraoke-browser.service ~/.config/systemd/user/
   systemctl --user daemon-reload
   systemctl --user enable --now pikaraoke-server.service
   systemctl --user enable --now pikaraoke-browser.service
   ```
4. **Check the status:**
   ```bash
   systemctl --user status pikaraoke-server.service
   systemctl --user status pikaraoke-browser.service
   docker ps | grep pikaraoke
   ```

With this setup PiKaraoke starts automatically, mounts the local song directory `~/pikaraoke-songs`, and benefits from Docker's `--restart unless-stopped` behavior.
