# Deckbound — Vision and Pillars

Status: **proposed** (SOU-32). Pillars require `director` approval; changes to them escalate to `director`.
Companion document: [concept.md](concept.md).

## Vision statement

Deckbound is the deckbuilder where you wear your deck. Every card you take is a question of what you will play and what you will become, and every binding you make is something the world can take from you. We want players to finish a run and talk about the page they bound too early, the one they refused to unbind, and the boss that tore it off them. Short runs, honest rules, a quiet drowned world, and a single mechanic deep enough to carry all of it.

## Pillars

### 1. Every card is a choice twice

**Meaning.** A page is only good enough to ship if both its Play face and its Bind face are worth choosing in some run. Design reviews ask of every page: when would you play it, when would you wear it, and when would you regret either. Enemies, events and rewards are designed to make that answer change over a run.

**Rules out.** Vanilla "number only" cards with a throwaway Bind face, and any separate relic or trinket system that gives passives without going through the deck.

### 2. Commitment has teeth

**Meaning.** Binding is powerful because it is exposed. Bindings can be frayed and severed, unbinding costs a rest, and the deck you thinned does not grow back. The game never quietly refunds a commitment; it makes the consequence visible and lets the player plan around it.

**Rules out.** Free unbinding at any time, undo buttons in combat, and "safe" bindings that no enemy can touch.

### 3. Readable before it is deep

**Meaning.** The player can always see the state that matters: enemy intents, bind slots and their status, deck and discard counts, and the two faces of every page. The screen that matters is a phone held in two hands in landscape at arm's length: everything above must be readable on a 6-inch screen without zooming or scrolling, the whole combat state reads left to right in one glance (the Scrivener and bindings, the fight, the enemies and their telegraphs, the hand below), every card in hand shows a compact face that is enough to decide with, and a single tap opens any page as a spread with both faces at full size. Nothing is shown only on hover, because there is no hover. Depth comes from the interaction of visible rules, never from hidden information. Every new mechanic ships with its on-screen representation, sized for the phone canvas, or it does not ship.

**Rules out.** Enemy actions that are not telegraphed, status effects with hidden timers, card text that requires a glossary to parse, tooltips that need a mouse, and any layout that only reads on a monitor or a tablet.

### 4. The run is the whole game

**Meaning.** A first-run player and a hundred-run player face the same hero and the same rules. Meta progression unlocks options (pages, events, heroes), never power. Runs are short, resumable from any node or turn when the phone is put away, and worth replaying because of decisions, not grind.

**Rules out.** Permanent stat upgrades between runs, currencies that carry over, content gated behind play time rather than discovery, and any purchase or ad reward that changes the power of a run.

### 5. A quiet, original dark fantasy

**Meaning.** The Chancery is our own place: a drowned archive of binding pacts, told through page text, enemy design and short events. Dread comes from the bureaucracy of the dead and from lantern light on black water, not from gore or volume. Every name, character, symbol and line of card text is written for this world; nothing is borrowed from an existing game, renamed or otherwise.

**Rules out.** Long cutscenes or dialogue trees, shock gore, and any character, card, enemy or UI element that would be recognisable as another game's.

## Visual direction

The look is 2D hand-drawn dark fantasy in the house style A Ink Cel: a bold, uneven ink outline and flat cel shading in two or three tones, with readable silhouettes and a restrained palette, as set out in [docs/art/ART-BIBLE.md](art/ART-BIBLE.md) §3A and produced through [docs/art/ART-PIPELINE.md](art/ART-PIPELINE.md). The pillars add two demands that the art pipeline must serve: bindings are worn on the hero and must read as part of the silhouette at gameplay scale, and every page has two faces, shown as a compact face in hand and as a two-page spread on tap, so card layout and type hierarchy are gameplay information first and decoration second. Both are judged on a phone in landscape at the performance budget in [concept.md](concept.md), not on a monitor. Reference study of other games follows the pipeline's §2.1 policy; nothing from those references ships.

## Acceptance criteria

Reviewers and QA can check a design or content change against this document as follows:

1. Each pillar above states a design consequence and names at least one thing it rules out.
2. Any proposed page has a Play and a Bind face that each pass the "when would you choose it" question in its design note (pillar 1).
3. Any proposed passive source other than binding is rejected or escalated to `director` (pillars 1 and 2).
4. Any proposed mechanic ships with an on-screen representation listed in its spec, and any UI change is checked on an Android phone of the target class in landscape: readable at arm's length, the compact card face readable in hand, both card faces legible in the spread after one tap, no hover-only information (pillar 3).
5. Any proposed meta-progression item unlocks options only; anything that raises run power is rejected (pillar 4).
6. Any proposed name, character, symbol, card text or UI treatment is checked against the originality rule before merge (pillar 5).
