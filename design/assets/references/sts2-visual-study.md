# Visual study: a current card-roguelike's art language

Internal reference study for the Art Bible v2 reset (SOU-97). Internal use only. Never shipped, never an image-generation input (`docs/art/ART-PIPELINE.md` §2.1). This file holds our own analysis in words. It has no images, no copied layouts and no extracted data.

Everything here is a reading of general craft. Findings reach the Art Bible only as principles with no asset, card or character names. Every number marked *(proposed)* is ours, not measured from a source.

## Sources

The study cites only these two sources. The game-artist had no web access in this task. Both were collected by the Board session and handed over as text, so this file records what the Board observed and nothing the artist saw first-hand.

### Source A. Official store screenshots

Slay the Spire 2 (Mega Crit), Steam store page, app 2868840. Six official 1920x1080 screenshots. Observed by the Board session on **2026-11-26**.

| Id | Shows | Store image URL |
|---|---|---|
| S1 | combat, forest | https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/2868840/1a373a95229aab0cfd97f553ecbe86092364bb9c/ss_1a373a95229aab0cfd97f553ecbe86092364bb9c.1920x1080.jpg |
| S2 | combat, dock | https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/2868840/f3af7cb9693b9c4b6a7555227db3fef943db3992/ss_f3af7cb9693b9c4b6a7555227db3fef943db3992.1920x1080.jpg |
| S3 | character select | https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/2868840/c3db69efd984ef012ae85c5b426663720152f0a4/ss_c3db69efd984ef012ae85c5b426663720152f0a4.1920x1080.jpg |
| S4 | merchant / event room | https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/2868840/0fdb2940c0d367a40b2be6433daf12e3634089cf/ss_0fdb2940c0d367a40b2be6433daf12e3634089cf.1920x1080.jpg |
| S5 | opening NPC choice | https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/2868840/18e8bda7bc4cdb37b90e0e2ce546967cbec87076/ss_18e8bda7bc4cdb37b90e0e2ce546967cbec87076.1920x1080.jpg |
| S6 | text event | https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/2868840/0aa6bff0eff26e37ccfdb07ad6cab52f8ab1ed4b/ss_0aa6bff0eff26e37ccfdb07ad6cab52f8ab1ed4b.1920x1080.jpg |

### Source B. Public README, text facts only

The public README of github.com/ptrlrd/spire-codex, read by the Board session on **2026-11-26**. That repository and its site redistribute files extracted from the game. **We use none of their images, renders or data.** We use only the public, general facts about how a game of this kind organises its art. Those facts are listed under "Asset structure" below. `docs/art/ART-PIPELINE.md` §2.1 now forbids using such sites as a source.

### Source C (not cited as a source)

General mobile-game craft knowledge: landscape phone readability, touch targets of at least 48 dp, silhouette-first design, colour-blind safety and Android texture budgets. These are common practice, not sources. They appear below as our own reasoning.

## 1. Value and palette

**Observed (A).**
- Backgrounds are dark and low in saturation, with one hue family per scene.
- Characters, enemies and cards are clearly lighter and more saturated than the background.
- The palette changes per scene, from saturated magenta to near-monochrome, while the character style stays constant.

**Analysis.** The scene is grouped into two value layers: a dark, quiet stage and bright actors. The eye lands on the actors with no help from outlines or UI. One hue family per scene means a new area is a recolour of the stage, not a new art style. Characters stay recognisable across areas because their rendering rules never change. Only the stage palette moves.

This also solves the colour-clash problem for generated art. If every background is held to one hue and a low saturation ceiling, any enemy cut-out will pop against it. We avoid per-asset colour matching.

**Deckbound takeaway.** Hold a value gap between stage and actors as a rule, then vary hue per floor area. Keep character rendering fixed across areas.

**Phone-size note.** On a 6-inch screen at arm's length, value contrast carries readability that fine detail cannot. A phone-size review should include a greyscale view of the screenshot. Actors must still separate from the stage in it.

## 2. Outline and shading

**Observed (A).**
- Characters and enemies have a thick, uneven dark outline. Backgrounds do not.
- Shading is flat cel with one shadow step.
- Background edges are soft.

**Analysis.** An outline on actors only is a second cue for "this is interactive or alive". The unevenness (line weight swells at corners and thins on straight runs) gives a hand-inked feel without adding detail. One shadow step keeps forms readable at small sizes and keeps the generated or painted work cheap to make consistently. Soft background edges separate the layers in focus as well as value.

