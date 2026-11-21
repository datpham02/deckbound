# Deckbound — M1 Enemies, Warden and Boss

Status: **proposed** (SOU-42, M1 plan §3 row T5, part a). Reviewer `director` (design intent and originality E7), then Board approval. Part b (SOU-4x, after T3 merges) writes the data files under `data/enemies/` and `data/encounters/` from the tables in this note; until then every number here is the proposed start value.

Sources: [M1-first-playable.md](../milestones/M1-first-playable.md) (§1 E4, E6, E7; §3 T5, T8, T10, T13, T14), [concept.md](../concept.md) ("Combat turn", "Binding", "First playable scope", "Originality"), [vision.md](../vision.md) (pillars 2, 3, 5), [ART-BIBLE.md](../art/ART-BIBLE.md) §4.4 and §5.

What this note fixes: the five enemies and their final names (T14 draws from them), the action vocabulary and how each action is telegraphed, each enemy's pattern and numbers, the fight compositions per map node, and the rules needed to run them (targeting, guard against fray and sever, fallbacks, boss phase, resume state). What it does not fix: page design (T4), map generation (T10), the Scrivener's own numbers (T3 `rules.json`, T4), and final tuning (T19).

## 1. Design goals

1. **Every enemy action is readable before it lands** (pillar 3). An enemy has one short, fixed, cycling pattern. After one fight with an enemy the player can say its rhythm out loud ("strike, strike, brace"). Every action is one of five kinds, each with its own icon and a number.
2. **Each common enemy attacks a different thing the player owns** (pillar 2). The Bailiff attacks health, the Bookmoth attacks bindings, the Blotter attacks the deck. The warden combines health and bindings; the boss is the only thing in M1 that can sever.
3. **A threatened binding is a decision, not a sentence.** A fray or sever shows a number; enough guard stops it. The player can pay Ink to defend the binding, kill the enemy first, or accept the loss. There is no fourth, hidden option.
4. **Fights are short.** Two to four minutes each: three to five turns for a common fight, five to six for the warden, seven to nine for the boss.
5. **Original in name and shape** (pillar 5). Everything is a clerk, a pest or an officer of the drowned Chancery. Nothing is borrowed.

## 2. Baseline assumptions used for sizing

Enemy numbers only mean something against the Scrivener's numbers. These are the proposed start values this note is balanced against; `rules.json` (T3) and the page set (T4, same author as this note) use the same ones, and T19 retunes all of them in `data/` after logged runs.

| Scrivener value | Start value | Lives in |
|---|---|---|
| Health | 80 | `data/run/rules.json` |
| Ink per turn | 3 | `data/run/rules.json` |
| Hand size | 5 | `data/run/rules.json` |
| Bind slots | 3 | `data/run/rules.json` |
| Deck floor | 5 (M1 plan E15) | `data/run/rules.json` |
| Starter strike | 6 damage for 1 Ink | `data/pages/` (T4) |
| Starter guard | 5 guard for 1 Ink | `data/pages/` (T4) |
| Expected player output | about 12 damage and 5 guard per turn with the starting deck | derived |
| Healing | **none in M1.** Rests only unbind (M1 plan §2). Health is a run-long resource. | scope |

Guard assumption (T6): the Scrivener's guard absorbs attack damage and is cleared at the start of the Scrivener's next turn. An enemy's guard absorbs the Scrivener's damage and is cleared when that enemy next acts.

Because there is no healing, the floor's **damage budget** matters more than any single fight. Target for a median run with the starting deck: about 105 unmitigated damage across the whole floor, of which guard stops roughly 40 %, leaving the Scrivener at 15 to 25 health entering the boss's second phase. If logged runs in T19 show the floor is too lethal, the levers are, in order: enemy attack values (`data/enemies/`), Scrivener health (`rules.json`), and only then a healing rest, which is a scope change for `director`.

## 3. Action vocabulary and telegraphs

