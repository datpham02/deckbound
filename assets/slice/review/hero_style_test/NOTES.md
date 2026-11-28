# Hero style test v2 (SOU-98): notes

Status (2026-11-28): round 4 delivered a gBot-style layered parts set, assembled and rotate-checked; two joints pass, three show defects. See "Round 4" at the end. The round-1 text below is kept as the record of what failed. Self-check is not an approval.

Image count, whole task: rounds 1 and 2 = 28 to 31; round 3 = 16 (Board allowance 20); round 4 = 30 (Board allowance 30, see "Round 4"). Total 74 to 77 generated images, above the original cap of 40 under the Board's round-3 and round-4 allowances.

Proportion (Board answer 1): the hero is about 5.5 heads tall in `c2_final` (hood 200 px of 1100 px). Chosen because at 345 px on screen the hood, the book at the hip, the lantern at knee height and three cord positions need vertical room; a 3.5-head figure would stack the book, cords and lantern into the same 100 px. Bible §5 says 3 to 4 heads: this is a deviation for the Board to confirm or reject.

## Generated images: 19 of 40 (budget)

All made with `comfy-draft.py`, model `flux1-schnell-fp8.safetensors` (Apache-2.0), 832 x 1216, 4 steps, euler/simple, cfg 1.0, no negative prompt, no input image. ComfyUI 0.46.0. Staging folders: `~/game-studio-workspace/staging/art/hero_v1|v2|v3/` (outside the repository; workflow and provenance JSON live there).

CORE (shared start of every prompt, from Bible §15): `chunky cartoon character, big head, oversized hands, short legs, three and a half heads tall, thick uneven dark brown ink outline, heavy hand-inked line with swelling corners, flat colour fills, a single hard-edged shadow tone, bright saturated colours, clean simple shapes, full body, standing, facing right, plain flat light grey backdrop, no ground shadow, no text.`

| Round | Asset | Seeds | Images | Subject line (after CORE) |
|---|---|---|---|---|
| 1 | hero_v1 | 1101-1104 | 4 | Tired archivist in a long ink-stained knee-length work coat with a high collar and uneven hem, holds a thick book with torn pages in the left hand, a quill in the right hand, round spectacles with large lenses, messy short hair, strips of paper tied with thread on the arm, shoulder and hip, a small lantern hanging on a hook at the back, parchment cream and oxblood red colours with ochre accent, relaxed slouching pose leaning slightly forward |
| 1 | hero_v2 | 2101-2104 | 4 | Determined archivist in a long ink-stained knee-length work coat with a high collar and uneven hem, hugging a thick book with torn pages against the chest with the left arm, the right hand lifted holding a quill like a pen, round spectacles with large lenses, soft cap, strips of paper tied with thread on the arm, shoulder and hip, a small lantern hanging from a hook, saturated burnt orange and ochre yellow coat with dark plum accents, upright striding pose with one foot forward |
| 1 | hero_v3 | 3101-3104 | 4 | Rumpled archivist in a long ink-stained knee-length work coat with a high collar and uneven hem, holds a thick book with torn pages out in front in the left hand, the right hand pinching a torn paper page, round spectacles with large lenses, messy hair with a pen behind the ear, strips of paper tied with thread on the arm, shoulder and hip, a small lantern hanging from a hook, saturated mustard yellow and deep plum purple coat with cream accents, leaning forward mid-stride pose |
| 2 | hero_v1 | 1201-1204 | 4 | CORE with "standing, facing right" replaced by "standing, side view facing right, face turned to the right". Subject: parchment cream coat, bright oxblood red cuffs and sash, quill tucked behind the ear, rest as v1 round 1 |
| 3 | hero_v1 | 1301-1303 | 3 | CORE with "standing, facing right" replaced by "walking to the right, profile view, nose pointing right". Subject as round 2 |

Why rounds 2 and 3: every round-1 v1 image faced left. Rounds 2 and 3 did not fix it (see facing, below).

Candidate sheets (target-size review, all 19): `candidates/cand_v1.png`, `cand_v1b.png`, `cand_v1c.png`, `cand_v2.png`, `cand_v3.png`.

Signature/text check: v1 seed 1301 had a text-like mark at the hem and a scribble near the foot: discarded, not used. The three chosen images (below) and their cut-outs were opened at full size: no mark found. The other candidates were looked at on the sheets only and are not used.

## Selected images and steps

| Variant | Source image | Notes |
|---|---|---|
| v1 | `hero_v1_flux_20261126-222756_s1302_0.png` (seed 1302) | parchment cream coat, oxblood cuffs and sash, ochre-brown straps |
| v2 | `hero_v2_flux_20261126-222356_s2102_0.png` (seed 2102) | saturated orange coat, plum accents, soft cap |
| v3 | `hero_v3_flux_20261126-222505_s3102_0.png` (seed 3102) | mustard coat, plum boots, torn page strips at shoulder |

