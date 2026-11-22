# The Scrivener (hero)

| Field | Value |
|---|---|
| Asset ID | `char_scrivener` |
| Display name | The Scrivener |
| Asset class | character |
| Owner | game-artist |
| Priority | high (slice piece 1) |
| Status | in production (SOU-64): full figure exported, parts atlas NOT achieved with the approved tools (see "Production result") |
| Approval state | not approved (approver: director, then Board) |
| Direction | B Bell Cloak, `docs/art/directions/char_scrivener.md` (director, 2026-11-22). The approved concept is a direction, not a production atlas or rig. |
| Integration owner (rig: rotation, overlap, animation, binding swap, pivot): | SOU-77 (Scrivener rig integration, `gameplay-programmer`, blocked by SOU-64; Board decision 2026-11-22) |
| Combat-context checks (readability over the real background, scale against other slice assets) | SOU-61 |

## Use
- Gameplay use: the hero in combat, left third, facing right, bindings drawn into the silhouette.
- Size on screen: about 650 px tall on the 2400 x 1080 canvas (about 60% of screen height).
- Region: inside the 16:9 gameplay-critical core.

## Canvas
- Dimensions: parts are generated large and reduced with `art-ops` to on-screen scale; the working canvas for the assembled figure is 1800 x 2400 (2x working scale), and the exported parts are at on-screen scale (650 px tall figure).
- Atlas limit (one limit): **one page, power-of-two, at most 2048 x 2048**, matching Art Bible §9. Parts are packed on that single page; no second page.
- Safe area / overscan: n/a (not full-bleed).
- Background: transparent.
- Pivot / origin: bottom centre, between the feet. Every part PNG uses the same bottom-centre pivot (the figure's pivot, kept as a common canvas origin so parts assemble without offsets).

## Budget
- Texture memory: 2048 x 2048 x 4 = 16 MB uncompressed (the page limit). The compressed GPU texture (ASTC, ETC2 fallback) is smaller; the engine setting belongs to `gameplay-programmer`.
- File size target: atlas PNG at most 4 MB.
- Atlas: one page, power-of-two, at most 2048 x 2048 (one limit; replaces the earlier 1024 x 1024 / 4 MB wording).
- Frame count: n/a (skeletal).

## Look constraints
- Palette roles: ink, paper, stone, lantern warm, Bind accent (cords), Danger (frayed ends), Wax.
- Lighting: warm key from the upper left, cool rim light on the right, cool ambient.
- Silhouette: reads as a solid black bell-shaped rounded vertical shape at 25% screen height (270 px on the 1080 canvas); lantern and book are the accent shapes.
- Minimum detail: nothing under 3 px at on-screen scale.
- Colour is not the only carrier: binding state shown by cord silhouette (intact loop, frayed gap with loose threads, severed cut ends).
- No baked text: yes.

## Production requirements (checkable)
Each line is a pass / fail check at review.
1. Silhouette: the flat black shape at 25% screen height (270 px) is a bell: narrow hooded top, wide hem, about 5 heads tall; it is not a column and has no thin spike under 3 px.
2. Contract-book: distinctive and held at the chest; readable as a book in the flat silhouette or as the brightest pale shape in the colour view; no baked text.
3. Bindings: three locations, shoulder (`binding_1`), chest (`binding_2`) and hip (`binding_3`), each told apart by place alone; three distinct states per location (`_intact`, `_frayed`, `_severed`) told apart in greyscale by cord silhouette.
4. Face and hands: a chin is visible under the hood; both hands are visible, pale, with readable fingers at on-screen scale.
5. Light: warm key from the upper left and cool rim light on the right edge of cloak, hood and book; cords lighter than the cloak.
6. Hidden parts: torso, legs and the arm and book areas behind the cloak are painted whole, so rotation shows no gap or hole.
7. Layers: the part list below is complete, one PNG per part, names exactly as listed.
8. Pivot: one common bottom-centre assembly origin for every part, and a joint point for every moving part, listed in the parts list.

## Animation (D2)
- Approach: Godot Skeleton2D (Bone2D + Polygon2D, AnimationPlayer). Decided in TOOL-DECISIONS D2: skeletal only for the Scrivener and bosses. Spine is not adopted.
- Reason and integration cost: bindings are separate parented sprites, so three states swap without redrawing the body. Rig and AnimationPlayer setup belong to `gameplay-programmer` (SOU-77); this asset supplies layered parts and timing intent. The cloak is one large part with a sway deform; the head and hood are one part.
- States: `idle` (loop, 2.0 s, breathing, cloak sway, lantern sway); `action_tear_page` (one-shot, 0.6 s: anticipation 0.2 s, release 0.1 s, recovery 0.3 s).
- Event markers (intent): `release` at 0.2 s.
- Frame rate: authored for 30 fps playback minimum.

### Arrangement of lantern, book and hands
The lantern hangs on a hook held in the **back hand** (`arm_back`), out to the left of the bell, at about hip height, outside the cloak edge so it shows in the silhouette. The **front hand** (`arm_front`) holds the book at the chest. The tear is told by the front hand, the book and the cloak, since the torso is hidden.

| State | Lantern (back hand, hook) | Book (chest) | Back hand | Front hand |
|---|---|---|---|---|
| `idle` | Hangs from the hook, swings gently, outside the cloak edge | Closed, held at the chest, rises slightly with the breath | Holds the hook, lowered beside the hem | Cradles the book from below, thumb on the cover |
| anticipation (0.2 s) | Swings back and up as the back hand pulls the hook back | Tilts up and toward the viewer, cover opens a little | Lifts the hook back and out | Pinches the corner of the loose page (`book_page`) |
| release (0.1 s) | Swings forward past the hem | Stays open at the chest | Snaps forward | Pulls the page out and to the right, away from the book (the `release` marker) |
| recovery (0.3 s) | Settles back to idle sway | Closes and returns to the chest | Lowers to the hip | Returns to the cradle |

The torn page flying away is a VFX element, not a part of this asset.

## Layers (parts, one PNG each)
Names per ART-BIBLE §5 (direction B):
- `body/` torso, painted whole behind the cloak.
- `head/` head and hood with a visible chin, one part.
- `arm_back/` back arm and hand, with the hook.
- `arm_front/` front arm and hand that holds the book.
- `leg_back/`, `leg_front/` feet and shins, painted whole, mostly hidden under the hem.
- `cloak/` the bell cloak, one large part with a sway deform, painted whole.
- `book/` `book_body` and `book_page` (one loose page, separate part).
- `lantern/` the lantern.
- `binding_1/` shoulder, `binding_2/` chest, `binding_3/` hip, each with `_intact`, `_frayed`, `_severed`.
- Draw order (back to front): `lantern`, `arm_back`, `leg_back`, `body`, `leg_front`, `cloak`, `book`, `binding_*`, `head`, `arm_front`.
  (The lantern is behind the back arm so the hook hand covers the cord; the book and bindings sit over the cloak; the head and hood sit over the cloak; the front hand is in front of the book.)

## Files
- Source deliverables (replace the Krita source): the selected generations (raw, unkeyed) and the per-part PNGs, kept under `art_src/characters/char_scrivener/` (`generations/` and `parts/`), with provenance per part (see below). Krita stays optional (deckbound PR #20); a `.kra` file is not required.
- Export: `assets/slice/characters/char_scrivener_parts.png` (one page) plus a parts list in `assets/slice/characters/char_scrivener_parts.md` (part name, rectangle, offset from the assembly origin, joint point, source generation).
- Godot resource path: set by `gameplay-programmer`. Slice only touches `assets/slice/` (swap-in is T22).
- Import notes: confirm with `gameplay-programmer`; no project settings changed here.

## Provenance (fill when made; one record per part)
- Origin: AI-generated (ComfyUI per COMFYUI-WORKFLOW.md), selected, regenerated for consistency and processed with `art-ops`; no Krita paintover required.
- Per part, record: part name, model file name and licence, tool and version, seed, prompt text, size, and each `art-ops` step with its arguments (key, crop, trim, resize, canvas, sheet, grade).
- Reference images used as generator input: none
- Licence notes: model `flux1-schnell-fp8.safetensors`, Apache-2.0 (as printed by the tool, 2026-11-22). Images are original; no input images.

### Records (SOU-64 run 1)
Common: Origin: generated + scripted cleanup. Tool: ComfyUI 0.46.0, art-ops. Settings: euler/simple, 4 steps, cfg 1.0, size 832 x 1216. Negative prompt: n/a. Reference images used as input: none.

**Selected: `art_src/characters/char_scrivener/generations/char_scrivener_flux_s6302.png`** (raw, unkeyed; pixel-exact copy via `resize --size 832 1216 --fit stretch`), workflow `char_scrivener_flux_20261122-111821_s6302.workflow.json` (staging).
Prompt: "one figure, full body head to feet, facing right, centered, perfectly flat uniform light grey backdrop, no vignette, no glow, no cast shadow. A scribe in a huge near-black hooded cloak that flares out like a bell: narrow hooded head and shoulders, the hem spreading very wide at the ground, hem at least twice as wide as the shoulders, smooth rounded triangle silhouette, five heads tall, the pale chin visible under the hood, a pale hand cradles a closed thick book with a plain blank cream cover at the chest, the other pale hand grips a short iron hook with a glowing lantern hanging at hip height outside the cloak edge, three bright teal cords tied across the cloak at shoulder, chest and hip. Warm amber light from the upper left, cool blue rim light on the right edge. Plain blank surfaces, no lettering, no gore, no weapons."
Editing for `assets/slice/characters/char_scrivener_full.png` (313 x 650): `key --tolerance 75 --soft 10` (corner colour 215,215,215) -> `trim` -> `key --tolerance 130 --soft 12` (from raw) -> `trim` -> `crop --box 0 0 491 1000` (removes feet and cast shadow) -> `trim` -> `resize --size 313 650`. Review images: `resize` 130 x 270, `grade --brightness 0` (silhouette), `grade --saturation 0` (greyscale), `contact --bg 27 32 38`.

Images generated: **16 of 32.** FLUX seeds: 6101-6103 (master round 1; 6101 has baked "Contract" text and a glyph at the hem, 6102/6103 columns), 6201-6204 (round 2; 6202 best but a column, 6201 lantern floats, 6203 floats, 6204 signature glyph), 6301-6304 (round 3; 6302 selected; 6301 pale face and short cloak, 6303 drab, 6304 hem trails and lantern doubles), 7101 lantern, 7201 book, 7301/7302/7303 chest-cord states (parts test, not used). Rejected candidates stay in staging; sheets: `assets/slice/review/char_scrivener/candidates_master.png`, `candidates_round2.png`, `candidates_round3.png`, `parts_test.png`.
- Originality check: _pending (director)_

## Production result (SOU-64, run 1)
Delivered: full figure `assets/slice/characters/char_scrivener_full.png` (hooded bell, visible chin, pale hands, closed book, lantern on a chain outside the cloak edge, teal cords at the collar and chest). Review: `assets/slice/review/char_scrivener/contact.png` (colour at 650 px, colour at 270 px, flat silhouette, greyscale, on `#1B2026`).

Not achieved:
- **Tool capability failure: parts atlas (body, head, arms, legs, cloak, book, loose page, lantern, 3 bindings x 3 states)** — parts generated one by one do not match the master figure or each other (`parts_test.png`: book came out open, cords tiny, "frayed" had no gap, backdrops vignetted and unkeyable), and parts cannot be cut from one image because hidden areas are not painted. What would fix it: an approved image-to-image or inpainting step on our own approved art (COMFYUI-WORKFLOW rule 2 names it as a possible later exception), or a layered paintover.
- **Tool capability failure: cast shadow under the feet** — it is close in value to the backdrop, so `key` leaves it, and `art-ops` has no region erase. The export is cropped at the hem, so the feet are not in it. What would fix it: a mask or region-erase tool, or a truly shadowless generation.
- Only one of the three binding locations is visible on the figure (collar/chest cords); the shoulder strap is brown, not a teal cord; the three states are not drawn. The lantern is not in the flat silhouette at 270 px. Rim light on the right is weak. The pose differs from the spec (the front hand holds the book and the lantern chain; `arm_back` with a hook is not shown). No `.kra`, no per-part PNGs (`parts/` is empty).
- D2 fallback (static figure + Godot transforms) is available; Director and the Board decide.
- Originality check: _pending (director)_

## Production result (SOU-64, run 2, comfy-edit inpaint)
Images used this run: 9 (total 25 of 64). All SDXL inpaint, `sd_xl_base_1.0.safetensors` (CreativeML Open RAIL++-M), input `char_scrivener_flux_s6302.png` (our own art), 30 steps, cfg 7.0, euler/normal, `outside_mask_changed: 0` every run. Masks: `art_src/characters/char_scrivener/masks/`.
- s8101 (denoise 1.0, mask `lantern_old.png`, prompt "perfectly flat uniform light grey backdrop, empty, plain"): removed the old right-side lantern and chain. Worked; faint amber tint left inside the cloak edge.
- s8102 (mask `glow_fix.png`, "near-black wool cloak edge ... no glow"): rejected, fuzzy dark blob at the cloak edge.
- s8103 (mask `glow_fix2.png`, flat backdrop prompt, input s8101 result): removed most of the glow. Kept.
- s8201-s8203 (mask `lantern_new.png`, prompt: pale hand gripping an iron hook, amber lantern hanging, flat backdrop) and s8301-s8303 (mask `lantern_new2.png`, prompt: glowing amber glass lantern, flat backdrop): **no lantern in any of the six**; the model extends the cloak (one a black box) instead. Sheets: `assets/slice/review/char_scrivener/inpaint_lantern_attempt1.png`, `inpaint_lantern_attempt2.png`.
- **Tool capability failure: lantern on a hook in the back hand, outside the cloak edge** (and by the same mechanism the missing cords and the binding states) — SDXL inpaint does not add a new object from a text prompt into a mostly empty mask; two attempts failed (stop condition 4). What would fix it: FLUX img2img on a rough layout, or a regenerated master that already has the lantern at the left edge (comfy-draft), after which inpaint is used only to remove and repaint existing areas.
- Parts atlas, hidden-part painting and binding states were not started: they depend on a master with the lantern, three cords and feet. The Task is not `art-ready`.

## Acceptance checklist
- [ ] Dimensions, alpha, pivot, naming match this spec
- [ ] Readable at 25% screen height on a target-class phone (checked in combat by SOU-61)
- [ ] Three binding states distinguishable in greyscale
- [ ] Parts rotate without gaps (checked in the engine by SOU-77)
- [ ] Parts overlap in the specified draw order; animation checks and binding swap (checked in the engine by SOU-77)
- [ ] Readability in combat over the real background and scale against other slice assets (checked by SOU-61)
- [ ] Size and memory inside budget
- [ ] Provenance complete (per part)
- [ ] Originality check passed

## Out of scope
Rig, animation player, scenes, scripts, swap into the game.
