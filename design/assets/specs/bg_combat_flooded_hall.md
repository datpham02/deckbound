# Combat background: flooded hall

| Field | Value |
|---|---|
| Asset ID | `bg_combat_flooded_hall` |
| Display name | Combat background: flooded hall |
| Asset class | background |
| Owner | game-artist |
| Priority | medium (slice piece 5) |
| Status | planned |
| Approval state | not approved (approver: director, then Board) |

## Use
- Gameplay use: the single combat background for the first floor.
- Size on screen: full-bleed.
- Region: lanes for the Scrivener (left third), play area, and enemies (right two thirds) are kept clear of busy detail. Nothing important in the overscan strip or the outer 16:9 crop margin.

## Canvas
- Dimensions: 2640 x 1080 (2400 canvas plus 120 px overscan per side, for 22:9; ART-BIBLE §4.1).
- Safe area / overscan: the centre 1920 x 1080 holds all composition anchors.
- Background: opaque.
- Pivot / origin: centre.

## Budget
- Texture memory: 2640 x 1080 x 4 = about 11.4 MB uncompressed (about 2.9 MB as ASTC 4x4, estimate; confirmed by `gameplay-programmer`).
- File size target: PNG at most 3.5 MB.
- Atlas: stands alone (over 2048 wide, so it is not packed; needs a note for `gameplay-programmer` on texture limits).
- Frame count: 1.

## Look constraints
- Palette roles: Water black, Stone dark and mid, Stone light rim, Lantern warm (one light source).
- Lighting: one warm lantern from the upper left, cool ambient, black water reflecting it.
- Value rule: two value steps darker than characters. No high-contrast shapes behind the lanes.
- Minimum detail: nothing under 3 px; texture is low-frequency, so characters and telegraphs win.
- Colour is not the only carrier: n/a.
- No baked text: yes.

## Animation (D2)
- Approach: static illustration. No parallax in the slice (Art Bible: only where it adds value). Optional water shimmer by Godot shader, owned by `gameplay-programmer`.
- Reason and integration cost: one opaque layer keeps overdraw low.

## Files
- Editable source: `art_src/backgrounds/bg_combat_flooded_hall.kra`
- Export: `assets/slice/backgrounds/bg_combat_flooded_hall.png`
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
- [ ] 2640 x 1080 opaque; centre 1920 x 1080 holds the composition
- [ ] Hero and both commons keep a clear silhouette against it
- [ ] Holds at 16:9, 20:9 and 22:9 with no letterbox
- [ ] Size and memory inside budget
- [ ] Provenance complete
- [ ] Originality check passed

## Out of scope
Parallax layers, props, other screens, shaders.
