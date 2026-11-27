# M1 Asset List

Status: **proposed** (SOU-97, 2026-11-26). Part of the art reset. Replaces all earlier asset lists and specs, which were deleted.

Scope: every asset the M1 first playable needs, and no more. Sources: [../milestones/M1-first-playable.md](../milestones/M1-first-playable.md), [../concept.md](../concept.md), [../design/enemies.md](../design/enemies.md) and [../design/pages.md](../design/pages.md). Look rules: [ART-BIBLE.md](ART-BIBLE.md) v2. Families follow the structure in the reference study.

**On-screen sizes** are for the 2400 x 1080 canvas and are all **(proposed)**. They come from the size classes in `enemies.md` (common 25 %, warden 35 %, boss 45 % of screen height) and the Bible (§7 to §9). The hero is set at about 32 % **(proposed)**. Touch targets are at least about 126 px (48 dp).

**Priority:** P0 needed on the M1 exit path, P1 needed for a complete first playable, P2 polish if time allows. **Order** is the production order, lowest first. Order 1 is the hero, the style test. No other asset starts before the hero passes review, because every later asset copies its outline, shading and proportion rules.

**Not produced in M1.** Relic icons, potion icons, power icons beyond the status icons below, NPC portraits, boss encounter icons (the map boss node icon serves), achievement icons, events art, shop art, a second hero, a second floor. M1 has no relics, potions, shop or events (`concept.md`, M1 scope). Audio is out of scope.

## 1. Characters and skeletal animation

| Order | id | Family | Use | On-screen size | Animation needs | Priority |
|---|---|---|---|---|---|---|
| 1 | `char_scrivener` | character | The player hero in combat. The style test. Faces right, left third of the screen. | about 345 px tall (32 %) | Skeleton2D. Idle, tear a page (play), bind, hit, defeat. Three bind positions visible on the figure. | P0 |
| 14 | `char_scrivener_portrait` | character | Rest screen and title screen figure. | about 400 px tall | Static pose, or idle from the same rig. | P2 |

## 2. Enemies (commons, warden, boss)

All face left. Silhouette rules are in the Bible §5.

| Order | id | Family | Use | On-screen size | Animation needs | Priority |
|---|---|---|---|---|---|---|
| 2 | `enemy_bailiff` | monster, common attacker | Intro fight 1, mixed fights. | about 270 px tall (25 %), wide | Frame loop or light Skeleton2D. Idle, attack (rap), guard (brace), hit, defeat. | P0 |
| 3 | `enemy_bookmoth` | monster, common frayer | Intro fight 2, mixed fights, in pairs. | about 270 px (25 %, by wingspan) | Frame loop. Idle (flutter), fray (unpick), attack (nibble), hit, defeat. | P0 |
| 4 | `enemy_blotter` | monster, common fouler | Intro fight 3, mixed fights. | about 270 px (25 %), low and round | Frame loop. Idle, foul (file), attack (smear), guard (brace), hit, defeat. | P0 |
| 5 | `enemy_registrar` | monster, warden | The warden node. Fought alone. | about 378 px tall (35 %), tall and narrow | Skeleton2D or frame loop. Idle, attack, fray (press), guard (brace), two-hit seal-press, hit, defeat. | P0 |
| 6 | `enemy_redactor` | monster, boss | The boss node. Two phases. | about 486 px tall (45 %) | Skeleton2D. Idle, attack, sever (strike out), guard (brace), hit, defeat. Phase 2 uses the same art; the change is a health-bar notch and a new telegraph (`enemies.md` §4.5). | P0 |

Rig sharing: the Bailiff, Blotter and Bookmoth do not share a rig, because their primary shapes differ. Only a palette or prop variant may reuse a rig. M1 has none.

## 3. Intent and status icons

