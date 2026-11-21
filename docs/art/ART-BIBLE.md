# Deckbound Art Bible: Outline

Status: **outline, proposed** (SOU-33, Art Phase 0). This is a structure with proposed rules, not an approved Art Bible. Visual pillars, palette values and the visual target pack are produced in Art Phase 1 and need Board approval (pipeline §5 Step 1). `game-designer` and `game-artist` propose the direction; `director` approves it (pipeline §6); the Board approves the visual target pack and budgets.
Companions: [ART-PIPELINE.md](ART-PIPELINE.md), [ART-PIPELINE-AUDIT.md](ART-PIPELINE-AUDIT.md), [TOOL-DECISIONS.md](TOOL-DECISIONS.md), [../concept.md](../concept.md), [../vision.md](../vision.md).

Numbers marked **(proposed)** are starting values to be confirmed by a readability test on a target-class Android phone in Phase 1. Numbers marked **(from concept)** are fixed by `docs/concept.md`.

## 1. Purpose and authority

- What this document governs; what it does not (gameplay, balance, engine settings, which belong to others).
- Order of authority: vision pillars, then concept, then this Art Bible, then asset specs.
- Reference policy: restate pipeline §2.1 in one paragraph. Findings enter this document only as general principles, never as descriptions of specific assets of another game.
- Originality rule: restate vision pillar 5.

## 2. Visual pillars (from the vision pillars)

Each art pillar below names the design consequence and what it rules out. Final wording is a Phase 1 deliverable.

| Vision pillar | Art consequence to write up |
|---|---|
| 1. Every card is a choice twice | Both faces carry equal visual weight. Play and Bind are told apart by form and position, never by colour alone. Illustration supports both faces |
| 2. Commitment has teeth | Fray and sever must be visible state: a bound page looks intact, frayed, or severed at a glance on the hero and the bind slot |
| 3. Readable before it is deep | Gameplay information first, decoration second. Everything reads on a 6-inch screen in landscape without zoom. No hover-only cues |
| 4. The run is the whole game | Run-state art (map, rests, summary) reads quickly after resuming from a backgrounded app. No art that requires reading long text |
| 5. A quiet, original dark fantasy | Damp stone, lantern light on black water, bureaucratic horror, no gore. Original symbols and silhouettes only |

## 3. Mood, palette and value structure

To define in Phase 1, with the structure fixed now:
- Palette: a restrained set (target of 8-12 anchor colours) with named roles: background stone and water, lantern warm light, paper/page, ink, Play accent, Bind accent, danger, safe/guard. Values chosen with contrast in mind.
- Value structure as general principles, for example "background sits two value steps below characters", "interactive elements hold the highest local contrast".
- Colour is never the only carrier of meaning (colour-blind safety): each state also has a shape, icon or position.
- Lighting: one dominant warm light source per scene, cool ambient, consistent direction (to fix in Phase 1).
- Per-floor palette variation limits (first playable has one floor).

## 4. Phone-screen rules

These apply to every asset. Display facts are **(from concept)** unless marked.

### 4.1 Canvas and orientation
- Landscape only, both rotations allowed. Design canvas 2400 x 1080 (20:9). Must also hold from 16:9 (1920 x 1080) to 22:9 using `canvas_items` stretch with `expand` aspect **(from concept)**.
- Backgrounds are full-bleed, authored at 2400 x 1080 plus **overscan** so a 22:9 screen (2640 px wide at 1080 high, wider than the 2400 canvas) gains width instead of letterboxing. Width of the overscan strip: **(proposed)** at least 120 px per side (2640 - 2400, halved), checked in Phase 1. Nothing important sits in the overscan or in the outer 16:9 crop margin.
- The 16:9 core region (1920 x 1080 centred) is the **gameplay-critical region**: characters, telegraphs and card art subjects stay inside it.

