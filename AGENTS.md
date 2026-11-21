# AGENTS.md — deckbound

Instructions for agents working in this repository. Read this before changing
files.

## Stack

| Thing | Version |
| --- | --- |
| Engine | Godot `4.6.3.stable.official.7d41c59c4` |
| Language | GDScript (static typing required) |

No gameplay plugins or addons are part of this seed.

## Commands

Run from repository root.

```bash
godot --path .                    # open in editor
godot --headless --path . --quit  # smoke check (required before handoff)
```

## Folder map

- `scenes/` runtime scenes; keep one scene per feature folder.
- `scripts/` runtime scripts; mirror scene folder structure where practical.
- `assets/` exported/imported runtime assets.
- `art_src/` editable source art files (reserved; do not replace with exports).
- `docs/` documentation.
- `design/assets/` art pipeline specs, registry, and references.
- `tools/asset-pipeline/` asset pipeline tooling.

## Conventions

- File and directory names use `snake_case`.
- GDScript is statically typed (`var foo: Type`, typed params, typed returns).
- Keep one scene per folder (example: `scenes/main/main.tscn`).
- Keep scope tight: do not refactor unrelated systems in seed tasks.

## Hotspots

- `project.godot` (project identity, startup scene, viewport/stretch settings)
- `scenes/main/main.tscn` (entry scene wiring)

## Art pipeline settings guardrail

Per `docs/art/ART-PIPELINE.md` section 5, project-wide import/render settings
changes require explicit Board approval before landing.
