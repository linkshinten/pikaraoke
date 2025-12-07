# PiKaraoke Fork for DIY PiKaraoke

This repository is a focused fork of [`vicwomg/pikaraoke`](https://github.com/vicwomg/pikaraoke). We adapt the karaoke server so it powers **DIY PiKaraoke**, a playful retro TUI with a vintage look that layers automation hooks and fresh UI flows on top of PiKaraoke.

## Why this fork?

We needed a handful of adjustments so the server fits our requirements.

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

