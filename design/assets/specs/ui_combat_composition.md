# Combat UI composition

| Field | Value |
|---|---|
| Asset ID | `ui_combat_composition` |
| Display name | Combat UI composition |
| Asset class | ui |
| Owner | game-artist, with `ui-designer` (composition and frame sizes, audit F9) |
| Priority | medium (slice piece 6) |
| Status | art-ready (review pending; see Provenance and Known limitations) |
| Approval state | not approved (approver: director, then Board) |

## Use
- Gameplay use: decorative textures for the combat layout (concept "Combat screen layout"): panel frames, bind-slot frame, end-turn button, counter plates, hand band edge. Text is Godot labels.
- Size on screen: elements tile or 9-slice to the layout; the mockup is 2400 x 1080.
- Region: elements shift inward by the safe-area inset; frames are never one baked full-screen overlay (ART-BIBLE §4.2).

## Canvas
- Mockup (reference only, not shipped): 2400 x 1080, shows hero, two commons, slots, hand and counters.
- Shipped pieces: 9-slice panel source 192 x 192 (corner 48 px); bind-slot frame 160 x 160; end-turn button 256 x 128 in states normal, pressed, disabled; counter plate 192 x 96. All in one atlas of at most 1024 x 1024.
- Background: transparent.
- Pivot / origin: centre, except 9-slice (margins in the registry later).

## Budget
- Texture memory: 1024 x 1024 x 4 = 4 MB uncompressed.
- File size target: atlas PNG at most 600 KB.
- Atlas: one page at most 1024 x 1024.
- Frame count: 3 button states.

## Look constraints
- Palette roles: Stone dark and mid panels, Stone light borders, Paper plates, Ink, Play and Bind accents only on the icons, Danger for telegraph elements.
- Lighting: flat with a soft warm highlight from the upper left.
- Value rule: interactive elements hold the highest local contrast; text on any plate meets 4.5:1.
- Minimum detail: nothing under 3 px; touch targets at least 48 dp (about 125 px) on every tappable piece.
- Colour is not the only carrier: pressed and disabled differ by shape (inset border, crossed edge), not tint alone. No hover state.
- No baked text: yes.

## Animation (D2)
- Approach: static + Godot transform effects (button press, panel fade). Owned by `gameplay-programmer`.
- Reason and integration cost: Control nodes with textures, per pipeline §3.

