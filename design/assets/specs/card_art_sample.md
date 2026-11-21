# Card illustration (one sample)

| Field | Value |
|---|---|
| Asset ID | `card_art_sample` |
| Display name | Card illustration sample (page name belongs to `game-designer`, T4) |
| Asset class | card_art |
| Owner | game-artist |
| Priority | medium (slice piece 3) |
| Status | art-ready candidate; FAILS file-size budget (1.16 MB vs 900 KB), see Provenance |
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
- Source: generated; reproducible from the provenance block (model, seed, prompt, settings) and the workflow JSON kept in `~/game-studio-workspace/staging/art/card_art_sample/`
- Export: `assets/slice/cards/card_art_sample.png`
- Godot resource path: set by `gameplay-programmer`.
- Import notes: confirm with `gameplay-programmer`.

## Provenance (fill when made)
- Origin: generated + scripted cleanup (deckbound PR #20); no paintover
- Tool and version: ComfyUI 0.46.0 via comfy-draft.py
- Model file name and licence: sd_xl_base_1.0.safetensors, CreativeML Open RAIL++-M
- Generation settings: seed 402, 25 steps, euler, normal, cfg 7.0, 896x1152; workflow `card_art_sample_sdxl_20261122-042027_s402.workflow.json`
- Prompt text: "dark fantasy painted illustration, close view of one single torn sheet of old parchment with ragged edges, bound to a thick frayed cord that loops across it, resting on wet dark stone, black water behind, warm amber glow from upper left, cool blue-grey shadows, a small copper tag on the cord, a small teal knot, muted painterly, empty page, no text, no letters, no lamp, no book"
- Negative prompt: "text, letters, writing, lamp, lantern, candle, book, watermark, frame, border, people"
- Reference images used as generator input: none
- Editing steps: `art-ops.py resize <s402 png> assets/slice/cards/card_art_sample.png --size 700 900` (Lanczos, same 7:9 ratio). Previews: `grade --contrast 0.6`, then `resize --size 280 360`.
- Images generated: 11 of 32 (7 first round, 4 refine round 1)
- Licence notes: output of an allowed model, no input images.
- Known gap (Tool capability failure: PNG size reduction): the PNG is 1,161,980 bytes, over the 900 KB budget. `art-ops.py` has no quantise or PNG optimise; softening the image by 20% still gave 1.0 MB. Needs a PNG optimiser (e.g. 256-colour quantise) or a budget decision.
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
