# Deckbound — Concept

Status: **proposed** (SOU-32). Needs `director` review and Board approval before milestone planning.
Companion document: [vision.md](vision.md).

## Pitch

Deckbound is a single-player roguelike deckbuilder in which every card is a choice twice. The hero is the Scrivener, a lapsed archivist who fights with pages torn from a stolen contract-book. Each page can be *played* for an immediate effect or *bound* to the Scrivener: binding removes the page from the deck for the rest of the run and turns it into a permanent passive that enemies can see, fray and sever. Runs are short descents through a drowned archive, and the whole game is in the run: what you bind, what you keep, and what you are willing to lose.

## Genre, platform, engine

- **Genre:** single-player roguelike deckbuilder (turn-based card combat, procedural run, permadeath per run). No multiplayer of any kind.
- **Target platform:** Windows desktop first, 16:9 landscape at 1920x1080 with mouse, keyboard and gamepad. Linux and Steam Deck are cheap follow-ons with Godot and should be kept working but not QA-gated until after the first playable.
- **Mobile:** realistic as a later port, not for the first milestone. Card combat is touch-friendly and the game is turn-based, so the engine and the genre are not the obstacle. The cost is UI: combat and map layouts must be re-composed for small landscape screens, and touch targets must meet a minimum size. To keep that door open, UI work from the start uses Godot Control anchors and containers rather than fixed pixel layouts, and no interaction may depend on hover alone.
- **Engine:** Godot 4.6.3, GDScript with static typing (see `AGENTS.md`).

## Core loop

**Run structure.** A run is a descent through the Sunken Chancery, one floor per act. Each floor is a short branching path of nodes: fights, a harder "warden" fight, rests, events and one boss at the bottom. Reaching the bottom of the last floor wins the run; losing all health ends it. Runs are meant to take under an hour.

**Combat turn.** Combat is turn-based against one to three enemies. Each turn the Scrivener draws a hand of pages and has a pool of Ink to spend. A page can be played (one-off effect, then it goes to the discard) or bound (see the distinctive mechanic below). Enemies telegraph their next action before the player acts. The turn ends when the player chooses; unplayed pages are discarded and enemies act.

**Deck growth.** After fights the player chooses one page from a small offer or takes none. Events and rests offer pages, removals, and the chance to unbind. Pages are the only kind of permanent reward: there are no separate relic or trinket items in the first playable, because bindings fill that role.

**Meta progression.** Unlock-only. Finishing or dying in a run can unlock new pages, events and later new heroes, but nothing makes the next run's hero stronger. Progress between runs is more options, never more power.

## The distinctive mechanic: Binding

Every page in the game has two faces printed on the same card: a **Play** effect and a **Bind** effect.

- **Play** spends the page's Ink cost for the immediate effect. The page goes to the discard and will come back when the deck is reshuffled, as in any deckbuilder.
- **Bind** spends the same Ink cost to bind the page to the Scrivener. The page leaves the deck for the rest of the run and its Bind effect becomes a passive that is always on. The Scrivener has a small number of bind slots, visible on the hero at all times.
- Bindings are **exposed**. Some enemy actions *fray* a binding, turning it off until the end of combat. A few *sever* it, destroying the page outright. Both are telegraphed like any other enemy action, so the player can defend a binding or accept the loss.
- At a rest the player may **unbind** one page, returning it to the deck as an ordinary card.

Why this is the spine of the game: binding thins the deck and strengthens the hero at the same time, which is the trade every deckbuilder player wants, but it is paid for with risk rather than gold. A deck of six pages and three bindings is lean and fast and one bad warden fight away from collapse. A deck of twenty pages with empty slots is safe and sluggish. Every page offer is now two questions: is this good to play, and is this good to wear. Illustrative pages (names and text are placeholders for tone, not a card list):

- *Pressed Thorn.* Play: a strike. Bind: whoever strikes the Scrivener is pricked back.
- *Inkwell Ward.* Play: gain guard this turn. Bind: begin every combat with guard.
- *Torn Margin.* Play: draw pages. Bind: a larger hand each turn.
- *Candle Debt.* Play: a large effect that adds a worthless page to the deck. Bind: Ink refunds when a binding is frayed.

