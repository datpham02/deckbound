# Art Tool Decisions (Art Phase 0)

Status: **proposed** (SOU-33). Every row marked "Board" needs Board approval. Nothing here is installed, purchased or adopted.
Companions: [ART-PIPELINE.md](ART-PIPELINE.md), [ART-PIPELINE-AUDIT.md](ART-PIPELINE-AUDIT.md), [ART-BIBLE.md](ART-BIBLE.md), [../concept.md](../concept.md).

## How to read this

- **Evidence limit.** This Task had no web or machine access to confirm vendor terms, prices or runtime versions. Facts about vendors below are general knowledge, flagged *verify*. Each *verify* item must be checked against the vendor's current published terms, and the check recorded in the decision record, before adoption. Nothing here is a legal conclusion.
- **Platform constraints** (from the concept): Android phone, landscape, low/mid-range (3-4 GB RAM, Mali-G52 / Adreno 610), 60 fps, download under 100 MB at first playable and 150 MB at release, peak memory under 1 GB, AAB export.
- Scores: **++** strong, **+** fine, **0** neutral, **-** weak, **?** unknown until verified.

## Android budgets that drive every decision below

These are art-side targets proposed for Board approval. `gameplay-programmer` confirms the engine settings.

| Budget | Proposed target | Reason |
|---|---|---|
| Install size for all art | 60 MB of the 100 MB first-playable download (the rest is code, audio, engine) | concept size budget |
| Texture memory resident in combat | 250 MB at most | 1 GB peak for the whole app, with headroom for the OS |
| Atlas page size | 2048 x 2048 maximum, power-of-two. 4096 only with approval | broad mobile GPU compatibility and lower memory spikes |
| GPU texture format | ASTC where supported, ETC2 fallback (Godot's `import_etc2_astc`). Needs the project setting from audit F3 | PNG on disk is not what is held in VRAM; uncompressed RGBA at 2048 x 2048 is 16 MB per page |
| Card illustration | authored at spread size (about 700 x 900 px), no larger | concept: card art at spread size, never print resolution |
| Full-screen background | 2400 x 1080 (plus a safe overscan strip for 22:9; Art Bible) | design canvas |
| Combat overdraw | few full-screen alpha layers, effects capped per combat | Mali-G52 / Adreno 610 fill rate |

## (a) Image-generation provider

Pipeline §1: provider is TBD; it must be chosen on licensing, commercial use, privacy, consistency, cost and the user's subscriptions. Pipeline §2.1 forbids feeding reference images into any generator, and `AGENTS.md`-level rules forbid assets with unclear provenance.

No provider is named in the Task, and I cannot confirm any provider's current terms. The matrix is therefore by **provider type**, with the questions that must be answered before any named product is adopted.

| Criterion | Hosted commercial service (subscription or API) | Open-weights model run on the studio machine | Commissioned or hand-painted art only (no generator) |
|---|---|---|---|
| Commercial-use terms | ? Varies by plan; some plans restrict commercial use or require a paid tier. *Verify* the exact plan | ? Licence depends on the model; many allow commercial use, some do not. *Verify* the model and its weights licence | ++ Contract terms are explicit |
| Output ownership and copyright | ? Ownership claims differ; AI-only output has uncertain copyright protection in several jurisdictions | ? same | ++ |
| Training-data provenance | ? Providers differ in how they document it. *Verify* any indemnity offered | - Often unclear | ++ |
| Privacy | 0 Prompts and uploads go to a third party. *Verify* retention and training-on-your-data settings | ++ Stays local | ++ |
| Style consistency across a set | + Reference/style features exist but §2.1 forbids using game references as inputs. Consistency must come from our own originals | + Local fine-tuning is possible, but only on our own approved art, never on reference-game images | ++ with one artist |
| Cost | 0 Subscription or per-image; unknown until a plan is chosen | 0 Hardware time; the studio GPU is `not checked` | - Highest per asset |
| Android pipeline fit | + Output is a PNG draft; refinement happens in Krita | + same | + |
| Setup effort | ++ | - GPU, model downloads, installs, all needing approval | + |

**Recommendation (Board decides):** allow a hosted commercial service **only for concept drafts**, refined or replaced in Krita before anything ships. Do not name one until Board has (1) checked commercial-use terms and plan, (2) confirmed prompts and uploads may leave the studio, and (3) recorded the plan, version and date. If those checks cannot be passed, fall back to hand-painted work in Krita for card art, which is slower but has no provenance risk. Either way:
- Prompts use original design details only (pipeline §5 Step 4).
- No reference image, our moodboard included, is ever an input.
- Each asset's provenance records the tool, version, settings and prompt, per the Game Artist rules.
- This Task does not create any account.

**Board question:** which provider (or none), on which plan, and are prompts allowed to leave the studio?

## (b) Animation: Spine vs Godot Skeleton2D vs frame animation

Pipeline §1 says adopt Spine only after a proof of concept in the real Godot project; §3 limits rigs to recurring and high-visibility assets; the concept limits rigs to the Scrivener and bosses and uses short frame animation for common enemies.

| Criterion | Spine 2D | Godot Skeleton2D (Bone2D + Polygon2D, AnimationPlayer) | Frame-by-frame sprite animation | Static + Godot transforms (tweens, shaders) |
|---|---|---|---|---|
| Authoring cost per character | + Strong tool: meshes, weights, IK, events | 0 Rigging inside the Godot editor. Basic, but enough for a few bones | - Every frame is painted | ++ none |
| Mesh deformation quality | ++ | + Polygon2D bones with weights. Less polished than Spine | n/a (each frame is hand-drawn) | - |
| Runtime on low-end Android | ? Skeletal runtimes are normally light, but this runtime's cost on Mali-G52 must be **measured** | + Native to the engine, no extra binary. Cost scales with polygon count | ++ trivial CPU, but memory grows per frame | ++ |
| Install size | ++ Small data files, shared atlas | ++ same texture reuse | - Many frames multiply texture size | ++ |
| Engine and export dependency | - Needs the Godot runtime from Esoteric Software, which may require custom engine or export templates for Godot 4.6.3, and AAB compatibility must be confirmed. *Verify* current support | ++ built in | ++ built in | ++ |
| Licence and cost | - Paid editor licence. *Verify* the licence tier needed for commercial release and what the runtime terms require | ++ free | ++ free | ++ free |
| Event markers (hit frames, sounds) | ++ native events | + AnimationPlayer method tracks | + via AnimationPlayer or frame signals | + |
| Fit for the Scrivener (bindings drawn into the silhouette, must stay readable) | ++ if it passes the PoC | + likely enough, because bindings can be separate sprites parented to bones | + | - |
| Fit for common enemies | - over-engineered | 0 | ++ short loops (idle, telegraph, attack, hit, death) | + for minor enemies |
| Risk | Integration and licence risk, unproven on the target device | Quality ceiling | Texture memory and artist time | Looks cheap if overused |

**Recommendation (Board decides):**
1. **Default now:** Godot Skeleton2D for the Scrivener and bosses; short frame animation for common enemies; static art + tweens for cards, icons and minor props. No licence spend.
2. **Spine stays an option, not a commitment.** Run the pipeline Spine gate on **one** character **only** after an Android export exists (audit F4), measured on a target-class phone, and only if the Board approves buying a licence for the test. Adopt it only if it clearly beats Skeleton2D on quality or authoring time and passes size, frame-rate and AAB checks.
3. The decision per asset is recorded in its spec (pipeline Step 3).

**Not done in this Task:** the Spine proof of concept. It needs a Spine licence, the runtime and an Android export, none of which exist or may be installed here. Pipeline §8 asked to "test feasibility without committing"; this document gives a desk assessment only, and the test is a Phase 1 item.

**Board question:** approve Skeleton2D as the default, and approve (or defer) a Spine licence for one Phase 1 test?

## (c) Editing, 3D and support tools

| Tool | Role | Decision | Notes |
|---|---|---|---|
| Krita | Primary 2D editor: paintover, cleanup, layered `.kra` sources | Keep (pipeline). Free and open source. *Verify* the installed version | Sources go to `art_src/`, binary in git per `.gitattributes` |
| Blender | Optional blockouts and pose references | Keep as optional, no install pre-approved | Reference only; never shipped as 3D |
| Python 3 | Validators: dimensions, naming, atlas sizes, alpha | Keep. **present**, 3.12.10. Validators belong to `gameplay-programmer` (pipeline tooling) | `game-artist` supplies the art-side rules (Art Bible) |
| Git LFS | Large binary art | **Defer.** Not configured. Source `.kra` files can grow; revisit when `art_src/` passes a size threshold the Board sets (suggest 500 MB total) | Needs approval to initialise |
| PixelFX | Pixel-art VFX sprites | Allowed where installed, but the visual direction is painterly, so use only where the Art Bible's VFX rules allow it | Provenance must record its use |
| Texture packing / atlas tool | Packing sprites into atlases | **Open.** Godot's import plus a validator script may be enough; choose in Phase 1 | `gameplay-programmer` |
| Godot 4.6.3 | Runtime | Keep. Android export needs the items in audit §3 | |

## Decision summary for the Board

| # | Decision | Recommendation |
|---|---|---|
| D1 | Image-generation provider and plan | Name none yet. Confirm commercial terms and privacy first; use it for drafts only; hand-paint otherwise |
| D2 | Animation default | Godot Skeleton2D (Scrivener, bosses) + frame animation (common enemies) |
| D3 | Spine | Not adopted. One Android-measured proof of concept in Phase 1, if a test licence is approved |
| D4 | Android texture and atlas budgets | Approve the table above, subject to `gameplay-programmer` confirmation |
| D5 | Project settings (audit F1-F3): 2400 x 1080 viewport, landscape, Compatibility renderer, ASTC/ETC2 | Request Board approval; `gameplay-programmer` implements |
| D6 | Git LFS | Defer; threshold above |

Phase 0 ends here. No Phase 1 work starts until the Board approves or amends these decisions.
