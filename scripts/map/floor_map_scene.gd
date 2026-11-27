class_name FloorMapScene
extends Control

signal node_selected(node_id: String, node_type: String, path: Array[String])

const FLOOR_MAP_LOADER_SCRIPT := preload("res://scripts/map/floor_map_loader.gd")
const FLOOR_MAP_GENERATOR_SCRIPT := preload("res://scripts/map/floor_map_generator.gd")
const FLOOR_MAP_NAVIGATION_SCRIPT := preload("res://scripts/map/floor_map_navigation.gd")

const FLOOR_DATA_PATH: String = "res://data/run/floor.json"
const CONNECTION_COLOR: Color = Color(0.6, 0.66, 0.72, 0.9)
const CURRENT_NODE_COLOR: Color = Color(0.42, 0.86, 0.54)
const VISITED_NODE_COLOR: Color = Color(0.63, 0.63, 0.66)
const DISABLED_NODE_COLOR: Color = Color(0.45, 0.45, 0.48)
const READY_NODE_COLOR: Color = Color(0.96, 0.96, 0.96)
const DEFAULT_LEFT_MARGIN_FRACTION: float = 0.06
const DEFAULT_RIGHT_MARGIN_FRACTION: float = 0.06
const DEFAULT_TOP_MARGIN_FRACTION: float = 0.08
const DEFAULT_BOTTOM_MARGIN_FRACTION: float = 0.08

@export var preview_seed: int = 1337

@onready var header_label: Label = $SafeArea/Layout/Header
@onready var status_label: Label = $SafeArea/Layout/Status
@onready var nodes_layer: Control = $SafeArea/Layout/Nodes

var floor_data: Dictionary = {}
var map_data: Dictionary = {}
var navigation: Variant = null
var node_buttons: Dictionary = {}
var node_draw_positions: Dictionary = {}

func _ready() -> void:
  nodes_layer.resized.connect(_on_nodes_layer_resized)
  get_viewport().size_changed.connect(_on_viewport_size_changed)
  header_label.text = "Floor Map"
  navigation = FLOOR_MAP_NAVIGATION_SCRIPT.new()
  var built: bool = build_for_seed(preview_seed)
  if not built:
    push_warning(status_label.text)

func build_for_seed(seed: int) -> bool:
  _clear_buttons()

  var load_result: Dictionary = FLOOR_MAP_LOADER_SCRIPT.load_from_path(FLOOR_DATA_PATH)
  if not bool(load_result.get("ok", false)):
    floor_data = {}
    map_data = {}
    status_label.text = str(load_result.get("error", "Could not load floor map data."))
    queue_redraw()
    return false

  floor_data = load_result["floor_data"]
  map_data = FLOOR_MAP_GENERATOR_SCRIPT.generate(floor_data, seed)

  navigation = FLOOR_MAP_NAVIGATION_SCRIPT.new()
  var navigation_result: Dictionary = navigation.setup(map_data)
  if not bool(navigation_result.get("ok", false)):
    status_label.text = str(navigation_result.get("error", "Could not initialize map navigation."))
    queue_redraw()
    return false

  _build_node_buttons()
  var started: bool = navigation.select_node(String(map_data.get("start_node_id", "")))
  if not started:
    status_label.text = navigation.last_error
    queue_redraw()
    return false

  _refresh_ui_state()
  return true

func get_selected_path() -> Array[String]:
  return navigation.visited_node_ids.duplicate()

func _clear_buttons() -> void:
  for button_variant: Variant in node_buttons.values():
    var button: Button = button_variant as Button
    if button != null:
      button.queue_free()
  node_buttons.clear()
  node_draw_positions.clear()

