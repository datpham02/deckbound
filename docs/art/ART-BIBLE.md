# Deckbound Art Bible v2

Status: **proposed**, v2 (SOU-97, 2026-11-26). Rewritten from zero after the Board's art reset of 2026-11-26. Nothing from v1 is carried over. Needs Board approval before any asset is produced against it.

Read with: [ART-PIPELINE.md](ART-PIPELINE.md), [TOOL-DECISIONS.md](TOOL-DECISIONS.md), [ASSET-LIST-M1.md](ASSET-LIST-M1.md), [../concept.md](../concept.md), [../vision.md](../vision.md), [../design/enemies.md](../design/enemies.md), and the reference study [../../design/assets/references/sts2-visual-study.md](../../design/assets/references/sts2-visual-study.md).

**How to read this document.** It states principles only. Every number is **(proposed)**: a start value for the first style test, to be confirmed or replaced by that test and by Board approval. Gameplay design (the hero, Binding, the Sunken Chancery, the five enemies) is fixed by the gameplay docs and is not changed here. Only its look is set. Canvas coordinates are for the 2400 x 1080 design canvas. At about 2.6 px per dp **(proposed)**, 48 dp is about 126 px.

## 1. Visual pillars

1. **Actors first.** Heroes, enemies and cards are lighter, warmer and more saturated than any stage behind them. The eye never has to search.
2. **Shape before detail.** Every actor is identified as a flat black shape at its on-screen size. Detail is a reward for looking closer, never the way to tell things apart.
3. **Bold, hand-inked, chunky.** Thick uneven outline on actors, flat colour with one shadow tone, exaggerated cartoon proportions. The look is friendly in form and dark in setting.
4. **Quiet world, loud information.** The Chancery is damp, dim and still. Gameplay information (telegraphs, bindings, counts) is the brightest and cleanest thing on screen.
5. **Phone first.** Judged on a phone in landscape at arm's length. A thing that only reads on a monitor is not finished.
6. **One style, many moods.** Colour mood changes by area. Character rendering never does.
7. **Never colour alone.** Every state and category is also told by shape, position or a mark.

## 2. Style

All **(proposed)**.

| Element | Rule |
|---|---|
| Outline | Characters, enemies and props held by actors have a heavy, uneven dark outline: weight swells at corners and overlaps, thins on long straight runs. Weight is about 1.8 to 2.2 % of figure height, never less than 5 px at on-screen size. |
| Outline colour | A near-black warm brown, never pure black, one value for all actors. |
| Backgrounds and stage | No outline. Soft edges, shapes defined by value. |
| Shading | Flat fill plus one shadow tone, hard-edged, cast from the upper left. A rim of light is allowed on one edge and counts as the single highlight. No gradients on actors, no texture noise. |
| Fills | Few, clean colours per actor. A figure has a main colour, a secondary colour and one accent. |
| Detail | At most one or two marks on the face at the 25 % screen-height size class. Props and hands carry the story. |
| UI | Flat, rounded, outlined in the same warm near-black. UI is lighter than the stage and calmer than actors. |

## 3. Value rule

- The stage (backgrounds, floor, set dressing) occupies the dark and low-saturation end. Proposed ceiling: stage saturation about 35 % and stage lightness no more than about 40 % **(proposed)**.
- Actors (hero, enemies, cards in hand) sit at least about 25 points of lightness above the stage average, and have clearly higher saturation **(proposed)**.
- Information (telegraph, numbers, counts) is the lightest layer, on a dark plate, so it passes in greyscale.
- **Test:** convert a combat screenshot to greyscale. Hero, enemies and telegraphs must still stand out from the stage. A failure here fails the asset, whatever the colour looks like.
- Exception: a shape that is meant to read as a dark mass (ink pool, a bar where a face would be) must be framed by a lighter body or outline so the figure's silhouette is still found.

## 4. Palette per area

