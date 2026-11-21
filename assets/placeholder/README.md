# Placeholder art pack (M1 T14)

Status: placeholder, proposed. Reviewer `ui-designer`, then Board approval; `director` checks originality (E7).

Every file is hand-authored SVG (vector, flat-shaded, no baked text, transparent where it is a sprite) using the Art Bible anchor palette (`docs/art/ART-BIBLE.md` §3). Sizes are the SVG `width` x `height` in px on the 2400 x 1080 design canvas. Provenance for every file: **original placeholder** (hand-written SVG, no generator, no external library, no reference image, no font). The asset registry belongs to T18; T22 adds registry rows when placeholders are swapped.

Sizing basis: enemy height = size class x 1080 (common 25 % = 270, warden 35 % = 378, boss 45 % = 486; `docs/design/enemies.md` §4, §7). Icons are 128 x 128, about the 125 px touch target (Art Bible §4.3). Backgrounds are 2400 x 1080 plus 120 px overscan per side (§4.1). The spread is two 700 x 900 pages (TOOL-DECISIONS card budget). All files are tiny (each under 3 KB), far inside the 60 MB art budget.

| File | Size (px) | Shows | Provenance |
|---|---|---|---|
| `characters/scrivener.svg` | 300 x 432 | Scrivener, faces right, stooped, lantern, satchel-book, three binding cords (shoulder, chest, hip) | original placeholder |
| `enemies/bailiff.svg` | 330 x 270 | Bailiff (common): broad, hooded, hooked tally-rod across body; widest | original placeholder |
| `enemies/bookmoth.svg` | 300 x 270 | Bookmoth (common): torn-page wings, trailing thread; only flier | original placeholder |
| `enemies/blotter.svg` | 300 x 270 | Blotter (common): low, round, under wet paper, stamp-fist, ink pool | original placeholder |
| `enemies/registrar.svg` | 240 x 378 | Registrar (warden): tall robe, seal-press held high, flat top | original placeholder |
| `enemies/redactor.svg` | 420 x 486 | The Redactor (boss): largest, hooded, black bar face, strike-through blade held low | original placeholder |
| `slots/slot_empty.svg` | 128 x 128 | Bind slot, empty: dashed ring | original placeholder |
| `slots/slot_intact.svg` | 128 x 128 | Bind slot, intact: whole stitched loop | original placeholder |
| `slots/slot_frayed.svg` | 128 x 128 | Bind slot, frayed: broken loop, loose threads | original placeholder |
| `slots/slot_severed.svg` | 128 x 128 | Bind slot, severed: cut ends, empty centre, cut mark | original placeholder |
| `telegraph/telegraph_attack.svg` | 128 x 128 | Attack icon: blade | original placeholder |
| `telegraph/telegraph_guard.svg` | 128 x 128 | Guard icon: shield | original placeholder |
| `telegraph/telegraph_fray.svg` | 128 x 128 | Fray icon: cord splitting into threads | original placeholder |
| `telegraph/telegraph_foul.svg` | 128 x 128 | Foul icon: ink blot on a page | original placeholder |
| `telegraph/telegraph_sever.svg` | 128 x 128 | Sever icon: cord cut by a bar | original placeholder |
| `cards/card_compact_frame.svg` | 240 x 360 | Compact card frame: cost, name, Play zone, divider, Bind zone | original placeholder |
| `cards/card_spread_frame.svg` | 1400 x 900 | Spread frame: Play left page, Bind right page, Ink cost at spine | original placeholder |
| `backgrounds/combat_background.svg` | 2640 x 1080 | Combat background, opaque, lantern light upper left, lanes kept clear | original placeholder |

## Notes and limits

- Silhouette tests are by design intent only; not tested on a target-class phone (Art Bible §12 item 5).
- Binding states differ by cord shape (whole loop, broken loop, cut ends), not tint alone. Play and Bind use shape (diamond vs loop) as well as colour.
- Slot frame and icon art are plain squares and circles; 9-slice and safe-area handling are `ui-designer` / `gameplay-programmer` work.
- No raster tool is approved for this role, so there are no PNGs. If the engine needs PNG, that is a separate handoff.
- Pivots: sprites use bottom-centre as the intended foot pivot. No animation frames are included (one idle pose each).
