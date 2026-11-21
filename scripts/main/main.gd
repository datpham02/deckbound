extends Control

@onready var title_label: Label = $Title
const TITLE_HALF_SIZE: Vector2 = Vector2(160.0, 28.0)

func _ready() -> void:
  title_label.text = "Deckbound"
  _position_title_in_safe_area()
  get_viewport().size_changed.connect(_position_title_in_safe_area)

func _position_title_in_safe_area() -> void:
  var safe_area: Rect2i = DisplayServer.get_display_safe_area()
  var viewport_center: Vector2 = get_viewport_rect().size * 0.5
  var safe_center: Vector2 = viewport_center

  if safe_area.size != Vector2i.ZERO:
    safe_center = Vector2(safe_area.position) + (Vector2(safe_area.size) * 0.5)

  var center_delta: Vector2 = safe_center - viewport_center
  title_label.offset_left = -TITLE_HALF_SIZE.x + center_delta.x
  title_label.offset_top = -TITLE_HALF_SIZE.y + center_delta.y
  title_label.offset_right = TITLE_HALF_SIZE.x + center_delta.x
  title_label.offset_bottom = TITLE_HALF_SIZE.y + center_delta.y
