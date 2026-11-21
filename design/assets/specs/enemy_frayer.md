# Common enemy: binding-frayer (working name)

| Field | Value |
|---|---|
| Asset ID | `enemy_frayer` |
| Display name | pending (name belongs to `game-designer`, T5) |
| Asset class | enemy |
| Owner | game-artist |
| Priority | high (slice piece 2b) |
| Status | planned |
| Approval state | not approved (approver: director, then Board) |

## Use
- Gameplay use: common enemy that frays bindings; its action reaches toward the bind slots on the left. Facing left.
- Size on screen: about 420 px tall on the canvas (about 39% of screen height).
- Region: inside the 16:9 core.

## Canvas
- Frame canvas: 512 x 512, 4 x 3 cells. The cell holds the stated on-screen height (about 420 px) plus the tallest and widest action pose at 1:1 (no runtime upscale); the reach pose stays inside the cell with headroom.
- Safe area / overscan: n/a.
- Background: transparent.
- Pivot / origin: bottom centre, between the feet. Same on every frame.

## Budget
- Texture memory: sheet 2048 x 1536 x 4 = about 12.6 MB uncompressed (12 cells, 10 used).
- File size target: sheet PNG at most 3 MB.
- Atlas: one sheet, at most 2048 x 2048.
- Frame count: 10 (idle 4, fray reach 6).

## Look constraints
- Palette roles: ink, stone, paper, Wax, Danger for the reaching hands' highlight.
- Lighting: warm from the upper left, cool ambient.
- Silhouette: tall and thin with long hands (ART-BIBLE §5), clearly different from the hero and from `enemy_attacker`.
- Minimum detail: nothing under 3 px.
- Colour is not the only carrier: the fray action reads from the long reaching arm pointing left.
- No baked text: yes. No telegraph icon or line in the art.

## Animation (D2)
- Approach: frame animation (common enemy, TOOL-DECISIONS D2).
- Reason and integration cost: short loops, no rig. Playback logic belongs to `gameplay-programmer`.
- States: `idle` 4 frames, loop, 5 fps, 0.8 s; `fray_reach` 6 frames, one-shot, 12 fps, 0.5 s (anticipation frames 1-2, release frame 4, recovery frames 5-6). The fray VFX (`vfx_fray`) plays at the hands on frame 4.
- Event markers (intent): `release` on frame 4.
- Frame order: row-major, idle first (frames 1-4), then fray_reach (5-10).

## Files
- Editable source: `art_src/enemies/enemy_frayer.kra`
- Export: `assets/slice/enemies/enemy_frayer_sheet.png`
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
- [ ] Readable at 25% screen height, distinct from `enemy_attacker`
- [ ] Loop has no pop
- [ ] Size and memory inside budget
- [ ] Provenance complete
- [ ] Originality check passed

## Out of scope
Animation logic, scenes, scripts, telegraph icon and line, final enemy name.
