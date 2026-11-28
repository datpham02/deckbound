class_name TelegraphView
extends HudInspectTarget
## One enemy's telegraph: the action icon and its number directly above the
## enemy's head (E4.1, enemies.md section 3). Hidden when the enemy is dead or
## has no telegraph. A fray or sever telegraph with a target slot exposes
## threat_type and target_slot so the controller can draw the line (E4.2, E4.3).
## Long-press opens the inspect text from enemies.md section 3 (E4.5).

const ICON_DIR: String = "res://assets/placeholder/telegraph"
const DEFAULT_FOUL_PAGE_NAME: String = "Water-stain"

static var _icon_cache: Dictionary = {}

var enemy_index: int = -1
var telegraph: Dictionary = {}
var threat_type: String = ""
var target_slot: int = -1

var _settings: CombatHudSettings = null
var _row: HBoxContainer = null
var _icon: TextureRect = null
var _number: Label = null

## Builds the children; call once before adding the view to the tree.
func build(settings: CombatHudSettings) -> void:
  _settings = settings
  name = "TelegraphView"
  custom_minimum_size = Vector2(0.0, float(settings.telegraph_icon_px))
  size_flags_horizontal = Control.SIZE_EXPAND_FILL

  _row = HBoxContainer.new()
  _row.name = "Row"
  _row.set_anchors_preset(Control.PRESET_FULL_RECT)
  _row.alignment = BoxContainer.ALIGNMENT_CENTER
  _row.mouse_filter = Control.MOUSE_FILTER_IGNORE
  _row.add_theme_constant_override("separation", 12)
  add_child(_row)

  _icon = TextureRect.new()
  _icon.name = "Icon"
  _icon.custom_minimum_size = Vector2(float(settings.telegraph_icon_px), float(settings.telegraph_icon_px))
  _icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
  _icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
  _icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
  _row.add_child(_icon)

  _number = Label.new()
  _number.name = "Number"
  _number.add_theme_font_size_override("font_size", settings.telegraph_number_font_px)
  _number.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
  _number.mouse_filter = Control.MOUSE_FILTER_IGNORE
  _row.add_child(_number)

## Shows the enemy's current telegraph; page_library resolves the foul page name.
func set_telegraph(enemy: Variant, index: int, page_library: Dictionary) -> void:
  enemy_index = index
  telegraph = enemy.telegraph.duplicate()
  var action_type: String = String(telegraph.get("type", ""))
  var shown: bool = enemy.is_alive() and action_type != ""
  visible = shown
  if not shown:
    threat_type = ""
    target_slot = -1
    inspect_title = ""
    inspect_body = ""
    inspect_footer = ""
    return

  var value: int = int(telegraph.get("value", 0))
  var hits: int = maxi(1, int(telegraph.get("hits", 1)))
  _number.text = number_text(value, hits)
  _icon.texture = icon_for(action_type)
  target_slot = int(telegraph.get("target_slot", -1))
  threat_type = action_type if (action_type == "fray" or action_type == "sever") and target_slot >= 0 else ""

  inspect_title = "%s: %s %s" % [String(enemy.name), action_type.capitalize(), _number.text]
  inspect_body = inspect_text(action_type, value, hits, String(telegraph.get("page_id", "")), page_library)
  inspect_footer = "No binding to target, so it attacks instead." if bool(telegraph.get("fallback_used", false)) else ""

func number_text_shown() -> String:
  return _number.text if _number != null else ""

## Where a fray or sever line starts: the left edge of the icon, in global space.
func line_anchor_global() -> Vector2:
  if _icon == null:
    return get_global_rect().get_center()
  var rect: Rect2 = _icon.get_global_rect()
  return Vector2(rect.position.x, rect.get_center().y)

static func number_text(value: int, hits: int) -> String:
  if hits > 1:
    return "%d ×%d" % [value, hits]
  return "%d" % value

static func icon_for(action_type: String) -> Texture2D:
  if _icon_cache.has(action_type):
    return _icon_cache[action_type]
  var path: String = "%s/telegraph_%s.svg" % [ICON_DIR, action_type]
  var texture: Texture2D = null
  if ResourceLoader.exists(path):
    texture = load(path) as Texture2D
  _icon_cache[action_type] = texture
  return texture

## Inspect text per action kind (enemies.md section 3, last column).
static func inspect_text(action_type: String, value: int, hits: int, page_id: String, page_library: Dictionary) -> String:
  match action_type:
    "attack":
      if hits > 1:
        return "Deals %d damage to you, %d times. Guard absorbs it first." % [value, hits]
      return "Deals %d damage to you. Guard absorbs it first." % value
    "guard":
      return "Gains %d guard. Your damage must get through it before it acts again." % value
    "fray":
      return "Frays the marked binding unless you have %d guard when it lands. Spends %d of your guard. A frayed binding stops working until the end of this fight." % [value, value]
    "foul":
      var page_name: String = DEFAULT_FOUL_PAGE_NAME
      var page: Variant = page_library.get(page_id, null)
      if page != null:
        page_name = String(page.name)
      return "Puts %d %s page%s into your discard pile." % [value, page_name, "" if value == 1 else "s"]
    "sever":
      return "Severs the marked binding unless you have %d guard when it lands. Spends %d of your guard. A severed page is gone from this run." % [value, value]
  return ""
