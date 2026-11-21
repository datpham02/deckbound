# Art Pipeline Audit (Art Phase 0, Step 0)

Status: **proposed** (SOU-33). Needs Board approval before Art Phase 1.
Scope: inspection only. Nothing was installed, configured or changed outside the three Phase 0 documents.
Companions: [ART-PIPELINE.md](ART-PIPELINE.md), [TOOL-DECISIONS.md](TOOL-DECISIONS.md), [ART-BIBLE.md](ART-BIBLE.md), [../concept.md](../concept.md), [../vision.md](../vision.md).

Status words: `present` (seen), `missing` (looked, not there), `not checked` (could not or did not verify).

## 1. What the repository has today

Inspected at `d1d407e` (main after the concept merge).

| Item | State |
|---|---|
| Engine | Godot `4.6.3.stable.official.7d41c59c4` per `AGENTS.md`; `project.godot` has `config/features=PackedStringArray("4.6")`; `.game-studio.yaml` says `4.6.3` |
| Language | GDScript, static typing required |
| Platform target | Android phones on Google Play, landscape (`docs/concept.md`, Board 2026-11-21) |
| Tracked files | 14: agent docs, `docs/`, `icon.svg(.import)`, `project.godot`, `scenes/main/main.tscn`, `scripts/main/main.gd(.uid)`, config dotfiles |
| Assets | None beyond the default `icon.svg`. No textures, atlases, fonts or audio |
| Art source | No `art_src/` folder yet (reserved by `AGENTS.md`) |
| Registry, specs, validators | None |
| Git LFS | `.gitattributes` marks `*.png *.jpg *.webp *.ogg *.wav *.kra *.psd *.blend` as `binary`. No `filter=lfs` entries, so LFS is not configured. The pipeline says not to initialise it without approval |
| Plugins / addons | None (`AGENTS.md`) |
| Existing art docs | Only `ART-PIPELINE.md` (before this Task) |

### Import and render settings (`project.godot`)

| Setting | Current value | Note |
|---|---|---|
| `display/window/size/viewport_width` x `height` | 1920 x 1080 | The concept's design canvas is **2400 x 1080**. Mismatch, see finding F1 |
| `display/window/stretch/mode` | `canvas_items` | Matches the concept |
| `display/window/stretch/aspect` | `expand` | Matches the concept |
| `display/window/handheld/orientation` | not set (default portrait on Android) | The concept needs landscape with both rotations. Finding F1 |
| Renderer (`rendering/renderer/rendering_method`) | not set (Godot default, Forward+) | The concept calls Compatibility the safe default for this device class. Finding F2 |
| Texture compression / VRAM import | not set. No `rendering/textures/vram_compression/import_etc2_astc`, so mobile texture compression is off | Finding F3 |
| Default texture filter | not set (linear). Painterly art is fine with linear; confirm in the Art Bible | none |
| Safe-area / immersive settings | not set | Gameplay work, not art |
| `export_presets.cfg` | missing (not in the repo) | Android export is not set up in the project |
| Default import presets for images | untouched Godot defaults | none |

## 2. Pipeline §4 folders and files

| Path listed in ART-PIPELINE §4 | State |
|---|---|
| `docs/art/ART-BIBLE.md` | **missing**; outline delivered by this Task |
| `docs/art/RENDER-STANDARDS.md` | missing (Phase 1) |
| `docs/art/ASSET-SPEC-TEMPLATE.md` | missing (Phase 1) |
| `design/assets/asset-registry.yaml` | missing |
| `design/assets/specs/` | missing |
| `design/assets/characters/` | missing |
| `design/assets/references/` | missing (required before any moodboard, per §2.1) |
| `tools/asset-pipeline/` | missing |

`AGENTS.md` lists `design/assets/`, `tools/asset-pipeline/` and `art_src/` in its folder map, but none exists in the tree. Git does not track empty folders, so each needs a first file when it is created. Neither the pipeline nor `AGENTS.md` defines `assets/` subfolders (cards, enemies, ui, backgrounds); that is a Phase 1 naming decision.

## 3. Studio machine tools

