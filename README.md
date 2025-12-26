# PiKaraoke Fork for diy-pikaraoke

This repository is a focused fork of [`vicwomg/pikaraoke`](https://github.com/vicwomg/pikaraoke). We adapt the karaoke server so it powers [diy-pikaraoke](https://codeberg.org/diy-aftershow/diy-pikaraoke), a playful retro TUI with a vintage look that brings fresh UI flows to PiKaraoke.

## Why this fork?

We needed adjustments so the server fits our requirements:

- Semitone offset in the API endpoints
- Adjustable score display after songs (incl. deterministic sequences via `--score-sequence`)

### Score sequences

Optionally you can pass a fixed list of scores at startup. The splash screen animation will pick randomly from this list:

```bash
python -m pikaraoke.app --score-sequence 161 1312 100 99 1337
```

If the option is omitted or empty, the previous random behavior remains. The list must contain integer values.

## Relationship to diy-pikaraoke

[`diy-pikaraoke`](https://github.com/linkshinten/diy-pikaraoke) tracks this fork as a submodule under `pikaraoke/`. Sync it via:

```bash
git clone --recurse-submodules git@github.com:linkshinten/diy-pikaraoke.git
cd diy-pikaraoke
./scripts/update_pikaraoke.sh   # pulls the latest submodule revision
```

Commit new features here first, then update the submodule SHA in the DIY repo so everyone uses the same revision.

## Thanks

PiKaraoke is built by @vicwomg. The solid foundation makes it easy to try retro-styled experiments without losing our footing. Sincere thanks for that!

