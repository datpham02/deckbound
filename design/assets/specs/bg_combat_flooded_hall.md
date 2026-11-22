# Combat background: flooded hall

| Field | Value |
|---|---|
| Asset ID | `bg_combat_flooded_hall` |
| Display name | Combat background: flooded hall |
| Asset class | background |
| Owner | game-artist |
| Priority | medium (slice piece 5) |
| Status | art-ready candidate (review) |
| Approval state | not approved (approver: director, then Board) |

## Use
- Gameplay use: the single combat background for the first floor.
- Size on screen: full-bleed.
- Region: lanes for the Scrivener (left third), play area, and enemies (right two thirds) are kept clear of busy detail. Nothing important in the overscan strip or the outer 16:9 crop margin.

## Canvas
- Dimensions: 2640 x 1080 (2400 canvas plus 120 px overscan per side, for 22:9; ART-BIBLE §4.1).
- Safe area / overscan: the centre 1920 x 1080 holds all composition anchors.
- Background: opaque.
- Pivot / origin: centre.

## Budget
- Texture memory: 2640 x 1080 x 4 = about 11.4 MB uncompressed (about 2.9 MB as ASTC 4x4, estimate; confirmed by `gameplay-programmer`).
- File size target: PNG at most 3.5 MB. Actual: 1,309,779 bytes (1.31 MB), inside budget.
- Atlas: stands alone (over 2048 wide, so it is not packed; needs a note for `gameplay-programmer` on texture limits).
- Frame count: 1.

## Look constraints
- Palette roles: Water black, Stone dark and mid, Stone light rim, Lantern warm (one light source).
- Lighting: one warm lantern from the upper left, cool ambient, black water reflecting it.
- Value rule: two value steps darker than characters. No high-contrast shapes behind the lanes.
- Minimum detail: nothing under 3 px; texture is low-frequency, so characters and telegraphs win.
- Colour is not the only carrier: n/a.
- No baked text: yes.

## Animation (D2)
- Approach: static illustration. No parallax in the slice (Art Bible: only where it adds value). Optional water shimmer by Godot shader, owned by `gameplay-programmer`.
- Reason and integration cost: one opaque layer keeps overdraw low.

## Files
- Source deliverables (replace the Krita source): the selected generation(s), kept under `art_src/backgrounds/bg_combat_flooded_hall/` with provenance. Krita stays optional (deckbound PR #20); a `.kra` file is not required.
- Export: `assets/slice/backgrounds/bg_combat_flooded_hall.png`
- Godot resource path: set by `gameplay-programmer`.
- Import notes: confirm with `gameplay-programmer`.

## Provenance (fill when made)
- Origin: generated + scripted cleanup (no paintover)
- Tool and version: ComfyUI 0.46.0, art-ops
- Model file name and licence: `flux1-schnell-fp8.safetensors`, Apache-2.0
- Generation settings: seed 2202, steps 4, sampler euler, scheduler simple, cfg 1.0, size 1344 x 576, workflow `bg_combat_flooded_hall_flux_20261122-085010_s2202.workflow.json` (staging)
- Prompt text: "wide empty flooded stone hall interior, damp dark stone walls and arches, still black water covering the floor, a single warm lantern glow in the upper left casting soft amber light, faint reflection on the water, cool blue-grey ambient shadow, large calm empty dark areas in the middle and right, low frequency texture, painterly, muted restrained palette, side view 2D game background, no characters, no text" (negative prompt: n/a for FLUX)
- Reference images used as generator input: none
- Editing steps: `resize --size 2640 1080 --fit cover` (centre crop) -> `round0_resized.png`; `grade --saturation 0.8 --contrast 0.85 --brightness 1.0` -> export. Round 1 (saturation 0.55) rejected: lantern lost its warmth.
- Candidates (5 images of the 32 budget): SDXL seeds 1101-1103 rejected (bright daylight windows and light shafts, high-contrast shapes behind the lanes, no lantern); FLUX seed 2201 rejected (large hanging lantern with foliage is a high-contrast shape top left, busy right arches); FLUX seed 2202 selected. Sheet: `assets/slice/review/bg_combat_flooded_hall/candidates.png`.
- Licence notes: model output, no input images; licence per AGENTS.md "Assets and licensing".
- Originality check: _pending (director)_
- Evidence: `assets/slice/review/bg_combat_flooded_hall/contact.png` (round 0 | round 1 | final)
- Known limitations: lantern is mid-height on the left wall, not at the top; hue is cooler teal than the neutral Stone anchors; the PNG has an alpha channel (all 255); the numeric value range was not measured. Tool capability failure: no approved tool measures the value range (`art-ops` has only info/crop/resize/key/trim/canvas/sheet/grade/contact; none reports luminance or a histogram) - a `stats` or `histogram` command in `art-ops` (mean luminance and percentiles, compared to the Art Bible section 3 anchors) would fix it. Judged by eye on `contact.png`: clearly darker than the character anchors.

## Acceptance checklist
- [x] 2640 x 1080 opaque (alpha all 255); `art-ops info`: 2640x1080 mode=RGBA alpha_bbox=(0, 0, 2640, 1080). Centre composition judged by eye on `contact.png`
- [ ] Value range two steps darker than characters: UNVERIFIED - no approved tool measures it (see Known limitations); by eye only
- [ ] Hero and both commons keep a clear silhouette against it: UNVERIFIED - deferred to SOU-61: readability of the Scrivener, enemies and telegraphs over this background
- [ ] Holds at 16:9, 20:9 and 22:9 with no letterbox: UNVERIFIED - deferred to SOU-61: crops in the engine
- [x] Size and memory inside budget (1,309,779 bytes of 3.5 MB; 11.4 MB texture memory estimate)
- [x] Provenance complete
- [ ] Originality check passed: pending (director)

## Out of scope
Parallax layers, props, other screens, shaders.
