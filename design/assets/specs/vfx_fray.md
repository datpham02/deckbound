# Fray VFX

| Field | Value |
|---|---|
| Asset ID | `vfx_fray` |
| Display name | Fray effect |
| Asset class | vfx |
| Owner | game-artist (artwork); `gameplay-programmer` (runtime) |
| Priority | medium (slice piece 7) |
| Status | planned |
| Approval state | not approved (approver: director, then Board) |

## Use
- Gameplay use: plays on a bind slot when a binding is frayed, and at the enemy's hands on the release frame. It must read: a cord's strands springing loose.
- Size on screen: about 256 px square at the slot or hands.
- Region: over the bind slot and the enemy; short enough not to hide telegraphs.

## Canvas
- Frame canvas: 256 x 256; 8 frames in a 4 x 2 sheet, 1024 x 512.
- Background: transparent, straight alpha (premultiplied policy is a Phase 1 item for `gameplay-programmer`).
- Pivot / origin: centre.

## Budget
- Texture memory: 1024 x 512 x 4 = 2 MB uncompressed.
- File size target: PNG at most 300 KB.
- Atlas: stands alone in the slice.
- Frame count: 8.
- Overdraw: one small sprite at a time; no full-screen layer. Counts toward the per-combat effect cap (Phase 1 measurement).

## Look constraints
- Palette roles: Bind accent for the cord, Danger for the snapping ends, Paper flecks, Ink outline.
- Lighting: flat, glow limited to a small warm core.
- Silhouette: radiating loose strands, readable as a solid shape.
- Minimum detail: strands at least 3 px.
- Colour is not the only carrier: the radiating strand shape and a visible gap in the loop.
- No baked text: yes.

## Animation (D2)
- Approach: frame animation, hand-drawn sprites, with runtime scale and fade by Godot tween. A Godot particle burst may be added by `gameplay-programmer`. PixelFX is not used (painterly direction, and not allowed for this role until the Art Bible permits it).
- Reason and integration cost: 8 frames is small; one-shot.
- States: `play` one-shot, 8 frames, 16 fps, 0.5 s (strands tense frames 1-2, snap frame 3, spread frames 4-6, fade frames 7-8).
- Event markers (intent): `snap` on frame 3, the moment the slot icon switches to frayed.
- Frame order: row-major.

## Files
- Editable source: `art_src/vfx/vfx_fray.kra`
- Export: `assets/slice/vfx/vfx_fray_sheet.png`
- Godot resource path: set by `gameplay-programmer`.
- Import notes: confirm with `gameplay-programmer`.

## Provenance (fill when made)
- Origin: original (drawn in Krita)
- Tool and version: _pending_
- Model file name and licence: n/a
- Generation settings: n/a
- Prompt text: n/a
- Reference images used as generator input: none
- Editing steps: _pending_
- Licence notes: _pending_
- Originality check: _pending (director)_

## Acceptance checklist
- [ ] Dimensions, alpha, frame order match this spec
- [ ] Reads at phone scale over the slot and over a dark background
- [ ] Does not hide the telegraph icon
- [ ] Size inside budget
- [ ] Provenance complete
- [ ] Originality check passed

## Out of scope
Shaders, particle systems, the sever effect (M2), triggering logic.
