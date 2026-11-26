# Common enemy: binding-frayer (working name)

| Field | Value |
|---|---|
| Asset ID | `enemy_frayer` |
| Display name | pending (name belongs to `game-designer`, T5) |
| Asset class | enemy |
| Owner | game-artist |
| Priority | high (slice piece 2b) |
| Status | concept (reference look accepted by the Board 2026-11-26; not integrated) |
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

## Reference look (Board decision 2026-11-26)
- The Board accepted the idle key pose in `art_src/enemies/enemy_frayer/key_pose/enemy_frayer_idle_keypose_512.png` (sha256 `c95e623a6381bdfcf01fd612b0b532b5ef8a296fb7f6f2203e304f878a43f1ee`) as the reference look. Status: concept. It is not an export and not integrated.
- View: three-quarter, with the body turned toward the viewer and the face and long reaching arm toward the left. The Board chose this over a side profile so the enemy faces the player. The spec text "facing left" is read as this view.
- It replaces the earlier frayer candidate in the SOU-65 art slice.
- Origin: the First Art Generation Pilot (company issue SOU-94). The game-artist made the drafts and the first cleanup; the operator applied the Board-requested fixes below.

## Provenance
- Origin: generated (comfy-draft) + own-art edit via comfy-edit (SDXL inpaint) + scripted cleanup (art-ops)
- Tool and version: ComfyUI 0.46.0 via comfy-draft.py and comfy-edit.py; art-ops.py
- Model file name and licence: `flux1-schnell-fp8.safetensors` (Apache-2.0) for the generation; `sd_xl_base_1.0.safetensors` (CreativeML Open RAIL++-M) for the inpaint
- Generation settings: seed 9306 (round 9301-9308), 832 x 1216, 4 steps, euler/simple, cfg 1.0, no negative prompt. File `art_src/enemies/enemy_frayer/generation/enemy_frayer_flux_20261126-170406_s9306_0.png` (sha256 `37e5157f1073a3d7395b61d6890c8f10e52709d450935a94666166451a98ab5a`)
- Prompt text: "2D hand-drawn illustration, bold uneven black ink outlines, flat cel shading with two or three flat tones, stylised exaggerated proportions, clean flat colour, muted dark palette with one warm amber accent, no 3D rendering. A tall thin gaunt figure about eight heads tall with a small narrow head and one very long thin arm reaching far out to the left, ending in long spindly hands with a small dark red highlight on the fingertips. Two thin legs only, standing on two feet, in a stone-grey ragged robe whose frayed hem ends at the ankles, the ankles and both feet clearly visible below it. Stone-grey skin, paper-pale rags, near-black ink shadows, loose blue-teal cords hanging from the other arm. Three-quarter view: the body is turned about 40 degrees toward the viewer, the face and the long reaching arm point to the left. Warm light from the upper left, cool ambient. Plain flat uniform light grey background, no shadow on the ground, no floor, no text, no signature."
- Reference images used as generator input: none for the generation. Own-art input for comfy-edit: the seed-9306 image above.
- Editing steps (in order):
  1. Shadow mask (art-ops): `mask --from-color <s9306> 157 156 145 --tolerance 12`, limited to the floor band y 1040-1115 with `compose`, then `mask --grow 4 --feather 2`. File `edit/enemy_frayer_s9401_shadow_mask.png` (sha256 `4086dec936517bcd37ea19c482e301d7ad95e489069c75c9b62ccb17ea57148c`).
  2. `comfy-edit inpaint --model sdxl --seed 9401 --denoise 1.0`, 30 steps, euler/normal, cfg 7.0. Prompt "plain flat uniform warm off-white paper background, empty, no shadow, no floor, no texture"; negative "text, watermark, logo, signature". This removed the baked foot shadow. `outside_mask_changed: 0`. Output `edit/enemy_frayer_inpaint_sdxl_20261126-172924_s9401.png` (sha256 `cb93ca2b4e1295c514f42116ce9e150ebea3092679b2e20e30fe8c47ce188eb5`).
  3. `art-ops key --tolerance 40 --soft 20` (corner colour).
  4. Enclosed backdrop pockets (between the legs, and between the right arm and the robe) cannot be reached by `key`. They were erased by composing the keyed image over a transparent 832 x 1216 base with `compose --mask` and a keep-mask, which is the inverse of `mask --from-color <s9401> 249 246 238 --tolerance 50 --grow 1`. File `edit/enemy_frayer_pocket_keep_mask.png` (sha256 `998cc0856a140ee846ffc788dc2ccc19a9a0324aba767662e49a2dfd522f507c`).
  5. `art-ops grade --brightness 0.62 --contrast 1.18 --saturation 0.5` (toward the stone/ink palette), then `trim`, `resize --size 512 420 --fit contain`, `canvas --size 512 512 --anchor bottom_center` → `key_pose/enemy_frayer_idle_keypose_512.png`.
- Signature/text check: this image has no mark (full-size check of the lower strip). In the same round, seed 9304 was discarded for a mark.
- Known minor defects: a faint residue under the feet; slightly smeared left toes (inpaint mask edge); feet a little right of the canvas centre.
- Licence notes: as listed in `AGENTS.md` "Assets and licensing"; no outside image used.
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