Every area has **one hue family** for the stage, with a narrow set of values. Actors keep their own fills in every area. Hue families here are proposed names for the Chancery's places, to be confirmed in a swatch test.

| Area | Mood | Stage hue family | Notes |
|---|---|---|---|
| Combat, flooded reading halls (M1 floor) | cold, damp | deep teal-blue | Lantern amber is the only warm light, a small, local glow. |
| Warden hall | formal, heavy | deep ink-violet | Same shapes as the halls, a different recolour. |
| Boss chamber | pressure, ink | deep oxblood-brown | Strongest contrast of the floor; the one place a larger dark shape may sit behind the actor. |
| Rest | refuge | dusky amber-brown | The only warm stage in M1, because it is a safe room. Still darker than actors. |
| Map | parchment | desaturated sepia on a dark ground | Nodes are icons on a page, not a scene. |
| Later areas | one new hue family each | by decision | The same rules apply. |

Rules:
- One hue family per scene. Do not mix two saturated hues in a stage.
- Accent colours for gameplay (see §10) are reserved. A stage never uses them at full saturation.
- Colour-blind safety: do not set red against green for any meaning. Pairs that must be told apart also differ in value or shape. Test with a deuteranopia and a protanopia simulation, and greyscale.

## 5. Shape language

Each actor is told apart as a **solid black shape** at its size class. Size classes are fractions of the screen height, from `docs/design/enemies.md`. Every figure is drawn at about 3 to 4 heads tall with an oversized head and hands. Enemies face left, the hero faces right.

| Actor | Primary shape | Silhouette rules |
|---|---|---|
| Hero (the Scrivener) | An upright rounded trapezoid, widest at the shoulders and coat hem | See §6. About 32 % of the screen height. |
| Bailiff (attacker, common) | **Wide and stooped.** A broad horizontal block with a hood on top | The widest of the commons. A long hooked rod runs across the body, so the silhouette has one diagonal. Heavy wet hem on the ground. |
| Bookmoth (frayer, common) | **Winged.** A triangular spread of torn wing corners around a small body | The only winged silhouette in M1. A trailing thread curls from below. Never grounded. |
| Blotter (fouler, common) | **Low and round.** A squat dome that slumps toward the ground | The lowest and roundest of the commons. One arm ends in a flat stamp-shaped fist. An ink pool spreads on the floor. |
| Registrar (warden) | **Tall and narrow with a flat top.** A tall column topped by a wide flat block | Taller and narrower than any common. About 35 % of the screen height. |
| The Redactor (boss) | **Largest, hooded, with one long horizontal line.** A wide cloak mass cut by one strike-through blade | Reads as "a line through a page". About 45 % of the screen height. |

Shape tests (all at on-screen size, flat black fill on mid-grey):
- Commons: wide, winged and low are told apart at arm's length.
- Warden and boss: both read as bigger than the commons, and as different from each other (a flat-topped column versus a hooded line).
- Colour is allowed to differ between figures, but is never what separates them.

## 6. Hero design identity

Described in words. The finished design is made later, in the style test of the next task.

**Who.** The Scrivener: a lapsed archivist who carries a stolen contract-book and tears pages out of it (`concept.md`). The tone is quiet dark fantasy with bureaucratic horror. The figure is tired, determined and slightly rumpled, not heroic in a knightly sense.

**Proportion (proposed).** About 3.5 heads tall. The head is large, with an oversized hand on each arm. The torso is chunky and the legs are short. Head height is about 28 % of figure height.

**Identity invariants** (what makes the Scrivener the Scrivener in any pose):
- A long, ink-stained work coat that reaches the knees, with a high collar. The hem is uneven.
- A large, thick contract-book held in the off hand (the left hand when facing right) with torn pages visible at its edge.
- **Bindings are drawn into the silhouette.** The hero has three bind positions, shown as page-strips tied with thread on the near arm, shoulder and hip. Each one is a flat page shape with a wax or ink seal. An empty position reads as a bare tie.
- A head shape that is easy to mark in black: a mop of short, messy hair or a soft cap, plus round spectacles with large lenses as the face's one signature mark.
- A pen or quill tucked behind the ear or held in the active hand.
- Palette: warm parchment and oxblood coat, an ochre accent, warm near-black outline. This is the warmest and most saturated figure on a cold stage.

