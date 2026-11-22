# Common enemy: binding-frayer (working name)

| Field | Value |
|---|---|
| Asset ID | `enemy_frayer` |
| Display name | pending (name belongs to `game-designer`, T5) |
| Asset class | enemy |
| Owner | game-artist |
| Priority | high (slice piece 2b) |
| Status | art-ready candidate (single pose, D2 fallback proposed) |
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
- Style: A Ink Cel (ART-BIBLE §3A): bold uneven ink outline, two or three flat tones per surface, no gradients or soft volume.
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
- Source deliverables (replace the Krita source): the selected generations (raw, unkeyed) and the per-part or per-frame PNGs the asset needs, kept under `art_src/enemies/enemy_frayer/` with provenance. Krita stays optional (deckbound PR #20); a `.kra` file is not required.
- Export: `assets/slice/enemies/enemy_frayer_sheet.png`
- Godot resource path: set by `gameplay-programmer`.
- Import notes: confirm with `gameplay-programmer`.

## Provenance (fill when made)
- Origin: generated (comfy-draft) + own-art edits via comfy-edit (inpaint, matte) + scripted cleanup (art-ops)
- Tool and version: ComfyUI 0.46.0 via comfy-draft.py and comfy-edit.py
- Model file name and licence: `flux1-schnell-fp8.safetensors` (Apache-2.0) for the generation; `sd_xl_base_1.0.safetensors` (CreativeML Open RAIL++-M) for inpaint; `birefnet.safetensors` (MIT, sha256 9ab37426bf4de0567af6b5d21b16151357149139362e6e8992021b8ce356a154) for matte
- Generation settings: selected image seed 7206 (batch 7205-7207), 832 x 1216, 4 steps, euler/simple, cfg 1.0, no negative prompt. Stem `enemy_frayer_flux_20261122-180831_s7206_0`
- Prompt text: `<A STYLE>` (ART-BIBLE §3A) + "One creature standing, full body, facing left, a very tall thin gaunt figure in a tattered dark stone-grey robe with a straight hem, ash-grey skin, a very small narrow head, extremely long thin arms with long fingers, one long arm stretched straight out to the left at shoulder height with an open hand, loose frayed threads hanging from the fingers, a dark red wax seal with no markings on the chest, no tail, legs hidden under the robe. Warm light from the upper left, cool ambient. Plain flat uniform light grey background, no shadow on the ground, no floor, no text, no signature."
- Reference images used as generator input: none for generation. Own-art inputs for comfy-edit: the selected seed-7206 image and its derivatives, all from this task.
- Editing steps (in order):
  1. `art-ops mask --size 832 1216 --rect 552 900 148 175 --feather 2`, then `comfy-edit inpaint --model sdxl --denoise 1.0 --seed 7301` (prompt "plain flat uniform light grey background, empty, nothing"): removes the generated tail. Input sha256 fe899dbc4af973d23b688b18e52662ed903c772675837d1248e535391a25b30e. `outside_mask_changed: 0`.
  2. First matte (run `2a2898b375a5`, leftover backdrop 0.135 %) left a white pocket between beak and neck. Fix: `art-ops mask --rect 335 225 80 60 --feather 2`, `comfy-edit inpaint --model sdxl --denoise 0.9 --seed 7321` (prompt "dark ash-grey thin neck in shadow under a bony head, flat cel shading, bold black ink outline"), input sha256 55d271b8ccfbaa597ff3fec08a3525417cb0f8c18cf401bd6879243c64a42d38. `outside_mask_changed: 0`.
  3. `comfy-edit matte` (BiRefNet), run `2b064d20a68d`, input sha256 f681e6b8fa6b428e9e85a74e5b273dbbfdd33a410e658c7cd047e4f9e53b0604: check passed, leftover backdrop 0.02 %, soft edge 6.39 %, no baked foot shadow.
  4. `art-ops trim`, `resize --size 480 420 --fit contain`, `canvas --size 512 512 --anchor bottom_center`, `sheet --cols 4 --cell 512 512` to `assets/slice/enemies/enemy_frayer_sheet.png`.
- Generated images: see `enemy_attacker.md` (26 of 32 for the whole task, shared count). Signature/text check (2026-11-22, game-artist): committed sheets show only checked images, mark found: no. Discarded for a mark: 7202, 7207.
- Licence notes: as listed in `AGENTS.md` "Assets and licensing"; no outside image used.
- Originality check: _pending (director)_

## Candidates (assets/slice/review/enemy_frayer/candidates.png, left to right)
Only images without a signature or text are shown. 7203 rejected: wide trailing cloak ribbons and a long tail make the figure wider and heavier at the hem than "tall and thin". 7205 rejected: no reach to the left, the arm hangs down. 7206 **selected**: tallest and thinnest, long arm and open hand reach left, hanging thread.

## Round log
- Round 1 (`r1_reach_on_bg.png`): tail removed. Defect found: white backdrop pocket between beak and neck.
- Round 2 (`before_after.png`, left first matte, right final): pocket filled by neck inpaint and re-matted. Remaining: a short tail stub next to the right foot, the hanging thread under the hand is under 3 px at screen scale, and the dark robe sits close in value to `#1B2026` (still reads in `contact.png`, but low contrast).
- Pose path: `comfy-edit img2img` (denoise 0.7, FLUX) did not lower the arm (pose unchanged), added tails and one gradient image. **Tool capability failure: idle pose with arms down — what would fix it: a mask-based repaint of the arm plus a pose guide, or a hand-drawn pose.** Path stopped.

## D2 fallback (for Director to accept)
Generated frames cannot stay consistent, so the export is one clean pose: the reach (the `release` key pose, frame 4 intent). Layout deviation: `assets/slice/enemies/enemy_frayer_sheet.png` is 2048 x 512 (a 4 x 1 strip, cell 1 used); the spec's 2048 x 1536 / 10-frame layout is not met. Proposed Godot transforms (for `gameplay-programmer`): `idle` = slow sway (rotate +-1.5 deg about the bottom-centre pivot, 0.8 s loop); `fray_reach` = lean back (rotate 3 deg, 0.17 s), then forward slide 30 px left (0.08 s, `release` event, `vfx_fray` at the hand near the upper left of the cell), recovery ease (0.25 s). The idle and reach pose are the same drawing, so the reach does not change the arm: that is the known limit of D2.

## Evidence
`assets/slice/review/enemy_frayer/contact.png` (cell at 420 px and a 25 % cell, on `#1B2026`), `candidates.png`, `before_after.png`, `r1_reach_on_bg.png`, `compare_with_attacker.png` (silhouette difference from the attacker).
Deferred: UNVERIFIED — deferred to SOU-61: readability over the real combat background, in-engine scale against the other slice assets, animation timing in context.

## Acceptance checklist
- [ ] Dimensions, alpha, pivot, naming, frame order match this spec
- [ ] Readable at 25% screen height, distinct from `enemy_attacker`
- [ ] Loop has no pop
- [ ] Size and memory inside budget
- [ ] Provenance complete
- [ ] Originality check passed

## Out of scope
Animation logic, scenes, scripts, telegraph icon and line, final enemy name.
