# PiKaraoke Fork for diy-pikaraoke

This repository is a focused fork of [`vicwomg/pikaraoke`](https://github.com/vicwomg/pikaraoke). We adapt the karaoke server so it powers [diy-pikaraoke](https://codeberg.org/diy-aftershow/diy-pikaraoke), a playful retro TUI with a vintage look that brings fresh UI flows to PiKaraoke.

## Why this fork?

We needed adjustments so the server fits our requirements:

- Semitone offset in the API endpoints

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

