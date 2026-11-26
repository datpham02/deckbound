# Hero style test v2 (SOU-98): notes

Status: **partial.** Part 1 (three variants) is done. Part 2 (parts test) is **not done**: blocked by two missing `art-ops` operations (see "Parts verdict"). Self-check is not an approval.

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

## Step 2b (layered parts): NOT done, stopped

Why: 4 images remain in the round-3 allowance. Per-part crop and inpaint of hidden areas needs about 12 inpaints for the 21 blueprint parts, and my one-in-five hit rate for inpaint (book worked, lantern never) means more. Starting it would spend the last 4 images and leave no `parts/`, no `parts_assembled.png`, no rotate check. Also the Bible §15 and §11 lines are unchanged, as they must describe a recipe that has not worked end to end.

## Bible

§16 and §11 (parts principle) are as in round 1. I did **not** change §15 or add the "parts sheet from a blocked-in template" line to §11: the recipe did not work, so writing it into the Bible would state something untested. Say if you still want them added.

