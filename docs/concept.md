# Deckbound — Concept

Status: **proposed** (SOU-32). Needs `director` review and Board approval before milestone planning.
Companion document: [vision.md](vision.md).

## Pitch

Deckbound is a single-player roguelike deckbuilder in which every card is a choice twice. The hero is the Scrivener, a lapsed archivist who fights with pages torn from a stolen contract-book. Each page can be *played* for an immediate effect or *bound* to the Scrivener: binding removes the page from the deck for the rest of the run and turns it into a permanent passive that enemies can see, fray and sever. Runs are short descents through a drowned archive, and the whole game is in the run: what you bind, what you keep, and what you are willing to lose.

## Genre, platform, engine

- **Genre:** single-player roguelike deckbuilder (turn-based card combat, procedural run, permadeath per run). No multiplayer of any kind.
- **Target platform:** Android phones, published on **Google Play** (Board decision, 2026-11-21). Every milestone is built, tested and accepted on an Android device. Desktop (Windows, Linux) and iOS are possible later ports, not targets: nothing in the first playable is designed for them, and nothing may be designed in a way that only works on them. Tablets must not break, but phones are the design target.
- **Engine:** Godot 4.6.3, GDScript with static typing (see `AGENTS.md`). Builds ship as an Android App Bundle from the Godot Android export.

### Orientation and screen

**Recommendation: portrait.** Pending Board decision. The reason is the two-faced card. A page must show Play above Bind on one card, so cards are tall; in portrait the hand spans the bottom of the screen with each card wide enough to read, the Scrivener and the bind slots sit just above the hand, and the one to three enemies with their telegraphs stack at the top. That is the whole combat state in one vertical glance, held in one hand, which is how a short session on a phone is actually played. Landscape would give a wider enemy row and look more like a desktop deckbuilder, but it halves the height available to the hand, forces two faces into a squat card, and needs two hands. If the Board prefers landscape, the card layout and the hand must be redesigned before UI work starts; everything else in this document stands.

- **Reference resolution:** 1080 x 2400 portrait (20:9) as the design canvas. The layout must also work unchanged from 16:9 (1080 x 1920) to 22:9, using Godot's `canvas_items` stretch with `expand` aspect so taller phones gain space rather than letterbox. No fixed pixel layouts: Control anchors and containers only.
- **Safe area:** all gameplay information and every tappable element stay inside the OS-reported safe area (status bar and camera cutout at the top, gesture navigation bar at the bottom), with an extra margin so a swipe-up for home cannot start on a card. Only full-bleed backgrounds may extend into the unsafe region. Changing the project's stretch or orientation settings requires Board approval per `AGENTS.md`.

### Input

Touch only. There is no hover state anywhere in the game, and no information is shown only on hover. Rules:

- **Touch targets:** every tappable element is at least 48 x 48 dp (about 9 mm), including cards in hand, bind slots, enemies, the end-turn button and map nodes. Cards in a full hand may overlap visually, but each keeps a 48 dp-wide tappable strip.
- **Reading both faces:** cards in hand show both faces at hand scale with abbreviated text. A **tap** on a card lifts it to full size, with both faces fully legible, and highlights the targets it can be played on or the slots it can be bound to. A **long-press** on any card, binding, enemy telegraph or status opens an inspect overlay with full rules text; releasing closes it and does nothing else. Inspecting is always free and never commits an action.
- **Play versus Bind without mis-taps:** a first tap never acts; it only selects. From a selected card, **Play** is a drag upward onto an enemy or the play area, and **Bind** is a drag downward onto one of the Scrivener's bind slots. The two destinations are on opposite ends of the screen, so a slip cannot turn one into the other. Because binding cannot be undone until a rest, dropping on a slot does not bind yet: the slot lights up with a Bind label and a second tap on it confirms. Releasing anywhere else cancels and returns the card to the hand. The end-turn button sits away from the hand and the gesture bar and asks for a tap, not a swipe.

## Core loop

**Run structure.** A run is a descent through the Sunken Chancery, one floor per act. Each floor is a short branching path of nodes: fights, a harder "warden" fight, rests, events and one boss at the bottom. Reaching the bottom of the last floor wins the run; losing all health ends it.