The outline is not just style. It is the silhouette's protective border on mid-value backgrounds. It keeps the figure separate even when a fill colour matches a patch of scenery.

**Deckbound takeaway.** Outline only the actors, make it uneven and heavy, allow one shadow tone, and keep backgrounds soft and outline-free.

**Phone-size note.** At actor heights of 270 to 500 px on a 1080 px-tall canvas, a 6 to 8 px outline stays visible. Thin lines vanish when the render is shown at phone density. Outline weight is set as a fraction of figure height, not as a fixed value.

## 3. Proportion and shape language

**Observed (A).**
- Strongly exaggerated cartoon shapes: big heads and hands, chunky bodies, about 3 to 4 heads tall.

**Analysis.** Exaggeration is a readability tool. A large head carries the face and the identity mark. Large hands carry the verb: what the figure does is visible in the hands. A chunky torso makes a clean block silhouette. Stretching proportions (larger head, shorter legs) is the cheapest way to keep a figure legible when it is 25 % of the screen height.

Each enemy class then gets its own primary shape (wide, tall, round, winged) so classes can be told apart in a black fill. Shape language is the class tag.

**Deckbound takeaway.** Draw actors at about 3 to 4 heads tall with oversized heads and hands. Give each enemy class one unmistakable primary shape and test every figure as a flat black fill.

**Phone-size note.** The 25 % height class is about 270 px on the 1080 px canvas, roughly 15 mm on a typical phone. Faces carry at most one or two marks at that size. Props and hands carry the story.

## 4. Combat composition

**Observed (A).**
- Landscape layout. The player is on the left third, enemies on the right, all on one shared ground line at about 55 to 65 % of the screen height.
- The hand fans across the bottom centre.

**Analysis.** A shared ground line makes the fight read as one stage with two sides. It also fixes where every actor's feet go, which makes pivots and sorting trivial. Putting the ground line above centre leaves the bottom third for the hand and HUD, so the cards never cover the fight. The left-to-right reading order (me, space, them) matches reading direction.

**Deckbound takeaway.** One ground line, hero left, enemies right, bottom band reserved for the hand. The concept's own layout already agrees: this study confirms it and gives the ground-line height as a number to test *(proposed)*.

**Phone-size note.** The OS gesture inset and the camera cutout eat both bottom and side space. Actors stay inside the safe area and only background art bleeds past it.

## 5. HUD hierarchy

**Observed (A).**
- A thin top bar shows HP, gold, potions, floor and map / deck / settings.
- The energy orb sits bottom-left above the draw pile. End Turn sits bottom-right above the discard pile.
- Both are large and isolated.

**Analysis.** The HUD is ranked by how often the player needs it. Constant information lives in a thin bar. Per-turn decisions get large, isolated, corner-anchored controls. Piles sit with their action (resource by the draw pile, end turn by the discard). Isolation (clear space around a control) keeps a mis-tap from landing on the neighbour.

**Deckbound takeaway.** Rank HUD items by frequency and risk: thin passive bar, large corner controls for per-turn actions, clear space around each. Deckbound adds bind slots as a left-edge column, per the concept.

**Phone-size note.** Every tap target is at least 48 x 48 dp, and the consequence-heavy End Turn gets more *(proposed: 72 dp)*. Text in a thin bar must stay at the minimum size set in the Bible. Nothing tappable sits where a swipe-up for home can start.

## 6. Card anatomy

**Observed (A).**
- Frame colour encodes the card's type and the character.
- The cost gem is top-left.
- A name ribbon crosses the top. The art window is in the upper half. A type label sits under the art. The rules text sits on a plain panel.
- The selected card scales up and rises above the hand.

**Observed (B).** Card frames exist per card type and rarity, as a separate asset family from card portraits.

**Analysis.** The card is a stack of fixed zones with one job each: cost, name, picture, type, rules. Colour on the frame is a category code, so the hand is sortable by eye. Rules text sits on a plain panel because text over art fails at reading size. Frames are separate from portraits, so N portraits times M frames costs N + M assets and not N x M. The raised, enlarged selected card is the cheapest "focus" state.

