# Direction record: game-wide 2D art style (`style`)

Task: SOU-79. Lane: L2 new visual direction. Author: `game-artist`. Decider: `director` (Board decision 2026-11-22, R8). Status: **decided: A Ink Cel (director, 2026-11-22)**. Concept images only; no production export. House style recipe validated in SOU-81 (see "Validation"); written into the Art Bible §3A and `COMFYUI-WORKFLOW.md`.

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

## Validation (SOU-81)
Task: SOU-81. Lane: L1 documentation with a validation run; no production art. Question: does the A recipe hold across 3 subjects and several seeds when it follows the specs (Board conditions (1)-(4))? Answer: **yes on 2D and silhouette; spec compliance is partial and the signature rate is high**. Judged by `game-artist` (not an approval).

### Recipe tested (final, after the one fix round)
`<A STYLE>. <SUBJECT>. Warm light from the upper left, cool ambient. Plain flat uniform light grey background, no shadow on the ground, no floor, no text, no signature.` FLUX schnell via `comfy-draft.py --asset style_validation --model flux --width 832 --height 1216 --count N`, 4 steps, euler/simple, cfg 1.0, no negative prompt, no input image. A STYLE words are those in "Style recipes" above. Subjects (each a design from its spec):
- **Scrivener (seeds 6101-6104):** "One figure standing upright, full body, facing right. The whole figure is one huge near-black bell-shaped cloak: a narrow hood on top, sloping sides and a very wide flared hem like a bell, about five heads tall. Small hood with a visible pale grey chin, pale grey hands, a thick closed pale contract book held at the chest. The back hand reaches out to the left of the cloak, clear of the cloak edge, gripping a short iron hook from which a small glowing amber lantern hangs at hip height. Three thin blue-teal cords tied around the cloak at shoulder, chest and hip, thin cool rim light on the right edge."
- **`enemy_attacker` (seeds 6111-6116):** "One creature standing, full body, facing left, a broad low hunched brute with huge wide shoulders, a very small head sunk between the shoulders, short legs, long heavy arms, stone-grey skin, a stone-grey leather apron, a dark red wax seal with no markings on the chest, gripping a big wooden mallet raised high above its head, hostile stance, no tail."
- **`enemy_frayer` (seeds 6121-6129):** "One creature standing, full body, facing left, a very tall thin gaunt figure in a tattered dark stone-grey robe, ash-grey skin, a very small narrow head, extremely long thin arms with long fingers, one long arm reaching far forward to the left with an open hand, loose frayed threads hanging from the fingers, a dark red wax seal with no markings on the chest, no tail."

Round 1 used the same words without "no shadow on the ground, no floor", without "pale grey" and "stone-grey / ash-grey skin", and without "no tail" and "no markings" (its Scrivener subject said "back hand held out" and "no cast shadow, no ground"). Round 1 images are not committed.

### Evidence (all under `assets/slice/review/style_validation/`)
Per subject, a colour sheet of the clean seeds keyed onto `#1B2026` (figures at 580 px cell height, no labels, left to right in the seed order below) and a 270 px silhouette row on Stone light `#6B7780` (all figures 270 px tall, flat black):
- `scrivener_sheet.png` (1600 x 580) seeds 6101, 6102, 6103, 6104; `scrivener_sil270.png` (1600 x 270)
- `attacker_sheet.png` (1600 x 580) seeds 6111, 6114, 6115, 6116; `attacker_sil270.png` (1600 x 270)
- `frayer_sheet.png` (1200 x 580) seeds 6123, 6124, 6127; `frayer_sil270.png` (1200 x 270)

Only images with no signature or text are committed. Images with a mark were discarded, so the frayer sheet has 3 seeds, not 4: the budget (31 of 32 images) was reached before a fourth clean frayer seed.

### Judging key
P = pass, p = partial (a defect that the production workflow can correct), F = fail. "2D" = flat cel, no glossy volume, no gradients, no depth of field. "Palette" = colours by Art Bible role. "Silhouette" = reads at 270 px as the right figure with its gameplay shape. Per-image grades, committed images only:

| Seed | 2D | Palette | Silhouette 270 | Spec compliance |
|---|---|---|---|---|
| **Scrivener** 6101 | P | p (stray orange cloak lining) | P (lantern outside; hem trails to one side) | p: bell trails, lantern on a chain from the front hand, no shadow |
| 6102 | P | P | P (hook wire under 3 px) | P bell, P lantern on hook out left, F soft baked foot shadow |
| 6103 | P | P | P (hook wire under 3 px) | P bell, p lantern ring held at the chest, F baked shadow |
| 6104 | p (soft lantern glow) | P | P (hook wire under 3 px) | P bell, P lantern on hook outside cloak, no shadow |
| **Attacker** 6111 | P | p (olive-brown apron, yellow teeth) | P (raised mallet) | P broad and low, P raised mallet, F baked shadow, p tail |
| 6114 | P | p (red-brown apron) | P | p tall, P raised mallet, F shadow, p tail |
| 6115 | P | p (brown skirt) | P | P broad and low, P mallet, F shadow |
| 6116 | P | p (tan apron) | P | P broad, p small mallet, F shadow with hatching, p tail |
| **Frayer** 6123 | P | P | P (reach left, thread under 3 px) | P tall and thin, P reach left, F shadow smudge, p tail |
| 6124 | P | P | P | P tall and thin, p reach is a raised hand (arm points up, not left), p tail |
| 6127 | p (soft grey gradient smudge on the long sleeve) | P | P | P tall and thin, P reach left, F shadow, p tail |

