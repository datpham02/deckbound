class_name CombatHudSettings
extends Resource
## Display tunables for the T13 combat HUD: telegraph icon and number sizes,
## fray and sever line style and colours, slot text sizes and the pulse cap.
##
## Gameplay numbers (Ink, hand size, slot count, enemy values) are never stored
## here: the HUD reads them from the combat state, which is built from data/.
## Display numbers can be overridden without a code change by an optional
## res://data/ui/hud.json whose keys are the property names below (ints,
## floats, or colours as "#rrggbb" strings); see load_default().

const DATA_OVERRIDE_PATH: String = "res://data/ui/hud.json"

## Side of the telegraph icon above an enemy's head, in canvas pixels.
@export var telegraph_icon_px: int = 88
## Font size of the telegraph number (Art Bible 4.4: 20 sp or larger; 56 px is
## about 21 sp on the 2400 x 1080 canvas).
@export var telegraph_number_font_px: int = 56
## Side of the bind-slot state icon, in canvas pixels.
@export var slot_icon_px: int = 48
## Font size of the slot name and state word (31 px is the tertiary minimum).
@export var slot_text_font_px: int = 31
## Width of the fray and sever lines, in canvas pixels.
@export var line_width_px: float = 6.0
## Dash length of the fray line (the sever line is solid).
@export var line_dash_px: float = 22.0
## Radius of the ring drawn where a line meets the threatened slot.
@export var line_end_radius_px: float = 16.0
## Border width drawn around a threatened slot.
@export var threat_border_px: float = 6.0
## Period of the line pulse, in seconds. 0 disables the pulse (static lines).
## This is the only telegraph animation: no particles, one redraw per frame.
@export var pulse_seconds: float = 1.2
## Lowest alpha the pulse reaches.
@export var pulse_min_alpha: float = 0.55
## Colour of the fray line, border and inspect cue.
@export var fray_color: Color = Color(0.98, 0.64, 0.24, 1.0)
## Colour of the sever line, border and inspect cue.
@export var sever_color: Color = Color(0.93, 0.22, 0.28, 1.0)
## Tint of a frayed or severed slot's text.
@export var inactive_slot_text_color: Color = Color(0.72, 0.68, 0.62, 1.0)
## Tint of a dead enemy's figure.
@export var dead_enemy_tint: Color = Color(0.45, 0.45, 0.5, 0.6)

## Defaults with any res://data/ui/hud.json overrides applied.
static func load_default() -> CombatHudSettings:
  var settings: CombatHudSettings = CombatHudSettings.new()
  settings.apply_data_overrides(DATA_OVERRIDE_PATH)
  return settings

## Applies the keys of a JSON object file to the matching properties. Returns
## the number of keys applied; a missing file applies nothing and is not an error.
func apply_data_overrides(path: String) -> int:
  if not FileAccess.file_exists(path):
    return 0
  var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
  if typeof(parsed) != TYPE_DICTIONARY:
    push_warning("CombatHudSettings: %s is not a JSON object; ignored." % path)
    return 0
  var overrides: Dictionary = parsed
  var applied: int = 0
  for key_variant: Variant in overrides.keys():
    var key: String = String(key_variant)
    var current: Variant = get(key)
    if current == null:
      push_warning("CombatHudSettings: %s :: $.%s :: Unknown setting; ignored." % [path, key])
      continue
    var value: Variant = overrides[key_variant]
    match typeof(current):
      TYPE_INT:
        set(key, int(value))
      TYPE_FLOAT:
        set(key, float(value))
      TYPE_COLOR:
        if typeof(value) == TYPE_STRING and Color.html_is_valid(String(value)):
          set(key, Color.html(String(value)))
        else:
          push_warning("CombatHudSettings: %s :: $.%s :: Expected a colour string like \"#rrggbb\"; ignored." % [path, key])
          continue
      _:
        push_warning("CombatHudSettings: %s :: $.%s :: Unsupported setting type; ignored." % [path, key])
        continue
    applied += 1
  return applied
