# Graphics Pipeline — Slay-the-Spire-2-Inspired Single-Player Game

## Decision

**Style target:** close to the visual language of Slay the Spire 2, without copying its protected artwork, characters, card illustrations, UI assets, names, animation, or other expressive content.

**Production priority:** balanced — prioritize a coherent, high-quality result while keeping the workflow practical for a small AI-assisted team.

**Scope:** single-player only. No multiplayer-specific visual, UI, networking, or production requirements.

**Recommended production model:** 2D illustrated assets + selectively rigged 2D skeletal animation + Godot composition/effects. Use Blender only when a specific asset benefits from 3D blockout, pose reference, or controlled rendering. Do not make full 3D production the default.

## 1. Toolchain

### Core tools

| Tool | Purpose | Policy |
|---|---|---|
| Godot 4.x | Game runtime, scenes, UI, animation playback, particles, shaders, asset integration | Primary engine; verify exact project version before configuring |
| Krita | Paintovers, cleanup, masks, texture edits, card art and background corrections | Primary 2D art editor |
| Blender | Optional 3D blockouts, pose references, turnarounds and controlled renders | Use only where it saves time or improves consistency |
| Spine 2D | Optional skeletal rigging/animation for recurring characters and enemies | Adopt only after a short import/export proof of concept in the actual Godot project |
| Git + Git LFS (if needed) | Versioning source art and large binary assets | Follow existing repository conventions; do not initialize or reconfigure without approval |
| Python tools | Asset validation, atlas preparation, naming/dimension checks, batch conversion | Scripts may be authored by Claude; never silently overwrite approved source assets |

### Image generation

**Board decision 2026-11-22: AI makes the final art.** The local ComfyUI (D1: FLUX.1 schnell and SDXL, text-to-image only) produces final illustrations as well as concepts. A generated image becomes final art through selection, regeneration for consistency and scripted operations (colour-key, trim, resize, grade, sprite sheets: `art-ops`), not through a required human paintover in Krita. Krita stays available for optional hand fixes. Every asset still passes Director review (originality, Art Bible) and Board approval by eye. Known trade-off accepted by the Board: purely AI-generated images may get no copyright protection in some jurisdictions.

Do not assume Claude Code itself is the image generator. Claude Code should orchestrate prompts, files, validation and integration around a separately selected image-generation tool.

### Spine decision gate

Do not commit the project to Spine immediately. First test one representative character:
1. Create a clean layered source image.
2. Rig a small set of bones and deformable meshes.
3. Export using a supported runtime/data format.
4. Import into the actual Godot version and target platform.
5. Check draw order, deformation, animation events, performance, licensing and authoring effort.

If the integration or license cost is not justified, use Godot's built-in 2D skeletal animation options or frame-based sprite animation for that asset class.

## 2. Visual direction

Aim for these high-level qualities:
- Dark fantasy atmosphere with readable silhouettes.
- Painterly, hand-illustrated character and card art.
- Restrained, coherent palette and deliberate value contrast.
- Distinctive shapes and silhouettes for enemies, heroes and relics.
- Clear focal hierarchy: gameplay information first, decoration second.
- Character motion with deliberate anticipation, impact, recoil and recovery.
- UI that is legible at the intended mobile/desktop resolution.

These are design principles, not instructions to reproduce Slay the Spire 2 assets. All game-specific art, compositions, silhouettes, card names, text, symbols and UI treatments must be original.

### 2.1 Reference policy

Referencing Slay the Spire 2 (and other games) for visual study **is allowed and encouraged**, within these rules.

**Allowed reference sources:**
- Official trailers, store-page screenshots, press kits and developer posts.
- Public gameplay videos and streams.
- Screenshots and screen recordings captured by the team while playing a **legally owned** copy (e.g. purchased on Steam).
- Art books, interviews and talks published by the developer.

**Allowed uses:**
- Analyze palette, value structure, lighting, composition, silhouette readability, UI hierarchy, animation timing and VFX feel.
- Build internal moodboards and reference sheets (internal use only, never shipped, never used as image-generation input/img2img/style-training data).
- Write the findings into the Art Bible as **general principles** (e.g. "enemy silhouettes read at 25% screen height", "background two value steps darker than characters"), not as descriptions of specific assets.

**Not allowed:**
- Using pirated or unofficial copies of the game in any form.
- Extracting, unpacking, decompiling or ripping files from the game install (textures, sprites, `.pck`/archives, animation data, shaders, audio, code), even "only for reference".
- Tracing, paintover or photo-bashing on top of reference images.
- Feeding reference images into image-generation tools as input, style reference or training data.
- Reusing names, card text, character designs, icons, symbols or UI layouts one-to-one.