## Files
- Source deliverables (replace the Krita source): the selected generations (raw, unkeyed) and the per-element PNGs, kept under `art_src/ui/ui_combat_composition/` with provenance. Krita stays optional (deckbound PR #20); a `.kra` file is not required.
- Export: `assets/slice/ui/ui_combat_atlas.png`; mockup `assets/slice/ui/ui_combat_mockup_2400x1080.png` (review only)
- Godot resource path and theme: set by `gameplay-programmer` and `ui-designer`; this spec changes no scene or theme.
- Import notes: confirm with `gameplay-programmer`.

## Provenance (fill when made)
- Origin: generated + scripted cleanup (comfy-draft, comfy-edit matte, art-ops). No own-art img2img or inpaint was used.
- Tool and version: ComfyUI 0.46.0, comfy-draft.py, comfy-edit.py matte, art-ops.py
- Model file name and licence: `flux1-schnell-fp8.safetensors`, Apache-2.0 (as verified 2026-11-22, `AGENTS.md` "Assets and licensing"); matte: `birefnet.safetensors`, MIT (sha256 9ab37426...a356)
- Generation settings: FLUX schnell, 4 steps, euler/simple, cfg 1.0, no negative prompt. Kept pieces and seeds (staging stems `ui_combat_composition_flux_<stamp>_s<seed>_0`, stamps in parentheses): panel 7112 (20261122-182559, 1024x1024); bind-slot frame 7123 (20261122-182659, 1024x1024); band 7401 (20261122-182838, 1024x256); button 7223 (20261122-183044, 1024x512); counter plate 7313 (20261122-183133, 1024x512). Workflow JSON and provenance JSON per image are in `~/game-studio-workspace/staging/art/ui_combat_composition/` (not committed).
- Prompt text (STYLE, then SUBJECT, then the fixed ending): STYLE = "2D hand-drawn illustration, bold uneven black ink outlines, flat cel shading with two or three flat tones, stylised exaggerated proportions, clean flat colour, muted dark palette, no 3D rendering." Subjects: panel "A perfectly square flat decorative panel frame filling the whole picture, seen straight on: a thick border of rough stone-grey blocks in cool grey and slate tones only, with a lighter grey rim on the top and left edge, four heavier corner stones, and a plain empty flat dark slate centre. No orange, no red, no glow, no sheen."; slot "A single square stone socket frame filling the picture, seen straight on: a thick square border of grey stone blocks with a lighter grey rim on the top and left edge, four corner stones, and a plain empty flat dark slate centre, heavy ink outline. No orange, no red, no glow."; band "A long horizontal trim strip filling the picture, seen straight on: one row of grey stone blocks with a lighter grey rim along the top edge, heavy ink outline, a dark slate band below. No orange, no glow."; button "A wide flat push button filling the picture, seen straight on: a thick slab with a flat paper-cream face, a thick grey stone border with a lighter rim on the top and left edge, heavy ink outline, nothing on the face. No orange, no peach, no glow."; plate "A wide flat plaque filling the picture, seen straight on: a plain empty paper-cream rectangle with slightly clipped corners and a thick dark stone-grey border with a lighter rim on the top and left edge, heavy ink outline. No orange, no glow." Ending: "Warm light from the upper left, cool ambient. Plain flat uniform <light grey | dark blue-grey> background, no shadow on the ground, no floor, no text, no signature." Panel, slot and band used the light grey backdrop; button and plate used dark blue-grey, because the cream face matched a light backdrop and the matte rejected it. Deviation from the recipe: square or wide UI shapes instead of 832 x 1216 figures; the new-subject-class gate used the pre-production prompts in the review notes.
- Reference images used as generator input: none
- Editing steps: panel, slot, band: `comfy-edit.py matte --asset ui_combat_composition --input <raw>` (check passed; leftover 0.001%, 0.002%, 0.038%), then `art-ops trim`, `resize --fit stretch` to 192x192, 160x160, 512x64. Button and plate: matte was rejected (leftover 4.649% and 2.77%, not raised); `art-ops key --tolerance 40 --soft 8` (corner colour), `trim`, `resize --fit stretch` to 256x128 and 192x96. Round 1 fix: `grade --saturation 0.6` on button and plate (face closer to Paper); panel interior smudge replaced with a flat patch (`crop` of a clean interior region, `resize`, `compose --at 34 30`). Button states from the normal button: pressed = `grade --brightness 0.45` body plus `resize` 228x108 face `compose --at 14 16` (inset border); disabled = `grade --saturation 0.15 --brightness 0.7` plus a diagonal strike (`mask --polygon 0 118 0 100 256 12 256 30`, `grade --brightness 0.12` layer, `compose --mask`). Atlas: transparent 1024x1024 `canvas`, then `compose` panel at (0,0), slot (200,0), plate (368,0), buttons normal/pressed/disabled at (0,200), (264,200), (528,200), band (0,340). Mockup: 2400x1080 Stone dark base from `contact --no-labels --bg 27 32 38`, then `compose` of the pieces (the panel stretched to 360x440 twice as the enemy panels; three slots, two plates, one button, five band tiles).
- Signature/text check: 2026-11-22, game-artist. Gate: 12 images, 1 marked (plate seed 7301, signature at the lower right) and discarded. Production: 12 + 6 images, 0 marked.
- Images generated: gate 12 (separate budget, limit 12); production 18 (limit 32); no SDXL, no img2img, no inpaint.
- Licence notes: model licences as above; no outside image used; no other game, studio, artist or character named.
- Originality check: _pending (director)_

## Atlas layout (`assets/slice/ui/ui_combat_atlas.png`, 1024 x 1024 RGBA, 209 KB)
Rects are x, y, w, h. Panel 0,0,192,192 (9-slice, corner 48); bind-slot frame 200,0,160,160; counter plate 368,0,192,96; end-turn normal 0,200,256,128; pressed 264,200,256,128; disabled 528,200,256,128; hand band edge strip 0,340,512,64. Pivot centre.
Per-element sources: not committed. `art_src/` is outside this Task's write set, so the atlas is the only shipped source; the elements are the rects above. The raw generations stay in staging. A follow-up Task with `art_src/ui/` in its write set can add them.

## Known limitations (art-ready, not integration-verified)
- Panel, slot and band are neutral grey, not the Stone hue (#3A434B, #6B7780): `art-ops grade` cannot tint. A palette pass or a Godot modulate is needed.
- The 9-slice source was stretched from a 1.4:1 generation to 192 x 192, so corner stones are slightly squashed. A thin dark bar remains at the bottom of the panel interior, where the flat patch ends.
- The band does not tile: its two ends do not match.
- Pieces were stretched, not 9-sliced, in the mockup; the mockup has no Scrivener or enemy art (none exists in this Task) and no hand cards.
- Button faces sit slightly above Paper saturation; text contrast (4.5:1) was not measured with text, only judged by eye on the cream faces.

## Acceptance checklist
- [ ] Layout matches the concept (Scrivener and slots left, enemies right, hand bottom, Ink and deck bottom-left, discard and end turn right)
- [ ] Safe-area shift works for both rotations; pieces tolerate inset
- [ ] Every tappable piece at least 48 dp
- [ ] Text contrast at least 4.5:1
- [ ] Atlas inside budget
- [ ] Provenance complete
- [ ] Originality check passed

## Out of scope
Scenes, themes, scripts, fonts (Godot default font in M1), card frames.
