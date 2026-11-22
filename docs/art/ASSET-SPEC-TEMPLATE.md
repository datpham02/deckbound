# Asset Spec Template

Copy this file to `design/assets/specs/<asset_id>.md` and fill every field. Fields follow [ART-PIPELINE.md](ART-PIPELINE.md) §4. "n/a" is allowed only with a reason. The Game Artist never sets `approved` or later states (pipeline §6).

Status flow: `planned → concept → review → approved → integrated → verified`.

```markdown
# <display name>

| Field | Value |
|---|---|
| Asset ID | `<snake_case, stable, matches registry>` |
| Display name | |
| Asset class | character / enemy / card_art / icon / background / ui / vfx |
| Owner | game-artist (or ui-designer for UI) |
| Priority | |
| Status | planned |
| Approval state | not approved (approver: director, then Board) |

## Use
- Gameplay or UI use:
- Size on screen (px on the 2400 x 1080 canvas, and % of screen height):
- Screen region (gameplay-critical 16:9 core or not):

## Canvas
- Dimensions, aspect:
- Safe area / overscan:
- Background: transparent / opaque
- Pivot / origin:

## Budget
- Texture memory (uncompressed RGBA in MB, from W x H x 4):
- File size target (exported PNG):
- Atlas page and whether packed:
- Frame count (if frame animation):

## Look constraints
- Palette roles used (ART-BIBLE §3):
- Lighting direction:
- Silhouette rule:
- Minimum detail (3 px rule):
- Colour is never the only carrier of meaning: what else carries it:
- No baked text: yes

## Animation (D2)
- Approach: static + Godot transforms / frame animation / Godot Skeleton2D / Spine (not adopted)
- Reason and integration cost:
- States, frame rate, duration, loop, event markers:
- Layer names for rig-ready sources (if Skeleton2D):

## Files
- Editable source: `art_src/...`
- Export: `assets/slice/...`
- Godot resource path (set by gameplay-programmer):
- Import notes (confirm with gameplay-programmer; no project settings changed here):

## Provenance (required before review)
- Origin: generated + scripted cleanup / own-art edit via comfy-edit / original / other (give source and licence)
- Tool and version (ComfyUI, model, Krita):
- Model file name and licence:
- Generation settings (seed, steps, sampler, size, workflow file):
- Prompt text (original design words only):
- Reference images used as generator input: none (must always be none)
- Editing steps (art-ops commands, comfy-edit runs, optional Krita fixes):
- Licence notes:
- Originality check (vision pillar 5):

## Acceptance checklist (pass / fail / not tested)
- [ ] Dimensions, alpha, pivot, naming match this spec
- [ ] Readable at gameplay scale on a target-class phone
- [ ] Silhouette clear on every intended background
- [ ] Inside safe and gameplay-critical regions; touch target at least 48 dp where tappable
- [ ] Palette, lighting, outline consistent with the Art Bible
- [ ] Size and memory inside budget
- [ ] Provenance complete
- [ ] Originality check passed

## Out of scope
```
