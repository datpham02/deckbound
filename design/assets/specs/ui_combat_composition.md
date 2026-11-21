# Combat UI composition

| Field | Value |
|---|---|
| Asset ID | `ui_combat_composition` |
| Display name | Combat UI composition |
| Asset class | ui |
| Owner | game-artist, with `ui-designer` (composition and frame sizes, audit F9) |
| Priority | medium (slice piece 6) |
| Status | planned |
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
- Editable source: `art_src/ui/ui_combat_composition.kra`
- Export: `assets/slice/ui/ui_combat_atlas.png`; mockup `assets/slice/ui/ui_combat_mockup_2400x1080.png` (review only)
- Godot resource path and theme: set by `gameplay-programmer` and `ui-designer`; this spec changes no scene or theme.
- Import notes: confirm with `gameplay-programmer`.

## Provenance (fill when made)
- Origin: original (drawn in Krita); generator drafts only if recorded per COMFYUI-WORKFLOW.md
- Tool and version: _pending_
- Model file name and licence: n/a unless a generator is used
- Generation settings: n/a unless a generator is used
- Prompt text: n/a unless a generator is used
- Reference images used as generator input: none
- Editing steps: _pending_
- Licence notes: _pending_
- Originality check: _pending (director)_

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