Each moodboard/reference sheet records its sources (URL or "own capture, legally owned copy, date") in `design/assets/references/`.

## 3. Asset classes and production method

| Asset class | Preferred method | Animation / integration |
|---|---|---|
| Player character | Original layered illustration; selective 2D rig | Idle, attack, hit, defend, death/defeat as required |
| Common enemies | Original illustration; rig only for recurring/high-visibility enemies | Idle, intent/telegraph, attack, hit, death |
| Bosses | Higher-detail original illustration; selective rig or limited frame animation | Telegraph, major attack, hit, phase transition, defeat |
| Card illustrations | Original generated illustration, selected and cleaned up by script (Board 2026-11-22) | Static; use Godot for hover, play and combat feedback |
| Relics, potions, icons | Consistent icon family, generated or drawn, cleaned up by script | Static with lightweight UI feedback |
| Environments | Layered painted backgrounds and props | Parallax only where it adds value |
| VFX | Godot particles, shaders, procedural effects, small hand-authored sprites | Runtime effects |
| UI frames and panels | Godot Control nodes + original decorative textures | Runtime layout and state transitions |

Do not rig every asset. Rig only assets whose reuse, screen time or motion quality justifies the setup cost.

## 4. Art Bible and asset specifications

Before bulk production, create and maintain:

- `docs/art/ART-BIBLE.md`
- `docs/art/RENDER-STANDARDS.md`
- `docs/art/ASSET-SPEC-TEMPLATE.md`
- `design/assets/asset-registry.yaml`
- `design/assets/specs/`
- `design/assets/characters/`
- `design/assets/references/`
- `tools/asset-pipeline/`

Use the repository's existing equivalent paths and conventions if they already exist. Do not duplicate or replace existing art documentation.

Each asset spec should record:
- Stable asset ID and display name.
- Asset class, owner and priority.
- Intended gameplay/UI use and screen size.
- Canvas dimensions, aspect ratio, safe area and transparent/opaque background.
- Layer naming and required separated parts if rigging is planned.
- Palette/material/lighting constraints.
- Animation states, frame rate, duration and event markers if applicable.
- Export format, import settings, pivot/origin and Godot resource path.
- Source/provenance, generation/editing history and license notes.
- Acceptance checklist and approval state.

Keep source files separate from generated exports. Never overwrite the only editable source with a flattened or compressed output.

## 5. Claude Code workflow

Claude Code acts as production coordinator and technical art assistant, not as an autonomous art director with approval authority.

### Step 0 — Inspect before changing

Claude must:
1. Inspect the existing repository, Godot version, art folders, asset registry, render standards and current asset pipeline.
2. Identify existing conventions and reuse them.
3. Report missing tools, extensions, runtimes or licensing dependencies.
4. Avoid installing tools, changing global configuration, changing project settings or modifying runtime code without explicit approval.

Deliverable: `ART-PIPELINE-AUDIT.md`.

### Step 1 — Establish visual direction

Game Designer + Game Artist propose:
- Art pillars and palette.
- Character proportions and silhouette rules.
- Linework, texture and lighting approach.
- Card-art composition rules.
- UI readability rules.

Produce a small visual target pack with original examples: one hero, one common enemy, one boss, one card illustration, one relic, one background and one UI screen.

Human/Board approval is required before scaling production.

### Step 2 — Create a representative vertical art slice

Create only a small, representative sample:
- 1 player character with one idle and one action animation.
- 2 visually distinct common enemies with one key action each.
- 1 card illustration.
- 1 relic icon.
- 1 combat background.
- 1 combat UI composition.
- 1 simple VFX effect.

Test the complete pipeline from source creation through export, Godot import, runtime display and target-resolution review.

Do not produce a large asset batch before the slice passes review.

### Step 3 — Choose animation implementation per asset

For each asset, Claude proposes one of:
- Static illustration + Godot transform effects.
- Frame-based sprite animation.
- Godot 2D skeletal animation.
- Spine 2D rig.

Choose the simplest approach that meets the quality bar. Record the reason and integration cost in the asset spec.

### Step 4 — Generate, refine and approve assets

For each asset:
1. Read the relevant Art Bible and asset spec.
2. Prepare a prompt using original design details, not copied game content.
3. Generate concept candidates using the selected image tool.
4. Compare candidates against silhouette, palette, composition and readability requirements.
5. Refine: regenerate for consistency and clean up with `art-ops` (optional hand fixes in Krita).
6. Separate layers and prepare rigging only if needed.
7. Export to a staging directory.
8. Run validation scripts.
9. Show a contact sheet or in-engine preview for human review.
10. Promote to approved/production only after explicit approval.

Suggested status flow:
`planned → concept → review → approved → integrated → verified`

