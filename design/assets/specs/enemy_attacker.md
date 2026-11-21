# Common enemy: plain attacker (working name)

| Field | Value |
|---|---|
| Asset ID | `enemy_attacker` |
| Display name | pending (name belongs to `game-designer`, T5) |
| Asset class | enemy |
| Owner | game-artist |
| Priority | high (slice piece 2a) |
| Status | planned |
| Approval state | not approved (approver: director, then Board) |

## Use
- Gameplay use: common enemy with a plain attack, in the right two thirds, facing left.
- Size on screen: about 380 px tall on the canvas (about 35% of screen height).
- Region: inside the 16:9 core.

## Canvas
- Frame canvas: 512 x 512, 4 x 3 cells, one frame per cell. The cell holds the stated on-screen height (about 380 px) plus the tallest and widest action pose at 1:1 (no runtime upscale); the idle figure stays within about 480 px wide so the raised-weapon wind-up has room.
- Safe area / overscan: n/a.
- Background: transparent.
- Pivot / origin: bottom centre, between the feet. Same on every frame.

## Budget
- Texture memory: sheet 2048 x 1536 x 4 = about 12.6 MB uncompressed (12 cells, 10 used).
- File size target: sheet PNG at most 3 MB.
- Atlas: one sheet, at most 2048 x 2048.
- Frame count: 10 (idle 4, attack 6).

## Look constraints
- Palette roles: ink, stone, paper, Wax, Danger for the strike highlight.
- Lighting: warm from the upper left, cool ambient.
- Silhouette: broad and low (ART-BIBLE §5), clearly different from the hero and from `enemy_frayer`.
- Minimum detail: nothing under 3 px.
- Colour is not the only carrier: the attack reads from the wind-up pose and raised weapon shape.
- No baked text: yes. No telegraph icon in the art (Godot draws it).

## Animation (D2)
- Approach: frame animation. Common enemies use short frame loops (TOOL-DECISIONS D2).
- Reason and integration cost: short loops, few frames, no rig. Playback logic belongs to `gameplay-programmer`.
- States: `idle` 4 frames, loop, 5 fps, 0.8 s; `attack` 6 frames, one-shot, 12 fps, 0.5 s (anticipation frames 1-2, impact frame 4, recovery frames 5-6).
- Event markers (intent): `impact` on frame 4.
- Frame order: row-major, idle first (frames 1-4), then attack (5-10).

## Files
- Editable source: `art_src/enemies/enemy_attacker.kra`
- Export: `assets/slice/enemies/enemy_attacker_sheet.png`
- Godot resource path: set by `gameplay-programmer`.
- Import notes: confirm with `gameplay-programmer`.

## Provenance (fill when made)
- Origin: generated draft + paintover
- Tool and version: _pending_
- Model file name and licence: _pending_
- Generation settings: _pending_
- Prompt text: _pending_
- Reference images used as generator input: none
- Editing steps: _pending_
- Licence notes: _pending_
- Originality check: _pending (director)_

## Acceptance checklist
- [ ] Dimensions, alpha, pivot, naming, frame order match this spec
- [ ] Readable at 25% screen height, distinct from `enemy_frayer`
- [ ] Loop has no pop between last and first idle frame
- [ ] Size and memory inside budget
- [ ] Provenance complete
- [ ] Originality check passed

## Out of scope
Animation logic, scenes, scripts, the telegraph icon, final enemy name.
