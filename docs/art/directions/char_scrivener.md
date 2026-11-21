# Direction record: the Scrivener (`char_scrivener`)

Task: SOU-71 (M1 T18b-0). Lane: L2 new visual direction. Author: `game-artist`. Decider: `director` (Board decision 2026-11-22). Status: **proposed, awaiting `director`**. Concept art only; no production export.

Spec and references: `design/assets/specs/char_scrivener.md`, `docs/art/ART-BIBLE.md` §2, §3, §5.

## Traits every direction keeps
1. Reads as a solid dark rounded vertical shape at 25% screen height (270 px on the 1080 canvas).
2. One warm lantern light from the upper left, cool ambient, anchor palette (Ink, Stone, Lantern warm, Paper, Wax).
3. Lantern and book are the accent shapes.
4. Three cord bindings can be drawn at shoulder, chest and hip, told apart by place.
5. Nothing under 3 px at 650 px height; no baked text; no gore.

## Evidence (all under `assets/slice/review/char_scrivener_direction/`)
- `direction_sheet.png`: the comparable sheet (1560 x 1400, background `#1B2026`). One row per direction, rows A, B, C, D from top to bottom. Every row has the same three cells (520 x 350 each, half scale of the 2400 x 1080 canvas):
  1. **Composition:** the hero at 325 px (650 px at full scale) beside a flat grey block of 190 px (the attacker's 380 px at full scale), on a shared baseline.
  2. **Silhouette:** the same figure as a flat black shape at 135 px (25% of screen height at half scale).
  3. **Raw:** the selected generation, unkeyed, with its own backdrop.
- `val_A.png`, `val_BCD.png`, `val_BCD_r2.png`: validation images (see "Process").
- `cand_A.png`, `cand_B.png`, `cand_C.png`, `cand_D.png`: the three FLUX candidates per direction (A's first round, which was rejected for its dark backdrop).
- `cand_A_regen_keytest.png`: A's second round (seeds 1105–1107) keyed onto red to check edges.

## The four directions

| | A Gaunt Clerk | B Bell Cloak | C Satchel Bearer | D Angular Notary |
|---|---|---|---|---|
| Idea | A starved, overworked clerk: all length and stoop | A faceless record-keeper hidden inside a hooded bell of cloth | A short, round, travelling scribe carrying more book than body | A rigid official with the ledger worn like a shell and the lantern held high on a pole |
| Silhouette | Tall thin column, small lantern and book at the hip | One large rounded triangle (bell), book and lantern as small bright inclusions | Round body with a wide hat brim and a big box on the hip | Narrow spike with horizontal pole and angled cap |
| Shape language | Long verticals, straight lines, thin limbs | Soft, heavy, draped curves | Round, soft, bulbous | Sharp angles, points, diagonals |
| Proportions | About 7 heads, lean, stooped | About 5 heads, wide at the base, small head | About 4 heads, wide | About 6 heads, narrow, stiff |
| Image used | `s1106` (FLUX) | `s2203` (FLUX) | `s3304` (FLUX) | `s4402` (FLUX) |

### Analysis per direction

**A Gaunt Clerk**
- *Silhouette at 25%:* reads as a tall thin figure; the lantern is a dot and the book vanishes in the silhouette (see row A, silhouette cell). Weakest of A–D for the "solid rounded shape" trait (it is thin, not rounded).
- *Identity:* the thin stooped clerk is the closest to the Art Bible's "lean, slightly stooped, long coat" wording. The bald pale head and bare feet read as undead, not as a clerk.
- *Lighting and palette:* near-black coat with amber lantern, warm side light plausible; the coat has little value separation from `#1B2026`, so it needs a rim light.
- *Skeleton2D:* **best.** Head, neck, both arms, coat, book and lantern are all separate and clean; thin limbs have few overlaps, so little hidden painting is needed.
- *Conflict:* the Art Bible gives the *binding-frayer* enemy "tall and thin with long hands". A would share a silhouette with that enemy.

**B Bell Cloak**
- *Silhouette at 25%:* the clearest of the four, a solid dark rounded vertical shape with a tapered hood top and a flared hem. Matches the Art Bible "solid black rounded vertical shape" best.
- *Identity:* hidden face, hood and a book held to the chest: an archivist, quiet and a little uncanny, in line with "bureaucratic horror, no gore". Less personality in a pose than C.
- *Lighting and palette:* dark ink cloak, amber lantern at the waist and warm page glow; works with one warm light upper left. Cords are dull red on near-black, so the three binding states will need a lighter cord value and the Bind teal.
- *Skeleton2D:* **workable with care.** `cloak/` is already a spec layer: cloak as one large part with a sway deform, hands and book as separate parts, hood+head as one part. Risk: arms and torso are mostly hidden, so `action_tear_page` has to be told by hands and cloak. Needs a hidden torso painted whole behind the cloak.
- *Enemy overlap:* distinct from the plain attacker (broad and low) and the frayer (tall and thin). Some overlap with the deck-fouler (bulbous) in mass, but the fouler trails paper and has no hood.

**C Satchel Bearer**
- *Silhouette at 25%:* strong, with a distinctive hat and box; but wide and bulbous.
- *Identity:* the most personality and the most readable story (the book is the burden). But a pointed hat with a white beard reads as a generic wizard-gnome, and the tone is warmer and more whimsical than "a quiet, original dark fantasy".
- *Lighting and palette:* coat is near-black, brown satchel gives value contrast; lantern warm. Good value separation from the background.
- *Skeleton2D:* **good.** Satchel, lantern, hat, head, arms and coat are separable; short limbs make overlap simple.
- *Enemy overlap:* its bulbous mass is the deck-fouler's silhouette idea.

**D Angular Notary**
- *Silhouette at 25%:* the weakest: the pole and the cap are thin spikes (under 3 px at 25%), and the figure turns away so the face and book are lost. Not a "rounded" shape.
- *Identity:* very distinct (cap, collar, ledger shell, pole lantern), but formal and cold; the spikes work against the soft "damp stone, lantern" mood.
- *Lighting and palette:* near-black coat, lantern high and left (good), but the whole body is the darkest of the four, so least value separation.
- *Skeleton2D:* **hard.** The pole crosses head, shoulder and arm, so it needs a separate parent bone and heavy overlap painting; the swallow-tail hem needs a segmented chain.

### Candidate selection
For each direction I generated a validation image first, then three seeds, and picked the one that shows the direction best (subject, silhouette, flat backdrop that can be keyed).
- A: `s1106` (clean key, flat book on hip, lantern in hand, cords visible). Rejected `s1105` (limbs too long and green skin), `s1107` (heavier build with apron, loses "gaunt"), and the first round `s1102–s1104` (dark navy backdrop with a lantern glow; it could not be keyed without eating the coat).
- B: `s2203` over `s2202` (backdrop glow, book too small), `s2204` (book and lantern merge).
- C: `s3304` over `s3302` (satchel on back, not hip), `s3303` (lantern floats off the body).
- D: `s4402` over `s4403` (back view, lantern pole hidden), `s4404` (profile, book reads as a backpack).

## Recommendation: **B Bell Cloak**

**Why B**
1. It best satisfies the hard readability rule (vertical solid shape at 25% screen height, spec "Look constraints") and gives the largest dark mass for the warm lantern accent to read against.
2. It gives the Scrivener a silhouette no enemy in the Art Bible list shares (attacker broad and low, frayer tall and thin, fouler bulbous with trailing paper).
3. It fits the setting tone ("bureaucratic horror, no gore, quiet") without a creepy face; `cloak/` and `book/` are layers the spec already names.
4. The three cords sit on a large uncluttered surface at shoulder, chest and hip, so each slot can be told by place.

**Trade-offs of B**
- The face is hidden, so identity comes from hood, book and lantern; expression must be carried by hands and cloak motion. To be mitigated in production by a visible chin and a pale hand with the contract-book.
- The cloak mass hides the torso; the rig needs a cloak mesh with a sway deform and a torso painted whole behind it (spec says each part is painted whole behind its overlap).
- Near-black cloak on `#1B2026` has low value separation: production must use a cool rim light on the right and a warm side light on the upper left, and lighter cords. The lantern should move from the waist to a hand-held or hooked position so it also reads in the silhouette.
- Deviates from the Art Bible "about 5.5 heads, lean, large satchel-book on the left hip" (B is about 5 heads, wide). The Art Bible numbers are marked proposed, so if `director` chooses B, §5 needs a wording update (not made here).

**Why not the others**
- **A:** best rig, but thin (not "rounded"), shares a silhouette with the frayer enemy, and its pale head and bare feet read as undead.
- **C:** most charming, but its wizard-hat-and-beard look is generic and off-tone, and its bulbous mass overlaps the deck-fouler. A good fallback if `director` wants warmth over quiet.
- **D:** weakest silhouette at 25% (thin spikes), hardest rig, lowest value contrast.

## Critique round (1 of 1)
Located issues found on `direction_sheet.png`; no regeneration was spent on them:
1. Rows A and D, hero cell, around the lantern: a pale halo disc remains where the keyed backdrop was enclosed by the lantern; row D also keeps a pale hole inside the pole loop. Cutout artefact, not a design defect.
2. Rows A–D, hero cell, at the feet: pale fringe of the cast shadow. Same cause.
3. All rows: near-black coats on `#1B2026` are low in value separation; this is why the flat-silhouette cell is the test, and why a rim light is a production requirement (see B trade-offs).
4. Row D, silhouette cell: the pole and cap break into thin pieces at 135 px. Counted against D.

**Tool capability failure (cutout only):** the keying tool needs a flat backdrop that differs from the figure; the generators add vignettes, glows and cast shadows, and `art-ops` has no way to edit one region. The result: pale halo and shadow fringes on the preview cutouts. What would fix it: a region-erase or mask tool in `art-ops`, or a generation workflow with a truly flat backdrop. It does not affect the direction decision; the raw column shows the unkeyed images.

## Process and budget
- Validation image first for each direction (SDXL). B, C and D failed it: B was a narrow hooded figure with no bell mass or book, C a cartoon-outline figure with no lantern, D a period gentleman with two canes. The cause was long prompts with SDXL. I rewrote the prompts shorter (key shape first) and used FLUX, which then showed the intended subject. A's SDXL validation was acceptable but A was remade on FLUX so all four use the same model for comparability.
- Prompts are written in parts: subject, composition, lighting, palette, exclusions. No input images; no names of other works.
- **Images generated: 19 of the maximum 48.** SDXL 4 (one validation image per direction), FLUX 15 (B, C, D: 3 each, 9 in all, the first being the FLUX validation image; A: 6 over two rounds).
- Author runs: 1 of 3. Critique round: 1 of 1. Review rounds: 0 of 2.

## Provenance (every image committed or shown on a sheet)
Common: ComfyUI 0.46.0, no input images (`reference_images_as_input: none`), size 832 x 1216, via `comfy-draft.py` (asset `char_scrivener_direction`). Candidates stay in `~/game-studio-workspace/staging/art/char_scrivener_direction/` (not committed). Workflow JSON per image is in the same folder.

- **SDXL:** `sd_xl_base_1.0.safetensors`, licence CreativeML Open RAIL++-M (its use restrictions apply), 25 steps, euler/normal, cfg 7.0, negative prompt "text, watermark, signature, gore, multiple characters, cropped, scenery, busy background".
- **FLUX:** `flux1-schnell-fp8.safetensors`, licence Apache-2.0, 4 steps, euler/simple, cfg 1.0, no negative prompt.
- Licences as verified 2026-11-22 (`AGENTS.md`, "Assets and licensing").

| Image | Model | Seed | Used in | Result |
|---|---|---|---|---|
| `…sdxl_20261122-044835_s1101` | SDXL | 1101 | `val_A.png` | A validation: ok, not used |
| `…sdxl_20261122-044908_s2201` | SDXL | 2201 | `val_BCD.png` | B validation: failed |
| `…sdxl_20261122-044927_s3301` | SDXL | 3301 | `val_BCD.png` | C validation: failed |
| `…sdxl_20261122-044945_s4401` | SDXL | 4401 | `val_BCD.png` | D validation: failed |
| `…flux_20261122-045018_s2202` | FLUX | 2202 | `val_BCD_r2.png`, `cand_B.png` | B validation: ok; not selected |
| `…flux_20261122-045051_s3302` | FLUX | 3302 | `val_BCD_r2.png`, `cand_C.png` | C validation: ok; not selected |
| `…flux_20261122-045115_s4402` | FLUX | 4402 | `val_BCD_r2.png`, `cand_D.png`, sheet row D | **D selected** |
| `…flux_20261122-045152_s1102` / `s1103` / `s1104` | FLUX | 1102–1104 | `cand_A.png` | A round 1: rejected (dark backdrop) |
| `…flux_20261122-045247_s2203` | FLUX | 2203 | `cand_B.png`, sheet row B | **B selected** |
| `…flux_20261122-045247_s2204` | FLUX | 2204 | `cand_B.png` | not selected |
| `…flux_20261122-045325_s3303` | FLUX | 3303 | `cand_C.png` | not selected |
| `…flux_20261122-045325_s3304` | FLUX | 3304 | `cand_C.png`, sheet row C | **C selected** |
| `…flux_20261122-045404_s4403` / `s4404` | FLUX | 4403, 4404 | `cand_D.png` | not selected |
| `…flux_20261122-045606_s1105` / `s1107` | FLUX | 1105, 1107 | `cand_A_regen_keytest.png` | A round 2: not selected |
| `…flux_20261122-045606_s1106` | FLUX | 1106 | `cand_A_regen_keytest.png`, sheet row A | **A selected** |

(The file name stem for all FLUX/SDXL images is `char_scrivener_direction_<model>_<stamp>_s<seed>_0`.)

Image count check: SDXL 4 + FLUX (2202, 3302, 4402, 1102–1104, 2203–2204, 3303–3304, 4403–4404, 1105–1107) 15 = 19.

### Prompts
SDXL (validation round), each with the common SDXL negative prompt above. Shared COMPOSITION tail: "single figure standing, facing right (A: side three-quarter view), whole body visible head to feet, centered, flat plain mid-grey backdrop, painterly concept art." Shared LIGHTING: "one warm lantern glow from the upper left, cool blue-grey ambient fill." Shared PALETTE: "near-black ink purple coat, warm amber lantern light, aged cream paper pages, dull wax red cords, damp slate grey." Shared EXCLUSIONS: "no text, no writing, no gore, no weapons". SUBJECT:
- A (s1101): "full-body character design of a gaunt, very tall thin clerk-scribe, stooped shoulders, long narrow straight ankle-length dark coat, small head, long thin arms, holding a closed thick leather ledger book against the left hip and a small hand lantern in the other hand, three braided cords tied across shoulder, chest and hip."
- B (s2201): "full-body character design of a scribe wearing a huge hooded bell-shaped cloak that forms a wide triangular mass from shoulders to the ground, small hidden face under the deep hood, only hands visible, clutching a large thick ledger book at the chest, a small lantern hanging from a cord at the waist, three braided cords crossing the cloak."
- C (s3301): "full-body character design of a short stocky round-bodied scribe, about four heads tall, wearing a very wide-brimmed round hat, short rounded coat, stubby legs, carrying an enormous oversized book-satchel bulging on the left hip that is nearly as big as the torso, a lantern swinging from a short hook on the satchel strap, three braided cords wrapped around the satchel and belly."
- D (s4401): "full-body character design of an angular notary, medium height, stiff tall pointed collar, tall narrow clerk's cap, sharp angular coat with long split swallow-tail hems and pointed shoulders, straight rigid posture, a thick ledger book strapped flat across the back like a shell, a lantern hanging from a long hooked pole carried over the shoulder, three braided cords crossing the chest in sharp diagonals."

FLUX (all FLUX images), with COMPOSITION "one figure, full body head to feet, facing right, centered, plain flat grey backdrop, dark fantasy digital painting." (A round 2: "background is a perfectly flat uniform light grey, no vignette, no glow behind the figure, digital painting."), LIGHTING "warm amber lantern light from the upper left, cool blue ambient.", and PALETTE "near-black coat (B: cloak; C: coat and hat), amber, cream pages, dull red cords." SUBJECT and EXCLUSIONS:
- A (s1102–1104, round 1): "a very tall gaunt thin scribe, six and a half heads tall, stooped shoulders, long narrow straight ankle-length black coat, small head, long thin arms, a closed thick ledger book held against the left hip, a small glowing lantern in the right hand, red cords tied across shoulder, chest and hip." Exclusions: "no text, no gore, no weapons, no staff".
- A (s1105–1107, round 2, selected `s1106`): same subject; exclusions add "no second lantern".
- B (s2202–2204): "a scribe in a gigantic dark hooded cloak shaped like a wide bell, the cloak is a huge dark triangle from the head down to the ground, tiny face in shadow, both hands hold a large leather book at the chest, a glowing lantern hangs at the waist." Exclusions: "no text, no gore, no weapons, no staff".
- C (s3302–3304): "a short plump scribe, four heads tall, huge round wide-brimmed hat, short dark round coat, an enormous bulging book-satchel on the left hip as big as his torso, a glowing lantern hanging from the satchel strap, red cords tied around the satchel." Exclusions: "no text, no gore, no weapons, no cartoon outline".
- D (s4402–4404): "a sharp angular notary in a black coat with pointed shoulders and long split swallow-tail hems, very tall stiff pointed collar, tall narrow pointed cap, a thick ledger book strapped flat on the back like a shell, a glowing lantern on a long hooked pole over the shoulder, red cords crossing the chest in sharp diagonals." Exclusions: "no text, no gore, no weapons, no canes".

### Editing steps (review images only; `art-ops.py`, from the Task Workspace root)
- Cutout: `key <raw> <out> --tolerance 35 --soft 8` (auto corner colour); `trim`; `resize --size 260 325` (hero) and `--size 300 135` after `grade --brightness 0` (silhouette); enemy block: `resize --size 110 190 --fit stretch` then `grade --contrast 0 --saturation 0`; `canvas --anchor bottom_center` for a shared baseline; `sheet --cols 2 --cell 260 350` (composition), `sheet --cols 3 --cell 520 350` (all rows); `contact --bg 27 32 38 --no-labels` for the final sheet. Candidate and validation sheets: `contact --cell 416 608 --bg 27 32 38`.
- The raw cells are unkeyed generations; their backdrop is the generator's, not `#1B2026`.

## Skeleton2D feasibility, summary
| Direction | Verdict | Main risk |
|---|---|---|
| A | Best | Thin parts; weak silhouette at 25% |
| B | Workable | Hidden torso; cloak deform |
| C | Good | Hat and satchel overlap the head and arm |
| D | Hard | Pole crosses the body; segmented hem |
This is a judgement on the concept images, not an atlas or rig.

## Limitations
- Concept images are not production parts; none are exported to `assets/slice/` outside the review folder.
- Cutouts have pale halo and shadow fringes (see critique).
- No formal originality check was run. No prompt names any other work and no reference image was used; the originality check is for `director` and `qa`.

## Decision
_To be filled only with what `director` decides: chosen direction, decided by, date, reason, rejected directions._

(Not decided yet.)
