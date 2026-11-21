# Deckbound — Milestone 1 QA test plan

Status: **draft for review** (SOU-59, M1 task T21a). Source of truth: [M1-first-playable.md](../milestones/M1-first-playable.md) §1 (exit criteria E1–E15) and §3 row T21; rules behind each row are in [concept.md](../concept.md). Reviewer `game-designer`, then Board approval.

## 0. How to use this plan (read first)

**Who runs it.** The Board Operator runs the device pass on their own Android phone. No tester skills are needed: each case below is a list of numbered steps. Do them in order, compare what you see with **Expected**, and write **Pass**, **Fail** or **Not tested** for the row.

**What counts.** M1 exits only when every row E1–E15 is **Pass**. **Not tested** counts as a fail for exit. If a case cannot be done (for example the game never offers the situation), write **Not tested** and say why. Do not guess a pass.

**Where to record.** Post one comment per session on the T21 Task (the device-pass Task). Copy the result table in §16 into the comment and fill in the *Result* and *Note* columns. For every Fail: the case id, the step number that went wrong, what you saw, and, if you can, a screenshot or screen recording. QA turns each Fail into a defect Task and, once all results are in, writes `docs/qa/M1-report.md`.

**What you need.**

| Item | Detail |
|---|---|
| Phone | The Board's Android phone, Android 10 or newer. Target class is 3–4 GB RAM, Mali-G52 / Adreno 610 class; note your model and Android version in the first comment. |
| Build | The **debug APK built from `main`**. Note the commit id or the APK file name and its size in MB. |
| Settings | Auto-rotate **on**. Gesture navigation on, if your phone offers it. Do not use a PC or a cable for any case except where marked **(QA or studio machine)**. |
| Cutout | If your phone has a camera cutout or notch, use it. If not, turn on Android Settings → Developer options → **Simulate a display with a cutout** (choose a notch or corner cutout) before the rows marked **[cutout]**. Say in your comment which one you used. Turn it off again afterwards if you like. |
| Fresh start | Before case S0 below, uninstall any older Deckbound so the save is empty. |

**Terms.** *Page* = a card. *Play face* = left page of the spread. *Bind face* = right page. *Spread* = the open two-page view after tapping a card. *Slot* = a bind slot on the left edge. *Node* = one stop on the map. *Kill the app* = open the Android recents screen and swipe Deckbound away (do not use Back or Home; that only backgrounds it). *Resume* = tap the app icon again, then **Continue** on the title screen if it shows one.

**Rotations.** The game is landscape only. "Both rotations" means landscape with the phone's top edge to the **left** and landscape with the top edge to the **right**. Rotate by turning the phone; the game should flip without leaving landscape and never show portrait.

**If the build behaves unexpectedly.** Crash, freeze, blank screen, wrong text: stop that case, mark it Fail, note the step, restart, and carry on with the next case.

### Setup cases

| Id | Steps | Expected | Record |
|---|---|---|---|
| S0 | 1. Install the APK. 2. Open Deckbound. | The game starts to a title screen with **Continue** (greyed out or absent on a fresh install) and **New run**. No crash. | Note only (blocks everything if it fails) |
| S1 | Tap **New run**. | The map for one floor shows, with branching nodes and a boss at the end. | Note only |

---

## 1. E1 — Every page has a Play face and a Bind face, both usable

Run across several runs. Keep a tally of the distinct page names you meet (about 20 pages exist). The goal is to see **every page** at least once; ask QA for the page list (`docs/design/pages.md`) to tick off.

| Case | Steps | Expected | Record |
|---|---|---|---|
| E1.1 | 1. Start a fight. 2. Tap any card in your hand. | The spread opens: Play on the left page, Bind on the right page, each with rules text, and the Ink cost in the middle. | E1 row |
| E1.2 | For each page you meet: open its spread (E1.1) and read both pages. | Both faces carry rules text. None is blank, "TODO" or cut off. | E1 row; note page names with a problem |
| E1.3 | Use the **Play** face of a page (drag right onto an enemy or the play area; see E10). Repeat on a different page each fight. | The page's Play effect happens and the page goes to the discard. | E1 row; note any page whose Play does nothing visible |
| E1.4 | Use the **Bind** face of a page (drag left to a slot, tap the slot to confirm; see E10). Repeat on different pages across runs. | The page's Bind effect applies and the slot shows it. | E1 row; note any page whose Bind does nothing |
| E1.5 | At the end of the testing, count pages seen against the page list. | Every page was seen and had **both faces used at least once**. List any not yet used. | E1 row: Pass only if all pages covered |