Steps, same for all three (every command from the repo root):
1. `comfy-edit.py matte --asset hero_vN --input <source>` with defaults (snap 250). First tries on v1 seed 1303 (0.601 % leftover) and v2 seed 2104 (1.01 % leftover) failed the 0.5 % gate; I did not raise `--max-leftover`, and chose seeds 1302 and 2102, which passed. v3 seed 3102 passed first time. Matte model `birefnet.safetensors` (MIT), sha256 9ab37426...a356.
2. `art-ops trim --pad 8`.
3. `vN.png`: `art-ops canvas --size 832 1216 --anchor bottom_center`, then `compose` over a flat grey (214,214,214) 832 x 1216 field. The grey field was made with `contact --cell 832 1216 --bg 214 214 214 --no-labels` from a 4 x 4 px stretched copy of the matte, and the one leftover pixel block was painted over with a crop of the field itself.
4. `vN_sil270.png`: `resize --size 1000 270 --fit contain` of the trimmed matte, then `mask --like <it> --from-alpha <it> --invert` (white field, black figure, 1000 x 270 canvas).
5. `vN_context.png`: field 2400 x 1080 in RGB (38,66,72), a deep teal-blue of about 22 % lightness, made as in step 3 with `contact --cell 2400 1080 --bg 38 66 72`. Figure `resize` to 345 px tall (asset list: 32 % of the screen), `trim`, `compose --at` x about 304 y 303 so the feet sit on the ground line y = 648 (left third, centre about x = 420). Empty enemy box (360 x 270, x 1400, y 378): a brightened copy of the field (`grade --brightness 2.4`) composed through `mask --rect 1400 378 360 270` at opacity 0.3. A thin ground line at y 646 to 650 the same way at opacity 0.5.

Intermediate working files were deleted. Not checked in an engine frame (UNVERIFIED: no Godot frame was made).

## Comparison

| | v1 parchment + oxblood | v2 orange + plum | v3 mustard + plum |
|---|---|---|---|
| Pose | walking, reading, slouched | striding, book hugged | standing, book open, page pinch |
| Silhouette at 270 px | hat-less head, bulky back kit with hanging lantern, long coat. Reads as "person with a backpack". Lantern a thin line | smallest mass, wide leg stride, one strong diagonal. Book merges with the body | head with spiky hair, round book and lantern at the sides. Most distinct head and hands |
| Separation from the field in `_context` | high (cream on dark teal) | highest saturation and warm hue | high (yellow on teal) |
| Proportion | about 5 heads, not 3.5 | about 4.5 heads | about 4.5 heads |
| Identity: coat | pass (long, high collar) | pass | pass |
| Identity: book with torn pages | partial: book yes, torn pages not visible | partial | pass (open, loose strips) |
| Identity: 3 bindings (arm, shoulder, hip) | partial: arm cuff and hip sash, no page strips | fail: only a stripe on the shoulder | partial: page strips at shoulder, none clear at arm and hip |
| Identity: spectacles, hair or cap, pen or quill | pass, quill | pass, cap, no quill seen | pass, pen above book |
| Outline | even, a bit thinner than 2 % on the interior folds | even | even |
| Shading | flat plus one tone, pass | pass | pass, a few soft tone shifts in the coat |
| Facing right | **fail** (faces left) | **fail** (body walks right but the face turns left to the viewer) | **fail** (faces left-front) |

Proportion decision: the generator ignored "three and a half heads" and "short legs" in all 19 images. It always gave 4.5 to 5 heads. I did not change the number in the Bible. The team's call for the next test: keep 3.5 in the words, as head size is what carries the read at 270 px, but add "huge head, stubby legs, head one third of the body" to the prompt. This is untested.

Outline method: kept the outline weight in the prompt, selected the most even results. No normalisation step was used. All three outlines are about 2 to 4 px at 345 px tall, thinner than the 5 px minimum of §2 at on-screen size. A heavier outline is needed (prompt "very thick outline"); it is not fixed here.

Recommended variant: **v3** (mustard and plum). It has the strongest head and hand read, the clearest book with torn pages, and a lantern outside the body. It still fails facing right and proportion. The Board decision should be informed by that: none of the three is final.

## Parts verdict: NOT TESTED

I did not generate parts (0 of the 21 images left in budget used). Two blockers, neither of which I can work around with the approved tools:
1. **No flip.** The hero must face right. The generator gives left-facing figures even when told "facing right", "walking to the right", "nose pointing right" (3 rounds). A horizontal mirror of the finished image would fix it, but `art-ops` has no `flip`.
2. **No rotate.** `parts_rotate_check.png` needs the head, front arm and cloak turned by +/-15 degrees. `art-ops` has no `rotate` (`compose` places only at integer offsets).

Not done because of this: `parts/`, `parts_sheet.png`, `parts_assembled.png`, `parts_rotate_check.png`. A separate risk, not yet tested: whether text-only prompts can give separate parts that match the design target. I expect that to be the hard part.

Ask: `gameplay-programmer` adds `flip` (horizontal) and `rotate` (degrees about a pivot, transparent fill, bicubic) to `art-ops` (shared pipeline code, not mine), or the Board tells me another approved route. Then I run the parts test, with 21 images left and 2 runs.

(Round 1 is superseded: `flip` and `rotate` were installed and the Board rejected round 1 as not fitting the genre. Its images are now in `candidates/round1/`.)

---

# Round 2: parts-first (Board "REDO 2")

Status: **method test stopped at the stop condition.** The parts-sheet render did not give clean, consistent parts within the budget I spent. No variant, no assembled figure and no rotate check exist. That is the test's answer for this method, see "Verdict".

## Image count

Round 1: 19. Round 2 before the parts method: 5 confirmed (SDXL `hero_r2a` x3, `hero_r2b` x2) plus one FLUX call (`hero_r2c`, 3 images) that was cut off by a stopped session and whose output I could not inspect. Parts-sheet renders: 4. **Total 28 if the cut-off call made nothing, 31 if it made 3.** Both are under 40; the Board counted 4 for round 2 at its stop. Staging folders: `hero_r2a`, `hero_r2b`, `hero_r2c`, `hero_sheet_a`.

## Rig blueprint (working scale, px)

