# Deckbound — Milestone 1: First Playable (Android)

Status: **proposed** (SOU-36). Reviewer `director` (scope and pillars approved 2026-11-21), then Board approval. After approval `project-manager` turns the task list in §3 into Paperclip Tasks; this document creates none.

Board decisions applied (Board Operator, 2026-11-21): M1 exits on a debug APK with the AAB build proven, and there is no Google Play upload, testing track or developer account until the game is complete · `data/` (JSON) is the design-tunable folder · the art vertical slice (T18) runs in parallel now in its own folders, Art Phase 1 is approved on the condition that it does not conflict with gameplay work, and D1 is decided (local ComfyUI with FLUX.1 schnell and SDXL, installed on the studio machine 2026-11-21) · the Board Operator runs the on-device pass with QA's test plan · Godot's default font for M1 placeholder UI.
Sources: [concept.md](../concept.md) ("First playable scope", acceptance criteria 1–13), [vision.md](../vision.md), [art/ART-PIPELINE.md](../art/ART-PIPELINE.md) §5 Step 2 and §8, [art/TOOL-DECISIONS.md](../art/TOOL-DECISIONS.md), [art/ART-BIBLE.md](../art/ART-BIBLE.md), [AGENTS.md](../../AGENTS.md).

## 1. Exit criteria

M1 ends when the **Board Operator** installs a **debug APK** built from `main` on their Android phone (target class per concept "Performance budget": 3–4 GB RAM, Mali-G52 / Adreno 610 class, Android 10+) and every row below passes by touch only, following QA's test plan `docs/qa/M1-test-plan.md`. QA agents cannot hold a phone: the Board reports pass / fail / not tested per row on T21, and QA writes `docs/qa/M1-report.md` from those results; "not tested" is a fail for exit.

| # | Check on device | Source |
|---|---|---|
| E1 | Every page in the build shows a Play face and a Bind face in the spread; each face can be used in combat. | concept AC1 |
| E2 | Binding a page removes it from hand, deck and discard for the rest of the run (deck and discard counts drop, it never draws again) and fills a visible bind slot. | AC2 |
| E3 | A frayed binding stops applying its effect until end of combat; a severed binding is gone from the run (slot empties, page not in deck). | AC3 |
| E4 | Fray and sever are telegraphed above the enemy before the player's turn, with a line to the threatened slot. | AC4 |
| E5 | Unbind at a rest returns the page to the deck and frees the slot. | AC5 |
| E6 | One run meets all three common enemy types and the warden, ends in the boss fight, and both winning and losing show the run summary. | AC6 |
| E7 | Originality checklist (concept "Originality") passes on every name, card text, enemy and UI element. | AC7 |
| E8 | Kill the app from recents at each node type (fight, warden, rest, boss, reward, map) and after a player turn and after an enemy turn in combat; reopening resumes the same node or turn with the same hand, deck, discard, bindings, health, guard and telegraphs. | AC8 |
| E9 | Compact face in hand shows cost, name, one Play line, one Bind line; tap opens the spread; long-press opens inspect and commits nothing; a first tap never acts. | AC9 |
| E10 | Play = drag right onto enemy or play area; Bind = drag left onto a slot plus a confirming tap; release elsewhere cancels. | AC10 |
| E11 | Combat layout matches the concept (Scrivener and slots left, enemies and telegraphs right, hand bottom, Ink and deck bottom-left, discard and end turn right); landscape only, both rotations. | AC11 |
| E12 | Every tappable element is at least 48 x 48 dp and inside the safe area in both rotations on a phone with a cutout and gesture navigation; no letterbox and no lost element from 16:9 to 22:9 (QA screenshot tool for the three sizes plus a device check; if the Board's phone has no cutout, the cutout rows use Android's developer option "Simulate a display with a cutout" and the test plan says so). | AC12 |
| E13 | 60 fps on map and in combat, never below 30 during card and binding animations; debug APK download under 100 MB. | AC13 |
| E14 | An **AAB** builds on the studio machine with the committed Gradle template (`godot --headless --export-release Android`). No upload to Google Play, no testing track and no developer account in M1 (Board decision: not until the game is complete). | concept "Google Play prerequisites" |
| E15 | Deck-floor rule: with the starting deck, binding is refused when it would leave fewer than the floor set in `data/run/rules.json` (start value 5), and drawing from an empty deck and empty discard draws nothing and does not hang. | concept risk 2 |

Difference from the concept's criteria: the concept says AAB on an internal testing track; by Board decision M1 exits on a debug APK, E14 keeps the AAB path proven, and the testing track waits until the game is complete.

