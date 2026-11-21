extends Control

@onready var title_label: Label = $Title
const TITLE_HALF_SIZE: Vector2 = Vector2(160.0, 28.0)

func _ready() -> void:
  title_label.text = "Deckbound"
  _position_title_in_safe_area()
  get_viewport().size_changed.connect(_position_title_in_safe_area)

func _position_title_in_safe_area() -> void:
  var safe_area: Rect2i = DisplayServer.get_display_safe_area()
  var viewport_size: Vector2 = get_viewport_rect().size
  var viewport_center: Vector2 = viewport_size * 0.5
  var safe_center: Vector2 = viewport_center
  var window_size: Vector2i = DisplayServer.window_get_size()

  if safe_area.size != Vector2i.ZERO and window_size.x > 0 and window_size.y > 0:
    var safe_left_ratio: float = float(safe_area.position.x) / float(window_size.x)
    var safe_top_ratio: float = float(safe_area.position.y) / float(window_size.y)
    var safe_width_ratio: float = float(safe_area.size.x) / float(window_size.x)
    var safe_height_ratio: float = float(safe_area.size.y) / float(window_size.y)

    var safe_area_in_viewport: Rect2 = Rect2(
      Vector2(viewport_size.x * safe_left_ratio, viewport_size.y * safe_top_ratio),
      Vector2(viewport_size.x * safe_width_ratio, viewport_size.y * safe_height_ratio)
    )
    safe_center = safe_area_in_viewport.position + (safe_area_in_viewport.size * 0.5)

  var center_delta: Vector2 = safe_center - viewport_center
  title_label.offset_left = -TITLE_HALF_SIZE.x + center_delta.x
  title_label.offset_top = -TITLE_HALF_SIZE.y + center_delta.y
  title_label.offset_right = TITLE_HALF_SIZE.x + center_delta.x
  title_label.offset_bottom = TITLE_HALF_SIZE.y + center_delta.y