## 2. E2 — Binding removes the page from hand, deck and discard

| Case | Steps | Expected | Record |
|---|---|---|---|
| E2.1 | 1. Start a fight. Note the **deck count** and **discard count**. 2. Open a card's spread and bind it (drag left, tap slot to confirm). | The card leaves your hand. A slot on the left now shows the page's icon. Ink goes down by the page's cost. | E2 row |
| E2.2 | Right after E2.1, read the deck and discard counts. | The page is in neither: total of hand + deck + discard is one lower than before the bind, and the **deck count did not go up** and the **discard count did not go up**. | E2 row |
| E2.3 | End the turn, then keep playing at least three more turns, until the deck has been reshuffled at least once (the discard returns to the deck). Watch the hand each turn. | The bound page never appears in hand again, including after a reshuffle. | E2 row |
| E2.4 | Finish the fight and go through the reward and map to the next fight. | The slot is still filled in the next fight, and the page is still not in the hand. | E2 row |

## 3. E3 — Fray and sever

| Case | Steps | Expected | Record |
|---|---|---|---|
| E3.1 *Fray* | 1. Bind a page whose effect you can see (for example guard or thorns). 2. Fight the **frayer** enemy (the common one with a fray telegraph). 3. Let it act on that slot. | The slot shows the **frayed** state (different look from intact). The page's effect **stops** applying: confirm by checking the effect is gone (for example no thorns, no starting guard, smaller hand). | E3 row |
| E3.2 *Fray ends* | Keep playing the same fight to its end, then start the next fight. | The slot is **intact** again at the start of the next fight and the effect works again. A frayed page is not lost. | E3 row |
| E3.3 *Fray: deck* | After a fray, check deck and discard counts. | They did not change because of the fray. The page does not come back into the deck. | E3 row |
| E3.4 *Sever* | 1. Bind a page. 2. Reach the **boss** (or a node whose enemy has a sever telegraph). 3. Let the sever hit that slot. | The slot **empties**. The page is gone from the run: look at the deck and discard counts (not changed) and play on; the page never appears. | E3 row |
| E3.5 *Sever stays* | After a sever, finish the fight and check at the rest. | At the next rest, the severed page cannot be unbound; it is not in the deck. The slot stays empty. | E3 row |
| E3.6 *Defend* | When a fray or sever is telegraphed, kill that enemy before it acts (guard does not protect a slot). | The slot is not frayed or severed. Note what you did. | E3 row, note |

If the game never gives you a fray or a sever situation in several runs, mark **Not tested** and say which enemy you were waiting for.

## 4. E4 — Telegraphs

| Case | Steps | Expected | Record |
|---|---|---|---|
| E4.1 | Start any fight. Look at each enemy **before you touch anything**. | Above each enemy's head: an action icon and a number. Its health sits below it. | E4 row |
| E4.2 | Find an enemy with a **fray** telegraph (the frayer). Have at least one slot filled. | A **line** is drawn from the enemy's telegraph to the **threatened slot** on the left. | E4 row |
| E4.3 | Find a **sever** telegraph (boss). Have at least one slot filled. | Same line to the threatened slot, and it is visibly different from the fray one (or the icon tells them apart). | E4 row |
| E4.4 | Check that you could read the telegraph **before** your turn begins (right after the new turn starts, before the first tap), at arm's length. | The telegraph is already shown when the turn starts and after the enemy acted. It is never shown only after you act. | E4 row |
| E4.5 | Press and hold (long-press) on a telegraph. | An overlay explains the action in text. Release closes it and nothing else happens. | E4 row (also E9) |

## 5. E5 — Unbind at a rest