## 2. Scope

**In.** One hero (Scrivener). Combat with Play / Bind, Ink, guard, draw and discard, enemy telegraphs, end turn. Binding with slots (start value 3), fray, sever, unbind at rest. Three common enemies (attacker, frayer, deck-fouler), one warden (a stronger attacker that frays), one boss (severs). One floor: branching map of fights, one warden, rests and the boss. Reward screen (choose one of three pages or none). Run summary on win and loss. Title screen with Continue and New run; abandon run from the map. Save at every node transition, after each player and enemy turn, and on app pause. About 20 pages. Rules and all numbers in `data/` files (JSON; the Board-approved design-tunable folder, recorded in `AGENTS.md` by T3). Headless tests for rules. Android Gradle build template and AAB export proof.

**Out.** Shop, events other than rests, meta unlocks, second hero or floor, monetization, analytics, accounts, audio and music, final art, Spine, localisation. Google Play developer account, store listing, testing track and upload: none of these until the game is complete (Board decision). Nothing in M1 may be designed so that it is later gated behind money for power (pillar 4).

**Art.** All M1 gameplay art on the exit path is **placeholder** made by `game-artist` to the Art Bible's readability rules (silhouette at 25 % screen height, no text in images, states told apart by shape and position): flat-shaded Scrivener, five enemies, bind-slot states (intact / frayed / severed), telegraph icons, compact and spread card frames, one background, all under `assets/placeholder/` and `assets/ui/placeholder/`. UI uses Godot Control nodes, a single placeholder theme and Godot's default font (Board decision; a licensed font is chosen with the art slice). The **art vertical slice** (pipeline §5 Step 2) runs **in parallel from day one** as its own track (T18): Art Phase 1 is approved on the condition that the slice does not conflict with gameplay work, and D1 is decided (local ComfyUI, FLUX.1 schnell and SDXL, drafts only). T18 therefore writes only its own folders (`art_src/`, `assets/slice/`, `design/assets/`, `docs/art/`) and never touches a placeholder folder, a scene or a script. The slice is **not** on the M1 exit path. Slice art replaces placeholders in a **separate swap-in PR (T22) after both T14 and T18 are merged**: it repoints scene references from `assets/placeholder/` to `assets/slice/` for the Scrivener, the two commons and the background, deletes the replaced placeholder files and updates the registry. If T22 is not merged before T20 starts, the swap lands in M2 and M1 exits on placeholders.

## 3. Task breakdown

Each Task is one PR of about 10 files / 400 lines; where a row says "split if", the assignee splits before starting rather than exceeding that. Roles: `gp` gameplay-programmer, `gd` game-designer, `ui` ui-designer, `ga` game-artist, `qa` qa-engineer. Folder rules: `data/` (JSON, the Board-approved design-tunable folder), `scripts/`, `scenes/` and `tests/` mirror each other per feature; `assets/placeholder/` and `assets/ui/placeholder/` for M1 placeholder art; `art_src/`, `assets/slice/`, `design/assets/` and `docs/art/` belong to the art slice track only.

