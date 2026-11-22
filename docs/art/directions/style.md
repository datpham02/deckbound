# Direction record: game-wide 2D art style (`style`)

Task: SOU-79. Lane: L2 new visual direction. Author: `game-artist`. Decider: `director` (Board decision 2026-11-22, R8). Status: **proposed; awaiting `director`**. Concept images only; no production export.

Why: the Board finds the current renders too 3D (semi-realistic lighting and volume) and wants a high-end 2D card-game look, built from general 2D traits (no other game's look, no names in prompts, no outside images as input).

What stays: the Scrivener's Bell Cloak identity (`docs/art/directions/char_scrivener.md`, direction B), the setting, and the Art Bible palette roles and value rules (§2–§3). No direction changes them. All four keep one warm light from the upper left with cool ambient.

## Evidence (all under `assets/slice/review/style_direction/`)
- `style_sheet.png` (800 x 1400, background `#1B2026`): the comparable sheet. Rows A, B, C, D from top to bottom. Each row: the Scrivener (325 px tall) on the left, `enemy_attacker` (190 px tall, the 380 : 650 height ratio at half scale) on the right, same cell size (400 x 350), shared baseline.
- `silhouettes_270.png` (800 x 1160): the same eight figures as flat black shapes, Scrivener 270 px tall (25% of 1080), enemy 158 px tall (same ratio), same row order. Background is Stone light `#6B7780` because black on `#1B2026` is invisible; the colour sheet is the test on `#1B2026`.

## The four directions

| | A Ink Cel | B Brush Blocks | C Soft Gouache | D Chunky Vector |
|---|---|---|---|---|
| Defined by | Bold uneven ink outline, flat cel shading in 2–3 tones | No line; flat painted colour blocks with dry-brush and paper grain | No or hairline outline; matte soft gouache | Thin clean outline, flat two-tone, big head and hands |
| Line | bold, uneven | none | none / hairline | thin, clean |
| Shading | flat cel, 2–3 tones | painted flat blocks | soft blended gouache | flat 2 tones |
| Proportions | stylised, exaggerated | natural | natural-stylised | chunky |
| Texture | clean | brush and paper grain | paper grain | clean |
| Palette | muted, one amber accent | muted, cool-leaning | richer, saturated amber, teal, wax red | richer, saturated |
| Selected images | Scrivener `s5101`, enemy `s5111` | Scrivener `s5201`, enemy `s5222` | Scrivener `s5304`, enemy `s5313` | Scrivener `s5401`, enemy `s5411` |

### Style recipes (reproduce with `comfy-draft.py --asset style_direction --model flux`, 832 x 1216, FLUX schnell, 4 steps, euler/simple, cfg 1.0, no negative prompt)
Each prompt is `<STYLE>. <SUBJECT>. Warm light from the upper left, cool ambient. Plain flat light grey background, no text, no signature.`

- **A STYLE:** "2D hand-drawn illustration, bold uneven black ink outlines, flat cel shading with two or three flat tones, stylised exaggerated proportions, clean flat colour, muted dark palette with one warm amber accent, no 3D rendering". Seeds: Scrivener 5101, enemy 5111.
- **B STYLE (Scrivener):** "2D painted illustration made of flat colour blocks with visible dry brush texture and paper grain, no outlines, natural proportions, muted cool dark palette, no 3D rendering". Seed 5201.
  **B STYLE (enemy, round 2, flatter):** "flat 2D painted illustration built from flat opaque colour blocks like cut paper, visible dry brush strokes and paper grain, no outlines, no gradients, no soft volume shading, no rim light, no 3D rendering, muted cool dark palette" (ends "unsigned, no text"). Seed 5222.
- **C STYLE (enemy):** "2D soft gouache illustration, matte opaque paint, soft blended edges, hairline outline only, paper grain, natural stylised proportions, rich saturated accent colours of amber, teal and wax red on deep dark tones, no 3D rendering". Seed 5313.
  **C STYLE (Scrivener, round 2, flatter):** "flat 2D gouache illustration, matte opaque flat paint areas with soft edges, hairline outline, paper grain, no volumetric shading, no gradients, no 3D rendering, rich saturated amber, teal and wax red on deep dark tones" (ends "unsigned, no text"). Seed 5304.
- **D STYLE:** "2D flat vector-style illustration, thin clean dark outline, flat two-tone shading, chunky short stocky proportions with big hands and big head, clean smooth shapes, rich saturated colours, no 3D rendering". Seeds: Scrivener 5401, enemy 5411.
- **SUBJECT, Scrivener:** "One figure, full body, facing right, a scribe in a huge dark hooded bell-shaped cloak, small hood with a visible pale chin, pale hands holding a thick closed contract book at the chest, a small glowing lantern hanging from a hook held in the back hand, three red cords tied at shoulder, chest and hip."
- **SUBJECT, enemy:** "One creature, full body, facing left, a broad low hunched brute with huge wide shoulders and a small head, long heavy arms, stone-grey leather apron, a wax red seal on the chest, gripping a big wooden mallet raised behind its head, hostile stance." (This is a working design for the style test only, not the approved `enemy_attacker` design.)

## Critique round (1 of 1), on `style_sheet.png` and `silhouettes_270.png`
Located issues, most important first:
1. **Scrivener bell shape is not held by any direction.** Silhouette cells: A is a tall narrow column (hem not flared), B a hooded column, D boxy with the lantern merged into the body; only C has a flared hem (but its cape trails to one side). Fix in production: state the bell mass and flared hem first in the prompt; judge by the silhouette cell, not the colour cell. Not regenerated here (direction question, not a style defect).
2. **Row C Scrivener is orange-brown and teal**, not near-black ink cloak. Off the Art Bible palette roles (Ink, Stone). Fix in production: colour words per palette role. Counted against C.
3. **Enemy weapon silhouette.** Rows B and C: the mallet is lost behind the head or hidden (silhouette cells), so "the attack reads from the raised weapon shape" (`enemy_attacker` spec) fails. A and D read.
4. **Rows B and C enemies are more volumetric than their Scrivener** (soft gradient shading on the skin and apron) even after the flatter prompt in round 2. This is the exact "too 3D" complaint, and B and C are less consistent between the two subjects than A and D.
5. **Cut-out artefacts** (all rows): a pale cast-shadow ellipse at the feet; row D Scrivener has a white hole between the legs and a pale fragment inside the cloak; row B enemy has a pale gap between the legs. Cause: the key removes only the backdrop colour reachable from the edges, and a higher tolerance eats the pale chin and hands. Not fixed.

**Tool capability failure (cut-out only):** pale cast-shadow and enclosed-backdrop fragments on the preview cut-outs — what would fix it: a region-erase or mask-keyed erase in `art-ops`, or generation on a truly flat backdrop with no cast shadow. It does not affect the style decision; the generator's own shadows are not part of the art.

## Production-feasibility judgement (on the sheet; not a rig)
| | Part separation | Hidden areas | Consistency between the two subjects | Verdict |
|---|---|---|---|---|
| A | **Best.** Closed ink contours, flat tones, almost no baked light: parts cut cleanly along lines | Flat fills and a line make a hidden torso or arm easy to paint whole; img2img at low denoise can keep the line weight | **Good.** Same line, same flat shading on both | Easiest to produce and to keep consistent |
| B | Medium. No outline: edges are painted, cloak and background values touch, cut-outs need care | Brush grain must be matched when a hidden area is painted; inpaint can do it but grain seams are likely | Weak. Scrivener is flat, enemy has soft volume | Risky to keep flat across assets |
| C | Hard. Soft edges and blended tones bake light into parts | Soft gradients make repainting hidden parts visibly different | Weak. Palette and volume differ between subjects | Hardest; closest to a 3D read on the enemy |
| D | Good. Thin clean line and two tones separate well | Easy: flat two-tone | **Good.** Same chunky language on both | Easy to produce; chunky proportions change the Bell Cloak mass and the lantern merges into the body |

## Recommendation: **A Ink Cel**
**Why A**
1. It is the clearest "2D, not 3D" answer to the Board's complaint: the bold ink line and two to three flat tones leave no room for glossy volume or soft lighting. B and C slid back toward volumetric shading, in particular on the enemy.
2. Best production fit: closed contours separate parts, flat tones bake in little light, hidden areas are easy to repaint, and the style stayed consistent between the Scrivener and the enemy.
3. The line is a hand-drawn trait of its own and not tied to any one work, which helps the originality gate.
4. At 270 px the Scrivener reads as one dark vertical shape with the lantern clearly outside the body, and the enemy's raised mallet reads.

**Trade-offs of A**
- The ink line is near-black on near-black cloak and `#1B2026`, so the cloak edge needs the cool rim light and the lighter cords from the direction B conditions; the line does not help separation.
- The sheet Scrivener is a tall narrow column, not the Bell Cloak mass (critique 1). Production must prompt the bell mass first and be judged on the silhouette.
- Muted palette with one amber accent matches the Art Bible, but Play, Bind and Danger accents need to be added by role.

**Why not the others**
- **B:** no line, so cut-outs and part separation are harder, brush grain is hard to match across repaints, and the enemy drifted volumetric; the mallet is lost in silhouette.
- **C:** softest and closest to a 3D read; the Scrivener left the Ink and Stone palette (orange-brown robe), the enemy's weapon is lost in silhouette, and hardest to repaint. It has the best bell hem on the Scrivener, which is its one advantage.
- **D:** a good second choice: clean, consistent and easy to produce. Not recommended because the chunky proportions change the Scrivener's Bell Cloak mass (the lantern merges into the body at 270 px) and the saturated palette departs from the muted Art Bible roles. A valid fallback if `director` prefers chunkier characters.

## Process and image count
- One validation image per direction first (Scrivener, FLUX, seeds 5101, 5201, 5301, 5401). All four read as 2D, so I batched. C's validation image carried a signature-like mark and was discarded.
- Enemy round 1: 3 seeds per direction (12). Seven of the 12 carried signature-like marks and were discarded; B had no clean image and C's first pick had a gradient backdrop that could not be keyed. B and C also looked too volumetric, so round 2 used flatter wording: B enemy 3 seeds, C Scrivener 3 seeds.
- **Images generated: 22 of the maximum 48.** FLUX 22, SDXL 0, `comfy-edit.py` 0. Author runs: 1 of 3. Critique round: 1 of 1. Review rounds: 0 of 2.
- Sheets that showed signed images (validation, enemy candidates, round 2 candidates) were deleted and are not committed. The eight images on the committed sheets were each checked for signature or text: none.

## Provenance
Common: ComfyUI 0.46.0 via `comfy-draft.py`, model `flux1-schnell-fp8.safetensors`, licence Apache-2.0 (as verified 2026-11-22, `AGENTS.md` "Assets and licensing"), 4 steps, euler/simple, cfg 1.0, size 832 x 1216, negative prompt none, reference images used as input: **none**, no `comfy-edit` input (so no input SHA256). Candidates and workflow JSON per image stay in `~/game-studio-workspace/staging/art/style_direction/` (not committed). File name stem: `style_direction_flux_<stamp>_s<seed>_0`. Prompts: see "Style recipes" (each `STYLE + SUBJECT + tail`).

| Seed | Stamp | Subject | Direction | Result |
|---|---|---|---|---|
| 5101 | 20261122-131727 | Scrivener | A | **selected** |
| 5201 | 20261122-131752 | Scrivener | B | **selected** |
| 5301 | 20261122-131817 | Scrivener | C | discarded (signature-like mark) |
| 5401 | 20261122-131840 | Scrivener | D | **selected** |
| 5111 | 20261122-131925 | enemy | A | **selected** |
| 5112, 5113 | 20261122-131925 | enemy | A | discarded (signature-like marks) |
| 5211, 5212, 5213 | 20261122-132019 | enemy | B | discarded (signature-like marks; too volumetric) |
| 5311 | 20261122-132114 | enemy | C | not used (gradient backdrop, could not be keyed) |
| 5312 | 20261122-132114 | enemy | C | discarded (signature-like mark) |
| 5313 | 20261122-132114 | enemy | C | **selected** |
| 5411 | 20261122-132210 | enemy | D | **selected** |
| 5412 | 20261122-132210 | enemy | D | discarded (signature-like mark) |
| 5413 | 20261122-132210 | enemy | D | not selected (clean) |
| 5221, 5223 | 20261122-132334 | enemy | B (round 2) | not selected (clean) |
| 5222 | 20261122-132334 | enemy | B (round 2) | **selected** |
| 5302 | 20261122-132430 | Scrivener | C (round 2) | discarded (signature-like mark) |
| 5303 | 20261122-132430 | Scrivener | C (round 2) | discarded (faint text near the feet) |
| 5304 | 20261122-132430 | Scrivener | C (round 2) | **selected** |

Count: 4 + 12 + 3 + 3 = 22.

Editing (review images only, `art-ops.py`, Task Workspace root; intermediates in staging): `key <raw> <out> --tolerance 35 --soft 8` (corner colour), `trim`, `resize --size 400 325|190|270|158 --fit contain`, `grade --brightness 0` (silhouettes), `canvas --size 400 350|290 --anchor bottom_center`, `sheet --cols 2 --cell 400 350|290`, `contact --cell 800 1400|1160 --bg 27 32 38 | 107 119 128 --no-labels`.

## Limitations
- Concept images only. No production export outside the review folder; Art Bible, specs and `char_scrivener` direction record are not edited (separate Task after the decision).
- The enemy is a working design for the style test, not the approved `enemy_attacker` design.
- Originality: no prompt names another work and no outside image was used; the style words are general. No formal originality check was run; that is for `director` and `qa`.
- The generator sometimes adds signature-like marks; every committed image was checked and none show one. A production workflow should check each image.

## Decision
Pending. This section states only what `director` decides, by whom and when.