Every enemy action is one of five kinds. The five placeholder telegraph icons in T14 are exactly these. Each telegraph is the icon plus a number at 20 sp or larger (Art Bible §4.4), directly above the enemy's head (concept "Combat screen layout"). Long-press on the telegraph opens the inspect overlay with the text in the last column.

| Action | Icon | Number means | Line to a slot | Inspect text |
|---|---|---|---|---|
| **Attack** | attack | Damage to the Scrivener. "6 ×2" means two hits of 6. | no | "Deals N damage to you. Guard absorbs it first." |
| **Guard** | guard | Guard the enemy gains when it acts. | no | "Gains N guard. Your damage must get through it before it acts again." |
| **Fray** | fray | Strength of the fray. | yes, to the threatened slot | "Frays the marked binding unless you have N guard when it lands. Spends N of your guard. A frayed binding stops working until the end of this fight." |
| **Foul** | foul | Number of Blot pages added to the discard. | no | "Puts N Blot pages into your discard pile." |
| **Sever** | sever | Strength of the sever. | yes, to the threatened slot | "Severs the marked binding unless you have N guard when it lands. Spends N of your guard. A severed page is gone from this run." |

### 3.1 Telegraph timing

- Enemies telegraph **at the start of combat**, before the Scrivener's first turn, and again **immediately after the enemy phase ends**. The player never takes a turn without seeing every living enemy's next action (E4, pillar 3).
- A telegraph never changes during the player's turn, whatever the player does (binds, kills another enemy, gains guard). What the player sees is what will happen.
- When an enemy dies its telegraph and any line disappear at once.
- Enemies act **left to right** in the order they stand on screen, which is the order they are listed in the composition. Guard checks use the Scrivener's guard remaining at the moment each action resolves.

### 3.2 Guard against fray and sever (rule decided in this note)

Fray N and Sever N are resolved like this, in order:

1. If the marked binding is no longer a valid target (see 3.3), the action does nothing further; skip to step 3.
2. If the Scrivener's current guard is **less than N**, the binding is frayed (or severed).
3. The Scrivener's guard is reduced by N, to a minimum of 0.

Fray and sever never deal health damage, even when guard is 0. Guard is the one defence the Scrivener has against all five actions, so the number above an enemy's head always means the same thing: "this much guard stops it". Concept: "the player can defend a binding or accept the loss."

### 3.3 Targeting

- The target slot is chosen when the telegraph is set, using the run seed, and is saved with the telegraph (E8).
- **Fray** targets a slot holding an **intact** binding, chosen uniformly at random among them. A fray that lands on a binding that was frayed earlier in the same enemy phase does nothing further.
- **Sever** targets any slot holding a binding, intact or frayed, chosen uniformly at random. Severing a frayed binding removes it like any other.
- When two enemies telegraph fray in the same phase they pick different slots where possible.
- A bound Blot (see §5.3) is a binding and can be targeted. Binding junk to draw fire costs a slot; that is the trade.

### 3.4 Fallbacks

Fray and sever need a target. If, at telegraph time, there is no eligible binding, the enemy telegraphs the action's **fallback** instead, which is always an attack. The fallback is a real telegraph (icon and number), not a blank. Fallbacks are tuned so that a player with no bindings is not rewarded for it: the fallback attack costs about as much guard to stop as the fray would have.

Patterns do **not** skip the step; the fallback consumes the pattern step and the enemy moves on. A player who binds during the turn after seeing a fallback keeps the fallback (3.1); the next fray comes round on schedule.

### 3.5 Pattern rules

- A pattern is an ordered list of actions. The enemy performs step 1, telegraphs step 2, performs it, and so on, wrapping to step 1. The current step index is saved (E8).
- An encounter may give an enemy a **start offset** so two of the same enemy do not act in lockstep.
- An enemy's health is shown under its figure (concept layout); guard is shown beside the health as a number with the guard icon, and disappears when it is cleared.

## 4. The enemies

Five enemies: three commons, one warden, one boss. Names are final for placeholder art (T14) and may only change through a director-approved revision of this note. Silhouette briefs follow the Art Bible: identifiable as a solid black shape at the size class given, facing left, no text in the image. Size classes are fractions of screen height, proposed, confirmed by the Phase 1 readability test.