**Pose-specific properties** (what animation may change): limb angles, facing within the two sides, grip, cloth swing, expression, which page is torn, and overlap order.

**Replaceable representations**: the reference pose, any concept image and the part split. They can be redone from the invariants.

**States** used in M1: idle, tear a page (play), bind a page, hit, defeat. A rest pose and a portrait come later.

## 7. Combat screen layout

For the 2400 x 1080 landscape canvas, with the wider range 1920 x 1080 to 22:9 in mind. All values **(proposed)**. Gameplay placement is from `concept.md` and is not changed here.

**Safe areas.**
- Side inset: about 120 px on each side for the camera cutout, shifted inward on the cutout side. Elements anchored to a side edge sit inside it.
- Bottom inset: about 60 px for the gesture bar, plus a margin of about 24 px.
- Top inset: about 24 px. The status bar is hidden.
- Only full-bleed backgrounds may extend into the unsafe region.

**Zones.**

| Zone | Placement | Contents |
|---|---|---|
| Top strip | Thin bar across the top, inside the safe area | Hero health, floor, deck and settings. Slim, passive. |
| Ground line | About 60 % of screen height (y about 648) | All actors' feet stand on it. Pivot is bottom centre. |
| Hero zone | Left third, x about 200 to 800 | The hero at full figure, health and guard directly below the feet. |
| Bind slots | Short column at the left edge beside the hero | Four-state slot icons. Each at least 126 px. |
| Fight space | Between the hero and the enemies | Play drop zone. Effects play here. |
| Enemy zone | Right two-thirds, x about 1000 to 2250 | One to three enemies on the ground line, each with the stack in §9. |
| Hand band | Bottom quarter, from y about 800 | Cards fan across the bottom centre, above the gesture inset. |
| Ink and deck | Bottom left | A large Ink number with its maximum, beside the deck pile. |
| Discard and end turn | Bottom right | Discard pile in the corner. End turn above it, clear of the hand. |

**Enemy stack, top to bottom:** telegraph (icon and number), figure, health bar with number, status icons. Damage numbers appear large and centred on the target.

**Rules.**
- Nothing tappable is smaller than 48 x 48 dp (about 126 px). End turn is larger, about 72 dp **(proposed)**.
- Nothing tappable sits where a swipe-up for home can start.
- Text minimums, from `docs/milestones/M1-first-playable.md`: 12 sp for tertiary text, 14 sp for body, 20 sp for telegraph numbers. At about 2.6 px per sp, that is about 31, 36 and 52 px.
- A 16:9 screen loses only side margin. A 22:9 screen gains width at the sides, filled by background art, never by new gameplay elements.

## 8. Card anatomy

Cards are built from separate layers, so portraits and frames multiply cheaply. Gameplay content is in `docs/design/pages.md`.

**Compact face (in hand)**, size on screen about 170 x 238 px **(proposed)**, ratio 5:7:

| Zone | Rule |
|---|---|
| Frame | Outlined, rounded. Frame colour codes the page's category. Shape of the frame ornament also differs per category, so colour is never the only cue. |
| Ink cost mark | Top left, in a round or gem-like shape, high contrast numerals. Never overlapped by a neighbouring card. |
| Name ribbon | Across the top. Name text on a plain plate. |
| Art window | Upper half. The illustration is for identification and mood, not information. Reduced contrast under text. |
| Play line | One short line on a plain panel, with the Play mark. |
| Divider | A visible tear or stitch line separating Play from Bind. |
| Bind line | One short line on the panel, with the bind mark. |