Sheet 1024 x 896. Rest pose: standing, three-quarter view facing right, arms a little away from the body, legs apart, nothing across the torso. Cell = part size, top-left on the sheet. Pivot is the joint the part rotates about, relative to the part's top-left.

| Part | Size | Cell (x,y) | Pivot | Joins |
|---|---|---|---|---|
| head_hood | 130x150 | 30,40 | 65,135 | torso top (neck) |
| torso | 130x170 | 190,40 | 65,150 | hips (root) |
| cloak_back | 190x330 | 350,40 | 95,20 | shoulders |
| cloak_front | 170x270 | 580,40 | 85,20 | shoulders |
| book | 130x160 | 790,40 | 65,80 | near hand (grip) |
| lantern | 60x120 | 950,40 | 30,10 | hip hook |
| arm_near_upper | 50x110 | 30,420 | 25,15 | near shoulder |
| arm_near_fore | 46x100 | 120,420 | 23,12 | near elbow |
| arm_near_hand | 48x48 | 206,420 | 24,8 | near wrist |
| arm_far_upper / fore / hand | 50x110 / 46x100 / 48x48 | 300,420 / 390,420 / 476,420 | as near | far side |
| binding_1 (shoulder), _2 (chest), _3 (hip) | 70x26 each | 600,420 / 600,486 / 600,552 | 35,13 | torso, over the cloak |
| thigh_near / shin_near / foot_near | 60x120 / 54x120 / 96x44 | 30,640 / 130,640 / 224,640 | 30,15 / 27,12 / 20,12 | hips, knee, ankle |
| thigh_far / shin_far / foot_far | same | 400,640 / 500,640 / 594,640 | as near | far side |

21 parts. Bones: root/hips, spine, head, 2x (upper arm, forearm, hand), 2x (thigh, shin, foot), cloak_front, cloak_back, book, lantern, binding_1..3.

Draw order, back to front: cloak_back, far arm (upper, fore, hand), far leg (thigh, shin, foot), torso, head_hood, near leg, binding_1..3, lantern, cloak_front, near arm, book (held at the near hand).

Proportion choice: about 5 heads, head not inflated, with the hood and the book as the big shapes. Reason: the hood reads as a flat black mass at 270 px, the book needs a hand-sized grip and the torso needs room for three cords. Not validated: no assembled figure exists.

## Template

`template.png` (1024 x 896): every part blocked as a flat colour shape (ellipses for round parts, rectangles for flat ones) on flat grey (205,205,205). Built only with `art-ops`: `contact --bg` for flat fields, `mask --rect/--ellipse` for each of the 21 shapes, `compose --mask` to place them. No generator input outside this task.

## Renders (SDXL, `comfy-edit.py img2img`, `sd_xl_base_1.0`, 1024 x 896)

Negative prompt, all four: `glasses, bald, cartoon nose, caricature, comic strip, chibi, cute, modern clothing, thin lines, sketch, realistic, photo, 3d render, gradient shading, soft airbrush, painterly texture, text, watermark, signature, full figure, connected figure, assembled body, scenery, multiple characters` (try 2 adds `, blank flat shape` and drops `connected figure`).

| Try | Seeds | Denoise | Positive prompt | Result |
|---|---|---|---|---|
| 1 | 5101, 5102 | 0.65 | character parts sheet for a 2D puppet rig, every part separate and disconnected with wide empty gaps on a plain light grey background, stylised dark fantasy game art, bold thick uneven dark brown hand-inked outline, flat colour fills with a single hard-edged shadow tone, a deep crimson red hood with a dark shadowed face opening, a cream ink-stained scribe coat torso, a crimson red weathered cloak back panel, a crimson red cloak front panel, a thick leather contract book with torn pages and a chain, a brass lantern, arm pieces in cream sleeves with gloved hands, dark leather leg pieces and boots, three bright teal cord strips with knots | Parts stay in their cells and stay separate, but they remain flat colour blobs. No outline, no shading, no hood opening, no book pages. Some cells distorted (limb ends ragged; one cell turned into a big cream page; one seed made a chain and a spike instead of the lantern). Sheet: `candidates/sheet_a_try1.png`. |
| 2 | 5201, 5202 | 0.75 (the tool maximum) | character design sheet of separate game art pieces on a plain light grey background, each piece detailed with a bold thick uneven dark brown ink outline and flat cel colours with one hard shadow tone: a deep crimson hood with a shadowed face opening, a cream coat torso with ink stains and buttons, a long tattered crimson cloak back panel with torn hem, a tattered crimson cloak front panel, a big thick leather book with page edges, brass buckles and a chain, a brass hanging lantern, sleeve pieces and leather gloves, leather trousers, boots, three teal cord straps with knots, stylised dark fantasy | Worse. Shapes turned into plain boxes with thin corner marks (hood became an octagon, torso a framed rectangle). Parts drifted and merged: seed 5201 lost the arms and cords and moved legs into a row with stray leather loops; seed 5202 lost the arms, placed a lantern-like piece in the empty area, and replaced feet with a red box and a black box. Still no hood, face, hands or book detail. Sheet: `candidates/sheet_a_try2.png`. |

Signature/text check: the four sheets were opened at full size; no letters or marks. None is kept as art.

## Verdict (parts test)

Failed, within the budget and the tool limits:
1. **Flat blocks carry no form.** img2img keeps the shape and colour of a flat block. At 0.65 it adds nothing; at 0.75 (the tool maximum) it starts to invent, but invents boxes, ornament and drift instead of a hood, a hand or a book. The outline, the one hard shadow tone and the hood opening, which the style needs, never appear.
2. **Fixing it needs a richer template**, not more seeds: for each part an outline, the hood opening, finger and cuff marks, the book's page edge, the cord knots. Each is a shape to draw with `art-ops` (about 60 more mask and compose steps per template), and it is still uncertain that SDXL will render them as clean, same-weight parts.
3. **Round-trip risk.** Cell consistency across parts (line weight, tone, palette) did hold in try 1 (the style was uniformly flat), but only because nothing was drawn.