### Results per subject (the bar)
| Subject | 2D not 3D: median / worst | Palette roles: median / worst | Silhouette 270: median / worst | Spec compliance: median / worst | Signature or text (final recipe) |
|---|---|---|---|---|---|
| Scrivener | **P** / p (6104) | **P** / p (6101) | **P** / P | **p** / p (6101) | 0 of 4 |
| `enemy_attacker` | **P** / P | **p-P** / p (all four, brown leather) | **P** / P | **p** / p (6116) | 2 of 6 |
| `enemy_frayer` | **P** / p (6127) | **P** / P | **P** / P | **p** / p (6127, 6124) | 6 of 9 |

Bar check (median 2D and palette pass for every subject; cords Bind-teal; silhouette reads at 270 px): **2D pass on all three; silhouette pass on all three; cords Bind-teal on all four Scrivener images (no red cord); palette pass on the Scrivener and the frayer; palette on the attacker passes on the median by `director`'s decision (SOU-81 review)**: the muted brown apron reads as a darkened, desaturated Paper tone. The worst, seed 6114 with a red-brown apron, sits too near Wax and would fail in production; the production prompt keeps "stone-grey apron, no brown". Stop condition 3 does not apply.

Line weight and tone count were consistent across subjects: a 2-4 px uneven near-black outline on every figure and two to three flat tones per surface, with no shared gradient. The two exceptions are the soft glow on one lantern and the grey smudge on one sleeve.