| Case | Steps | Expected | Record |
|---|---|---|---|
| E5.1 | 1. Bind a page in a fight. 2. Go on the map to a **rest** node. | The rest screen offers to unbind a page, or skip. | E5 row |
| E5.2 | Unbind the page. | The slot is **empty** and can be filled again. | E5 row |
| E5.3 | Leave the rest, enter the next fight, look at the deck count and the hand over a few turns. | The page is **back in the deck** as an ordinary page: the deck count went up by one after the unbind, and it can be drawn and played or bound again. | E5 row |
| E5.4 | At another rest, choose **skip**. | Nothing changes: slots and deck remain as before. | E5 row |
| E5.5 | At a rest with no bound pages. | No page can be unbound; the screen does not freeze and you can leave. | E5 row |

## 6. E6 — Full run: all enemy types, warden, boss, summary

| Case | Steps | Expected | Record |
|---|---|---|---|
| E6.1 | Play one run from New run to the end by choosing a path. Tick each as you meet it: attacker, frayer, deck-fouler, warden. | All three common enemy types and the warden show up in the one run. If a run misses one, mark **Fail** and note the path you took. | E6 row |
| E6.2 | Reach the last node. | The last fight is the **boss** and nothing comes after it. | E6 row |
| E6.3 *Win* | Beat the boss. | A **run summary** appears for the win (shows it was a win and some run facts). A way back to the title is offered. | E6 row |
| E6.4 *Loss* | Start a new run and lose all health on purpose (end turns without playing). | A **run summary** appears for the loss. A way back to the title is offered. | E6 row |
| E6.5 *Abandon* | In a run, on the map, choose to abandon the run (the menu or button on the map). | The run ends cleanly and returns to the title. **Continue** no longer offers the abandoned run. | E6 row, note |
| E6.6 | After a summary, tap **New run**. | A fresh run starts: full health, starting deck, empty slots. | E6 row |

## 7. E7 — Originality checklist

This check is by reading. Use the concept's "Originality" section: genre conventions are fine; specific names, characters, card text, art, levels, UI layouts and the look of another game are not. The reference games are Slay the Spire (1 and 2), Monster Train, Inscryption and Griftlands.

| Case | Steps | Expected | Record |
|---|---|---|---|
| E7.1 | While playing, write down every **page name**, **enemy name**, **boss and warden name**, and the hero name you see. | None is the name of a card, character, enemy or place from the reference games, or an obvious near-copy (a one-word change). | E7 row, with the list pasted in |
| E7.2 | Read the Play and Bind text of every page you opened. | The wording is original; no text lifted from the reference games. | E7 row |
| E7.3 | Look at the combat screen, the map, the reward screen, the rest and the summary. | The look is not a copy of a reference game's screen (icon shapes, colours, frames, layout of the map). It uses the Chancery theme: pages, ink, binding. | E7 row |
| E7.4 | Check there is **no relic or trinket system** and no energy orbs named as in the references. | Passives come only from binding. The resource is called Ink. | E7 row |

If you are unsure on any item, say **Not sure** in the note and name the item; QA passes the question to `director`, who decides. Record **Pass** only when all four cases are clear.

## 8. E8 — Kill and resume at every node and combat phase

For every case: follow the steps, then compare with the state you wrote down before the kill.

**Before each kill, write down (or take a screenshot of):** the node, the hand (names in order), the deck count, discard count, the slots (which page, intact/frayed), health, guard, Ink, and the enemies' health and telegraphs.

**After each resume, check:** all of the above are **identical**. For combat, the same turn (still your turn, or the next turn after the enemy acted) and the **same hand** (not a fresh draw).

