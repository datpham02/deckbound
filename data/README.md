# Deckbound data format (M1 T3)

`data/` is the board-approved design-tunable folder for gameplay numbers and authored content.
Code must read these values through `scripts/data/data_loader.gd` instead of hard-coding them.

## Folder layout

- `data/pages/*.json`: page definitions (one page per file)
- `data/enemies/*.json`: enemy definitions (one enemy per file)
- `data/run/rules.json`: run-level numeric and boolean rules

## Page schema (`data/pages/*.json`)

```json
{
  "id": "nib_cut",
  "name": "Nib Cut",
  "cost": 1,
  "compact": {
    "play": "Deal 6",
    "bind": "Strikes deal 1 more"
  },
  "play_effects": [
    { "id": "damage", "params": { "amount": 6, "target": "enemy" } }
  ],
  "bind_passives": [
    { "id": "played_damage_bonus", "params": { "amount": 1 } }
  ]
}
```

Required fields:

- `id` string
- `name` string
- `cost` int (`>= 0`)
- `compact.play` string
- `compact.bind` string
- `play_effects` array of objects with `id` and optional `params` dictionary
- `bind_passives` array of objects with `id` and optional `params` dictionary

Effect and passive ids are validated against known registries in the loader.

## Enemy schema (`data/enemies/*.json`)

```json
{
  "id": "bailiff",
  "name": "Bailiff",
  "stats": {
    "health": 26
  },
  "actions": [
    { "id": "rap", "type": "attack", "value": 5 },
    { "id": "brace", "type": "guard", "value": 7 }
  ],
  "telegraph_pattern": ["rap", "brace"]
}
```

Required fields:

- `id` string
- `name` string
- `stats.health` int (`> 0`)
- `actions` array of objects:
  - `id` string (unique per enemy)
  - `type` string (`attack`, `guard`, `fray`, `foul`, `sever`)
  - `value` int (`>= 0`)
  - optional `hits` int (`> 0`)
- `telegraph_pattern` array of action ids; each value must reference an action in `actions`

## Run rules schema (`data/run/rules.json`)

Required fields:

- `schema_version` int (`>= 1`)
- `hero_health` int (`> 0`)
- `ink_per_turn` int (`>= 0`)
- `hand_draw` int (`> 0`)
- `hand_max` int (`> 0`, and `>= hand_draw`)
- `bind_slots` int (`> 0`)
- `deck_floor` int (`>= 0`)
- `blot_persists_after_combat` bool

## Validation errors

Loader errors always include file path and field path:

`<file> :: <field> :: <reason>`

Examples:

- `res://data/pages/nib_cut.json :: $.name :: Missing required field.`
- `res://data/pages/nib_cut.json :: $.play_effects[0].id :: Unknown play effect id 'foo'.`
- `res://data/run/rules.json :: $.deck_floor :: Expected int, got String.`
