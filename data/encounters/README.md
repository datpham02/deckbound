# Encounter compositions (M1 T5b)

One composition per file. Source of truth for the values: `docs/design/enemies.md` §5
(SOU-42). These files are design-tunable data (`AGENTS.md`, `data/`): T19 retunes
weights and offsets here, not in code.

## Who reads this folder

The T3 loader (`scripts/data/data_loader.gd`) reads `data/pages/`, `data/enemies/` and
`data/run/rules.json`. It does **not** read `data/encounters/` yet. M1 plan §3 row T8
("composition loading") adds the loader and validation for this folder, using the schema
below; T10 (floor map) draws from the pools by node type and applies the coverage rules in
`docs/design/enemies.md` §5.2.

## Schema (`data/encounters/*.json`)

```json
{
  "id": "bookmoth_pair",
  "node": "fight",
  "pool": "intro_2",
  "weight": 1,
  "enemies": [
    { "id": "bookmoth", "start_offset": 0 },
    { "id": "bookmoth", "start_offset": 1 }
  ]
}
```

Fields (all required):

- `id` string, unique across the folder; the file is named `<id>.json`.
- `node` string: `fight`, `warden` or `boss`. The map node type this composition may be
  placed on.
- `pool` string: `intro_1`, `intro_2`, `intro_3`, `mixed`, `warden` or `boss`. The map
  generator draws a composition from the pool its node asks for (enemies note §5.2).
- `weight` int (`> 0`): relative draw weight inside the pool.
- `enemies` non-empty array (at most 3 entries) of objects:
  - `id` string: an enemy id that exists in `data/enemies/`.
  - `start_offset` int (`>= 0`): the pattern step this enemy starts on, so two copies of
    the same enemy do not act in lockstep (enemies note §3.5). The loader should reject an
    offset at or beyond the enemy's `telegraph_pattern` length.

Array order is screen order left to right and action order (enemies note §3.1): position 0
stands leftmost and acts first.

## Pools and the coverage rule (for T10)

| Pool | Node | Compositions |
|---|---|---|
| `intro_1` | fight 1 on every path | `bailiff_solo` |
| `intro_2` | fight 2 on every path | `bookmoth_pair` |
| `intro_3` | fight 3 on every path | `blotter_solo` |
| `mixed` | every later fight | `bailiff_pair`, `bailiff_bookmoth`, `bailiff_blotter`, `bookmoth_blotter` (weight 2 each); `bookmoth_pair_bailiff`, `clerks_three` (weight 1 each) |
| `warden` | the one warden node | `registrar` |
| `boss` | the boss node | `redactor` |

Rules 1 to 4 (first three fights, warden and boss on every path, later fights from
`mixed`, no adjacent repeat of a composition id) are stated in `docs/design/enemies.md`
§5.2 and are T10 acceptance tests, not data in this folder.
