# ComfyUI Draft Workflow

Status: **proposed** (SOU-56). Applies decision D1 from the M1 plan: local ComfyUI with FLUX.1 schnell and SDXL, installed on the studio machine 2026-11-21 (Board decision). This document describes use; it installs and changes nothing.

## Rules (non-negotiable)
1. **Drafts only.** Generator output is a concept draft. Nothing generated ships unrefined: every shipped piece is painted over, cleaned up or replaced in Krita (pipeline §3, §5 Step 4).
2. **Never a reference image as input.** No img2img, ControlNet, IP-Adapter, style reference, LoRA or fine-tune built from any game's screenshots, captures, moodboard or other reference material (pipeline §2.1). Text prompts only. An empty latent is the only image-shaped input. The one later exception to consider is our own approved original art, and that needs separate approval and is not used in this PR.
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
| Painterly texture and mood, background and card-art drafts | SDXL | more control over style words and negative prompts |

Either may be used for any piece; record which.

## Steps
1. Read the asset spec and the Art Bible palette and silhouette rules.
2. Write the prompt from the spec's design description. Include: subject, silhouette cue, lantern light from one side, damp stone, restrained palette words, "no text". Keep a negative prompt for SDXL ("text, watermark, gore, signature").
3. Generate at a working size at or above the final size (never print resolution), 4 to 8 seeds per round. Use an empty latent and a fixed seed per candidate.
4. Save the ComfyUI workflow JSON and the output PNG into a staging folder outside the repository (for example `~/game-studio-workspace/staging/art/<asset_id>/`). Candidates are not committed.
5. Compare candidates against the spec: silhouette at 25% screen height as solid black, palette roles, composition. Pick at most one or two.
6. Move the chosen draft into Krita as a bottom reference layer for paintover. Paint over, separate layers, simplify details under 3 px. Save the `.kra` to `art_src/<class>/`.
7. Export to `assets/slice/` per the spec. Run the validators `gameplay-programmer` provides, when they exist.
8. Fill the provenance block in the spec: tool and version, model file and licence, seed, steps, sampler, size, workflow file name, prompt, "reference images as input: none", Krita steps.

## Provenance record (copy into the spec)
```
Origin: generated draft + paintover
Tool: ComfyUI <version>, Krita <version>
Model: <FLUX.1 schnell | SDXL base> <file name>, licence <name and link>, checked <date>
Settings: seed <n>, steps <n>, sampler <name>, size <W x H>, workflow <file>
Prompt: <text>
Negative prompt: <text or n/a>
Reference images used as input: none
Editing: <Krita steps>
```

## What this workflow does not cover
- Rigging, animation and Godot import (`gameplay-programmer` owns import settings and animation logic).
- Text, fonts and UI layout (Godot Control nodes).
- Approval. The Game Artist does not approve its own work.
