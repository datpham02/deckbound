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
