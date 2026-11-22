# Bind-slot icon (four states)

| Field | Value |
|---|---|
| Asset ID | `slot_icon_states` |
| Display name | Bind-slot icon: empty, intact, frayed, severed |
| Asset class | icon |
| Owner | game-artist (with `ui-designer` for icon family consistency) |
| Priority | high (slice piece 4; replaces the pipeline's relic icon) |
| Status | planned |
| Approval state | not approved (approver: director, then Board) |

## Use
- Gameplay use: the bind slot frame on the left edge. It is the Bind drop zone and the status display (concept). Shows the slot state, not the page icon (page icons come later).
- Size on screen: 128 x 128 px on the canvas. Tappable area at least 125 px (48 dp at about 2.6x); the glyph reads at about 32 dp (about 83 px).
- Region: left edge, inside the OS safe area (placement by `gameplay-programmer`).

## Canvas
- Dimensions: 128 x 128 per state; sheet of 4 states in one row, 512 x 128.
- Safe area: glyph inside the central 96 x 96; 16 px margin.
- Background: transparent.
- Pivot / origin: centre.

## Budget
- Texture memory: 512 x 128 x 4 = 256 KB.
- File size target: PNG at most 60 KB.
- Atlas: shares an atlas with UI pieces later.
- Frame count: 4 states (not an animation).

## Look constraints
- Palette roles: Bind accent for the loop, Ink outline, Danger for frayed ends, Stone for empty.
- Lighting: flat with a small warm highlight from the upper left.
- Silhouette: each state is a distinct silhouette without colour: `empty` = open dashed ring; `intact` = closed stitched loop; `frayed` = loop with a gap and loose threads; `severed` = two cut ends and an empty ring.
- Minimum detail: strokes at least 4 px at 128 px.
- Colour is not the only carrier: silhouette, as above.
- No baked text: yes.

## Animation (D2)
- Approach: static + Godot transform effects (a pulse when it lights up for the confirming tap).
- Reason and integration cost: none beyond the texture.

## Files
- Source deliverables (replace the Krita source): the selected generations (raw, unkeyed) and the per-state PNGs, kept under `art_src/icons/slot_icon_states/` with provenance. Krita stays optional (deckbound PR #20); a `.kra` file is not required.
- Export: `assets/slice/icons/slot_icon_states.png`
- Godot resource path: set by `gameplay-programmer`.
- Import notes: confirm with `gameplay-programmer`.

## Provenance (fill when made)
- Origin: generated + scripted cleanup (comfy-draft, art-ops); own-art edits via comfy-edit if used; or original. Record per COMFYUI-WORKFLOW.md.
- Tool and version: _pending_
- Model file name and licence: n/a unless a generator is used
- Generation settings: n/a unless a generator is used
- Prompt text: n/a unless a generator is used
- Reference images used as generator input: none
- Editing steps: _pending_
- Licence notes: _pending_
- Originality check: _pending (director)_

## Acceptance checklist
- [ ] Four states distinguishable in greyscale and a colour-blind simulation
- [ ] Glyph readable at about 83 px on a phone
- [ ] Dimensions, alpha, naming match this spec
- [ ] Provenance complete
- [ ] Originality check passed

## Out of scope
Page icons inside the slot, slot placement, confirm-tap logic.
