# Visual Target Pack Plan

Status: **proposed** (SOU-56). Plan only; no images yet. Pipeline §5 Step 1 asks for a small pack of original examples that fixes the look before the slice is built. Board approves the pack before the slice scales (Art Bible §12).

## Purpose
Seven pieces that together show: silhouette language, palette, lighting, linework and texture, card-art composition, icon style and UI readability. Each is a concept-level original, drafted with the [ComfyUI workflow](COMFYUI-WORKFLOW.md) (text prompts only) and painted over in Krita. The pack is a look reference. Slice pieces follow it; slice pieces are not the same files.

## Pieces
| # | Piece | Shows | Size (px) | Feeds slice spec |
|---|---|---|---|---|
| 1 | Hero: the Scrivener, full figure, facing right, three bindings worn (one intact, one frayed, one severed) | proportions, silhouette, binding states on the body | 900 x 1200 working, bound to 25% screen height silhouette test | `scrivener` |
| 2 | Common enemy: binding-frayer | enemy silhouette, facing left, shape distinct from the hero | 800 x 800 working | `enemy_frayer`, informs `enemy_attacker` |
| 3 | Boss (severing) | boss scale and menace, higher detail | 1200 x 1000 working | none in M1 slice; look reference only |
| 4 | Card illustration | focal region, readability when mostly covered, full at spread size | 700 x 900 | `card_art_sample` |
| 5 | Bind-slot icon, three states (intact, frayed, severed) | icon family, shape-not-colour state coding | 128 x 128 each | `slot_icon_states` |
| 6 | Combat background | lanes kept clear, overscan, value structure | 2640 x 1080 | `bg_combat_flooded_hall` |
| 7 | Combat UI screen mockup | layout per concept, safe areas, readability, colour-blind check | 2400 x 1080 | `ui_combat_composition` |

Pipeline's relic icon is replaced by piece 5 (concept has no relics; Art Bible §12).

## Approval gate
1. `game-designer` confirms gameplay readability of pieces 1, 2, 3 and 7 (telegraph and slot readability).
2. `director` reviews originality (vision pillar 5, M1 E7) and direction.
3. Board approves the pack. Until then no slice piece moves past `concept`.

## Checks on each piece before review
- Silhouette as solid black at 25% screen height.
- Palette inside the Art Bible anchor set.
- One warm light source, cool ambient, same direction.
- No baked text, no detail under 3 px.
- Greyscale and a colour-blind simulation still show Play vs Bind and intact vs frayed vs severed.
- Provenance recorded; reference images never an input.

## Evidence at review
Contact sheet of all seven at their sizes, plus a phone-size mockup (the UI piece with the hero and an enemy placed in it). A phone test is a Board device task; where it is not done the check is reported `not tested`.

## Out of scope
Final production art, rigging, Godot import, scenes, scripts, project settings.