| # | Task and goal | Role | Write set | Depends on | Reviewer |
|---|---|---|---|---|---|
| T1 | **Android Gradle build template + AAB proof.** Install the Godot 4.6.3 Android build template into the repo, ignore its generated output, export a debug APK and a release AAB headlessly, refresh the "Android export prerequisites" section. | gp | `android/`, `.gitignore`, `export_presets.cfg`, `AGENTS.md` (export section only) | — | qa |
| T2 | **Headless test runner + CI smoke.** A `godot --headless` test runner that exits non-zero on failure, one example test, and a workflow that runs it and the smoke check on every PR. | gp | `tests/`, `.github/workflows/`, `AGENTS.md` (commands section only) | — | qa |
| T3 | **Data format + loader.** JSON schema for pages (id, name, cost, compact lines, Play effect list, Bind passive list), enemies (stats, telegraph pattern, action list) and run rules; typed loader with validation errors on bad data; `AGENTS.md` records `data/` as the design-tunable folder (approved by the Board 2026-11-21). | gp | `data/README.md`, `data/run/rules.json`, `scripts/data/`, `tests/data/`, `AGENTS.md` (one paragraph) | T2 | gd |
| T4 | **Page set.** Design note for about 20 pages, each with a "when play / when bind / when regret" answer (vision AC2), the starting deck, and their data files. | gd | `docs/design/pages.md`, `data/pages/` | T3 (data), doc may start earlier | director |
| T5 | **Enemies, warden, boss.** Design note and data for three commons (attacker, frayer, fouler), the warden and the boss (sever), telegraph patterns and fight compositions per node. | gd | `docs/design/enemies.md`, `data/enemies/`, `data/encounters/` | T3 | director |
| T6 | **Combat core.** Turn loop: draw, Ink, play effects, guard, discard, end turn, enemy acts from telegraph; effect registry keyed by the ids used in `data/`. Pure logic, no scene. Split if over size: hand/deck vs enemy turn. | gp | `scripts/combat/core/`, `tests/combat/core/` | T3 | gd |
| T7 | **Binding system.** Bind (page leaves hand, deck and discard), slots, passive application, fray (off until end of combat), sever (removed from run), unbind, deck-floor rule (E15). | gp | `scripts/combat/binding/`, `tests/combat/binding/` | T6 | gd |
| T8 | **Enemy behaviours from data.** Attack, guard, fray, foul (adds a worthless page to the discard), sever; warden and boss sequences; composition loading. | gp | `scripts/combat/enemies/`, `tests/combat/enemies/` | T5, T7 | gd |
| T9 | **Run state + save framework.** `RunState` as the single source of truth (deck, bindings, health, map position, seed), JSON save at `user://`, save on node transition and pause, load on start, versioned schema. | gp | `scripts/run/`, `scripts/save/`, `tests/save/` | T3 | qa |
| T10 | **Floor map.** Seeded generation of one branching floor (fights, one warden, rests, boss), map scene with touch node selection, map data in `data/run/`. | gp | `scripts/map/`, `scenes/map/`, `data/run/floor.json`, `tests/map/` | T9 | gd |
| T11 | **Combat screen layout + placeholder theme.** Control-node layout per concept "Combat screen layout", safe-area insets, hand band, compact card and spread scenes (static), one theme; verified with the QA screenshot tool at 1920/2400/2640 x 1080. | ui | `scenes/combat/`, `scenes/card/`, `themes/`, `assets/ui/placeholder/` | — (uses T14 icons when ready) | gp |
| T12 | **Card interaction.** Tap opens spread, drag right = Play (target highlight), drag left = Bind with confirming tap, release elsewhere cancels, long-press inspect; wires T6/T7 into T11. | gp | `scripts/combat/ui/card_*`, `scenes/card/` | T6, T7, T11 | ui |
| T13 | **Telegraphs and slot status.** Enemy telegraph icon and number above the head, fray/sever line to the threatened slot, bind-slot intact/frayed/severed display, Ink/deck/discard counters, end turn. | gp | `scripts/combat/ui/telegraph_*`, `scripts/combat/ui/slot_*`, `scripts/combat/ui/hud_*` | T8, T11 | ui |
| T14 | **Placeholder art pack.** Scrivener, five enemies, slot states, telegraph icons (attack, guard, fray, foul, sever), compact and spread frames, one background, each sized per the Art Bible budgets, with provenance "original placeholder" listed in `assets/placeholder/README.md` (the asset registry belongs to T18; T22 adds the placeholder rows when it swaps). | ga | `assets/placeholder/` | T5 (enemy list) | ui |
| T15 | **Rest and reward screens.** Rest: unbind one page or skip. Reward: offer three pages from `data/pages/` or take none. Both write to `RunState`. | gp | `scenes/rest/`, `scenes/reward/`, `scripts/screens/` | T7, T9, T11 (theme) | gd |
| T16 | **Run flow + summary.** Title (Continue / New run), map → node → combat → reward → map → boss → summary (win / loss), abandon from map; entry scene wiring. | gp | `scripts/flow/`, `scenes/summary/`, `scenes/title/`, `scenes/main/main.tscn` | T10, T12, T13, T15 | gd |
| T17 | **Combat save and resume.** Snapshot after the player ends a turn, after enemies act and on pause: hand, deck order, discard, bindings and fray state, enemy health and telegraphs; resume mid-combat. | gp | `scripts/save/combat_snapshot.gd`, `scripts/combat/core/` (serialize only), `tests/save/` | T9, T16 | qa |
| T18 | **Art vertical slice track** (pipeline §5 Step 2): Art Bible Phase 1 wording and visual target pack, asset registry and specs, then one Scrivener with idle + one action (Skeleton2D), two commons with one action each, one card illustration, one bind-slot icon, one background, one UI composition, one fray VFX; local ComfyUI generation (house style A Ink Cel) → `art-ops` cleanup (Krita optional) → export to `assets/slice/` → Godot test scene under `assets/slice/` → device. Split into one PR per asset class. Never writes to `assets/placeholder/`, `assets/ui/placeholder/`, `scenes/` or `scripts/`; the swap into the game is T22. | ga (with ui for the UI composition) | `art_src/`, `assets/slice/`, `design/assets/`, `docs/art/` | — (Art Phase 1 approved and D1 decided, 2026-11-21; runs from day one) | director |
| T19 | **Tuning sheet + first balance pass.** `docs/design/tuning.md` lists every number and where it lives in `data/`; a pass over Ink, hand size, slot count, deck floor, fray/sever frequency after ten logged runs on device. | gd | `docs/design/tuning.md`, `data/` | T16 | director |
| T20 | **Performance and size pass.** Profile on the target device; per-texture `VRAM Compressed` import, atlas sizes, animation caps; confirm E13. | gp | `assets/**/*.import`, `scripts/combat/ui/` (effect caps), `docs/qa/perf-M1.md` | T16, T14 | qa |
| T21 | **QA test plan and M1 report.** QA writes step-by-step test cases derived from E1–E15 (plan written early), including kill-and-resume at every node type and both rotations. The **device pass is run by the Board Operator** on their Android phone with the debug APK from `main`, following the plan and reporting per-row results as Task comments; QA then writes `docs/qa/M1-report.md` from those results. | qa (device pass: Board) | `docs/qa/M1-test-plan.md`, `docs/qa/M1-report.md` | plan: none; report: T17, T20 and the Board's device results | gd |
| T22 | **Slice art swap-in** (off the exit path). Repoint scene references for the Scrivener, the two slice commons and the background from `assets/placeholder/` to `assets/slice/`, delete the replaced placeholder files, add placeholder and slice rows to the registry; device check that E11–E13 still pass. One PR, after both T14 and T18 (those asset classes) are merged. | ga (with ui) | `scenes/combat/`, `scenes/card/` (texture references only), `assets/placeholder/` (deletions only), `design/assets/asset-registry.yaml` | T14, T16, T18 | director |

