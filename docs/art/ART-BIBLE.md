# Deckbound Art Bible: Outline

Status: **Phase 1 wording, proposed** (SOU-56, M1 T18a; outline from SOU-33). Sections 2, 3 and 5 now carry Phase 1 wording and starting palette values. Nothing here is approved: `director` reviews, then the Board approves, with the visual target pack ([TARGET-PACK-PLAN.md](TARGET-PACK-PLAN.md)) before the slice scales (pipeline §5 Step 1). Values stay **(proposed)** until a readability test on a target-class phone. `game-designer` and `game-artist` propose the direction; `director` approves it (pipeline §6); the Board approves the visual target pack and budgets.
Companions: [ART-PIPELINE.md](ART-PIPELINE.md), [ART-PIPELINE-AUDIT.md](ART-PIPELINE-AUDIT.md), [TOOL-DECISIONS.md](TOOL-DECISIONS.md), [../concept.md](../concept.md), [../vision.md](../vision.md).

Numbers marked **(proposed)** are starting values to be confirmed by a readability test on a target-class Android phone in Phase 1. Numbers marked **(from concept)** are fixed by `docs/concept.md`.

## 1. Purpose and authority

- What this document governs; what it does not (gameplay, balance, engine settings, which belong to others).
- Order of authority: vision pillars, then concept, then this Art Bible, then asset specs.
- Reference policy: restate pipeline §2.1 in one paragraph. Findings enter this document only as general principles, never as descriptions of specific assets of another game.
- Originality rule: restate vision pillar 5.

## 2. Visual pillars (from the vision pillars)

Each art pillar names the design consequence, the rule, and what it rules out. Phase 1 wording, proposed.

| Vision pillar | Art rule (Phase 1) | Rules out |
|---|---|---|
| 1. Every card is a choice twice | Both faces carry equal visual weight. Play sits on the left page and Bind on the right, each with its own icon shape (Play: open hand-strike mark; Bind: closed stitched loop). The illustration serves both faces | Colour-only Play/Bind coding; an illustration that favours one face |
| 2. Commitment has teeth | A binding has three drawn states: **intact** (taut, whole stitched cord), **frayed** (loose threads, a visible gap, desaturated), **severed** (cut ends, empty loop). The same three states appear on the hero and in the bind slot icon, told apart by silhouette | State shown by tint alone; a severed binding that still looks attached |
| 3. Readable before it is deep | One focal point per area, gameplay information first, decoration second. Every character and enemy passes the black-silhouette test at 25% screen height and the 3 px detail minimum. No hover-only cues | Fine texture that reads as noise at phone size; baked text |
| 4. The run is the whole game | Map, rest, reward and summary art is recognisable in under a second after resuming the app: one large shape per screen, text in Godot labels only | Art that needs reading; run state hidden in decoration |
| 5. A quiet, original dark fantasy | Damp stone, lantern light on black water, bureaucratic horror (stamps, ledgers, cord, wax), no gore. Original symbols, silhouettes and shapes only | Any shape, symbol, layout or character borrowed from another game |

## 3. Mood, palette and value structure

### Anchor palette **(proposed, 12 colours)**
Final values are confirmed in the target pack and the phone test. Painted art may blend between anchors but stays inside their hue families.

| Role | Hex | Use |
|---|---|---|
| Water black | `#0E1317` | deepest background, water |
| Stone dark | `#1B2026` | background walls, shadow |
| Stone mid | `#3A434B` | background mid tones, panels |
| Stone light | `#6B7780` | rim light on stone, UI borders |
| Lantern warm | `#E8A33D` | the single dominant light, highlights |
| Paper | `#E6DCC3` | pages, card faces, text panels |
| Ink | `#1A1426` | linework, text on paper, silhouettes |
| Play accent | `#D9783A` | Play face marks (copper) |
| Bind accent | `#4FA3B8` | Bind face marks (blue-teal) |
| Danger | `#A8324A` | fray and sever telegraphs, damage |
| Guard | `#7C9A6D` | guard, safe states (moss) |
| Wax | `#8C2F2B` | accents on seals and cords, never state coding |

### Value structure (principles)
- Background sits two value steps darker than characters; characters sit one step darker than interactive elements.
- Interactive elements and telegraphs hold the highest local contrast on screen.
- The warm lantern light comes from the upper left in screen space with a cool ambient fill, on the Scrivener, enemies, background and card art alike, so the whole scene has one light.
- Illustration behind the compact card face is lowered in contrast so text wins (4.5:1 minimum).