**Session length and resuming.** A full run is meant to take 20 to 30 minutes, made of fights of two to four minutes, so that one node is a complete session on a bus and a run is an evening's play in pieces. Runs are always resumable. The game saves the run state at every node transition and at the end of every combat turn (after the player ends the turn and after the enemies act), and on the app being paused. Backgrounding or killing the app and reopening it returns the player to the same node and the same turn with the same hand, deck, discard, bindings and enemy telegraphs. There is no "abandon on exit"; a run only ends by winning, dying or the player choosing to abandon it from the map.

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
- Placeholder art and UI that respect the visual direction's readability rules (see [vision.md](vision.md)), laid out for the portrait phone canvas above.
- Save and resume at every node and combat turn, delivered as an Android App Bundle and installed on a target-class device for QA.

## Performance budget

- **Target device class:** a low to mid-range Android phone from about 2020 onward: 3 to 4 GB of RAM, an entry-level GPU (Mali-G52 or Adreno 610 class), a 1080p-class screen, Android 10 or newer. If it runs well there, it runs everywhere on Google Play that matters. QA keeps at least one such device; a flagship is not a test device.
- **Frame rate:** a steady 60 frames per second in combat and on the map on the target device, never dropping below 30 during card and binding animations. The game is turn-based, so this budget is about animation smoothness and input latency, not simulation.
- **Install size:** under 100 MB download for the first playable and under 150 MB at release, inside Google Play's base bundle limit without on-demand asset packs. Memory use stays under 1 GB at peak so the OS does not kill the app in the background and discard the resume state.
- **What this means for the art pipeline** (`docs/art/ART-PIPELINE.md`): painterly art is authored at phone scale, not desktop scale. Card illustrations, enemies and backgrounds are sized for the 1080-wide canvas, packed into compressed atlases, and never shipped at print resolution. Rigged skeletal animation is limited to the Scrivener and bosses, as the pipeline already prefers; common enemies use short frame animation. Any Spine or skeletal runtime must pass its proof of concept on the target device, not on a desktop. Particle and shader effects are capped per combat so that the fray and sever telegraphs read without the phone throttling. The renderer choice (Godot's Compatibility renderer is the safe default for 2D on this device class) is a project setting and needs Board approval before it changes.

## Monetization: open Board question

No monetization model is chosen in this document. The options the Board must decide between, with what each brings:

1. **Paid up front.** One price on Google Play, no in-app store. Simplest legally and in design; hardest to get installs for an unknown title.
2. **Free with one unlock.** The first floor is free; one in-app purchase unlocks the full game. Needs Google Play Billing integration and the IAP requirements below.
3. **Ads.** Free with interstitial or rewarded ads. Needs an ads SDK, user consent handling in the EU and UK, and the ad network's own data disclosures; rewarded ads also pull at pillar 4 ("The run is the whole game") and must never sell run power.
4. **In-app purchases.** Cosmetics or content packs. Same requirements as option 2, and more store review surface.

Both ads and IAP add legal and store requirements beyond a paid app: Google Play Billing and its policies, a consent framework for personalised ads, extra answers in the data safety form, and in some regions age-gating and refund rules. The decision affects the first playable only in one way: nothing in the run may be designed so that it is later gated behind money for power (pillar 4).

## Main risks

1. **Binding is dominant or ignored.** If binding is always right, the game is a relic picker; if never right, it is a plain deckbuilder. Mitigation: every fray and sever source is tuned in data files, and the first playable ships a tuning sheet in `docs/` rather than numbers in code.
2. **Degenerate tiny decks.** Thin decks plus draw passives can loop infinitely. Mitigation: a floor on deck size or a rule for drawing from an empty deck, decided during first-playable tuning and written as an acceptance test.
3. **Two faces on one card hurts readability.** Mitigation: fixed card layout with Play above Bind, a single Ink cost, and a readability check at gameplay scale in every UI review.
4. **Originality drift.** The reference game is close in genre and in visual target. Mitigation: the originality section below is a review checklist for every content PR.
5. **Content and art cost.** Each page needs art and two effects. Mitigation: first playable at about 20 pages, art per `docs/art/ART-PIPELINE.md` rollout phases, authored at the phone budget above.
6. **Two faces on a phone screen.** The readability risk is sharper on a 6-inch screen than on a monitor. Mitigation: the portrait canvas, tap-to-lift and long-press inspect rules above, and a readability check on the target device in every UI review.
7. **Resume state bugs.** Saving every turn means a save-and-reload of a combat mid-turn must be exact or the player loses trust and bindings. Mitigation: the save is the single source of run state from the start, and QA tests kill-and-resume at every node type.

### Google Play prerequisites

These are prerequisites and risks for publishing, not work for this Task. Each needs an owner before the first store upload:

- **Android App Bundle export from Godot.** Godot 4.6's Android export needs the Android SDK, a JDK, export templates and a release keystore set up on the build machine, with Play App Signing enrolled. Prove the export and an install on the target device early, in the first playable milestone, not at release.
- **Target API level policy.** Google Play requires new apps and updates to target a recent Android API level and raises the requirement each year. The Godot export's target SDK must match the policy in force at submission, and this must be re-checked before every upload.
- **Developer account and testing requirements.** A Google Play developer account, and for new personal accounts a closed test with a minimum number of testers for a set period before production access.
- **Content rating questionnaire.** Answered honestly for a dark-fantasy game with no gore; the answers determine age ratings per region.
- **Data safety form.** Must declare what the app collects and shares, including anything an ads or analytics SDK collects. A game with no accounts and local saves only has the easiest answers; monetization changes them.
- **Privacy policy URL.** Required on the store listing and inside the app, hosted at a stable address.

## Originality

The closest existing games and how Deckbound differs:

- **Slay the Spire and Slay the Spire 2** (branching-map roguelike deckbuilders with energy, draw, telegraphed enemy intents and relics). Deckbound shares those genre conventions, which are in general use. It differs in its spine: there is no relic system, passives come only from binding cards out of the deck, and those passives can be attacked. Deck thinning is a core verb, not a shop purchase. All names, characters, card text, symbols, enemies and UI are original; nothing may be taken from either game.
- **Monster Train** (deckbuilder with units placed on floors). Deckbound has no board and no units; the hero is the only permanent piece.
- **Inscryption** (sacrifice-based card costs, meta-narrative). Deckbound's binding is a commitment of the card to the hero, not a sacrifice to pay for another card, and the story stays inside the fiction.
- **Griftlands** (negotiation deck, grafts as passives). Deckbound has one deck and one combat mode; passives are earned from the deck itself rather than from a separate item pool.

Rule for all content: genre conventions and mechanics in general use are fine. Specific names, characters, card text, art, levels, UI layouts and the distinctive look of another game are not. The `director` review of every content PR checks this.

## Acceptance criteria for the first playable

QA verifies each of these on an Android phone of the target device class, installed from the Android App Bundle (via an internal testing track or bundletool), using touch only:

1. Every page in the build shows a Play effect and a Bind effect and both can be used in combat by touch.
2. Binding a page removes it from the deck, discard and hand for the rest of the run and occupies a visible bind slot.
3. A frayed binding stops applying its effect until end of combat; a severed binding is removed from the run.
4. Fray and sever actions are telegraphed before the player's turn, like any other enemy action.
5. Unbind at a rest returns the page to the deck and frees the slot.
6. A run contains at least one of each listed enemy type and ends in the boss fight; winning and losing both return to a run summary.
7. No name, card text, character, symbol or UI element in the build matches one from Slay the Spire, Slay the Spire 2 or another existing game (reviewer checklist).
8. Killing the app (swipe away from recents) at any map node, and mid-combat after any turn, then reopening it, resumes at the same node or turn with the same hand, deck, discard, bindings, health and enemy telegraphs.
9. A tap on a card in hand lifts it with both faces fully legible; a long-press on a card, binding or telegraph opens the inspect overlay and commits nothing; a first tap never plays or binds.
10. Play and Bind are reached by drags in opposite directions, and binding requires the confirming tap on the slot; releasing a card anywhere else cancels.
11. Every tappable element measures at least 48 x 48 dp and lies inside the safe area on the test device, including one with a camera cutout and gesture navigation.
12. Combat and map hold 60 frames per second on the target device, never below 30 during animations, and the installed download is under 100 MB.
