class_name TelegraphLineLayer
extends Control
## Draws the fray and sever lines from a telegraph to the threatened bind slot
## (E4.2, E4.3). Fray is a dashed line in the fray colour; sever is a solid
## line in the sever colour with a cut mark near the slot, so the two read
## apart without text. Both end in a ring on the slot.
##
## Endpoints are given in global canvas coordinates by the controller. The only
## animation is an alpha pulse (one redraw per frame while a line exists and
## pulse_seconds > 0), which is the T13 animation cap for telegraphs.

var _settings: CombatHudSettings = null
var _lines: Array[Dictionary] = []
var _pulse_time: float = 0.0

func _ready() -> void:
  name = "TelegraphLines"
  mouse_filter = Control.MOUSE_FILTER_IGNORE
  set_anchors_preset(Control.PRESET_FULL_RECT)

func configure(settings: CombatHudSettings) -> void:
  _settings = settings
  queue_redraw()

## Each entry: {"from": Vector2 (global), "to": Vector2 (global), "type": "fray"|"sever"}.
func set_lines(lines: Array[Dictionary]) -> void:
  if lines == _lines:
    return
  _lines = lines.duplicate(true)
  queue_redraw()

func clear_lines() -> void:
  set_lines([])

func line_count() -> int:
  return _lines.size()

func lines() -> Array[Dictionary]:
  return _lines.duplicate(true)

func _process(delta: float) -> void:
  if _lines.is_empty() or _settings == null or _settings.pulse_seconds <= 0.0:
    return
  _pulse_time += delta
  queue_redraw()

func _draw() -> void:
  if _settings == null or _lines.is_empty():
    return
  var to_local: Transform2D = get_global_transform().affine_inverse()
  var alpha: float = _pulse_alpha()
  for line: Dictionary in _lines:
    var from: Vector2 = to_local * Vector2(line.get("from", Vector2.ZERO))
    var to: Vector2 = to_local * Vector2(line.get("to", Vector2.ZERO))
    var line_type: String = String(line.get("type", "fray"))
    var color: Color = _settings.sever_color if line_type == "sever" else _settings.fray_color
    color.a *= alpha
    var width: float = _settings.line_width_px
    if line_type == "sever":
      draw_line(from, to, color, width, true)
      _draw_cut_mark(from, to, color, width)
    else:
      draw_dashed_line(from, to, color, width, _settings.line_dash_px, true, true)
    draw_circle(to, _settings.line_end_radius_px, color)
    draw_arc(to, _settings.line_end_radius_px * 1.7, 0.0, TAU, 32, color, width * 0.5, true)

## A short bar across the line, a little before the slot, like a cut cord.
func _draw_cut_mark(from: Vector2, to: Vector2, color: Color, width: float) -> void:
  var direction: Vector2 = (to - from)
  if direction.length_squared() <= 0.0:
    return
  direction = direction.normalized()
  var normal: Vector2 = Vector2(-direction.y, direction.x)
  var centre: Vector2 = to - direction * (_settings.line_end_radius_px * 3.5)
  var half: float = _settings.line_end_radius_px * 1.4
  draw_line(centre - normal * half, centre + normal * half, color, width, true)

func _pulse_alpha() -> float:
  if _settings.pulse_seconds <= 0.0:
    return 1.0
  var phase: float = 0.5 + 0.5 * sin(TAU * _pulse_time / _settings.pulse_seconds)
  return lerpf(clampf(_settings.pulse_min_alpha, 0.0, 1.0), 1.0, phase)