func _build_node_buttons() -> void:
  var touch: Dictionary = map_data.get("touch", {})
  var node_diameter: float = float(touch.get("node_diameter", 128))
  var button_size: Vector2 = Vector2(node_diameter, node_diameter)

  var nodes_variant: Variant = map_data.get("nodes", [])
  if typeof(nodes_variant) != TYPE_ARRAY:
    return

  var nodes: Array = nodes_variant
  for node_variant: Variant in nodes:
    if typeof(node_variant) != TYPE_DICTIONARY:
      continue

    var node: Dictionary = node_variant
    var node_id: String = String(node.get("id", ""))
    var node_type: String = String(node.get("type", "fight"))

    var button: Button = Button.new()
    button.custom_minimum_size = button_size
    button.size = button_size
    button.text = _short_label(node_type)
    button.focus_mode = Control.FOCUS_NONE
    button.pressed.connect(_on_node_pressed.bind(node_id))

    nodes_layer.add_child(button)
    node_buttons[node_id] = button

  _layout_node_buttons()

func _layout_node_buttons() -> void:
  var layer_rect: Rect2 = Rect2(Vector2.ZERO, nodes_layer.size)
  var button_rects: Dictionary = compute_node_button_rects(map_data, layer_rect)
  var layer_origin: Vector2 = nodes_layer.get_global_rect().position - get_global_rect().position
  node_draw_positions.clear()

  for node_id_variant: Variant in node_buttons.keys():
    var node_id: String = String(node_id_variant)
    var button: Button = node_buttons[node_id]
    if not button_rects.has(node_id):
      button.visible = false
      continue

    var button_rect: Rect2 = button_rects[node_id]
    button.visible = true
    button.custom_minimum_size = button_rect.size
    button.size = button_rect.size
    button.position = button_rect.position
    node_draw_positions[node_id] = layer_origin + button_rect.get_center()

  queue_redraw()

func _on_nodes_layer_resized() -> void:
  _layout_node_buttons()

func _on_viewport_size_changed() -> void:
  call_deferred("_layout_node_buttons")

func _on_node_pressed(node_id: String) -> void:
  var did_select: bool = navigation.select_node(node_id)
  if not did_select:
    status_label.text = navigation.last_error
    return

  var current_node: Dictionary = navigation.get_current_node()
  emit_signal(
    "node_selected",
    node_id,
    String(current_node.get("type", "")),
    navigation.visited_node_ids.duplicate()
  )
  _refresh_ui_state()

func _refresh_ui_state() -> void:
  var selectable_ids: Array[String] = navigation.get_selectable_node_ids()
  var current_node: Dictionary = navigation.get_current_node()
  var current_type: String = String(current_node.get("type", ""))
  var path: Array[String] = navigation.visited_node_ids.duplicate()
  status_label.text = "Current: %s (%s) | Path: %s" % [
    navigation.current_node_id,
    current_type,
    " -> ".join(path)
  ]

  for node_id_variant: Variant in node_buttons.keys():
    var node_id: String = String(node_id_variant)
    var button: Button = node_buttons[node_id]
    button.disabled = not selectable_ids.has(node_id)

    var is_current: bool = (node_id == navigation.current_node_id)
    var is_visited: bool = navigation.visited_node_ids.has(node_id)
    if is_current:
      button.modulate = CURRENT_NODE_COLOR
    elif is_visited:
      button.modulate = VISITED_NODE_COLOR
    elif button.disabled:
      button.modulate = DISABLED_NODE_COLOR
    else:
      button.modulate = READY_NODE_COLOR

  queue_redraw()

func _draw() -> void:
  var nodes_variant: Variant = map_data.get("nodes", [])
  if typeof(nodes_variant) != TYPE_ARRAY:
    return
  var nodes: Array = nodes_variant
  if nodes.is_empty():
    return

  var touch: Dictionary = map_data.get("touch", {})
  var line_width: float = float(touch.get("line_width", 3))
  for node_variant: Variant in nodes:
    if typeof(node_variant) != TYPE_DICTIONARY:
      continue
    var node: Dictionary = node_variant
    var from_id: String = String(node.get("id", ""))
    if not node_draw_positions.has(from_id):
      continue
    var from_position: Vector2 = node_draw_positions[from_id]
    var next_ids_variant: Variant = node.get("next_ids", [])
    if typeof(next_ids_variant) != TYPE_ARRAY:
      continue

    var next_ids: Array = next_ids_variant
    for next_id_variant: Variant in next_ids:
      var next_id: String = String(next_id_variant)
      if not node_draw_positions.has(next_id):
        continue
      var to_position: Vector2 = node_draw_positions[next_id]
      draw_line(from_position, to_position, CONNECTION_COLOR, line_width, true)