### 4.1 Bailiff (common, attacker)

*The Chancery's debt-collectors did not stop when the water came. A Bailiff still comes for what is owed and still does not care whether you can pay.*

| | |
|---|---|
| id | `bailiff` |
| Role | Plain attacker. Teaches the attack and guard telegraphs and the guard trade. |
| Health | 26 |
| Size class | common, 25 % screen height |
| Silhouette | Broad, stooped, hooded; a long tally-rod with a hook held across the body; coat hem heavy with water. The widest of the commons. |
| Pattern | 1. **Attack 5** (rap) · 2. **Attack 5** (rap) · 3. **Guard 7** (brace) |
| Fallbacks | none needed |

Sizing: alone it dies on turn 3 against baseline output and lands one or two raps (5 to 10 unmitigated). In a pair with offsets 0 and 1, the pair lasts about five turns and deals about 35 unmitigated.

### 4.2 Bookmoth (common, frayer)

*Something still eats the stitching in the drowned stacks. Bookmoths find the newest thread first: a binding worn on a living Scrivener.*

| | |
|---|---|
| id | `bookmoth` |
| Role | Frayer. Fragile; the fight is a race between its fray and the player's damage. |
| Health | 12 |
| Size class | common, 25 % screen height (wingspan; the body is small) |
| Silhouette | A ragged moth the size of a dog, wings like torn page-corners, a long proboscis that trails a loose thread. Unmistakably a flier; the only winged silhouette in M1. |
| Pattern | 1. **Fray 4** (unpick) · 2. **Attack 3** (nibble) · 3. **Attack 3** (nibble) |
| Fallbacks | step 1 with no intact binding: **Attack 5** (bite) |

Sizing: one starter strike and one Ink of guard beats a single moth's fray on turn 1. A pair (offsets 0 and 1) means one fray per turn for the first two turns unless the player kills one; the pair dies by turn 3.

### 4.3 Blotter (common, fouler)

*A clerk who drowned at the desk and kept filing. Everything it touches comes back blotted, and it files the blots into your book.*

| | |
|---|---|
| id | `blotter` |
| Role | Deck-fouler. Puts Blot pages into the discard; the pressure is on the deck, not on health. |
| Health | 22 |
| Size class | common, 25 % screen height |
| Silhouette | Squat and slumped, like a seated figure under a sheet of wet paper, one arm ending in a flat stamp-shaped fist, ink dripping from the hem into a pool. The lowest and roundest of the commons. |
| Pattern | 1. **Foul 1** (file) · 2. **Attack 4** (smear) · 3. **Attack 4** (smear) · 4. **Guard 6** (brace) |
| Fallbacks | none needed |

Sizing: alone it files one Blot before it dies on turn 2 or 3. Two Blotter fights on a floor add two to four Blots; see §5.3 for what a Blot is and why it is not harmless.

### 4.4 Registrar (warden)

*The Registrar kept the register of what was bound to whom. It still presses its great seal onto anything that claims to be bound, and the seal presses flat.*

| | |
|---|---|
| id | `registrar` |
| Role | Warden. A stronger attacker that frays (M1 plan §2). Fought alone at the warden node. |
| Health | 58 |
| Size class | warden, 35 % screen height |
| Silhouette | Tall and straight, long robe, a great seal-press held in both hands above the head, so the top of the silhouette is a wide flat block. Taller and narrower than any common. |
| Pattern | 1. **Attack 8** (strike) · 2. **Fray 6** (press) · 3. **Attack 8** (strike) · 4. **Guard 10** (brace) · 5. **Attack 6 ×2** (seal-press) |
| Fallbacks | step 2 with no intact binding: **Attack 7** (strike) |

Sizing: about five turns against baseline output; 28 to 35 unmitigated attack damage plus one fray, two if the fight runs long. The two-hit seal-press is the one multi-hit in M1 and gives "when struck" bind passives (T4) something to answer.