**Deckbound takeaway.** Build the card from separate layers: frame, art window, cost mark, rules panel. Colour the frame by category. Deckbound's card has two faces (Play and Bind), so the compact face and the spread need their own zones, defined in the Bible.

**Phone-size note.** The compact card in hand is small. The only text that must survive is the cost, the name and two short lines, so zones are sized for that. The full text lives in the spread, which uses the wide screen.

## 7. Enemy readability and intents

**Observed (A).**
- The HP bar with numbers sits under each combatant, with status icons under it.
- The intent icon and number float above the enemy.
- Damage numbers are large and centred over the target.

**Analysis.** Each combatant carries a vertical stack of information in a fixed order: intent above, body, health below, statuses under that. The player learns where to look once. Damage numbers sit on the target, where the eye already is, and grow big because they are the fight's feedback. The enemy's body shape gives the class and the floating icon gives the next action, so there are two separate channels of information, one slow (shape) and one fast (icon).

**Observed (B).** Skins and variants are reused across related monsters, so one skeleton can serve several enemies.

**Deckbound takeaway.** Keep the fixed stack: telegraph above, figure, health below, status row below that. Make intent icons shape-distinct, not just colour-distinct. Reuse one rig across related enemies when a palette and prop swap is enough.

**Phone-size note.** The telegraph icon and number are at least 20 sp as the milestone requires. The status row is the first thing to become unreadable, so statuses are capped at a few icons and long-press opens the detail.

## 8. Events and dialogue

**Observed (A).**
- A large illustration takes the left or centre.
- Wide choice buttons are stacked, with a gold title and white text.
- Keywords are coloured inline.
- NPC portraits exist, with small portrait icons (B).

**Analysis.** An event screen is one picture plus a short list of big choices. The picture sets the mood, and the stacked wide buttons are easy thumb targets. A gold title over white body text gives a two-level hierarchy in a single colour accent. Coloured inline keywords let the player scan for outcomes without reading every line.

**Deckbound takeaway.** M1 has no events apart from rests, so only the rest and reward screens use this pattern now. Plan the pattern (one big picture, stacked wide choices, one accent colour for titles) so later events reuse it.

**Phone-size note.** Landscape leaves little height for a stack of buttons. Each must be at least 48 dp tall with spacing. Three choices is the practical limit per screen.

## 9. Animation approach

**Observed (B).**
- Characters and monsters are skeletal animations, not static images.
- Each character has several poses: combat, rest site and character select.
- Skins and variants are reused across related monsters.

**Observed (A).** The mood changes per scene while character style stays constant, which suggests animated actors are a reusable layer over a swappable stage.

**Analysis.** Skeletal animation gives many frames from one set of parts, which suits a small team and a tight install size. Variants reuse one skeleton with different parts or colours, so cost scales with the number of skeletons, not enemies. Multiple poses per hero (combat, rest, select) are cheap once the parts exist.

**Deckbound takeaway.** Rig the hero and the bosses with Godot Skeleton2D (no Spine, per `docs/art/TOOL-DECISIONS.md` D2 and D3). Common enemies use short frame loops or a light Skeleton2D. Related enemies share a rig where the silhouette still differs. Every action reads in three beats: anticipation, impact and recoil.

**Phone-size note.** Skeleton2D is cheap in memory, because it needs one atlas rather than many frames. On a 3 to 4 GB Android phone that matters more than the animation budget in CPU. Test the rig on the target device class, not on a desktop.

## Asset structure learned from source B

Text facts only. These tell us how a game of this kind organises its art. They are not a list of copied assets.

- Characters and monsters are skeletal animations, with several poses per character.
- Skins and variants are reused across related monsters.
- Asset families:
  - card portraits
  - card frames per card type and rarity
  - relic icons
  - potion icons
  - intent icons
  - power / status icons
  - orb / resource icons
  - map-node icons
  - NPC portraits and their small portrait icons
  - boss encounter icons
  - backgrounds per act or area
  - achievement / badge icons
- Scale of a full game, for proportion only: about 5 characters and over 100 monsters, with hundreds of cards, relics and potions. M1 needs a small fraction of this (see `docs/art/ASSET-LIST-M1.md`).

## What this study does not claim

- It does not claim any measured pixel value, line width or colour from a source. All numbers are ours and marked *(proposed)*.
- It does not describe or reproduce any specific character, enemy, card or layout.
- It is a reading of six official screenshots as the Board described them. The artist did not view them.
