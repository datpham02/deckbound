class_name CardInspectView
extends Control
## Long-press inspect overlay (E9.4): full Play and Bind text for a page, shown
## while the finger is held and placed so it never covers the thing inspected.
## Never takes input and never commits an action. The text API is generic so
## T13 can reuse it for slots, telegraphs and statuses (E9.5).

const EDGE_MARGIN: float = 24.0
const GAP: float = 20.0

@onready var _panel: PanelContainer = $Panel
@onready var _title: Label = $Panel/Rows/Title
@onready var _play_text: Label = $Panel/Rows/PlayText
@onready var _bind_text: Label = $Panel/Rows/BindText

func _ready() -> void:
  mouse_filter = Control.MOUSE_FILTER_IGNORE
  visible = false

func show_card(card: Variant, page: Variant, avoid_rect: Rect2) -> void:
  var title: String = String(page.name) if page != null else String(card.page_id)
  var cost_text: String = "%s   (%d Ink)" % [title, int(card.cost)]
  var play_text: String = String(page.play_text) if page != null else ""
  var bind_text: String = String(page.bind_text) if page != null else ""
  show_text(cost_text, "Play: %s" % play_text, "Bind: %s" % bind_text, avoid_rect)

func show_text(title: String, play_text: String, bind_text: String, avoid_rect: Rect2) -> void:
  _title.text = title
  _play_text.text = play_text
  _bind_text.text = bind_text
  _play_text.visible = play_text != ""
  _bind_text.visible = bind_text != ""
  visible = true
  _panel.size = _panel.get_combined_minimum_size()
  _place_clear_of(avoid_rect)

func hide_inspect() -> void:
  visible = false

func _place_clear_of(avoid_rect: Rect2) -> void:
  var bounds: Rect2 = get_global_rect()
  var panel_size: Vector2 = _panel.size
  var local_avoid: Rect2 = Rect2(avoid_rect.position - bounds.position, avoid_rect.size)
  var x: float = local_avoid.get_center().x - panel_size.x * 0.5
  x = clampf(x, EDGE_MARGIN, maxf(EDGE_MARGIN, bounds.size.x - panel_size.x - EDGE_MARGIN))
  var y: float = local_avoid.position.y - GAP - panel_size.y
  if y < EDGE_MARGIN:
    var below: float = local_avoid.end.y + GAP
    y = below if below + panel_size.y <= bounds.size.y - EDGE_MARGIN else EDGE_MARGIN
  _panel.position = Vector2(x, y)