### 4.5 The Redactor (boss)

*What the Chancery could not collect, it struck out. The Redactor is the pen that did the striking, and it has not been told the kingdom is gone.*

| | |
|---|---|
| id | `redactor` |
| Role | Boss. The only enemy in M1 that severs. Fought alone at the boss node. Two phases. |
| Health | 96 |
| Size class | boss, 45 % screen height |
| Silhouette | The largest figure: hooded, with a horizontal black bar where a face would be, carrying a wide flat blade like a strike-through line, held low; ink pooling under it. Reads as "a line through a page" at a glance. |
| Phase 1 pattern (health above 48) | 1. **Attack 8** (strike) · 2. **Sever 8** (strike out) · 3. **Guard 12** (brace) · 4. **Attack 9** (strike) |
| Phase 2 pattern (health 48 or below) | 1. **Sever 10** (strike out) · 2. **Attack 12** (strike) · 3. **Guard 10** (brace) · 4. **Attack 10** (strike) |
| Fallbacks | phase 1 step 2 with no binding: **Attack 10**; phase 2 step 1 with no binding: **Attack 12** |

**Phase change.** When the Redactor's health is at or below half at the moment it next telegraphs, it switches to the phase 2 pattern from its step 1 and never switches back. The change is on screen in two ways, both required (pillar 3, vision AC4): the boss's health bar carries a visible notch at the half point, and the next telegraph is simply the phase 2 action. No extra art state is needed; the Redactor's placeholder is one figure.

Sizing: seven to nine turns. About 40 unmitigated attack damage, plus two sever telegraphs for a player with three bindings, one in each phase. Stopping a sever costs 8 or 10 guard, about two Ink of starter guard, which is most of a turn: that is the boss's question. Guard 12 on phase 1 step 3 is the turn to defend or to bind rather than to attack.

## 5. Encounters and nodes

### 5.1 Node types and what fights there

| Node | Enemies | Composition source |
|---|---|---|
| fight | 1 to 3 commons | a pool chosen by the fight's position on the path (5.2) |
| warden | Registrar alone | `warden` |
| boss | The Redactor alone | `boss` |
| rest, reward, map | none | — |

Enemies stand left to right in the order the composition lists them; that is also their action order (3.1).

### 5.2 Pools and the coverage rule

E6 requires that every run meets all three commons, the warden and the boss. The map (T10) is a branching floor, so this note does not pick fights per node; it gives **pools** and a rule the generator must satisfy:

- **Rule 1 (first three fights).** The first, second and third fight nodes on every path from the start draw from the pools `intro_1`, `intro_2` and `intro_3` in that order. The simplest way for T10 to satisfy this is to make rows 1 to 3 of the floor fight-only rows (no rests before row 4). Any other layout is fine if the rule still holds on every path; that is a T10 acceptance test.
- **Rule 2 (warden and boss).** Every path crosses exactly one warden node and ends at the boss node.
- **Rule 3 (later fights).** Every fight node after the third draws from `mixed`.
- **Rule 4 (no repeats).** Two adjacent fight nodes on a path must not use the same composition id if the pool offers another.

| Pool | Composition id | Enemies (left to right) | Start offsets | Weight |
|---|---|---|---|---|
| `intro_1` | `bailiff_solo` | Bailiff | 0 | 1 |
| `intro_2` | `bookmoth_pair` | Bookmoth, Bookmoth | 0, 1 | 1 |
| `intro_3` | `blotter_solo` | Blotter | 0 | 1 |
| `mixed` | `bailiff_pair` | Bailiff, Bailiff | 0, 1 | 2 |
| `mixed` | `bailiff_bookmoth` | Bookmoth, Bailiff | 0, 0 | 2 |
| `mixed` | `bailiff_blotter` | Blotter, Bailiff | 0, 1 | 2 |
| `mixed` | `bookmoth_blotter` | Bookmoth, Blotter | 1, 0 | 2 |
| `mixed` | `bookmoth_pair_bailiff` | Bookmoth, Bookmoth, Bailiff | 0, 1, 2 | 1 |
| `mixed` | `clerks_three` | Bookmoth, Blotter, Bailiff | 0, 0, 1 | 1 |
| `warden` | `registrar` | Registrar | 0 | 1 |
| `boss` | `redactor` | The Redactor | 0 | 1 |