| Case | When you kill the app | Steps | Expected | Record |
|---|---|---|---|---|
| E8.1 *Map* | On the map, with at least one node done and one slot bound | 1. Note state. 2. Kill from recents. 3. Reopen, tap **Continue**. | Back on the **map** at the same position with the same completed nodes. Deck, bindings and health as before. | E8 row |
| E8.2 *Fight, player turn* | In a normal fight, **after the player turn began** and you have played one page, before ending the turn | Note state. Kill. Resume. | Same fight, same turn, same hand (minus the played page), same Ink, deck and discard counts, enemy health, telegraphs. | E8 row |
| E8.3 *Fight, after player turn* | In a normal fight, **right after you tap End turn and the screen is showing the enemy's result** (if it goes too fast, kill the app as soon as the enemy has acted) | Note state. Kill. Resume. | Resumes in the **same fight** at the point stored: either your next turn with the hand shown before the kill, or the state right after your turn ended. Counts, telegraphs, health and guard match. If the game resumes at the end of your turn, the enemies then act **once**; health, guard and slots afterwards match one enemy turn, never two, and never none. | E8 row, note which you got |
| E8.4 *Fight, after enemy turn* | In a normal fight, **after the enemy acted and your new turn has begun**, before you touch anything | Note state. Kill. Resume. | Same turn, **same hand** (not re-drawn), same new telegraphs. | E8 row |
| E8.5 *Warden* | Repeat E8.2 and E8.4 in the **warden** fight | As above | As above, including the warden's telegraph. | E8 row |
| E8.6 *Boss* | Repeat E8.2 and E8.4 in the **boss** fight | As above | As above, including a sever telegraph and its line to the slot. | E8 row |
| E8.7 *Rest* | On the rest screen, before choosing | Note state. Kill. Resume. | Back on the **rest** screen, same bound pages offered. If you had already unbound, the slot is still empty and the page still back in the deck. | E8 row |
| E8.8 *Reward* | On the reward screen, before choosing | Note state, including the three pages offered. Kill. Resume. | Back on the **reward** screen with the **same three pages**. Choosing one or none works and returns to the map. | E8 row |
| E8.9 *Frayed slot* | In combat with a **frayed** slot | Note state. Kill. Resume. | The slot is still frayed (effect still off) until the end of this combat. | E8 row |
| E8.10 *Both rotations* | Repeat E8.2 once with the phone rotated top-left, and once top-right; resume in the **other** rotation than you killed in | Note state. Kill. Rotate. Resume. | State is the same and the layout is correct in the new rotation. | E8 row |
| E8.11 *Summary* | On the run summary screen | Kill. Resume. | The title screen (or the summary again); **Continue** does not offer the finished run. No crash. | E8 row |
| E8.12 *Pause, not kill* | In combat, press Home, wait ten seconds, and return from recents. Then press Home, wait, **kill** from recents, and resume. | Back in the same state both times. | E8 row |
| E8.13 *Repeat* | Do E8.2 three times in a row in one fight (kill, resume, play a card, kill, resume, …) | Each resume matches. Nothing is duplicated or lost; deck+hand+discard+bound totals stay the same. | E8 row |

## 9. E9 — Compact face, tap opens spread, long-press inspects

| Case | Steps | Expected | Record |
|---|---|---|---|
| E9.1 | In a fight, look at the hand without touching. | Each card shows: **Ink cost**, **name**, **one Play line**, a divider, **one Bind line** with the bind icon. Lines are not cut off with "...". Text is readable at arm's length. | E9 row |
| E9.2 | **Tap** one card once. | The spread opens. **Nothing else happens**: Ink, hand, enemies and counts do not change. The rest of the screen is dimmed but enemies and slots are visible, and the enemies this page can target, or the slots it can go to, are highlighted. | E9 row |
| E9.3 | With the spread open, tap the dimmed area. Then open it again and tap the card. | Each closes the spread **without acting**. | E9 row |
| E9.4 | **Press and hold** a card in hand (about one second). | An inspect overlay with full text opens. Release closes it. **Nothing is played or bound.** Ink and counts unchanged. | E9 row |
| E9.5 | Long-press a **bind slot** that is filled, an **enemy telegraph** and a **status** (guard, frayed). | Each opens an inspect overlay with text that does not cover the thing you inspect. Release closes it; nothing else happens. | E9 row |
| E9.6 | Tap fast on three different cards, one after the other, without waiting. | Never does a first tap play or bind a card. | E9 row |
| E9.7 | With a full hand (5–7 cards) overlapping, tap the **edge** of each card. | Each card can be selected on its own; a tap on the strip opens that card, not its neighbour. | E9 row |

## 10. E10 — Play and Bind gestures