A rejected asset returns to `concept` or `review`; it must not be silently promoted.

### Step 5 — Integrate into Godot

Claude may:
- Create/update asset registry entries.
- Prepare import metadata and resource references.
- Create or update scenes only within an approved task scope.
- Connect animation states and VFX to gameplay events.
- Add preview scenes for isolated visual QA.
- Run approved, non-destructive validators.

Claude must not:
- Change gameplay rules while performing an art task.
- replace approved assets without approval.
- silently change project-wide rendering/import settings.
- add plugins or paid dependencies without approval.
- claim an asset is verified without an actual preview/test result.

### Step 6 — Visual QA

Check:
- Correct dimensions, aspect ratio, alpha and pivot.
- Readability at actual gameplay scale.
- Silhouette clarity against every intended background.
- Palette and lighting consistency.
- Animation loops, timing, deformation and draw order.
- UI overlap, clipping, scaling and text legibility.
- Import warnings, missing resources and runtime errors.
- Performance of rigged characters and VFX on the target device.

QA reports `pass`, `fail` or `not tested`; do not convert missing evidence into pass.

## 6. Department responsibilities

- **Director / Board:** approves visual direction, budget and major scope changes.
- **Producer:** owns asset priorities, capacity and milestone risk.
- **Project Manager:** breaks work into asset tasks, dependencies and review queues.
- **Game Designer:** defines gameplay purpose, visual readability and telegraph requirements.
- **Game Artist:** owns visual concepts, illustration, cleanup, consistency and source files.
- **Gameplay Programmer:** owns Godot integration, animation triggers, scene wiring and runtime VFX.
- **UI Designer:** owns card frames, combat layout, icons and UI visual hierarchy.
- **QA Engineer:** verifies asset correctness, visual behavior and runtime integration.
- **Web Engineer:** not involved unless a separately approved web deliverable requires it.

One asset has one accountable owner. Game Artist cannot self-approve final production assets; approval follows the project's existing human-only policy.

## 7. Claude task template

Every art task should include:

- **Asset ID:**
- **Gameplay purpose:**
- **Reference documents to read:**
- **Original design description:**
- **Required deliverables:**
- **Canvas / dimensions / aspect ratio:**
- **Palette / lighting / silhouette constraints:**
- **Animation states (if any):**
- **Godot target path:**
- **Validation commands allowed:**
- **Acceptance criteria:**
- **Approval required from:**
- **Explicitly out of scope:**

Claude must return:
1. Files created or changed.
2. Source and export paths.
3. Tool/model and relevant version.
4. Validation results and preview evidence.
5. Known limitations.
6. Approval status.
7. Confirmation that unrelated project files and runtime settings were not changed.

## 8. Rollout plan

### Art Phase 0 — Audit and decisions
- Inspect current project and pipeline.
- Confirm engine version and target platforms.
- Confirm image-generation provider and licensing.
- Test Spine/Godot integration feasibility without committing to adoption.
- Deliver audit, tool decision matrix and proposed Art Bible outline.
- Stop for approval.

### Art Phase 1 — Art Bible and vertical slice
- Approve visual pillars.
- Create representative sample assets.
- Prove source → refine → animate → export → Godot → QA.
- Measure time and cost per asset.
- Stop for approval before bulk production.

### Art Phase 2 — Production pipeline
- Finalize templates, registry, validators and naming conventions.
- Produce assets in small approved batches.
- Review each batch before the next.

### Art Phase 3 — Polish and optimization
- Improve animation timing, VFX, UI transitions and readability.
- Optimize atlases, texture sizes and runtime performance.
- Complete target-device visual QA.

## 9. Explicit non-goals and safety boundaries

- No multiplayer art, UI, avatars, lobbies, social features or network states.
- No copying or extracting Slay the Spire 2 assets, source code, card text, names, characters, environments, animations or UI.
- Visual reference is allowed under §2.1 (public materials and captures from a legally owned copy).
- No pirated/unofficial game copies, and no reverse engineering or asset extraction from any game install.
- No tool installation, account creation, subscription purchase or global configuration change without approval.
- No large-scale asset generation before the visual direction and vertical slice are approved.
- No agent self-approval of production art.
- No implementation beyond the currently approved phase.

## 10. Definition of done for the first pipeline milestone

The first milestone is complete only when:
- Existing project conventions have been audited.
- Art Bible and asset-spec templates are approved.
- One representative vertical art slice passes visual review.
- Godot import/runtime integration is demonstrated.
- Animation approach and toolchain are chosen based on evidence.
- Provenance and approval states are recorded.
- Cost/time estimates for a small production batch are documented.

This milestone does not authorize full asset production or unrelated gameplay implementation.