| Order | id | Family | Use | On-screen size | Animation needs | Priority |
|---|---|---|---|---|---|---|
| 7 | `icon_intent_attack` | intent | Telegraph above an enemy. | 96 px minimum, plus number at 20 sp or more | Static. Gentle pop on appear is done in Godot. | P0 |
| 7 | `icon_intent_guard` | intent | Telegraph. | as above | Static | P0 |
| 7 | `icon_intent_fray` | intent | Telegraph, with a line to the threatened slot. | as above | Static. The line is drawn in Godot. | P0 |
| 7 | `icon_intent_foul` | intent | Telegraph. | as above | Static | P0 |
| 7 | `icon_intent_sever` | intent | Telegraph, with a line to the threatened slot. | as above | Static | P0 |
| 8 | `icon_status_guard` | status | Guard value beside a combatant's health. | about 48 px | Static | P0 |
| 8 | `icon_status_frayed_mark` | status | Small notch mark shown on frayed bindings and in the inspect overlay. | about 48 px | Static | P1 |

The five intent icons form one set and are made together, so they are told apart as flat black shapes.

## 4. Bind slot and resource icons

| Order | id | Family | Use | On-screen size | Animation needs | Priority |
|---|---|---|---|---|---|---|
| 9 | `slot_empty` | bind slot | Bind slot with no page. Drop zone. | at least 126 px | Static. A highlight state is a Godot effect. | P0 |
| 9 | `slot_intact` | bind slot | A bound page that applies. | at least 126 px | Static | P0 |
| 9 | `slot_frayed` | bind slot | A frayed binding, off until end of combat. | at least 126 px | Static | P0 |
| 9 | `slot_severed` | bind slot | A severed binding, brief state before it empties. | at least 126 px | Static. Fade to `slot_empty` is a Godot effect. | P0 |
| 10 | `icon_ink_orb` | orb / resource | Ink pool, bottom left, with a number and a maximum. | about 180 px | Static. Fill change is a Godot effect. | P0 |
| 10 | `icon_pile_deck` | resource | Deck pile with count. | about 150 px | Static | P0 |
| 10 | `icon_pile_discard` | resource | Discard pile with count. | about 150 px | Static | P0 |
| 10 | `btn_end_turn` | UI button | End turn, bottom right. Normal, pressed and disabled states. | about 190 x 190 px (at least 72 dp) | Three static states | P0 |
| 11 | `icon_health` | resource | Health marker on the bars. | about 48 px | Static | P1 |
| 11 | `ui_bar_health` | UI bar | Health bar plate with the half-point notch used by the boss. | about 280 x 36 px | Static plate, fill drawn in Godot | P0 |

The four slot states differ in shape, not only colour (Bible §9). The bar fill and notch positions are Godot work (`gameplay-programmer`).

## 5. Card frames and portraits

| Order | id | Family | Use | On-screen size | Animation needs | Priority |
|---|---|---|---|---|---|---|
| 12 | `card_frame_compact` | card frame | Card in hand, compact face, with the Ink cost mark, name ribbon, art window, Play and Bind panels. One category for now. | about 170 x 238 px | Static. Raise and scale on select is a Godot effect. | P0 |
| 12 | `card_frame_spread` | card frame | The open two-page spread after a tap, Play left, Bind right, cost at the spine. | about 1500 x 760 px | Static | P0 |
| 12 | `card_cost_mark` | card frame | Ink cost mark, digits 0 to 3. | about 56 px | Static | P0 |
| 12 | `card_icon_play`, `card_icon_bind` | card frame | The two marks that label the Play and Bind lines. | about 40 px | Static | P0 |
| 13 | `card_portrait_<page id>` x21 | card portrait | One illustration per page (`pages.md` §5). 21 ids: `nib_cut`, `inkwell_ward`, `torn_margin`, `pressed_thorn`, `tally_mark`, `candle_debt`, `wax_seal`, `lantern_oath`, `errata_slip`, `footnote`, `docket_stamp`, `sealed_lien`, `drowned_codicil`, `salt_line`, `knotted_thread`, `blank_folio`, `ledger_of_debts`, `blotting_sheet`, `oath_of_the_dry_hand`, `flooded_index`, `water_stain`. | art window of the compact card; the spread shows it larger. Authored at about 512 x 384 px | Static | P1 |

Frame variants per category or rarity are not needed until `game-designer` defines them. See Bible §16, question 5. The starting deck needs five portraits first: `nib_cut`, `inkwell_ward`, `torn_margin`, `pressed_thorn`, `tally_mark`.