| Case | Steps | Expected | Record |
|---|---|---|---|
| E10.1 *Play on enemy* | Open a spread. Drag **right** and release on an enemy. | Enemies that can be targeted are highlighted while you drag. The page is played, Ink drops, the page goes to the discard. | E10 row |
| E10.2 *Play on area* | Open a page with no target (for example a guard page). Drag **right** and release in the **play area** between the Scrivener and the enemies. | The page is played. | E10 row |
| E10.3 *Bind* | Open a spread. Drag **left** and release on an empty slot. | The slot lights up with a **Bind** label. **The page is not bound yet.** | E10 row |
| E10.4 *Bind confirm* | After E10.3, tap the lit slot. | Now the page is bound: leaves the hand, fills the slot, Ink is spent. | E10 row |
| E10.5 *Bind not confirmed* | After E10.3, instead tap elsewhere (the dimmed area, an enemy, the hand). | The bind is **not** done. The page returns to the hand (or the spread closes) with no change. | E10 row |
| E10.6 *Cancel* | Drag a card and release it: in the middle of the hand, at the top of the screen, between enemies without a target, and over the end-turn button. Do each once. | Each release cancels: the card returns to the hand; no Ink spent; nothing played or bound. | E10 row |
| E10.7 *Wrong direction* | Drag **right** and release over a bind slot, if you can reach it. Drag **left** and release over an enemy. | Neither acts. Right never binds; left never plays. | E10 row |
| E10.8 *Not enough Ink* | With less Ink than the page costs, try to play it and try to bind it. | Both are refused with some visible cue; Ink and the hand do not change. The game does not freeze. | E10 row |
| E10.9 *Slots full* | Fill all slots (start value is 3). Try to bind a fourth page. | Refused; no page is lost. The game explains or shows it, and you can still play the page. | E10 row |

## 11. E11 — Combat layout and rotations

Do each check in **both** rotations (top-left, then top-right).

| Case | Steps | Expected | Record |
|---|---|---|---|
| E11.1 | Start a fight in rotation A. Compare to this layout. | **Left:** the Scrivener and the slot column beside it; health and guard under the figure. **Right, upper:** enemies (1–3) with telegraphs above their heads and health below. **Bottom:** the hand in one row. **Bottom-left:** Ink (number with its maximum) and the deck pile with count. **Bottom-right:** the discard pile with count, and the **End turn** button on the right edge above it. | E11 row |
| E11.2 | Rotate the phone to rotation B. | The game turns to the other landscape without a restart. The same layout holds, nothing is mirrored, and nothing disappears. | E11 row |
| E11.3 | Turn the phone upright (portrait) with auto-rotate on. | The game **stays in landscape** (it does not show portrait). | E11 row |
| E11.4 | Open the spread, the inspect overlay and the reward screen in both rotations. | Each is laid out correctly in landscape with no cut-off. | E11 row |
| E11.5 | In a fight with three enemies (if one exists), check the row of enemies. | All three fit with telegraphs and health visible, not overlapping the hand or the end-turn button. | E11 row |

## 12. E12 — Touch size, safe area, aspect ratios

### 12a. Device checks (Board, on the phone)

| Case | Steps | Expected | Record |
|---|---|---|---|
| E12.1 **[cutout]** | With the cutout (real or simulated) on, rotation A: open the title, the map, a fight, the spread, the reward, the rest and the summary. Look at the side with the cutout. | Nothing that you can tap or must read sits under the cutout. Left-edge items (slots) and right-edge items (End turn, discard) are **moved inward** on their side. | E12 row |
| E12.2 **[cutout]** | Rotate to rotation B and repeat E12.1. | Same result; the cutout is now on the other side. The inward shift follows the cutout, not the left side only. | E12 row |
| E12.3 | With **gesture navigation**, swipe up from the bottom edge to go home, while on a fight screen. Try it starting at the bottom edge and then at the hand. | The hand sits above the gesture area; a swipe-up for home never starts on a card; the End turn button is clear of the gesture bar. | E12 row |
| E12.4 | Status bar. | It is hidden (immersive); no bar is over the game. | E12 row |
| E12.5 *48 dp* | Try to tap the smallest things: a card strip in a full hand, a bind slot, an enemy, End turn, a map node, a reward page, reward skip, rest buttons, title buttons. Use your normal thumb, no care. | Each can be hit on the **first try** at least 9 times out of 10. As a rough guide each target is about 9 mm wide. A target that needs care is a Fail; note which. | E12 row |
| E12.6 | Look for a letterbox (black bars) or cut-off screen edges in both rotations. | The picture fills the screen. No black bars. Only background art may extend under the cutout. | E12 row |

