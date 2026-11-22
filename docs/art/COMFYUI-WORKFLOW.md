# ComfyUI Draft Workflow

Status: **proposed** (SOU-56). Applies decision D1 from the M1 plan: local ComfyUI with FLUX.1 schnell and SDXL, installed on the studio machine 2026-11-21 (Board decision). This document describes use; it installs and changes nothing.

## Rules (non-negotiable)
1. **Final art allowed (Board 2026-11-22).** Generated images may ship as final art after selection, consistency checks and scripted cleanup with `art-ops`, then the Task's review stages (`qa`, Director) and Board approval. Krita paintover is optional.
2. **Never an outside image as input.** No img2img, ControlNet, IP-Adapter, style reference, LoRA or fine-tune built from any game's screenshots, captures, moodboard or other reference material (pipeline §2.1). **Exception (Board decision 2026-11-22):** Deckbound's own art with recorded provenance may be the input of `comfy-edit.py` (img2img with SDXL or FLUX; inpainting with SDXL and an `art-ops mask`, pixels outside the mask restored exactly). ControlNet, IP-Adapter, style reference, LoRA and fine-tunes stay not approved.
3. **Original design words only** in prompts. No game, character, card or artist names from other works.
4. **Local only.** Prompts and outputs stay on the studio machine.
5. Record provenance for every kept draft (below). A draft without provenance is deleted.

## Install and models
- Install: `~/game-studio-workspace/tools/ComfyUI_windows_portable` (portable build). Start with its own run script, in its own folder; do not run its Python from inside the repository.
- Models: FLUX.1 schnell and SDXL base checkpoints as installed there. Record the exact file name, and its licence as published by the model's author, in each asset's provenance. Verify the licence terms permit commercial use before the first draft is kept (TOOL-DECISIONS (a) "verify"); this is not a legal conclusion. Not verified in this PR.
- Do not install custom nodes, LoRAs or other models without approval.

## Which model for what
| Use | Model | Why |
|---|---|---|
| Fast composition and silhouette exploration (many seeds) | FLUX.1 schnell | few steps (typically 1-4), quick iteration |
| House style A Ink Cel (Art Bible §3A): characters, enemies, cards, backgrounds | FLUX.1 schnell (recipe below, validated in SOU-81) | the recipe was validated with FLUX; SDXL is needed for `comfy-edit.py inpaint` |

Either may be used for any piece; record which.

## Steps
1. Read the asset spec and the Art Bible palette and silhouette rules.
2. Write the prompt from the spec's design description. Include: subject, silhouette cue, lantern light from one side, damp stone, restrained palette words, "no text". Keep a negative prompt for SDXL ("text, watermark, gore, signature"). For character, enemy, prop, card and background art use the **house-style recipe** (next section).
3. Generate at a working size at or above the final size (never print resolution), 4 to 8 seeds per round. Use an empty latent and a fixed seed per candidate.
4. Save the ComfyUI workflow JSON and the output PNG into a staging folder outside the repository (for example `~/game-studio-workspace/staging/art/<asset_id>/`). Candidates are not committed.
5. **Signature/text check on every image, before anything else is done with it.** Open each generated PNG with an image viewer (at full size, and the lower corners and any seal, book or sign enlarged) and look for a signature, handwriting, letters, numerals or a character-like glyph. The answer is recorded per image as yes or no in the review notes. **Any mark: discard the image** (delete it from staging; never key, edit, sheet, commit or ship it; never count it as a candidate). An abstract seal emblem is not a mark. A prompt that says "no text, no signature" does not prevent marks (SOU-79: 9 of 22; SOU-81: 8 of 19 with the house recipe), so generate about twice as many seeds as clean images wanted, and report the marked count in the Run summary. `qa` repeats the check on every committed image.
6. Compare candidates against the spec: silhouette at 25% screen height (270 px) as solid black, palette roles, composition, and (house style) the A Ink Cel traits and the spec's own checks, which are judged separately from the style. Pick at most one or two.
7. Clean up the chosen image with `art-ops`: generate on a flat plain backdrop, `key` it to transparency, `trim`, `resize` to the spec's size, place it on the spec's `canvas`, build `sheet`s for frames, and make a `contact` sheet for review. Optional: hand fixes in Krita.
8. Export to `assets/slice/` per the spec. Run the validators `gameplay-programmer` provides, when they exist.
9. Fill the provenance block in the spec: tool and version, model file and licence, seed, steps, sampler, size, workflow file name, prompt, the input images ("none" for `comfy-draft.py`; for `comfy-edit.py` the template, denoise, input path and SHA256, mask SHA256), Krita steps.

## House-style recipe: A Ink Cel (Board 2026-11-22; validated in SOU-81)
The traits are in Art Bible §3A; the validation is in `docs/art/directions/style.md`. How to use it:
1. Prompt form: `<STYLE>. <SUBJECT>. Warm light from the upper left, cool ambient. Plain flat uniform light grey background, no shadow on the ground, no floor, no text, no signature.` STYLE: "2D hand-drawn illustration, bold uneven black ink outlines, flat cel shading with two or three flat tones, stylised exaggerated proportions, clean flat colour, muted dark palette with one warm amber accent, no 3D rendering".
2. SUBJECT comes from the asset spec, shape and held items first, colours **by palette role** (cords "blue-teal", never red; "dark red wax seal with no markings"; "stone-grey" skin and apron). Scrivener: state the bell mass and flared hem first and put the lantern on a hook in the back hand outside the cloak. Enemies: state the exaggerated shape and the weapon or reach pose from the spec; add "no tail" unless the design has one.
3. FLUX schnell through `comfy-draft.py --model flux --width 832 --height 1216 --seed N --count 2-4`, 4 steps, euler/simple, cfg 1.0. Use a fixed seed list per subject and record it.
4. Prove a recipe on **3 subjects x 4 seeds** and judge the median and the worst before relying on it for a new asset class (studio decision D8). Judge style and spec compliance as separate columns.
5. Judge each kept image on: 2D not 3D (no glossy volume, gradients, soft glow, depth of field), silhouette at 270 px, palette roles, line weight and tone count consistent with the family, spec compliance, signature/text (step 5 above).
6. The generator's backdrop is white or cream, not the requested grey: `key` takes the corner colour. A baked foot shadow and enclosed backdrop fragments remain after `key` (SOU-79, SOU-81; a `art-ops` region erase would fix it); remove the shadow by selection or paint the part whole.

## Provenance record (copy into the spec)
```
Origin: generated + scripted cleanup (comfy-draft) | own-art edit via comfy-edit | original
Tool: ComfyUI <version>, art-ops (Krita <version> if used)
Model: <FLUX.1 schnell | SDXL base> <file name>, licence <name and link>, checked <date>
Settings: seed <n>, steps <n>, sampler <name>, size <W x H>, workflow <file>
Prompt: <text>
Negative prompt: <text or n/a>
Reference images used as input: none (comfy-draft) | own art: <template> <input path> sha256 <...>, mask sha256 <...>, denoise <x> (comfy-edit)
Editing: <art-ops commands, and Krita steps if any>
Signature/text check: <date>, checked by <agent>, mark found: no (an image with a mark is deleted and has no record)
```

## What this workflow does not cover
- Rigging, animation and Godot import (`gameplay-programmer` owns import settings and animation logic).
- Text, fonts and UI layout (Godot Control nodes).
- Approval. The Game Artist does not approve its own work.