### Colour-blind safety
- Colour is never the only carrier of meaning. Play vs Bind: shape and page side. Intact vs frayed vs severed: silhouette of the cord. Danger telegraph: icon and number.
- Check each piece in greyscale and with a deuteranopia and protanopia simulation before review. Play copper and Danger crimson are close in some simulations, so they never appear as the only difference between two states.

### Lighting
- One dominant warm light per scene (lantern), cool ambient, light direction from the upper left in screen space, consistent across hero, enemies, background and card art. Exact angle fixed in the target pack.
- Per-floor palette variation limit: a hue shift of at most one anchor family per floor. First playable has one floor.

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
- Layer separation for rig-ready sources (Scrivener, bosses). Part and layer names are `snake_case`, grouped `body/`, `head/`, `arm_front/`, `arm_back/`, `leg_front/`, `leg_back/`, `cloak/`, `book/`, `lantern/`, and `binding_1/`, `binding_2/`, `binding_3/` each with sub-layers `_intact`, `_frayed`, `_severed`. For the Scrivener (direction B): `body/` is the torso painted whole behind the cloak; `leg_front/` and `leg_back/` are reduced to feet and shins mostly hidden under the hem; `arm_back/` carries the lantern hook; `arm_front/` carries the book hand; `book/` holds the book and one loose page. Each part is painted whole behind its overlap so bones can rotate without gaps. Parts are delivered as per-part PNGs with a bottom-centre pivot; a Krita source is optional (deckbound PR #20). Draw order is stated in the spec.
- Proportions **(direction B Bell Cloak, SOU-71, director 2026-11-22)**: the Scrivener is a hooded, bell-shaped cloak about 5 heads tall, wide at the base, with a small hooded head, a visible chin, pale expressive hands and a distinctive contract-book held at the chest. The lantern hangs from a hook held in the back hand so it reads in the silhouette. It reads as one solid rounded vertical shape at 25% screen height, with the lantern and book as the bright accents. Light on the Scrivener: warm key from the upper left, cool rim light on the right. Enemies each have one exaggerated shape feature (attacker: broad and low; frayer: tall and thin with long hands; fouler: bulbous, trailing paper) so no two share a silhouette.
- Binding on the hero: three cords crossing the cloak, each a loop with its own position (shoulder, chest, hip) so the three slots are told apart by place. Cords are lighter than the cloak, in the Bind role colour.

## 6. Cards (compact face, spread)

- Compact face in hand: cost, name, one Play line, divider, one Bind line with bind icon, illustration behind at reduced contrast **(from concept)**.
- Spread: two-page open book, Play on the left page, Bind on the right, shared Ink cost at the spine **(from concept)**.
- Frame and layout art as 9-slice or layered pieces, drawn for both faces at their two sizes. Frame sizes are a `ui-designer` deliverable (audit F9).
- Illustration composition rules: subject inside a safe focal region, readable when mostly covered by text (compact), full at spread size. Illustration authored at spread size, no larger **(from concept)**.
- Card-art production method: original generated illustration, selected and cleaned up by script; Krita fixes optional (pipeline §3, Board 2026-11-22).
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
- Atlas pages at most 2048 x 2048 **(proposed)**, which is 16 MB uncompressed per page; the Scrivener parts atlas uses one such page (see its spec); compressed GPU textures (ASTC, ETC2 fallback) require the project setting and the per-texture `VRAM Compressed` import mode in audit F3.
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

1. Approve the Phase 1 pillars, palette roles and proposed values (§2, §3, §5) as the direction for the slice.
2. Approve the visual target pack in [TARGET-PACK-PLAN.md](TARGET-PACK-PLAN.md): seven pieces (hero, common enemy, boss, card illustration, bind-slot icon, background, UI screen). The pipeline's relic icon is replaced by the bind-slot icon, because the concept has no relics.
3. D1 (local ComfyUI, FLUX.1 schnell and SDXL; final art allowed since 2026-11-22) is decided by the Board (M1 plan, 2026-11-21); workflow in [COMFYUI-WORKFLOW.md](COMFYUI-WORKFLOW.md). Model licences verified 2026-11-22 against the official files (Company OS dependency registry: `sd-xl-base-1-0` CreativeML Open RAIL++-M, `flux1-schnell-fp8` Apache-2.0); the licensing rule is in `AGENTS.md`. D2-D6 in [TOOL-DECISIONS.md](TOOL-DECISIONS.md) remain as approved there.
4. Project-setting changes in audit F1-F3 are `gameplay-programmer` work and are not part of this document.
5. A phone readability test confirms or changes every **(proposed)** number.