### 12b. Screenshot tool and size check **(QA or studio machine)**

QA runs the permitted screenshot command, which renders the main scene at **1920x1080 (16:9), 2400x1080 (20:9) and 2640x1080 (22:9)**, and opens `.godot/qa/main-<W>x<H>.png`. QA records for each size:

| Case | Check | Expected | Record |
|---|---|---|---|
| E12.7 | Screenshots at the three sizes. | No letterbox; no element lost or overlapping; margins at the sides only at 16:9. | E12 row, with the three screenshots attached |

The runner shows the main scene only, and QA cannot use other sizes without Board approval of the command. If the build's main scene changes, QA notes which screens (title only, or combat) the screenshots showed.

## 13. E13 — Frame rate and size

| Case | Steps | Expected | Record |
|---|---|---|---|
| E13.1 *Map* | Open the map and move around it, scroll if it scrolls, tap nodes. | Looks smooth, as the system's UI does (60 fps); no stutter. | E13 row |
| E13.2 *Combat* | In a fight, play pages and end turns for at least 3 turns. | Smooth (60 fps); enemy action animations do not hitch. | E13 row |
| E13.3 *Animations* | Watch the busiest moments: playing a card, a bind, a fray, a sever, a reshuffle, a boss fight. If you can, record the screen (Android's screen recorder). | No visible freeze or slideshow (never below 30 fps). Note any stutter and the moment. | E13 row, attach recording of the worst moment |
| E13.4 *Measure (if a counter exists)* | If the build shows an FPS counter or a debug overlay, read it during E13.1–E13.3. If not, ask QA for the measurement in `docs/qa/perf-M1.md` (T20). | Map and combat steady at about 60; lowest value during animations at least 30. | E13 row, note the numbers |
| E13.5 *Size* | On the phone or the PC, check the APK file size (Files app → Details; or the build output). | **Under 100 MB.** | E13 row, with the size in MB |
| E13.6 *Memory* | After 10 minutes of play, press Home for a minute, then return. | Either the game is still where you left it, or it restarts to the title and **Continue** brings back the same node and state. Losing the node is a Fail for E8 as well. | E13 row, note |

The eye test is the Board's call; QA treats the T20 measurement as the proof for the numbers. A row only passes if both agree. Without a measurement, the row is **Not tested**.

## 14. E14 — AAB export **(QA or studio machine)**

The Board does not run this case on the phone. QA runs it on the studio machine only if the permission layer allows the exact command; if it does not, the Board or `gameplay-programmer` runs it and posts the output.

| Case | Steps | Expected | Record |
|---|---|---|---|
| E14.1 | In the repository root on `main`, run `godot --headless --export-release Android` (with the preset in `export_presets.cfg`; it names the output file). | The command exits with no error and writes an **.aab** file at the path the preset names. | E14 row, paste the last lines of output and the file size |
| E14.2 | Check the repository has the committed Gradle template (`android/` folder) and that the export used it (no "template missing" error). | Template is present in git; the build did not ask for anything that is not committed. | E14 row |
| E14.3 | Confirm that nothing in M1 needed a Google Play developer account, a testing track or an upload. | None is used or required. | E14 row (note only) |
| E14.4 | `git status --short` after the export. | The generated output is ignored; no untracked build files show. | E14 row |

## 15. E15 — Deck floor and empty deck

The floor value is in `data/run/rules.json` (start value **5**). Ask QA for the current value before this case; use it as *F* below. The starting deck is at most floor + slot count (8 with the current values 5 and 3), so the floor is reachable in one run by binding, without debug tools.

| Case | Steps | Expected | Record |
|---|---|---|---|
| E15.1 *Refuse at floor* | 1. Start a new run with the starting deck. Count the deck + hand + discard (**N** pages). 2. Choose **none** at every reward so the deck does not grow. Bind pages until the unbound total (deck + hand + discard) equals **F**. The number of binds needed is **S - F**, where S is the starting deck size; ask QA for S from `docs/design/pages.md`. 3. Try to bind one more page. | The bind is **refused** (a visible message or cue). The page stays in the hand, Ink is **not** spent, the slot stays empty. | E15 row |
| E15.2 *Just above* | Bind a page when the total would stay at or above F after binding. | This bind **is allowed**. | E15 row |
| E15.3 *Empty deck and discard* | At the floor, reach a turn where every unbound page is in your hand (deck 0, discard 0; this happens when the hand size is at least the unbound total; use draw pages if needed). 1. Play a page that draws cards. 2. Tap **End turn**. | 1. It does nothing for the draw part, no hang, you can still tap End turn. 2. The hand is discarded, enemies act, the discard reshuffles into the deck and a new hand is drawn normally (the draw stops at the number of pages that exist). No crash, no endless loop. | E15 row |
| E15.4 | *Merged into E15.3; id kept so references stay stable. Nothing to run.* | n/a | n/a |
| E15.5 *Kill at the floor* | At the floor and at the empty-draw state, kill and resume (see E8). | The floor and the state are the same after resume. | E15 row |

If you cannot reach the floor, mark **Not tested** and say how far you got (the lowest total reached). It is reachable in one run by natural play, so treat this as a defect to investigate, not an expected outcome.

## 16. Result table

Copy this into the T21 comment and fill in the last two columns.

| Row | Cases | Result (Pass / Fail / Not tested) | Note (case id, step, what you saw) |
|---|---|---|---|
| E1 | E1.1–E1.5 | | |
| E2 | E2.1–E2.4 | | |
| E3 | E3.1–E3.6 | | |
| E4 | E4.1–E4.5 | | |
| E5 | E5.1–E5.5 | | |
| E6 | E6.1–E6.6 | | |
| E7 | E7.1–E7.4 | | |
| E8 | E8.1–E8.13 | | |
| E9 | E9.1–E9.7 | | |
| E10 | E10.1–E10.9 | | |
| E11 | E11.1–E11.5 | | |
| E12 | E12.1–E12.7 | | |
| E13 | E13.1–E13.6 | | |
| E14 | E14.1–E14.4 | | |
| E15 | E15.1–E15.5 | | |

A row is **Pass** only if every case in it passes. One failed case is a Fail for the row.

Header for the comment: phone model, Android version, cutout (real / simulated), build commit or APK name and size, date, runs played.

## 17. Coverage map

| Exit criterion | Cases | Run by |
|---|---|---|
| E1 | E1.1–E1.5 | Board (device) |
| E2 | E2.1–E2.4 | Board |
| E3 | E3.1–E3.6 | Board |
| E4 | E4.1–E4.5 | Board |
| E5 | E5.1–E5.5 | Board |
| E6 | E6.1–E6.6 | Board |
| E7 | E7.1–E7.4 | Board lists names and reads; QA passes unclear items to `director` |
| E8 | E8.1–E8.13 (all node types: map, fight, warden, rest, boss, reward; after player turn and enemy turn; both rotations) | Board |
| E9 | E9.1–E9.7 | Board |
| E10 | E10.1–E10.9 | Board |
| E11 | E11.1–E11.5 | Board |
| E12 | E12.1–E12.6 device; E12.7 screenshots | Board; QA for E12.7 |
| E13 | E13.1–E13.6 | Board; measurement from T20 |
| E14 | E14.1–E14.4 | QA or studio machine |
| E15 | E15.1–E15.5 | Board |

## 18. Known limits and open items for the reviewer

- **Page, enemy and rules names are not yet in the repository** (T4, T5 and T3 have not merged). The cases use the roles from the M1 plan (attacker, frayer, deck-fouler, warden, boss) and the concept's example pages. QA refreshes this plan with the real names and the real floor value once those Tasks merge; the structure and ids stay the same.
- **No debug tools are assumed.** The deck floor (E15) is reachable by natural play (design commitment for T4). Three enemies (E11.5) and a sever (E3.4) are natural-play cases: T5 puts a three-enemy fight on every path and the boss always severs. Every path from start to boss has each common type at least once and the warden exactly once.
- **E13 needs a measurement**, not only the eye. T20 (`docs/qa/perf-M1.md`) is the source for the numbers.
- **E12.7** can only use the three sizes of the committed screenshot command and only the main scene.
- **E8.3** depends on the save timing T17 implements (after the player ends the turn, after enemies act). The game designer confirmed both resume points are intended; the case checks that the enemies act exactly once.