### Spec compliance notes (Board condition (4))
- **Fixed by the recipe change:** the lantern now hangs from a hook outside the cloak edge in 3 of 4 Scrivener images (it was in the front hand under the book in SOU-79); the mallet is raised in 6 of 6 attacker images (it was held down); no figure is a flat column except 6101's trailing hem.
- **Not fixed:** a baked foot shadow remains on 9 of 11 committed images (2 of 4 Scrivener, 4 of 4 attacker, 3 of 3 frayer, counting the frayer shadow smudges) even with "no shadow on the ground, no floor". The Scrivener silhouette is a tall A-shaped cone about 7 heads tall, not the spec's bell about 5 heads tall; the generator does not take a head count from the prompt. The hook wire and the frayer's thread are under 3 px at 270 px (spec minimum detail). Three of four attackers have a tail and all three frayers have a tail, which the specs do not mention. The frayer reach points left in 2 of 3.
- **Production consequence:** these are all corrected in production by selecting, part-building and `art-ops`/`comfy-edit` (the spec's layered parts, a thick hook, no tail), not by the style. The recipe fixes the style; it does not give the specs' proportions.

### Signature and text rate (Board condition (3))
Every generated image was opened and checked for a signature, handwriting, letters or a character-like glyph. A mark means discard. Seal emblems that are abstract shapes (circle and cross, wave) were not counted.
- Round 1 (original recipe), 12 images: **4 marked** (6103 Scrivener; 6112 and 6113 attacker, the latter with letter-like marks on the seal; 6122 frayer) = 33%.
- Round 2 (fix recipe), 12 images: **4 marked** (attacker 6112 signature and 6113 seal letters; frayer 6121 and 6122) = 33%.
- Replacement seeds, 7 images: **4 marked** (frayer 6125 "text" at the corner, 6126, 6128 signature, 6129 character glyph on the seal); attacker 6115 and 6116 clean.
- **Final recipe (round 2 plus replacements), 19 images: 8 marked = 42%** (Scrivener 0 of 4, attacker 2 of 6, frayer 6 of 9). All 31 generated images: 12 marked = 39%. SOU-79 had 9 of 22 = 41%, so "no signature" in the prompt does not prevent it; the marks usually sit in the lower corner. None is committed.
- Consequence: the workflow check (COMFYUI-WORKFLOW.md step 5) is mandatory, and a subject needs about twice as many seeds as the number of clean images wanted.

### Tool capability failures
- **Tool capability failure:** keyed cut-outs keep a pale cast-shadow ellipse and enclosed white fragments (visible on the frayer sleeves in `frayer_sheet.png`); the generator's backdrop was white or cream, not the grey the prompt asked for, so `key` has to take the corner colour — what would fix it: a mask-keyed erase in `art-ops`, or generation on a truly flat backdrop. This also blocks measuring the foot shadow exactly. It does not affect the style decision.
- **Tool capability failure:** a signature or text mark cannot be removed once it is in the image except by inpainting; `comfy-edit.py inpaint` (SDXL) would work in principle but was not tried, because regenerating is cheaper at this size — what would fix it: a seed list with replacements, as used here.

### Process and image count
- **Images generated: 31 of the maximum 32.** FLUX 31, SDXL 0, `comfy-edit.py` 0. Round 1 12 (Scrivener 6101-6104, attacker 6111-6114, frayer 6121-6124), fix round 12 (same seeds), replacement seeds 7 (attacker 6115-6116, frayer 6125-6129). Committed images: 6 sheets showing 11 figures. Fix rounds: 1 of 1. Author runs: 1 of 2. Review rounds: 0 of 2.
- Candidates, workflow JSON and provenance JSON per image are in `~/game-studio-workspace/staging/art/style_validation/` (not committed). Stems: `style_validation_flux_<stamp>_s<seed>_0`, stamps: round 1 Scrivener 20261122-135334, attacker 20261122-135452, frayer 20261122-135606; round 2 Scrivener 20261122-135759, attacker 20261122-135915, frayer 20261122-140031; replacements attacker 20261122-140233, frayer 20261122-140315 (6125-6127) and 20261122-140421 (6128-6129).
- Provenance (common): ComfyUI 0.46.0, `flux1-schnell-fp8.safetensors`, Apache-2.0 (as verified 2026-11-22, `AGENTS.md` "Assets and licensing"), 4 steps, euler/simple, cfg 1.0, 832 x 1216, reference images used as input: none, no `comfy-edit` input. Prompts: see "Recipe tested".
- Editing (review images only, `art-ops.py`, outputs in staging): `key <raw> <out> --tolerance 35 --soft 8` (corner colour), `trim`, `resize --size 400 270 --fit contain`, `grade --brightness 0` (silhouettes), `contact --cell 400 580 --bg 27 32 38 --no-labels` (colour) and `contact --cell 400 270 --bg 107 119 128 --no-labels` (silhouettes).
- Which seeds are in the committed sheets (round 2 recipe): Scrivener 6101, 6102, 6103, 6104; attacker 6111, 6114, 6115, 6116; frayer 6123, 6124, 6127. Not committed because marked: round 2 attacker 6112 and 6113, frayer 6121 and 6122; replacements 6125, 6126, 6128, 6129; every round 1 image.

## Restyle list (SOU-81, acceptance criterion 4)
Judged against A Ink Cel (2D, bold uneven ink outline, two or three flat tones). Nothing is changed here; the Board decides any restyle Task. "No art yet" assets match A by definition once they are made with the recipe; their specs still describe a painterly look and should get one line pointing to the Art Bible section (spec edits are outside this Task).

| Asset | State | Verdict | Note |
|---|---|---|---|
| `card_art_sample` (`assets/slice/cards/card_art_sample.png`, merged, art-ready) | made | **needs restyle** | Painterly semi-real cord and paper with soft gradients, cracks and depth; no outline, no flat tones |
| `bg_combat_flooded_hall` (`assets/slice/backgrounds/bg_combat_flooded_hall.png`, merged, art-ready candidate) | made | **needs restyle** | Photographic stone, depth of field, soft gradients and water reflections; no line, many tones |
| `char_scrivener` | spec only (planned, SOU-64) | matches A once made | The earlier direction images under `assets/slice/review/char_scrivener_direction/` are concept references and are superseded by this style; the spec must be made with the Art Bible recipe |
| `enemy_attacker` | spec only (planned) | matches A once made | The SOU-79 working enemy is not this design |
| `enemy_frayer` | spec only (planned) | matches A once made | |
| `slot_icon_states` | spec only (planned) | matches A once made | Original drawn icons; use the A line weight and flat tones |
| `ui_combat_composition` | spec only (planned) | matches A once made | Godot Control textures; use the A line and palette roles |
| `vfx_fray` | spec only (planned) | matches A once made | Flat-toned frame VFX; PixelFX only with Board approval for this project |
| `target_pack` pieces (`pack_*`) | planned, look references only | matches A once made | Same recipe |
| Review images (`assets/slice/review/*`, including `style_direction/`) | concept and review evidence, not shipped | not applicable | Except the two made assets above, no approved visual asset exists |

## Decision
**A Ink Cel** chosen by `director` on 2026-11-22 (SOU-79 review, round 1). Chosen as recommended. Conditions for the Art Bible update Task: (a) the Scrivener prompt states the Bell Cloak mass and flared hem first and is judged on the silhouette cell; (b) the ink line is near-black on near-black cloak, so the cloak edge relies on the cool rim light and the lighter cords from `char_scrivener.md` direction B; (c) Play, Bind and Danger accents are added by Art Bible palette role, with amber as the one warm accent.