No assembled preview, no `vN_sil270`, no `vN_context`, no `parts_rotate_check.png` exist. The round-1 `v1`-`v3` files are in `candidates/round1/` as a record of what failed. The hero look is therefore still undecided. The only round-2 images with dark-fantasy form are the whole-figure SDXL tests `hero_r2a` and `hero_r2b` (sheets `candidates/r2a.png`, `r2b.png`): hooded, weathered cloak, flat inked look, but they have a sword or nothing in the hand, no book, no lantern and scattered teal. The Board told me not to generate full figures, so I did not continue them.

## Options for the Board (one choice needed)

A. **Richer template** (outline, hood opening, hands, book, knots drawn with `art-ops`), then 1 to 2 renders at denoise 0.7 to 0.75. Cost: many commands, about 4 to 8 images. Uncertain.
B. **Part-by-part txt2img on the grey backdrop** (one generation per part with the same style words and a fixed seed family), then `matte` and `art-ops` assembly. About 21 images for one variant: over budget for three variants, and joints and line weight may not match.
C. **Design the look from whole-figure tests first** (the Board's "design variants"), then make the parts from the chosen design by method B. This reverses the Board's REDO 2 order, so I need your decision.
D. Stop the generated-parts route and plan the hero as a hand-built (vector or paint-over) rig.

## Round 3, step 1: concepts (Board option C, "Concept, then layered parts")

Status: step 1 done, **stopped for the Board's pick.** Step 2 (layered parts) not started.

Images this step: 8 (SDXL txt2img via `comfy-draft.py`, `sd_xl_base_1.0`, 832 x 1216). Running total: 28 to 31 before, so **36 to 39** (cap 40; the round-3 budget of 20 allows more, but the hard cap of 40 now leaves only 1 to 4 images, which is too few for step 2's inpainting, so I need the Board to say which count rules).

Shared positive prompt (the `hero_r2a` words, with the book at the hip, the lantern hanging, a rest pose and a colour pair per concept): `stylised dark fantasy game hero, bold thick uneven dark brown hand-inked outline, flat colour fills with a single hard-edged shadow tone, muted dark palette with one saturated accent colour, clean simple shapes, strong readable silhouette, full body, three-quarter view facing right, plain flat light grey background, no ground shadow. A hooded scribe with a deep hood and the face in shadow, a heavy weathered <CLOAK> cloak over a long <COAT> ink-stained scribe's coat, a thick contract-book with torn pages chained and strapped at the left hip, a small brass lantern hanging free from the belt, three bright teal cords tied around the shoulder, chest and hip, standing upright rest pose, arms slightly away from the body, legs apart, nothing crossing in front of the torso`

Negative, all: `sword, blade, dagger, weapon, armor, monochrome, black and white, glasses, bald, cartoon nose, caricature, comic strip, chibi, cute, modern clothing, walking, thin lines, sketch, realistic, photo, 3d render, gradient shading, soft airbrush, painterly texture, text, watermark, signature, background scenery, multiple figures, cropped, extra limbs`

| Asset | CLOAK / COAT | Seeds | Kept |
|---|---|---|---|
| hero_c1 | crimson red / cream | 6101, 6102, 6103 | **6101** (6102 was the better figure but its dark backdrop failed the matte gate at 3.5 % leftover) |
| hero_c2 | mustard ochre yellow / dark slate blue | 6201, 6202, 6203 | **6203** |
| hero_c3 | pale bone white / oxblood red | 6301, 6302 | **6302** (6301 was the better figure, a white hood; it failed the matte gate at 1.7 %). The model gave a red cloak, not bone. |

Matte: `comfy-edit.py matte` defaults; I did not raise `--max-leftover`. Then `trim --pad 8`, `canvas 832x1216` and `compose` on grey (214,214,214) for `cN.png`; `resize` to 270 px, `mask --from-alpha --invert` for `cN_sil270.png` (1000 x 270 canvas); 345 px tall on the 2400 x 1080 field (38,66,72), feet on y 648, enemy box and ground line as in round 1, for `cN_context.png`. Candidate sheet of all 8: `candidates/r3_all.png`. Signature/text check on the three kept images at full size: no mark.

Files: `c1.png`, `c1_sil270.png`, `c1_context.png` and the same for `c2`, `c3`.

| | c1 crimson | c2 ochre | c3 red + staff-lantern |
|---|---|---|---|
| Identity | deep hood, face black, torn crimson cloak and long ribbons, belt wraps, gloves. **No book, no lantern, no clear teal cords** | deep hood, ochre cloak, rope cords hanging from the belt (read as bindings), open hand. **No book, no lantern** | hood, wrapped coat, lantern on a staff (hand-held, not hanging), cloak. **No book, no clear teal cords** |
| Silhouette at 270 px | hood on a column, ribbons make it wide at the hem: strong | hood and sloping cloak, open arms: strong, reads as a person | tall staff and lantern make the most unusual, clear shape |
| Rig-readiness | front view, arms near the body, ribbons cross it | three-quarter, arm out, legs apart: closest to the rest pose | arm on a staff, cloak hides the legs |
| Value vs the field | red is dark: weaker than c2 | ochre reads clearly | dark red and brown: weakest |
| Facing right | front | right | front |

All three fail the same items from the brief: **no contract-book, no three teal cords at shoulder, chest and hip, no hanging lantern**. SDXL follows the dark-fantasy mood and colour but ignores object lists. The book, lantern and cords would be added at step 2 (inpaint) or by choosing seeds again. Recommendation: **c2** (ochre): best value against the field, closest rest pose, rope cords hang as bindings, a clear flat-colour read.

## Round 3, step 2a: c2_final (identity fix on the Board's pick, c2)

Board pick: **c2**; budget: the round-3 allowance of 20 images overrides the old cap. Round 3 has used **16 of 20** (8 concepts, 8 inpaint). Total with rounds 1 and 2: 44 to 47 by the old count, which is why the Board's override was needed.

Input: `hero_c2` seed 6203 (own art, provenance above), 832 x 1216. Base for all inpaints: the original image, then each result as the next input.

| Step | Tool | Mask | Prompt (no negative option in `inpaint`) | Seeds / denoise | Result |
|---|---|---|---|---|---|
| Book, try 1 | `comfy-edit inpaint` SDXL | rect 590,520 200x190, feather 3 (`candidates/m_book.png`) | a thick leather bound contract book with torn page edges and a short iron chain, held in a dark gloved hand at hip height, bold thick uneven dark brown ink outline, flat colour with a single hard-edged shadow tone, dark fantasy game art, plain light grey background | 7101, 7102 / 0.9 | smudges, no book |
| Book, try 2 | inpaint | rect 560,470 272x290, feather 2 (`m_book2.png`) | a large thick closed leather contract book with a metal clasp and torn paper page edges, a hand in a dark glove gripping it at hip height, a short iron chain hanging from it, bold thick uneven dark brown ink outline, flat ochre and brown colour with one hard shadow tone, dark fantasy game art, plain grey background | **7201** / 1.0 (7202 failed: a thin sliver) | **book with chain in a gloved hand: kept** (`candidates/book_try2.png`) |
| Lantern, tries 1 and 2 | inpaint on 7201 | rect 60,640 150x200 and rect 30,630 210x270 | a small / a large brass hanging lantern with a glowing amber glass window and a ring handle, hanging on a short cord, bold outline, flat colour, one hard shadow tone | 7301, 7302 and 7401, 7402 / 1.0 | blobs or a streak, no lantern: **rejected** (`lantern_try.png`, `lantern_try2.png`) |

The inpaint outputs report `outside_mask_changed: 0`. SDXL inpaint worked once for a big, simple object (the book) and failed four times for the small lantern.

**Lantern and cords: drawn deterministically with `art-ops`** (no generation). `contact --bg` for flat colour fields, `mask --rect/--ellipse/--polygon` for shapes, `compose --mask` to place them, on the book inpaint (7201):
- three Bind-teal cords (40,190,175) with a dark (45,33,28) outline grown 4 px: shoulder polygon 528,352 578,392 566,410 516,372; chest polygon 395,402 505,412 503,430 393,420; hip polygon 340,478 515,492 512,512 338,498 (over the belt);
- a lantern hung from the end of the existing rope: cord rect 126,610 8x80, ring ellipse 116,662 28x28, cap polygon 100,700 160,700 148,682 112,682, body rect 92,700 76x120 (dark outline), brass rect 99,707 62x106 (205,150,55), amber window rect 113,726 34x70 (255,195,70).
Result `c2_final_src.png`; matte (`comfy-edit matte`, default gate passed), `trim --pad 8`, grey and context steps as in step 1: `c2_final.png`, `c2_final_sil270.png`, `c2_final_context.png`.

Honest verdict on c2_final:
- **Identity now present:** hood, face in shadow, weathered ochre cloak, **book with chain at the front hand, hip height**, **lantern from the back hand outside the cloak**, **three teal cords at shoulder, chest and hip**, no blade, facing right.
- **Quality gaps:** the lantern and the cords are flat geometric shapes with straight edges, so they do not carry the hand-inked uneven outline of the figure; they look pasted on. The cords are straight bars, not tied. The book is more realistic and lit than the cloak (a bright page edge). The cloak and the coat still lean to brown, so the cord teal separates well, and the lantern amber is the single warm accent.
- **Outline weight** (Board answer 3) is not yet measured or normalised.
- At 345 px in `c2_final_context.png` the figure reads: hooded column, lantern, book and teal bars are all visible.

## Step 2b: parts cut from c2_final, assembled and rotated (Director's cheaper route)

Images generated in this step: **0**. Round 3 stays at 16 of 20. (No txt2img for the lantern and cords: they are already separate, clean `art-ops` shapes, and the standalone txt2img rebuild is the upgrade that remains open.) Hidden joint areas were **not** repainted; all parts are **FLAT CUTS, FLAT PLACEHOLDER for the hidden areas** (see verdict).

### Blueprint fit (reduced, 10 parts instead of 21)

Working frame: the 832 x 1216 canvas of `c2_final_src.png` (all pivots and positions are in it; the figure is about 1100 px tall there, 345 px on screen, scale 0.31). Draw order, back to front: legs, cloak, torso, head_hood, arm_front, binding_1, binding_2, binding_3, book, lantern.

| Part | Cut (canvas px) | Pivot (canvas px) | Joins |
|---|---|---|---|
| legs | rect 255,975 310x235 (trousers, boots) | hips (400, 990) | torso |
| cloak | polygon 232,250 300,185 330,300 400,330 412,400 408,640 392,1000 300,1075 190,1115 115,968 240,830 240,640 115,545 235,330 (the large left mass, back arm, rope) | shoulder (330, 320) | torso |
| torso | polygon 380,300 530,300 545,470 590,650 650,1000 560,1060 380,1000 | root (416, 700) | legs |
| head_hood | polygon 298,185 300,70 350,18 440,12 498,45 522,200 526,335 330,335 | neck (440, 335) | torso |
| arm_front | polygon 515,350 580,375 632,492 605,545 560,500 525,430 (sleeve only) | shoulder (548, 362) | torso |
| book (with chain, gloved hand) | rect 546,462 210x316 | wrist (600, 560) | arm_front |
| lantern (cord, ring, body) | rect 86,604 86x220 | hook (130, 612) | cloak (back hand) |
| binding_1 / _2 / _3 | rect 512,346 70x70 / 390,398 120x36 / 335,474 186x42 | centres | torso |

Not in this reduced set (they remain in the 21-part blueprint above): separate upper arm, forearm, hand, thigh, shin and foot, the far arm, cloak front/back split. They need hidden-area paint, which this run did not do.

Method: `art-ops` only. A fully transparent 832 x 1216 base (grey `contact --bg` from a transparent pixel, then `key`), `mask --rect/--polygon` per part, `compose --mask` of the matte of `c2_final_src` through each mask for one full-canvas layer per part, `trim --pad 2` for `parts/*.png`, `compose` in draw order for the assembly. Part PNGs are trimmed, so their placement offsets in the 832 x 1216 frame are **not recorded** (the tool prints only the size); for the rig they follow from the cut rectangles in the table, and a proper export needs the offsets (note for `gameplay-programmer`).

Files: `parts/head_hood.png`, `torso.png`, `cloak.png`, `arm_front.png`, `book.png`, `lantern.png`, `legs.png`, `binding_1.png`, `binding_2.png`, `binding_3.png`; `parts_sheet.png` (all ten on one sheet); `parts_assembled.png` (c2_final left, assembled parts right); `parts_rotate_check.png`.

### Verdict

**Match to the design target (`parts_assembled.png`):** close. The assembled parts reproduce c2_final at full size, with no visible seam or colour change, because they are cuts of the same pixels. My first cut left a vertical seam at the torso/cloak join and a wedge at the neck; both fixed by widening the polygons. One tiny white sliver remains at the left edge of the cloak near y 740 (one pixel wide).

**Rotate check (`parts_rotate_check.png`, ±15° each, pivots above):**
- **Head: mostly passes.** +15° is clean. -15° shows a small lighter-grey notch at the hood's left edge where the cut polygon ends (`FLAT PLACEHOLDER`: the cloak behind it was never painted).
- **Front arm: small gaps.** A thin slit appears between the sleeve and the book/torso at both angles; the book is a separate part, so the sleeve turns away from it. Acceptable for a first rig, needs a painted sleeve end.
- **Cloak: fails.** At -15° a large transparent wedge opens between the cloak and the torso (the cloak's cut is straight at x about 400 and at y 975, and the area behind it was never painted), and the cloak's straight bottom edge shows. At +15° the cloak edges and legs show hard straight cuts. The cloak cannot swing 15° without hidden-area paint behind it and a shaped hem.

Why it fails, exactly: no hidden area was painted. The parts only exist where pixels exist in the single concept. Anything behind another part is missing, so any rotation that moves a part off its neighbour shows a hole. This confirms the lesson: **a flat cut of a whole figure does not rotate**; only repainted parts with hidden areas will. The inpaint route for that (about 12 or more images, with a poor hit rate on small areas) is the open cost.

**Outline weight (Board answer 3): not measured with a tool, no normalisation applied.** Estimate by eye: the outline is about 5 to 8 px in the 832 x 1216 frame and about 2 px at the 345 px on-screen height, under the Bible's 5 px minimum at on-screen size. UNVERIFIED as a number. Normalisation (a scripted thickening of the outline layer) is still to be done.

**Other carried items from the Director:**
- The chain hangs loose from the book; it should attach to the hip cord (`binding_3`). Not done.
- The cord and lantern shapes are flat `art-ops` geometry (placeholders).

### Bible changes in this step
§11: the rigged-actor line replaced with the concept-then-layered-parts principle plus the clause on small-part inpaint. §15: a "Hero recipe that worked" block with the SDXL words and negative that produced c1 to c3, and a note not to use the cartoon words for the hero. §16 unchanged (answers already recorded).

### Remaining budget and what is still open
Image count this round: 16 of 20 (4 left). Open: standalone txt2img for lantern, book and cords (3 to 4 images); hidden-area paint for the cloak, hood, sleeve and torso (about 8 to 12 inpaints, with the risk seen above); outline normalisation; recorded part offsets.

## Bible

§16 and §11 (parts principle) are as in round 1. I did **not** change §15 or add the "parts sheet from a blocked-in template" line to §11: the recipe did not work, so writing it into the Bible would state something untested. Say if you still want them added.

## Round 4: gBot-style layered parts (Board, 2026-11-28; "Yes, gBot-style, 30")

Status: **delivered with defects.** 14 parts painted or generated, assembled at the pivots, rotated at ±20°. The arm, both cloak panels and the head at +20° show no transparent gap at the joint; the head at -20° and the front leg at both angles do. Details in "Rotate check". The front arm does not match the concept (see "Honest defects"). Bible §11 now carries the Board's wording of the parts principle; nothing else in the Bible changed this round.

### Image count and provenance

Round 4 used **30 of 30**. Run 1 (2026-11-27, interrupted by the shared usage limit before it wrote any notes) generated **28 images by candidate-sheet count**: 13 calls, each cell of a sheet in `candidates/r4/` being one generated image: `cand_p1` and `cand_p1b` (head, 2 + 2), `cand_p2` (torso, 2), `cand_p3` and `cand_p3b` (cloak front, 2 + 2), `cand_p4` (cloak back, 2), `cand_p5` (front arm, 2), `cand_p6` (small hidden part, 2), `cand_p7` (legs, 2), `cand_book` (2), `cand_lantern` (2), `cand_cord` (2), `cand_limbs` (txt2img limbs, 4). **UNVERIFIED: the prompts, seeds, denoise and masks of those 28 images.** They are in the provenance JSONs under `~/game-studio-workspace/staging/art/hero_r4_*/` and in the run log of run `25c0782a`, neither of which this workspace can read. The method was the one in the plan comment: crop with margin from `c2_final_src`, mask the neighbours to flat grey, upscale 2x, SDXL `comfy-edit inpaint` of the hidden area plus a round cap, downscale, key, trim. The Board can paste the run log if the exact words are needed.

Run 2 (this run) generated **2 images**, recorded in full:

| Asset | Tool | Input | Mask | Prompt | Seeds / denoise | Result |
|---|---|---|---|---|---|---|
| hero_r4_arm | `comfy-edit.py inpaint`, SDXL `sd_xl_base_1.0`, 608 x 800, 30 steps, cfg 7, euler/normal, negative `text, watermark, logo, signature` (tool default) | the 2x crop of box 400,280 304x400 of `c2_final_src` (sha256 563775bf…) | round shoulder cap at frame (545,345), sleeve and forearm down to the book (sha256 933f6264…) | the front arm of a hooded scribe painted whole: a long brown ink-stained coat sleeve hanging straight down from a round shoulder, ending in a dark leather gloved hand, bold thick uneven dark brown hand-inked outline, flat colour fills with a single hard-edged shadow tone, muted dark fantasy game art, plain flat light grey background | **8101** kept, 8102 rejected / 1.0 | 8101: a bandaged grey forearm with a leather bracer and glove, shoulder painted as black shadow; 8102: a fist at the elbow and the shoulder painted as background. `outside_mask_changed: 0` on both. Sheet: `candidates/r4/cand_arm.png` |

Crop boxes of run 1 (recovered exactly: a crop of each saved full-canvas mask at this box differs from the saved cropped mask by 0 px, `art-ops diff`): head (272,0) 288x416; torso (336,256) 304x784; cloak front (96,168) 576x960; cloak back (104,584) 336x544; legs (384,536) 176x616; front arm (400,280) 304x400. All boxes are x y w h in the 832 x 1216 frame of `c2_final_src.png`. `candidates/r4/check_inputs.png` shows the masked crops and their hidden-area masks; `check_keyed.png` the keyed results.

### Which candidate became which part (run 1 images)

- `head_hood`: `cand_p1b` left (rounded cape bottom painted under the hood).
- `torso`: `cand_p2` left (collar and neck stump painted; the coat's leg window stays open, see defects).
- `cloak_front`: `cand_p3b` left; the old chain column (crop x 460–576, y 0–590) is removed by cropping, the right flap below it kept.
- `cloak_back`: `cand_p4` left.
- `leg_front`: `cand_p7` left, cut below its failed hip region (the inpaint painted a bucket on the left candidate and a soldier's head on the right one, see `cand_p7`); the leg below is the inpainted trousers and boot. The coat strip at its right edge is cropped off.
- `book`: `cand_book` left, cleaned crop, white sticker rim keyed (a faint rim remains).
- `chain`: the strap-and-chain from `cand_book` left, rotated 40° to run from the hip cord to the book.
- `lantern`: `cand_lantern` left; a 6 px dark rope line from the back hand to the ring is the only `art-ops` drawn element (polygon 198,596 206,602 142,646 134,640).
- `binding_1..3`: `cand_cord` right (tied knot), scaled to 90x22 (rotated -40°), 120x30 and 186x46.
- `arm_back`, `leg_back`: `grade --brightness 0.75 --saturation 0.8` copies of the front parts.
- Not used: `cand_p5` (arm, both blobs), `cand_p6` (both blobs), `cand_limbs` (txt2img limbs: wrong palette and whole figures), `cand_p1`, `cand_p3` first tries.

### Parts, offsets and pivots (frame 832 x 1216 of `c2_final_src`; on screen the figure is 345 px tall, scale 0.3136)

Part files are `trim --pad 2` of the 1x working images. Origin = top-left of the PNG in the frame. Pivot given in frame px and in part px.

| # | File | Size | Origin (x, y) | Pivot frame (x, y) | Pivot in part | Draw order (1 = back) |
|---|---|---|---|---|---|---|
| 1 | `leg_back.png` | 164x398 | (284, 746) | hip (355, 630) | (71, -116) | 1 |
| 2 | `arm_back.png` | 256x381 | (155, 265) | shoulder (300, 330) | (145, 65) | 2 |
| 3 | `cloak_back.png` | 269x489 | (134, 624) | (270, 640) | (136, 16) | 3 |
| 4 | `leg_front.png` | 164x398 | (384, 736) | hip (455, 620) | (71, -116) | 4 |
| 5 | `torso.png` | 234x726 | (368, 284) | root (450, 650) | (82, 366) | 5 |
| 6 | `arm_front.png` | 256x381 | (400, 280) | shoulder (545, 345) | (145, 65) | 6 |
| 7 | `head_hood.png` | 240x402 | (296, 14) | neck (430, 335) | (134, 321) | 7 |
| 8 | `cloak_front.png` | 551x950 | (96, 168) | collar (400, 300) | (304, 132) | 8 |
| 9 | `binding_2.png` | 120x30 | (390, 401) | centre | (60, 15) | 9 |
| 10 | `binding_3.png` | 186x46 | (334, 472) | centre | (93, 23) | 10 |
| 11 | `binding_1.png` | 79x68 | (504, 351) | centre | (40, 34) | 11 |
| 12 | `chain.png` | 81x126 | (499, 499) | book end (578, 622) | (79, 123) | 12 |
| 13 | `book.png` | 192x202 | (556, 466) | hand (600, 575), child of arm_front | (44, 109) | 13 |
| 14 | `lantern.png` | 123x187 | (86, 594) | rope top at the back hand (198, 596) | (112, 2) | 14 |

The hip pivots sit 116 px above the top of the leg parts because the thigh under the coat was never painted (the hip-cap inpaint failed twice, `cand_p7`). The rotate check uses these pivots as the brief asks, which is why the leg fails (below).

### Assembly (`parts_assembled.png`: `c2_final.png` left, parts right)

Same figure, same colours, same silhouette for hood, cloak, book position, lantern side and cord positions. Differences from the concept: the front arm is a bandaged grey forearm with a bracer instead of the ochre sleeve (the inpaint ignored "coat sleeve"); the three cords are tied knots, larger and more graphic than the flat bars; the book is the standalone closed book with a faint white rim, not the open book; the lantern is the standalone boxed lantern; the trousers are a lighter grey-teal (the 2x inpaint lightened them); the back boot is a graded copy, so both boots point right; the cloak collar piece crosses the hood's left edge as a hard seam at (400–440, 230–300).

### Rotate check (`parts_rotate_check.png`: rest pose, then head -20/+20, arm -20/+20, cloak front -20/+20, cloak back -20/+20, leg -20/+20; all at the pivots above)

| Joint | -20° | +20° | Verdict |
|---|---|---|---|
| Head (430,335) | small transparent gap at the left of the neck, (300–350, 240–300): the hood's painted cape turns away from the cloak collar and nothing is painted behind it | no gap; the cloak collar's hard cut edge shows across the hood's left edge | **fails at -20°** (gap about 40 px) |
| Front arm + chain + book (545,345) | no gap at the shoulder (the cloak covers it); the keyed grey fringe around the forearm shows; the book overlaps the hip cord | no gap; the black shoulder shadow of the arm part peeks from under the cloak | **passes for gaps**, with the fringe and the wrong sleeve as defects |
| Cloak front (400,300) | no transparent gap: the torso is painted whole behind it; the cloak collar's torn seam against the hood | no gap; a hard straight top edge on the shoulder cape at (270–330, 230–250), the crop boundary of the collar paint | **passes for gaps**, one hard straight edge |
| Cloak back (270,640) | no gap, no straight edge | no gap, no straight edge | **passes** |
| Front leg (455,620) | the coat's leg window (405–510, 745–1000) empties to background where the leg moved | same | **fails**: the torso's inner coat and the thigh were never painted, so the window shows background |

Head and leg failures were not fixed because the round-4 allowance was spent (30 of 30) before they were found; the fix for both is one more inpaint each (hood collar region painted into the cloak_front, and a painted thigh plus coat lining in the torso window).

### Outline weight, measured

Method: `resize` `c2_final_src.png` to 261 x 381 (the figure at 345 px, its on-screen height), `mask --from-color 40 30 25 --tolerance 45` for dark-line pixels, then the same mask with `--shrink 1`, `2`, `3`. A line of width w survives a shrink of s only if w > 2s. Counts: 11593 px at shrink 0, 5235 at shrink 1, 3087 at shrink 2, 1835 at shrink 3. More than half of the dark pixels vanish at a 1 px shrink, and `candidates/r4/outline_view.png` shows that what survives shrink 1 is the cloth-shadow blobs, not contour lines. **The contour outline at 345 px is 1 to 2 px, under the Bible §2 minimum of 5 px.** At working scale (832 x 1216) the same masks give 115086 / 46712 (shrink 3) / 31107 (shrink 5), so the generator's line is about 4 to 6 px there. No normalisation was applied in this round; `art-ops` has no outline-thickening operation, so Board answer 3's "scripted normalisation" is still open.

### Honest defects and what is UNVERIFIED

- Front arm: wrong garment (bandaged forearm, not the ochre sleeve); its shoulder cap is a black shadow, not a rounded darker sleeve end; a grey fringe remains after keying. Only visible where the cloak does not cover it.
- Leg front: no thigh, no hip cap (two failed inpaints); straight top edge hidden under the coat only in the rest pose.
- Torso: the coat's leg window is a straight-edged hole, not a painted lining.
- Head: hood under the cloak collar leaves a 40 px gap at -20°.
- Cloak front: collar paint ends in a hard straight edge at its crop top.
- Book, cords and lantern are standalone generations in a cleaner, more "sticker" style than the inked figure.
- UNVERIFIED: prompts and seeds of the 28 run-1 images (see above); whether run 1 made any image beyond the 13 sheets (if the arm-context inpaint it had prepared also ran, the count is 32, not 30).
- Not made this round: `_sil270` and `_context` of the assembled figure (the concept's `c2_final_sil270.png` and `c2_final_context.png` stand).

Tools: `art-ops.py` (info, crop, resize, key, trim, mask, compose, rotate, grade, contact, diff) and `comfy-edit.py inpaint` only. No input image from outside this task; no prompt names a game, studio, artist or character. Working files were kept outside the commit; only the candidate sheets in `candidates/r4/` are committed as evidence.

