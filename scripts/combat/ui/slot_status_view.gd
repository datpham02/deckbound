class_name SlotStatusView
extends HudInspectTarget
## Bind-slot status display (E2, E3): the T14 slot icon for empty, intact,
## frayed or severed, the state word beside it and the bound page's name under
## it. Fills the T11 slot button, which stays the Bind drop zone for T12. A
## threatened slot (fray or sever telegraphed on it) gets a border in the
## threat colour, where the telegraph line ends. Long-press inspects the
## binding (E9.5).

enum Status { EMPTY, INTACT, FRAYED, SEVERED }

const ICON_DIR: String = "res://assets/placeholder/slots"
const STATUS_WORDS: Dictionary = {
  Status.EMPTY: "empty",
  Status.INTACT: "intact",
  Status.FRAYED: "frayed",
  Status.SEVERED: "severed",
}
const STATUS_ICONS: Dictionary = {
  Status.EMPTY: "slot_empty",
  Status.INTACT: "slot_intact",
  Status.FRAYED: "slot_frayed",
  Status.SEVERED: "slot_severed",
}

static var _icon_cache: Dictionary = {}

var slot_index: int = -1
var status: int = Status.EMPTY
var page_name: String = ""
var threat_type: String = ""
var threat_value: int = 0

var _settings: CombatHudSettings = null
var _icon: TextureRect = null
var _status_label: Label = null
var _name_label: Label = null
var _bind_text: String = ""

## Builds the children; call once before adding the view to the slot button.
func build(settings: CombatHudSettings) -> void:
  _settings = settings
  name = "SlotStatusView"
  set_anchors_preset(Control.PRESET_FULL_RECT)

  var margin: MarginContainer = MarginContainer.new()
  margin.name = "Margin"
  margin.set_anchors_preset(Control.PRESET_FULL_RECT)
  margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
  for side: String in ["margin_left", "margin_top", "margin_right", "margin_bottom"]:
    margin.add_theme_constant_override(side, 10)
  add_child(margin)

  var rows: VBoxContainer = VBoxContainer.new()
  rows.name = "Rows"
  rows.mouse_filter = Control.MOUSE_FILTER_IGNORE
  rows.add_theme_constant_override("separation", 4)
  margin.add_child(rows)

  var head: HBoxContainer = HBoxContainer.new()
  head.name = "Head"
  head.mouse_filter = Control.MOUSE_FILTER_IGNORE
  head.add_theme_constant_override("separation", 8)
  rows.add_child(head)

  _icon = TextureRect.new()
  _icon.name = "Icon"
  _icon.custom_minimum_size = Vector2(float(settings.slot_icon_px), float(settings.slot_icon_px))
  _icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
  _icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
  _icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
  head.add_child(_icon)

  _status_label = Label.new()
  _status_label.name = "Status"
  _status_label.add_theme_font_size_override("font_size", settings.slot_text_font_px)
  _status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
  _status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
  head.add_child(_status_label)

  _name_label = Label.new()
  _name_label.name = "PageName"
  _name_label.add_theme_font_size_override("font_size", settings.slot_text_font_px)
  _name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
  _name_label.max_lines_visible = 2
  _name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
  _name_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
  _name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
  rows.add_child(_name_label)

## Reads the slot from the combat state. severed_mark says the slot was emptied
## by a sever this combat (the state itself only knows the slot is empty).
func set_slot(index: int, state: Variant, page_library: Dictionary, severed_mark: bool) -> void:
  slot_index = index
  page_name = ""
  _bind_text = ""
  if state.binding_slot_has_card(index):
    var card: Variant = state.binding_slots[index]["card"]
    var page: Variant = page_library.get(String(card.page_id), null)
    page_name = String(page.name) if page != null else String(card.page_id)
    _bind_text = String(page.bind_text) if page != null else ""
    status = Status.FRAYED if state.binding_slot_is_frayed(index) else Status.INTACT
  elif severed_mark:
    status = Status.SEVERED
  else:
    status = Status.EMPTY
  _apply()

## Marks the slot as the target of a fray or sever telegraph ("" clears it).
func set_threat(action_type: String, value: int = 0) -> void:
  if threat_type == action_type and threat_value == value:
    return
  threat_type = action_type
  threat_value = value
  _apply_inspect_text()
  queue_redraw()

## Where a telegraph line ends: just inside the slot's right edge, in global space.
func line_anchor_global() -> Vector2:
  var rect: Rect2 = get_global_rect()
  return Vector2(rect.end.x - _settings.threat_border_px, rect.get_center().y)

func status_word() -> String:
  return String(STATUS_WORDS.get(status, ""))

func _apply() -> void:
  _icon.texture = icon_for(status)
  _status_label.text = status_word()
  _name_label.text = page_name if page_name != "" else "Slot %d" % (slot_index + 1)
  var inactive: bool = status == Status.FRAYED or status == Status.SEVERED
  var text_color: Color = _settings.inactive_slot_text_color if inactive else Color.WHITE
  _name_label.modulate = text_color
  _status_label.modulate = text_color
  _apply_inspect_text()
  queue_redraw()

func _apply_inspect_text() -> void:
  var slot_label: String = "Slot %d" % (slot_index + 1)
  match status:
    Status.INTACT:
      inspect_title = "%s: intact" % page_name
      inspect_body = "Bind: %s" % _bind_text
      inspect_footer = "The Bind effect is on. The page is out of your deck until you unbind it at a rest."
    Status.FRAYED:
      inspect_title = "%s: frayed" % page_name
      inspect_body = "Bind: %s" % _bind_text
      inspect_footer = "Frayed: this effect is off until the end of this fight. The page stays bound."
    Status.SEVERED:
      inspect_title = "%s: severed" % slot_label
      inspect_body = "The page that was bound here is gone from this run. The slot is free again."
      inspect_footer = ""
    _:
      inspect_title = "%s: empty" % slot_label
      inspect_body = "Drag a page left from its spread and tap the slot to bind it. Binding takes the page out of your deck for the rest of the run."
      inspect_footer = ""
  if threat_type != "":
    var threat_line: String = "Threatened: %s %d targets this slot. Hold %d guard when it lands to stop it." % [threat_type.capitalize(), threat_value, threat_value]
    inspect_footer = threat_line if inspect_footer == "" else "%s\n%s" % [inspect_footer, threat_line]

func _draw() -> void:
  if threat_type == "" or _settings == null:
    return
  var color: Color = _settings.sever_color if threat_type == "sever" else _settings.fray_color
  var border: float = _settings.threat_border_px
  var rect: Rect2 = Rect2(Vector2.ZERO, size).grow(-border * 0.5)
  draw_rect(rect, color, false, border, true)

static func icon_for(slot_status: int) -> Texture2D:
  if _icon_cache.has(slot_status):
    return _icon_cache[slot_status]
  var path: String = "%s/%s.svg" % [ICON_DIR, String(STATUS_ICONS.get(slot_status, "slot_empty"))]
  var texture: Texture2D = null
  if ResourceLoader.exists(path):
    texture = load(path) as Texture2D
  _icon_cache[slot_status] = texture
  return texture