The permission layer for this run limits shell access to the workspace and blocks running most executables, so only Python could be confirmed. Everything else is `not checked`, not `missing`. An operator can fill the table in with one pass.

| Tool | State | Needed for |
|---|---|---|
| Python 3 | **present** (3.12.10) | validators, atlas checks (pipeline §1) |
| Krita | not checked | primary 2D editor |
| Blender | not checked | optional blockouts and pose references |
| Spine (Essential or Professional licence) and its Godot runtime | not checked; no licence is recorded anywhere | only if the proof of concept passes |
| Image-generation provider (account, subscription, API key) | not checked; provider is still TBD | concept drafts. See TOOL-DECISIONS |
| Godot editor binary on PATH | not checked (version is documented, not verified on this machine) | all |
| Git LFS binary | not checked | only if LFS is approved |
| PixelFX (Board-approved 2026-11-21 for VFX sprites) | not checked | optional pixel-art VFX |
| Image validation libraries for Python (for example Pillow) | not checked | validators |

### Android export prerequisites (studio machine)

Per `docs/concept.md` ("Google Play prerequisites"). Nothing was installed.

| Prerequisite | State | Notes |
|---|---|---|
| Android SDK (platform-tools, build-tools, platform, cmdline-tools) | not checked | Godot 4.6 needs it for export; the required versions are listed in the editor's export documentation and must be read at setup time |
| JDK | not checked | Godot's Android export needs a JDK of a version its docs name; verify then |
| Godot Android export templates (matching 4.6.3) | not checked | |
| Debug keystore | not checked | auto-generated by the SDK/JDK `keytool` setup; needed to run a debug build on a device |
| Release keystore / Play App Signing | not checked, probably missing | Board or build owner; never commit it |
| `export_presets.cfg` with an Android preset | **missing** in the repo | |
| Target Android device (low/mid-range, Android 10+) plus USB debugging | not checked | the concept requires at least one |
| Google Play developer account | not checked | outside this Task |

## 4. Findings

Each item below is a request for a decision or a handoff. This Task does not change any of it.

| ID | Finding | Owner of the fix |
|---|---|---|
| F1 | The project viewport is 1920 x 1080 and orientation is unset, while the concept designs for 2400 x 1080 landscape (both rotations). Art is sized for 2400 x 1080 in the Art Bible | `gameplay-programmer`, with Board approval for project settings (AGENTS.md guardrail) |
| F2 | The renderer is the Godot default, not the Compatibility renderer the concept names as the safe choice on Mali-G52 / Adreno 610 | Board approval, then `gameplay-programmer` |
| F3 | Mobile texture compression is not enabled. Without ASTC or ETC2 import, atlases are stored uncompressed in VRAM, which breaks the 1 GB memory and 100 MB size budgets | Board approval, then `gameplay-programmer`; art side defines atlas sizes in the Art Bible |
| F4 | No Android export preset exists, so no size or performance number can be measured on a device yet | `gameplay-programmer`, first-playable milestone |
| F5 | Spine's proof of concept (pipeline Spine gate) must run on the target Android device, but no export path exists yet (F4) | blocks the Spine decision, see TOOL-DECISIONS |
| F6 | Registry, specs, references and validator folders do not exist. The registry schema, parser and validators belong to `gameplay-programmer`; its content fields belong to `game-artist` | Phase 1 |
| F7 | `art_src/` does not exist, and nothing says where editable `.kra` sources vs exports live relative to `assets/`. Proposed in the Art Bible §Files: `art_src/<class>/` for sources, `assets/<class>/` for exports | Board approval of the Art Bible |
| F8 | No licence or account record exists for any tool or provider | Board |
| F9 | The pipeline describes UI as a Control-node layout, and the concept has a spread view and long-press inspect. Card frame and icon sizes are not specified anywhere yet | `ui-designer` with `game-designer`, Art Bible §Cards |

## 5. Verified commands

- Repository inspection used `git ls-files` and file reads only.
- `godot --headless --path . --quit` was not run in this Task (no code changed; shell execution of Godot is `not checked`).
