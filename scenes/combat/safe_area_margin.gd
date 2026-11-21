class_name SafeAreaMargin
extends MarginContainer
## Pads this container to the display safe area (cutout, rounded corners,
## gesture bar). Placeholder minimum insets apply when the device reports none,
## so layouts are checked against a realistic safe area in QA screenshots.

@export var min_left: int = 64
@export var min_top: int = 24
@export var min_right: int = 64
@export var min_bottom: int = 48

func _ready() -> void:
  _apply_insets()
  get_viewport().size_changed.connect(_apply_insets)

func _apply_insets() -> void:
  var left: int = min_left
  var top: int = min_top
  var right: int = min_right
  var bottom: int = min_bottom

  # Device insets are only meaningful for the real window, not a QA SubViewport.
  if get_viewport() == get_tree().root:
    var safe_area: Rect2i = DisplayServer.get_display_safe_area()
    var window_size: Vector2i = DisplayServer.window_get_size()
    var viewport_size: Vector2 = get_viewport_rect().size
    if safe_area.size != Vector2i.ZERO and window_size.x > 0 and window_size.y > 0:
      var to_canvas: Vector2 = Vector2(
        viewport_size.x / float(window_size.x),
        viewport_size.y / float(window_size.y)
      )
      left = maxi(left, int(safe_area.position.x * to_canvas.x))
      top = maxi(top, int(safe_area.position.y * to_canvas.y))
      right = maxi(right, int((window_size.x - safe_area.end.x) * to_canvas.x))
      bottom = maxi(bottom, int((window_size.y - safe_area.end.y) * to_canvas.y))

  add_theme_constant_override("margin_left", left)
  add_theme_constant_override("margin_top", top)
  add_theme_constant_override("margin_right", right)
  add_theme_constant_override("margin_bottom", bottom)