static func compute_node_button_rects(next_map_data: Dictionary, layer_rect: Rect2) -> Dictionary:
  var button_rects: Dictionary = {}
  var nodes_variant: Variant = next_map_data.get("nodes", [])
  if typeof(nodes_variant) != TYPE_ARRAY:
    return button_rects

  var touch: Dictionary = next_map_data.get("touch", {})
  var layout: Dictionary = next_map_data.get("layout", {})
  var node_diameter: float = float(touch.get("node_diameter", 128))
  var node_size: Vector2 = Vector2(node_diameter, node_diameter)
  var content_rect: Rect2 = _compute_content_rect(layer_rect, layout, node_diameter)

  var nodes: Array = nodes_variant
  for node_variant: Variant in nodes:
    if typeof(node_variant) != TYPE_DICTIONARY:
      continue
    var node: Dictionary = node_variant
    var node_id: String = String(node.get("id", ""))
    if node_id.strip_edges() == "":
      continue
    var normalized_position: Vector2 = node.get("position", Vector2(0.5, 0.5))
    var clamped_position: Vector2 = Vector2(
      clampf(normalized_position.x, 0.0, 1.0),
      clampf(normalized_position.y, 0.0, 1.0)
    )
    var center: Vector2 = content_rect.position + Vector2(
      clamped_position.x * content_rect.size.x,
      clamped_position.y * content_rect.size.y
    )
    button_rects[node_id] = Rect2(center - (node_size * 0.5), node_size)

  return button_rects

static func _compute_content_rect(layer_rect: Rect2, layout: Dictionary, node_diameter: float) -> Rect2:
  var left_margin: float = layer_rect.size.x * _layout_fraction(layout, "left_margin_fraction", DEFAULT_LEFT_MARGIN_FRACTION)
  var right_margin: float = layer_rect.size.x * _layout_fraction(layout, "right_margin_fraction", DEFAULT_RIGHT_MARGIN_FRACTION)
  var top_margin: float = layer_rect.size.y * _layout_fraction(layout, "top_margin_fraction", DEFAULT_TOP_MARGIN_FRACTION)
  var bottom_margin: float = layer_rect.size.y * _layout_fraction(layout, "bottom_margin_fraction", DEFAULT_BOTTOM_MARGIN_FRACTION)
  var center_padding: Vector2 = Vector2(node_diameter * 0.5, node_diameter * 0.5)

  var content_origin: Vector2 = layer_rect.position + Vector2(left_margin, top_margin) + center_padding
  var content_size: Vector2 = layer_rect.size - Vector2(
    left_margin + right_margin + node_diameter,
    top_margin + bottom_margin + node_diameter
  )
  content_size.x = maxf(0.0, content_size.x)
  content_size.y = maxf(0.0, content_size.y)
  return Rect2(content_origin, content_size)

static func _layout_fraction(layout: Dictionary, key: String, fallback: float) -> float:
  if not layout.has(key):
    return fallback
  var value: Variant = layout[key]
  if typeof(value) == TYPE_FLOAT or typeof(value) == TYPE_INT:
    return float(value)
  return fallback

func _short_label(node_type: String) -> String:
  match node_type:
    "start":
      return "S"
    "fight":
      return "F"
    "rest":
      return "R"
    "warden":
      return "W"
    "boss":
      return "B"
    _:
      return "?"
