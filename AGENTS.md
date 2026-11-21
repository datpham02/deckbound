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
bash ./tests/run_headless_tests.sh      # headless tests (CI/Linux/macOS)
# .\tests\run_headless_tests.cmd        # headless tests (Windows cmd)
godot --headless --path . --quit  # smoke check (required before handoff)
# optional non-zero proof run:
# bash ./tests/run_headless_tests.sh -- --case res://tests/cases/example_failure_case.gd
# .\tests\run_headless_tests.cmd --case=res://tests/cases/example_failure_case.gd
# release signing must come from shell env vars (never commit values):
#   GODOT_ANDROID_KEYSTORE_RELEASE_PATH
#   GODOT_ANDROID_KEYSTORE_RELEASE_USER
#   GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD
godot --headless --path . --export-release Android build/android/deckbound.aab
# optional debug export command:
# godot --headless --path . --export-debug AndroidDebug build/android/deckbound.apk
```

## Android export prerequisites (studio machine, 2026-11-21)

- Godot 4.6.3 editor: present
- Godot 4.6.3 export templates: present
- Android SDK at `%LOCALAPPDATA%\Android\Sdk`: present (build-tools 36.0.0, android-36.1, platform-tools)
- JDK: present only as Android Studio JBR OpenJDK 21
- Debug keystore (`~/.android/deckbound_debug.keystore`): present
- Release signing vars (set in shell only, no committed values): `GODOT_ANDROID_KEYSTORE_RELEASE_PATH`, `GODOT_ANDROID_KEYSTORE_RELEASE_USER`, `GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD`

## Android SDK policy values in this repo

- `export_presets.cfg` sets `gradle_build/target_sdk="36"` (Google Play mobile app requirement effective 2026-08-31):  
  [developer.android.com/google/play/requirements/target-sdk](https://developer.android.com/google/play/requirements/target-sdk) and  
  [support.google.com/googleplay/android-developer/answer/11926878](https://support.google.com/googleplay/android-developer/answer/11926878)
- `export_presets.cfg` sets `gradle_build/min_sdk="24"` (Godot 4.6 Android exporter minimum; Play currently mandates target API but does not publish a mobile minSdk policy value):  
  [godotengine/godot `platform/android/export/export_plugin.cpp` (`DEFAULT_MIN_SDK_VERSION`)](https://github.com/godotengine/godot/blob/4.6-stable/platform/android/export/export_plugin.cpp)

## QA screenshots

Run from repository root:

```bash
godot_console --path . --windowed --scene res://tools/qa/qa_screenshot_runner.tscn --
```

Arguments after `--` are optional and positional:

- `scene_path` (default: `res://scenes/main/main.tscn`)
- `sizes_csv` (default: `1920x1080,2400x1080,2640x1080`)

Output PNGs are written to `.godot/qa/` as `<scene-name>-<W>x<H>.png`.

This tool must run in a normal windowed session. Do not use `--headless` for captures.

## Folder map

- `scenes/` runtime scenes; keep one scene per feature folder.
- `scripts/` runtime scripts; mirror scene folder structure where practical.
- `data/` design-tunable gameplay JSON (pages, enemies, run rules); gameplay numbers live here, not hard-coded in scripts.
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

## Assets and licensing (Board decision 2026-11-22)

- **Allowed:** original work; output of the registered checkpoints
  `sd-xl-base-1-0` (CreativeML Open RAIL++-M; its use restrictions apply) and
  `flux1-schnell-fp8` (Apache-2.0), made through `comfy-draft.py`. PixelFX
  effects only with a Board approval for this project.
- **Not allowed:** third-party art, fonts or textures; any reference image fed
  to a generator; prompts naming another game, studio, artist or character.
- **Provenance:** recorded for every asset in its spec under
  `design/assets/specs/` (model file and licence, seed, prompt, art-ops steps).
- **Review evidence folder:** `assets/slice/review/` (contact sheets,
  target-background previews, before/after, direction sheets). It replaces the
  company default `art_src/review/<TASK-KEY>/` for this project.
- **Direction records:** `docs/art/directions/<asset_family>.md`, one per L2
  direction decision, naming the chosen direction, who decided it and why.
- **Art-direction authority:** `director` decides L2 art-direction choices for
  this project (Board decision 2026-11-22; `docs/art/ART-PIPELINE.md` section 6).

## Art pipeline settings guardrail

Per `docs/art/ART-PIPELINE.md` section 5, project-wide import/render settings
changes require explicit Board approval before landing.