Pool draws are weighted and use the run seed, so a resumed run shows the same map. Enemy order within a composition puts the fragile frayer leftmost so it acts first and the player's "kill the moth or guard the binding" decision is about this turn, not next turn.

### 5.3 The Blot page

Foul puts **Blot** pages into the discard. The Blot is a page and lives in `data/pages/` (T4) so that E1 holds for every page in the build; this note fixes only what T5 needs from it:

- id `blot`, name "Blot", Ink cost 0, compact lines "Nothing happens" (Play) and "Takes a slot, does nothing" (Bind).
- Play: no effect; the Blot goes to the discard. Bind: no passive; it occupies a slot and is a valid fray and sever target like any binding.
- **Blots persist for the run** (`blot_persists_after_combat: true` in `rules.json`, tunable by T19). The deck does not heal any more than the Scrivener does. The ways out are the ones the game already has: bind it (costs a slot, removes it from the deck, draws fire from real bindings), or let the Redactor sever it. Blots count as pages for the deck floor (E15), which is consistent with the floor's purpose: a Blot in the deck prevents a thin-deck loop exactly as any other dead page does.

If T19 finds Blots too punishing, the first lever is the flag above, the second is the Blotter's pattern (fewer foul steps), both in `data/`.

### 5.4 Damage budget per node (for T19)

Unmitigated damage a median run takes, assuming baseline output and that the player kills enemies in the order they stand. Fray and sever counts assume three intact bindings.

| Node | Composition | Turns | Attack damage | Fray / sever telegraphs | Blots |
|---|---|---|---|---|---|
| fight 1 | `bailiff_solo` | 3 | 5–10 | 0 | 0 |
| fight 2 | `bookmoth_pair` | 3 | 6–9 | 2 fray | 0 |
| fight 3 | `blotter_solo` | 3 | 4–8 | 0 | 1 |
| fight 4 | `mixed` (typical) | 4–5 | 14–20 | 0–2 fray | 0–1 |
| fight 5 | `mixed` (typical) | 4–5 | 14–20 | 0–2 fray | 0–1 |
| warden | `registrar` | 5 | 28–35 | 1–2 fray | 0 |
| boss | `redactor` | 7–9 | 38–45 | 2 sever | 0 |
| **floor** | | | **about 110–145** | | **1–3** |

The lower end of the floor total is the budget in §2; the upper end is a run that takes every fight node and plays slowly. T19 logs ten runs and compares.

## 6. State that must survive a kill and resume (E8)

Per living enemy, T8 exposes and T17 saves: enemy id, position (0 to 2), health, guard, phase (boss), pattern step index, the current telegraph (action kind, number, hits, target slot or none, whether it is a fallback). Per fight: composition id and the seed state used for targeting. Reopening the app shows the same telegraphs with the same lines to the same slots.

## 7. Placeholder art requirements (T14)

T14 needs only this section. Five figures, facing left, flat-shaded, one idle pose each, no text, sized per the Art Bible budgets, under `assets/placeholder/`:

| Asset | Name on screen | Size class | Silhouette brief |
|---|---|---|---|
| `bailiff` | Bailiff | common 25 % | broad, stooped, hooded, long hooked tally-rod across the body |
| `bookmoth` | Bookmoth | common 25 % | ragged moth, torn-page wings, trailing thread; the only flier |
| `blotter` | Blotter | common 25 % | squat slumped figure under wet paper, stamp-fist, ink pool |
| `registrar` | Registrar | warden 35 % | tall, straight robe, seal-press held high (flat top) |
| `redactor` | The Redactor | boss 45 % | largest, hooded, black bar for a face, wide strike-through blade held low |

