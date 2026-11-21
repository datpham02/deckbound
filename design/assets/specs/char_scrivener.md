# The Scrivener (hero)

| Field | Value |
|---|---|
| Asset ID | `char_scrivener` |
| Display name | The Scrivener |
| Asset class | character |
| Owner | game-artist |
| Priority | high (slice piece 1) |
| Status | planned |
| Approval state | not approved (approver: director, then Board) |

## Use
- Gameplay use: the hero in combat, left third, facing right, bindings drawn into the silhouette.
- Size on screen: about 650 px tall on the 2400 x 1080 canvas (about 60% of screen height).
- Region: inside the 16:9 gameplay-critical core.

## Canvas
- Dimensions: layered Krita source 1800 x 2400 (2x working scale); exported parts atlas at most 1024 x 1024, parts at on-screen scale.
- Safe area / overscan: n/a (not full-bleed).
- Background: transparent.
- Pivot / origin: bottom centre, between the feet.

## Budget
- Texture memory: 1024 x 1024 x 4 = 4 MB uncompressed.
- File size target: atlas PNG at most 1.5 MB.
- Atlas: one page, power-of-two, at most 2048 x 2048.
- Frame count: n/a (skeletal).

## Look constraints
- Palette roles: ink, paper, stone, lantern warm, Bind accent (cords), Danger (frayed ends), Wax.
- Lighting: warm from the upper left, cool ambient.
- Silhouette: reads as a solid black rounded vertical shape at 25% screen height; lantern and book are the accent shapes.
- Minimum detail: nothing under 3 px at on-screen scale.
- Colour is not the only carrier: binding state shown by cord silhouette (intact loop, frayed gap with loose threads, severed cut ends).
- No baked text: yes.

## Animation (D2)
- Approach: Godot Skeleton2D (Bone2D + Polygon2D, AnimationPlayer). Decided in TOOL-DECISIONS D2: skeletal only for the Scrivener and bosses. Spine is not adopted.
- Reason and integration cost: bindings are separate parented sprites, so three states swap without redrawing the body. Rig and AnimationPlayer setup belong to `gameplay-programmer`; this asset supplies layered parts and timing intent.
- States: `idle` (loop, 2.0 s, breathing and lantern sway); `action_tear_page` (one-shot, 0.6 s: anticipation 0.2 s, release 0.1 s, recovery 0.3 s).
- Event markers (intent): `release` at 0.2 s.
- Frame rate: authored for 30 fps playback minimum.
- Layers: per ART-BIBLE §5 (`body/`, `head/`, `arm_front/`, `arm_back/`, `leg_front/`, `leg_back/`, `cloak/`, `book/`, `lantern/`, `binding_1..3/` with `_intact`, `_frayed`, `_severed`).
- Draw order (back to front): `arm_back`, `leg_back`, `body`, `cloak`, `book`, `binding_*`, `leg_front`, `head`, `lantern`, `arm_front`.

## Files
- Editable source: `art_src/characters/char_scrivener.kra`
- Export: `assets/slice/characters/char_scrivener_parts.png` plus a parts list in `assets/slice/characters/char_scrivener_parts.md`
- Godot resource path: set by `gameplay-programmer`. Slice only touches `assets/slice/` (swap-in is T22).
- Import notes: confirm with `gameplay-programmer`; no project settings changed here.

## Provenance (fill when made)
- Origin: generated draft + paintover (ComfyUI draft per COMFYUI-WORKFLOW.md, rebuilt in Krita)
- Tool and version: _pending_
- Model file name and licence: _pending_
- Generation settings: _pending_
- Prompt text: _pending_
- Reference images used as generator input: none
- Editing steps: _pending_
- Licence notes: _pending_
- Originality check: _pending (director)_

## Acceptance checklist
- [ ] Dimensions, alpha, pivot, naming match this spec
- [ ] Readable at 25% screen height on a target-class phone
- [ ] Three binding states distinguishable in greyscale
- [ ] Parts rotate without gaps
- [ ] Size and memory inside budget
- [ ] Provenance complete
- [ ] Originality check passed

## Out of scope
Rig, animation player, scenes, scripts, swap into the game.