Reviewer `director` additionally checks originality (E7) on T4, T5, T14 and T18.

## 4. Parallel lanes

Write sets inside a lane are sequential; lanes never share a folder, so they run at the same time.

- **Lane A, platform and QA:** T1 → T2 → T20 → T21 (report). T21 plan is written at the start of the milestone.
- **Lane B, rules:** T3 → T6 → T7 → T8 → T17 → T19.
- **Lane C, content (design):** T4 and T5 docs from day one; data files after T3 merges.
- **Lane D, screens:** T11 → T12 and T13 (parallel, distinct file prefixes) → T15 → T16. T9 → T10 runs beside T11.
- **Lane E, placeholder art:** T14, from day one (needs only T5's enemy list for names).
- **Lane F, art slice:** T18 from day one in its own folders (`art_src/`, `assets/slice/`, `design/assets/`, `docs/art/`), one PR per asset class; `game-artist` sequences T14 before the slice character work so placeholders are never late. T22 only after T14, T16 and T18 are merged, and only if it lands before T20 starts.

Critical path: T3 → T6 → T7 → T12 → T16 → T17 → T21 (Board device pass). Everything else has slack.

## 5. Risks

| Risk | Mitigation in M1 |
|---|---|
| **Binding dominant or ignored.** | All fray / sever sources, slot count and page numbers live in `data/`; T19 logs ten runs and records bind rate per page. Target: between 30 % and 70 % of offered pages are ever bound across runs, else retune before exit. |
| **Degenerate thin decks.** | E15 deck floor (start 5) and the empty-deck rule, both in `data/run/rules.json` with a headless test in T7. Draw passives are capped per slot in T4's design note. |
| **Two-faced card readability on a phone.** | T11 verified on device at arm's length before T12 starts; compact lines authored in T4, never truncated; minimum text sizes from the Art Bible (12 / 14 / 20 sp). If summaries fail the check, T4 rewrites them rather than adding text. |
| **Android performance and size.** | Compatibility renderer and ASTC/ETC2 are already set (D5). T20 profiles on the target device, not a desktop; placeholder art stays within the 60 MB art budget; animation caps in T13. |
| **Resume bugs.** | `RunState` is the only run state from T9; T17 serialises combat from the same object; T21 kills and resumes at every node type and both combat phases. |
| **Toolchain.** | Export templates and debug keystore are listed missing in `AGENTS.md`; T1 goes first and refreshes that section so the facts on `main` match the machine. |

## 6. Open Board questions

None. The five questions raised in the first draft (debug-APK exit, `data/` as the tunable folder, art slice timing, who holds the phone, placeholder font) were answered by the Board Operator on 2026-11-21 and are applied in §1–§4; see "Board decisions applied" at the top.
