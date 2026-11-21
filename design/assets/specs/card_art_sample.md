# Card illustration (one sample)

| Field | Value |
|---|---|
| Asset ID | `card_art_sample` |
| Display name | Card illustration sample (page name belongs to `game-designer`, T4) |
| Asset class | card_art |
| Owner | game-artist |
| Priority | medium (slice piece 3) |
| Status | planned |
| Approval state | not approved (approver: director, then Board) |

## Use
- Gameplay use: illustration behind the compact face in hand (reduced contrast) and full in the spread.
- Size on screen: spread size, about 700 x 900 px.
- Region: subject inside a central focal region (about the middle 60% of width and height), because text covers the compact face.

## Canvas
- Dimensions: 700 x 900 (7:9), authored at spread size, no larger (concept).
- Safe area / overscan: keep important detail at least 70 px from each edge, since frames and 9-slice borders cover the edge.
- Background: opaque.
- Pivot / origin: n/a.

## Budget
- Texture memory: 700 x 900 x 4 = about 2.4 MB uncompressed.
- File size target: PNG at most 900 KB.
- Atlas: packed with other card art later; not packed in the slice.

## Look constraints
- Palette roles: full anchor set; Play and Bind accents each appear once as a small motif.
- Lighting: warm from the upper left, cool ambient.
- Silhouette: single clear subject (a torn page and cord) that still reads when about 60% is covered by text.
- Minimum detail: nothing under 3 px at 700 x 900.
- Colour is not the only carrier: n/a (identification art, not state).
- No baked text: yes.

## Animation (D2)
- Approach: static illustration + Godot transform effects (hover is not used; play and bind feedback by tween).
- Reason and integration cost: none beyond the texture; effects belong to `gameplay-programmer`.

## Files
- Editable source: `art_src/cards/card_art_sample.kra`
- Export: `assets/slice/cards/card_art_sample.png`
- Godot resource path: set by `gameplay-programmer`.
- Import notes: confirm with `gameplay-programmer`.

## Provenance (fill when made)
- Origin: generated draft + paintover (human paintover and cleanup in Krita per pipeline §3)
- Tool and version: _pending_
- Model file name and licence: _pending_
- Generation settings: _pending_
- Prompt text: _pending_
- Reference images used as generator input: none
- Editing steps: _pending_
- Licence notes: _pending_
- Originality check: _pending (director)_

## Acceptance checklist
- [ ] Dimensions and naming match this spec
- [ ] Subject readable with a compact-face text overlay at reduced contrast
- [ ] Text on it meets 4.5:1 in the reduced-contrast mockup
- [ ] Size and memory inside budget
- [ ] Provenance complete
- [ ] Originality check passed

## Out of scope
Card frame, text, rarity cues, card back.