## Setting and tone

The Chancery was the archive of a kingdom that ran on written pacts: every debt, oath and sentence was a bound page, and the Scriveners kept the books. Then the water came, the kingdom drowned, and the books kept binding anyway. The Scrivener descends into the flooded halls with one stolen contract-book to find the page that bound them, and tears out everything in the way. The tone is quiet dark fantasy: damp stone, lantern light on black water, bureaucratic horror rather than gore, and a story told through page text and events rather than cutscenes.

## First playable scope

The first playable proves the binding loop and nothing else. It is a QA-able build, not a demo.

- One hero (the Scrivener), one floor of the Chancery with a branching path.
- About 20 pages, each with a Play and a Bind face, plus a starting deck drawn from them.
- Three common enemy types with distinct roles: a plain attacker, one that frays bindings, one that fouls the deck with worthless pages.
- One boss that can sever bindings.
- Fights, one warden fight, rests with unbind, and a single reward screen. No shop, no events beyond rests, no meta unlocks.
- Placeholder art and UI that respect the visual direction's readability rules (see [vision.md](vision.md)).

## Main risks

1. **Binding is dominant or ignored.** If binding is always right, the game is a relic picker; if never right, it is a plain deckbuilder. Mitigation: every fray and sever source is tuned in data files, and the first playable ships a tuning sheet in `docs/` rather than numbers in code.
2. **Degenerate tiny decks.** Thin decks plus draw passives can loop infinitely. Mitigation: a floor on deck size or a rule for drawing from an empty deck, decided during first-playable tuning and written as an acceptance test.
3. **Two faces on one card hurts readability.** Mitigation: fixed card layout with Play above Bind, a single Ink cost, and a readability check at gameplay scale in every UI review.
4. **Originality drift.** The reference game is close in genre and in visual target. Mitigation: the originality section below is a review checklist for every content PR.
5. **Content and art cost.** Each page needs art and two effects. Mitigation: first playable at about 20 pages, art per `docs/art/ART-PIPELINE.md` rollout phases.

## Originality

The closest existing games and how Deckbound differs:

- **Slay the Spire and Slay the Spire 2** (branching-map roguelike deckbuilders with energy, draw, telegraphed enemy intents and relics). Deckbound shares those genre conventions, which are in general use. It differs in its spine: there is no relic system, passives come only from binding cards out of the deck, and those passives can be attacked. Deck thinning is a core verb, not a shop purchase. All names, characters, card text, symbols, enemies and UI are original; nothing may be taken from either game.
- **Monster Train** (deckbuilder with units placed on floors). Deckbound has no board and no units; the hero is the only permanent piece.
- **Inscryption** (sacrifice-based card costs, meta-narrative). Deckbound's binding is a commitment of the card to the hero, not a sacrifice to pay for another card, and the story stays inside the fiction.
- **Griftlands** (negotiation deck, grafts as passives). Deckbound has one deck and one combat mode; passives are earned from the deck itself rather than from a separate item pool.

Rule for all content: genre conventions and mechanics in general use are fine. Specific names, characters, card text, art, levels, UI layouts and the distinctive look of another game are not. The `director` review of every content PR checks this.

## Acceptance criteria for the first playable

QA can verify each of these on the build:

1. Every page in the build shows a Play effect and a Bind effect and both can be used in combat.
2. Binding a page removes it from the deck, discard and hand for the rest of the run and occupies a visible bind slot.
3. A frayed binding stops applying its effect until end of combat; a severed binding is removed from the run.
4. Fray and sever actions are telegraphed before the player's turn, like any other enemy action.
5. Unbind at a rest returns the page to the deck and frees the slot.
6. A run contains at least one of each listed enemy type and ends in the boss fight; winning and losing both return to a run summary.
7. No name, card text, character, symbol or UI element in the build matches one from Slay the Spire, Slay the Spire 2 or another existing game (reviewer checklist).