## 6. Map-node icons

| Order | id | Family | Use | On-screen size | Animation needs | Priority |
|---|---|---|---|---|---|---|
| 15 | `node_fight` | map node | Fight node on the map. | at least 126 px touch target | Static. Visited and available states are told apart by value and a mark. | P0 |
| 15 | `node_warden` | map node | Warden node. | as above | Static | P0 |
| 15 | `node_rest` | map node | Rest node. | as above | Static | P0 |
| 15 | `node_reward` | map node | Reward node. | as above | Static | P1 |
| 15 | `node_boss` | map node | Boss node. Doubles as the boss encounter icon. | as above, larger | Static | P0 |
| 15 | `map_path_line` | map | Path between nodes, drawn as a dashed or inked line. | tiles | Static | P1 |

## 7. Backgrounds

| Order | id | Family | Use | On-screen size | Animation needs | Priority |
|---|---|---|---|---|---|---|
| 16 | `bg_combat_halls` | background | Combat stage for fights, one hue family. Empty floor at the ground line, no outlines. | 2400 x 1080 plus a margin for the 22:9 range | Static. Optional slow parallax or drifting dust, if the memory budget allows. | P0 |
| 17 | `bg_combat_warden` | background | Warden fight. Same layout, new hue. | as above | Static | P1 |
| 17 | `bg_combat_boss` | background | Boss fight. Same layout, new hue. | as above | Static | P1 |
| 18 | `bg_rest` | background | Rest screen (unbind, skip). | as above | Static | P1 |
| 18 | `bg_map` | background | Map page. | as above | Static | P1 |
| 18 | `bg_title` | background | Title screen. | as above | Static | P2 |

Warden, boss, rest and map backgrounds may be hue variants of one structure. Decide at the style test.

## 8. Effects (sprites for runtime VFX)

Godot builds the particles and shaders. The artist supplies small flat sprites.

| Order | id | Family | Use | On-screen size | Animation needs | Priority |
|---|---|---|---|---|---|---|
| 19 | `vfx_hit_flash` | VFX | Impact on a hit, on the target. | about 200 px | 3 to 5 frames, or one sprite scaled in Godot | P1 |
| 19 | `vfx_page_tear` | VFX | Play effect scraps, and the bind seal appear. | about 150 px | Few frames or one sprite | P1 |
| 19 | `vfx_fray_thread` | VFX | Fray effect at a slot. | about 150 px | Few frames | P1 |
| 19 | `vfx_sever_cut` | VFX | Sever effect at a slot. | about 200 px | Few frames | P1 |
| 19 | `vfx_ink_splash` | VFX | Ink and foul effect on the hero. | about 200 px | Few frames | P2 |
| 19 | `vfx_guard_gain` | VFX | Guard gained. | about 200 px | Few frames | P2 |
| 19 | `ui_damage_number_style` | UI | Large, centred damage numbers over the target. A style, not a sprite set. Font choice is an open question. | at least 52 px | Done in Godot | P1 |

## 9. Summary

| Group | Items | P0 | P1 | P2 |
|---|---|---|---|---|
| Characters | 2 | 1 | 0 | 1 |
| Enemies | 5 | 5 | 0 | 0 |
| Intent and status icons | 7 | 6 | 1 | 0 |
| Bind slot and resource | 10 | 9 | 1 | 0 |
| Card frames and portraits | 5 frame assets, 21 portraits | 5 | 21 | 0 |
| Map nodes | 6 | 4 | 2 | 0 |
| Backgrounds | 6 | 1 | 4 | 1 |
| Effects | 7 | 0 | 5 | 2 |

Production order in short: hero (1), then the five enemies (2 to 6), then the icon sets (7 to 11), the card frames and portraits (12, 13), the map nodes and backgrounds (15 to 18), the effects last (19).

Each asset gets an asset spec from `ASSET-SPEC-TEMPLATE.md` and a registry row when its production starts. No specs or registry rows exist yet. Production Tasks, one PR per family, are proposed by `project-manager` after the Board approves the Bible and the hero style test.