### 4.2 Safe areas
- All gameplay information and tappable elements stay inside the OS-reported safe area: the camera cutout on whichever side is rotated, and the gesture bar at the bottom **(from concept)**.
- Art consequence: UI frames and side-anchored elements (bind slots, end turn, deck and discard) need artwork that tolerates being shifted inward by a variable inset. Frames are 9-slice or have a decorative margin that can be cropped; they are never one baked full-screen overlay.
- Decorative edge art may extend into the unsafe region only if losing it changes no information.
- The hand art has an extra bottom margin above the gesture bar inset **(from concept)**.

### 4.3 Touch targets
- Every tappable element is at least 48 x 48 dp **(from concept)**. At a typical 2.6x density this is roughly 125 px on the design canvas **(proposed approximation; `gameplay-programmer` converts from real density)**.
- Art must provide a visible shape at least as large as the touch target for: card in hand (48 dp-wide tappable strip even when overlapped), bind slot, enemy, end-turn, deck and discard piles, map nodes. The tappable area may be larger than the art, never smaller.
- Icons: draw so that the glyph reads at roughly 32 dp, and set inside a 48 dp target.

### 4.4 Readability at phone size
- Test distance: arm's length, phone in two hands, **on a target-class device, not a monitor** (vision pillar 3).
- Silhouettes: enemies and the hero identifiable as a solid black shape at **(proposed)** 25% of screen height. Bindings read as part of the Scrivener's silhouette.
- Text: no text baked into illustrations; all text is Godot labels. Minimum sizes **(proposed)**: spread rules text 14 sp-equivalent, compact face text 12 sp-equivalent, numbers (Ink, damage, telegraph values) 20 sp-equivalent or larger. Confirmed or changed by the Phase 1 device test.
- Contrast: text on any background meets at least 4.5:1 (WCAG AA body text). Illustration behind the compact face is lowered in contrast so text wins.
- Stroke and detail minimum: lines or details thinner than **(proposed)** 3 px on the canvas are removed, because they vanish at phone scale.
- Icon vocabulary: one icon family with a hard limit on distinct icons per screen, and each icon distinct as a silhouette.

### 4.5 No hover
- No art or state may depend on hover. Pressed, selected, disabled and highlight states are all explicit variants for touch.

## 5. Characters and enemies

- Proportions and silhouette rules for the Scrivener (hero) and for enemy classes: plain attacker, binding-frayer, deck-fouler, boss (first playable list **from concept**).
- Binding visualisation: how a bound page appears worn on the hero, in three states (intact, frayed, severed), and in the bind slot icon.
- Facing: hero faces right, enemies face left **(from concept)**.
- Telegraph art: action icon plus number above each enemy's head; a fray or sever draws a line to the threatened slot.
- Rig vs frame animation per asset class: follows [TOOL-DECISIONS.md](TOOL-DECISIONS.md) (b): skeletal only for the Scrivener and bosses **(from concept)**, short frame loops for common enemies.
- Animation timing principles: anticipation, impact, recoil, recovery. Frame-rate targets and durations in asset specs. Nothing may drop animation below 30 fps on the target device **(from concept)**.
- Layer separation requirements for rig-ready sources (naming in Phase 1).

## 6. Cards (compact face, spread)

- Compact face in hand: cost, name, one Play line, divider, one Bind line with bind icon, illustration behind at reduced contrast **(from concept)**.
- Spread: two-page open book, Play on the left page, Bind on the right, shared Ink cost at the spine **(from concept)**.
- Frame and layout art as 9-slice or layered pieces, drawn for both faces at their two sizes. Frame sizes are a `ui-designer` deliverable (audit F9).
- Illustration composition rules: subject inside a safe focal region, readable when mostly covered by text (compact), full at spread size. Illustration authored at spread size, no larger **(from concept)**.
- Card-art production method: original concept draft, human paintover and cleanup in Krita (pipeline §3).
- Card back, rarity or type cues: not defined yet. To be designed (if any) without relying on colour alone.