Plus the five telegraph icons (attack, guard, fray, foul, sever), each distinct as a silhouette and legible at telegraph size beside a 20 sp number. The three commons must be told apart as black shapes: one wide, one winged, one low.

## 8. Originality check (E7)

Checked against the concept's named references (Slay the Spire and Slay the Spire 2, Monster Train, Inscryption, Griftlands) and the general genre. Mechanics in general use (telegraphed intents, enemy guard, junk cards added to the deck, a two-phase boss) are allowed by the concept's rule; names, characters and shapes are ours.

| Name | What it is | Nearest thing elsewhere | Verdict |
|---|---|---|---|
| Bailiff | drowned debt-collector | generic word; no enemy of that name or shape in the references | original |
| Bookmoth | paper-winged pest that frays bindings | none; "Book of Stabbing" (Slay the Spire) is a book, not a moth, and attacks health | original |
| Blotter | drowned filing clerk that adds Blots | none; status-card enemies exist in the genre, the clerk is ours | original |
| Registrar | warden with a seal-press | none | original |
| The Redactor | boss that strikes out bindings | none; the "strike-through" figure is ours | original |
| Blot | worthless page | junk cards are a genre convention; name and faces are ours | original |
| fray / foul / sever | action names | our own verbs from the concept | original |

No enemy reuses another game's name, pattern signature, pose or icon. `director` re-checks on review and again on T14's art.

## 9. Acceptance criteria

QA derives test cases from these. 1 to 13 are headless (T8 tests) unless marked device; 14 to 16 are device checks on the debug APK.

1. Five enemies load from `data/enemies/` with ids `bailiff`, `bookmoth`, `blotter`, `registrar`, `redactor` and the health, size class and patterns in §4.
2. The eleven compositions in §5.2 load from `data/encounters/` with the listed enemies, order, offsets, pool and weight.
3. At combat start and after every enemy phase, every living enemy has a telegraph; no enemy ever acts on an action that was not telegraphed before the player's turn (E4).
4. A telegraph does not change during the player's turn, including when the player binds, gains guard or kills another enemy.
5. Attack N reduces guard first and health by the remainder; "N ×2" applies twice.
6. Guard N gives the enemy N guard; the player's damage that turn is absorbed by it first; it is cleared when the enemy next acts.
7. Fray N with player guard below N frays the marked binding and sets guard to 0; with guard at or above N the binding stays intact and guard drops by N; health never changes.
8. Sever N behaves as 7 but removes the page from the run (slot empties, page in no pile) and can target a frayed binding.
9. Fray targets only intact bindings; sever targets any binding; two frays telegraphed in one phase target different slots when two or more are eligible.
10. With no eligible binding at telegraph time, Bookmoth telegraphs Attack 5, Registrar Attack 7, the Redactor Attack 10 (phase 1) or Attack 12 (phase 2); the pattern step still advances.
11. Foul N puts N `blot` pages into the discard; Blots remain in the deck after combat while `blot_persists_after_combat` is true and are removed at end of combat when it is false.
12. The Redactor switches to the phase 2 pattern at step 1 on the first telegraph set while its health is 48 or below, and never switches back.
13. Killing the app and reopening mid-combat restores every enemy's health, guard, phase, step index and telegraph, including the target slot of a fray or sever (E8).
14. Device: every telegraph shows the icon and a number of at least 20 sp above the enemy's head; fray and sever draw a line to the threatened slot; long-press on a telegraph shows the inspect text from §3 (E4, E9).
15. Device: a run from New run to the boss meets a Bailiff, a Bookmoth and a Blotter in its first three fights, exactly one Registrar at the warden node, and the Redactor last (E6).
16. Device: the five placeholder figures are told apart as silhouettes at arm's length and match the names in §7; no name, shape or icon matches a reference game (E7).

## 10. Open questions

None blocking. Two values are flagged for the director on review rather than asked: the fray-versus-guard rule (3.2) is a new rule rather than one in the concept, and Blot persistence (5.3) is set to true on purpose. Both are reversible in `data/` without a code change.