**Spread (after a tap)**, shown across the wide screen as an open book: Play page on the left, Bind page on the right, the shared Ink cost at the spine, the art across both. Full rules text on plain panels. The enemies and bind slots remain visible, dimmed.

**Rules.**
- Text sits on plain panels, never directly on art.
- Both faces have the same weight and importance. Neither looks like the main one.
- Keywords (Guard, Ink, Fray) get an icon or colour mark inline, plus the word.
- The selected card scales up and rises above the hand. No hover state exists.
- Card portrait art is authored at about 512 x 384 px **(proposed)**, not larger.
- Frame variants per category are separate assets from portraits. Rarity variants are added only when the game has rarity.

## 9. Icon family rules

All icons share: the warm near-black outline of §2, a flat fill with one shadow tone, a simple central symbol, and a plain contrast plate where they sit on art.

| Family | Rules |
|---|---|
| Intent (telegraph) | Five kinds: attack, guard, fray, foul, sever (`enemies.md` §3). Each has its own silhouette, so they are told apart as black shapes, plus a colour from §10. Always shown with a number at 20 sp or more. Minimum 96 px **(proposed)**. |
| Status | Small, one simple symbol each, count shown as a number, never as repeated icons. At most about five shown, the rest by long-press. |
| Bind slot | Four states told by **shape**, not colour alone: empty (dashed outline, no seal), intact (whole page strip and a closed seal), frayed (the strip's edge torn and the seal cracked), severed (strip and seal in two separated halves). The frayed state also carries a small notch mark. Minimum 126 px. |
| Relic | Not used in M1 (the concept has none; bindings fill that role). If added later, the same family rules apply. |
| Potion | Not used in M1. Same note. |
| Map node | One symbol per node type (fight, warden, rest, reward, boss). Distinct silhouettes, minimum 126 px touch target, visited and unvisited told apart by value and a mark. |
| Resource and pile | Ink, deck and discard marks. Large, isolated, in the bottom corners. |

Prefer **deterministic vector or scripted construction** for icons that need exact geometry or a strict grid. Use image generation for organic shapes.

## 10. Gameplay colour accents (proposed)

Reserved accents, used for gameplay meaning. Each is paired with a shape and a word or number.

| Meaning | Accent | Paired cue |
|---|---|---|
| Attack | warm red-orange | sharp, pointed shape |
| Guard | cool blue | rounded shield shape |
| Fray | amber | torn-edge shape |
| Foul | muted violet | drip shape |
| Sever | bright white-and-black pair | split shape |
| Ink resource | deep blue-black with a light core | round drop |
| Health | warm red on dark plate | number always shown |

Rule: a screenshot passed through a deuteranopia filter must still separate Attack from Guard and Fray from Sever by shape and value.

## 11. Animation rules

Per `docs/art/TOOL-DECISIONS.md` D2 and D3, the rigged-animation tool is Godot **Skeleton2D**. There is no Spine.

| Actor | Method | States |
|---|---|---|
| Hero | Skeleton2D, one parts atlas | idle, tear a page (play), bind, hit, defeat |
| Bosses | Skeleton2D | idle, telegraph, big attack, hit, phase mark, defeat |
| Common enemies | Short frame loops, or a light Skeleton2D where the shape allows | idle, attack, hit, defeat. Related enemies may share a rig. |
| Warden | Skeleton2D or frame loop, by decision | as common enemies plus a heavy attack |

Principles, all actors:
- Every action reads in three beats: **anticipation** (a slow wind-up pulling away from the target), **impact** (one or two fast frames at full extension), **recoil** (overshoot and settle).
- A telegraphed action's anticipation is clearly longer than other idles, so the telegraph and the body agree.
- Idle is a small, slow loop (a breath or a sway) of about 2 to 3 seconds **(proposed)**. It never moves the silhouette enough to disturb the shape test.
- Timing on twos or threes (about 8 to 12 poses per second) suits the flat cel look **(proposed)**. Keep key poses clear and tween the rest.
- All motion stays within the actor's size class box, so layout never shifts.
- Hit reaction: a quick squash and a brief light flash **(proposed)**, not a screen shake over gameplay information.
- Animation events (impact frame, effect spawn) are named markers, so the programmer can hook damage numbers and effects to them.

## 12. VFX style

- Flat, bold, outlined shapes: ink splashes, torn page scraps, wax seal cracks, thread snaps. No realistic smoke, no photographic textures.
- Effects use the gameplay accent of the action (§10) and the warm outline.
- Short: 250 to 500 ms for a hit, up to about 800 ms for a fray or sever **(proposed)**. They never hide telegraphs, numbers or bind slots.
- Fray and sever read in the fight space as a line from the enemy to the bind slot, and as a visible tear at the slot.
- A handful of particles per effect, with a per-combat cap set by `gameplay-programmer`. Sprites are few, small and reusable.
- No full-screen flashes. Nothing flickers faster than three times a second.
- Effects are built in Godot (particles, shaders) from small sprites supplied by `game-artist`.

## 13. Android texture budgets (all proposed, confirmed by T20)

Targets: a low to mid-range phone from about 2020 (3 to 4 GB RAM, Mali-G52 or Adreno 610 class), Android 10 or newer, from `concept.md`. The download stays under 100 MB.

| Item | Budget |
|---|---|
| Art in the install, M1 | At most about 60 MB compressed on disk |
| Texture memory resident in combat | At most about 64 MB after GPU compression, including UI |
| Atlas size | At most 2048 x 2048. Use 1024 where it fits. |
| Hero parts atlas | One atlas, at most 2048 x 2048 |
| Each common enemy | At most 1024 x 1024 or its share of a shared atlas |
| Boss | At most 2048 x 2048 |
| Combat background | At most 2400 x 1080 plus a margin for the wider range. Compressed. Parallax layers only if memory allows. |
| Card portraits | About 512 x 384, in atlases |
| Icons | 96 to 192 px, in a shared atlas |
| Format | GPU compression per Godot import (T20), lossless sources in `art_src/` |

Rules:
- Author at phone scale. Do not author at print or desktop size and downscale at the last step.
- Reuse beats new art: one rig, one frame set, one palette swap.
- Large flat-colour areas compress better than noise. The flat cel look is cheaper than a painted look, which is a reason for the style, not just a taste.
- Anything above its budget needs a reason in its asset spec.

## 14. Review checklist

An asset is not ready for review until every line below has a result in its handoff: pass, fail, or `UNVERIFIED` with the reason.

1. Shape test: flat black fill at on-screen size is identifiable and different from its neighbours.
2. Greyscale test: the actor separates from its stage.
3. Outline: weight, unevenness and colour match §2. Actors only.
4. Shading: one shadow tone, hard-edged, upper left. No gradients.
5. Proportion: about 3 to 4 heads tall, oversized head and hands.
6. Palette: matches the area's hue family and the actor's fills.
7. Colour-blind check: deuteranopia, protanopia and greyscale views.
8. Size: matches the canvas and the budget in §13.
9. Pivot, canvas and transparent edges: no matte halo, no stray pixels, pivot at bottom centre for actors.
10. Phone-size view: the asset is checked at on-screen size on the target background, and where possible in an engine frame at 2400 x 1080.
11. Touch targets: at least 48 x 48 dp for anything tappable.
12. Animation: anticipation, impact and recoil are present. Loops close. Markers are named.
13. Originality: nothing resembles another game's character, creature, layout or icon. The prompt names no other game, studio, artist or character.
14. Provenance recorded: tool, model, prompt, seed, size and each operation.
15. Registry and spec updated, `approved` is never set by the game-artist.

## 15. ComfyUI style recipe v2 (to be tested by the next task)

Written new for v2. It names no other game, studio, artist or character. It is a proposal: the next task generates test figures with it and records what works. Settings follow `docs/art/COMFYUI-WORKFLOW.md` and the tools approved in `docs/art/TOOL-DECISIONS.md`: text prompts only, no reference images.

**Core style words (all actors, characters and enemies):**

> chunky cartoon character, big head, oversized hands, short legs, three and a half heads tall, thick uneven dark brown ink outline, heavy hand-inked line with swelling corners, flat colour fills, a single hard-edged shadow tone, bright saturated colours, clean simple shapes, full body, standing, facing right, plain flat light grey backdrop, no ground shadow, no text

(For enemies, "facing left".)

**Per-subject line, appended to the core words.** Describe the original design from §5 and §6 only, for example:
- Hero: "tired archivist in a long ink-stained coat with high collar, holds a thick book with torn pages, round spectacles, messy hair, pen behind the ear, strips of paper tied with thread on arm shoulder and hip, parchment and oxblood colours".
- Common enemy: the silhouette rule and one prop from §5, plus the fill colours.

**Negative words (SDXL):** "thin lines, sketch, realistic, photo, 3d render, gradient shading, soft airbrush, painterly texture, text, watermark, signature, background scenery, multiple figures, cropped, extra limbs".

**Settings to test (proposed):**

| Setting | FLUX.1 schnell | SDXL |
|---|---|---|
| Size | 1024 x 1024 | 1024 x 1024 |
| Steps | the model's recommended low-step value | the workflow's default |
| Candidates per round | 4 to 8, different seeds | 4 to 8, different seeds |
| Seed | recorded for every candidate | recorded for every candidate |

**Backgrounds (separate words, stage layer):**

> wide empty environment, dark low saturation, single hue teal, soft edges, no outlines, flat large shapes with simple value steps, flooded stone hall with arched shelves and black water, faint lantern glow, clear empty floor in the lower middle, no figures, no text

(Change only the hue word per area from §4.)

**Card art words:**

> small illustration, same chunky cartoon style, thick uneven dark brown outline, flat colour with one shadow tone, one clear subject, simple background shape, no text, no frame

**Process notes:**
- Judge every candidate at on-screen size, flat-black and in greyscale, against §14.
- Cut out figures with the approved matte operation. Do not key figures by colour.
- Use deterministic scripted operations for icons, frames and repeated variants, not generation.
- Test whether outline weight and proportions stay constant over candidates. If they do not, record which words or settings fail and propose a change.

## 16. Open questions for the Board

1. **Hero proportion.** Is about 3.5 heads right, or should the head be larger still (closer to 3)? The next task shows both.
2. **Rig from generated art.** Skeleton2D needs separated parts. Generating a whole figure, then splitting it, may lose consistency. Does the Board accept hand or scripted part cleanup, or a part-by-part generation test first?
3. **Outline consistency.** Generated outlines vary in weight. Does the Board accept an outline-normalisation step (scripted) or require regeneration until consistent?
4. **Rest and map mood.** The rest area is the only warm stage in M1. Confirm, or keep the whole floor cold?
5. **Card categories.** The page set has no categories yet, so the frame colour code in §8 has nothing to code. Ask `game-designer` for page categories, or use one frame for M1?
6. **Font.** M1 uses Godot's default font. Choose a licensed font at the style test?
7. **Stale references in kept documents.** Several kept docs still point to the old Art Bible section numbers and the old house style name: `concept.md`, `vision.md`, `docs/design/enemies.md`, `docs/design/pages.md`, `docs/art/COMFYUI-WORKFLOW.md` and `docs/art/TOOL-DECISIONS.md`. Those edits were outside this task. Which Task fixes them?
8. **Ground line and sizes.** The 60 % ground line and the size classes are proposed and untested at phone size. The next task checks them in a Godot frame.