## 7. Environments and UI

- Combat background: layered, parallax only where it adds value. Lanes for the Scrivener (left third), the play area, and enemies (right two thirds) stay clear of busy detail **(layout from concept)**.
- Map, rest, reward and run-summary screens: style notes and screen list, restricted to the first-playable scope.
- UI frames, buttons, bind slots, counters: Godot Control nodes with original decorative textures (pipeline §3). Pressed, disabled and highlighted states included.
- Typography: font selection pending. Every font must have a licence that permits embedding in a commercial Android app and must be recorded. No bundled font from any external library is used unless its own licence allows it.

## 8. VFX

- Runtime effects built with Godot particles, shaders and small sprites (pipeline §3). Fray and sever effects have priority and must be readable.
- Caps per combat on particles, overdraw and full-screen shader passes, to keep 60 fps on a Mali-G52 / Adreno 610 class device **(from concept)**. Cap values: Phase 1 measurement.
- Style: matches the painterly direction. PixelFX is used only where the Art Bible later allows it (see TOOL-DECISIONS).
- Implementation (shaders, runtime systems) belongs to `gameplay-programmer`. This section sets the visual target.

## 9. Technical art budget for Android

Detailed numbers are proposed in [TOOL-DECISIONS.md](TOOL-DECISIONS.md) ("Android budgets") and become `RENDER-STANDARDS.md` after approval.

- Resolution and aspect per asset class; no print-resolution sources shipped.
- Atlas pages at most 2048 x 2048 **(proposed)**; compressed GPU textures (ASTC, ETC2 fallback) require the project setting and the per-texture `VRAM Compressed` import mode in audit F3.
- Texture memory in combat at most 250 MB **(proposed)**. Art size of the first playable at most 60 MB **(proposed)**, inside the 100 MB download **(from concept)**.
- Transparent versus opaque rules: opaque where possible, to limit overdraw. Premultiplied alpha policy to settle in Phase 1.
- Mipmaps and texture filtering policy for painterly art on UI and scaled elements: to settle in Phase 1.
- Source rule: never overwrite the only editable source with a flattened export (pipeline §4).

## 10. Files, naming and provenance

- Folders, as proposed in audit F7: editable sources in `art_src/<class>/`, exports in `assets/<class>/`, specs and registry in `design/assets/`, references in `design/assets/references/`. `snake_case` names **(from AGENTS.md)**.
- Asset ID scheme, spec template (`ASSET-SPEC-TEMPLATE.md`) and registry fields follow pipeline §4. The registry schema and tools are owned by `gameplay-programmer`; content fields by `game-artist`.
- Provenance: every asset records "original" or source and licence, plus tool, version and generation settings, and prompts if a generator was used.
- Status flow: `planned → concept → review → approved → integrated → verified`. The Game Artist never approves its own work.

## 11. Review checklist (for every asset)

Pass / fail / not tested, never inferred (pipeline §6):
- Dimensions, aspect, alpha, pivot, and naming match the spec.
- Readable at gameplay scale on a target-class phone in landscape; silhouette clear against every intended background.
- Inside the safe and gameplay-critical regions; touch targets at least 48 dp.
- Palette, lighting and outline consistent with the references.
- Both card faces legible; no information relies on colour alone or on hover.
- Size and memory within the budgets above.
- Originality checked against the vision rule; provenance recorded.

## 12. Open questions for Board approval

1. Approve this structure and the proposed numbers as a starting point for Phase 1.
2. Approve the visual target pack in Phase 1: one hero, one common enemy, one boss, one card illustration, one background and one UI screen. A relic icon is dropped for now, because the concept has no relics (bindings fill that role); the pipeline's relic item is replaced by a bind-slot icon.
3. Confirm D1-D6 in [TOOL-DECISIONS.md](TOOL-DECISIONS.md).
4. Confirm the project-setting changes in audit F1-F3.
