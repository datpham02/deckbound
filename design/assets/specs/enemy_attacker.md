# Common enemy: plain attacker (working name)

| Field | Value |
|---|---|
| Asset ID | `enemy_attacker` |
| Display name | pending (name belongs to `game-designer`, T5) |
| Asset class | enemy |
| Owner | game-artist |
| Priority | high (slice piece 2a) |
| Status | art-ready candidate (single pose, D2 fallback proposed) |
| Approval state | not approved (approver: director, then Board) |

## Use
- Gameplay use: common enemy with a plain attack, in the right two thirds, facing left in a three-quarter view (see Look constraints).
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
- Style: A Ink Cel (ART-BIBLE §3A): bold uneven ink outline, two or three flat tones per surface, no gradients or soft volume.
- Lighting: warm from the upper left, cool ambient.
- View: three-quarter, with the body turned about 30-45 degrees toward the viewer and the face and the action toward the left (Board decision 2026-11-26). Not a side profile, not straight-on. Prompts state the view explicitly; a bare "facing left" produced side profiles. The current slice sheet (SOU-65) was made before this decision; whether it needs a redo is a separate Board decision.
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
- Source deliverables (replace the Krita source): the selected generations (raw, unkeyed) and the per-part or per-frame PNGs the asset needs, kept under `art_src/enemies/enemy_attacker/` with provenance. Krita stays optional (deckbound PR #20); a `.kra` file is not required.
- Export: `assets/slice/enemies/enemy_attacker_sheet.png`
- Godot resource path: set by `gameplay-programmer`.
- Import notes: confirm with `gameplay-programmer`.

## Provenance (fill when made)
- Origin: generated (comfy-draft) + own-art edits via comfy-edit (inpaint, matte) + scripted cleanup (art-ops)
- Tool and version: ComfyUI 0.46.0 via comfy-draft.py and comfy-edit.py
- Model file name and licence: `flux1-schnell-fp8.safetensors` (Apache-2.0) for the generation; `sd_xl_base_1.0.safetensors` (CreativeML Open RAIL++-M) for inpaint; `birefnet.safetensors` (MIT, sha256 9ab37426bf4de0567af6b5d21b16151357149139362e6e8992021b8ce356a154) for matte
- Generation settings: selected image seed 7106 (batch 7105-7107), 832 x 1216, 4 steps, euler/simple, cfg 1.0, no negative prompt. Stem `enemy_attacker_flux_20261122-180731_s7106_0`
- Prompt text: `<A STYLE>` (ART-BIBLE §3A) + "One creature standing, full body, facing left, a very wide low hunched brute, shoulders wider than its whole body is tall, a very small head sunk between the shoulders, short thick legs, long heavy arms, stone-grey skin, a stone-grey leather apron, a dark red wax seal with no markings on the chest, gripping a huge wooden mallet with a big square head raised high above its head with both hands, hostile stance, no tail. Warm light from the upper left, cool ambient. Plain flat uniform light grey background, no shadow on the ground, no floor, no text, no signature."
- Reference images used as generator input: none for generation. Own-art inputs for comfy-edit: the selected seed-7106 image (input sha256 of the tail inpaint is in the edit record) and its derivatives, all from this task.
- Editing steps (in order):
  1. `art-ops mask --size 832 1216 --rect 622 830 95 80 --feather 2`, then `comfy-edit inpaint --model sdxl --denoise 1.0 --seed 7311` (prompt "plain flat uniform light grey background, empty, nothing"): removes the generated tail. `outside_mask_changed: 0`.
  2. `art-ops mask --ellipse 365 285 185 100 --feather 2`, then `comfy-edit inpaint --model sdxl --denoise 0.8 --seed 7331` (prompt "angry grey stone-skinned brute face with small eyes and a heavy brow, plain bald stone-grey skin, no red marks, flat cel shading, bold black ink outline"): removes red cheek marks and green hair crest (off palette role). `outside_mask_changed: 0`, input sha256 b2639ffbf0fc4b71ffa3872c77db14ea235de3c55694bf127990ad56f0b662d9 (the tail-free image).
  3. `comfy-edit matte` (BiRefNet), run `a500b59f5a84`, input sha256 8b8cc6ae575e6a2c8275169a5a4e6a6905e5d7ddf68b0e8354bf5f60f1e037dc: check passed, leftover backdrop 0.004 %, soft edge 3.276 %, no baked foot shadow.
  4. `art-ops trim`, `resize --size 480 380 --fit contain`, `canvas --size 512 512 --anchor bottom_center`, `sheet --cols 4 --cell 512 512` to `assets/slice/enemies/enemy_attacker_sheet.png`.
- Generated images: 26 of 32 for the whole task (attacker batch 7101-7104, 7105-7107; frayer 7201-7204, 7205-7207; 8 inpaints; 4 img2img pose tests). Signature/text check (2026-11-22, game-artist): committed sheets show only checked images, mark found: no. Discarded for a mark: 7101, 7103, 7104, 7107, and one img2img pose test.
- Licence notes: Apache-2.0, CreativeML Open RAIL++-M and MIT models as listed in `AGENTS.md` "Assets and licensing"; no outside image used.
- Originality check: _pending (director)_

## Candidates (assets/slice/review/enemy_attacker/candidates.png, left to right)
Only images without a signature or text are shown. 7102 rejected: the mallet is a small tube that does not read as a raised weapon shape at 270 px. 7105 rejected: mallet reads well, but a tail and an olive-brown apron with dark leg guards (off palette role). 7106 **selected**: raised square-headed mallet reads as a weapon at distance, broadest and lowest body.

## Round log
- Round 1 (`r1_idle_on_bg.png`, `before_after.png` left): tail removed. Defects found: red cheeks (Danger/Wax hue off role), green hair crest.
- Round 2 (`before_after.png` right): cheeks and crest removed by head inpaint. Remaining: a dark green necklace cord (reads near-black), brown apron (desaturated, inside the tan family), small orange tint on the top of the head.
- Pose path: `comfy-edit img2img` (denoise 0.7, FLUX) from the idle did not change the pose (still mallet raised), added tails and one mark. **Tool capability failure: strike pose (mallet down) — what would fix it: a pose-controlled edit (mask-based repaint of the arms and mallet at SDXL with a pose guide) or a hand-drawn strike pose.** Path stopped.

## D2 fallback (for Director to accept)
Generated frames cannot stay consistent, so the export is one clean pose: the raised-mallet wind-up. Layout deviation: `assets/slice/enemies/enemy_attacker_sheet.png` is 2048 x 512 (a 4 x 1 strip, cell 1 used, cells 2-4 empty); the spec's 2048 x 1536 / 10-frame layout is not met. Proposed Godot transforms (for `gameplay-programmer`): `idle` = slow scale-y breathing about the bottom-centre pivot (about 2 %, 0.8 s loop); `attack` = anticipation (rotate 4 deg back, 0.17 s), snap forward lunge (rotate 8 deg forward, move 40 px left, 0.08 s, impact event here), recovery ease (0.25 s). Pivot: bottom centre of the 512 x 512 cell. The strike pose itself is not drawn; the impact reads from the lunge and the VFX.

## Evidence
`assets/slice/review/enemy_attacker/contact.png` (cell at 380 px and a 25 % cell, on `#1B2026`), `candidates.png`, `before_after.png`, `r1_idle_on_bg.png`; silhouette comparison with the frayer: `assets/slice/review/enemy_frayer/compare_with_attacker.png`.
Deferred: UNVERIFIED — deferred to SOU-61: readability over the real combat background, in-engine scale against the other slice assets, animation timing in context.

## Acceptance checklist
- [ ] Dimensions, alpha, pivot, naming, frame order match this spec
- [ ] Readable at 25% screen height, distinct from `enemy_frayer`
- [ ] Loop has no pop between last and first idle frame
- [ ] Size and memory inside budget
- [ ] Provenance complete
- [ ] Originality check passed

## Out of scope
Animation logic, scenes, scripts, the telegraph icon, final enemy name.
