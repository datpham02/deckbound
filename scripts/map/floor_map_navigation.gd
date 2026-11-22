class_name FloorMapNavigation
extends RefCounted

var map_data: Dictionary = {}
var nodes_by_id: Dictionary = {}
var start_node_id: String = ""
var current_node_id: String = ""
var visited_node_ids: Array[String] = []
var last_error: String = ""

func setup(next_map_data: Dictionary) -> Dictionary:
  return _setup(next_map_data)

func _setup(next_map_data: Dictionary) -> Dictionary:
  map_data = next_map_data
  var nodes_variant: Variant = map_data.get("nodes", [])
  if typeof(nodes_variant) != TYPE_ARRAY:
    return _failure("map_data.nodes must be an Array.")

  var nodes: Array = nodes_variant
  nodes_by_id = {}
  for node_variant: Variant in nodes:
    if typeof(node_variant) != TYPE_DICTIONARY:
      return _failure("map_data.nodes entries must be Dictionary values.")
    var node: Dictionary = node_variant
    var node_id: String = String(node.get("id", ""))
    if node_id.strip_edges() == "":
      return _failure("Every node requires a non-empty id.")
    nodes_by_id[node_id] = node

  start_node_id = String(map_data.get("start_node_id", ""))
  if start_node_id.strip_edges() == "":
    return _failure("map_data.start_node_id must be a non-empty string.")
  if not nodes_by_id.has(start_node_id):
    return _failure("map_data.start_node_id '%s' does not exist in nodes." % start_node_id)

  current_node_id = ""
  visited_node_ids.clear()
  last_error = ""
  return {"ok": true}

func get_selectable_node_ids() -> Array[String]:
  if current_node_id == "":
    return [start_node_id]

  var selectable: Array[String] = []
  var current_node: Dictionary = nodes_by_id[current_node_id]
  var next_ids_variant: Variant = current_node.get("next_ids", [])
  if typeof(next_ids_variant) != TYPE_ARRAY:
    return selectable

  var next_ids: Array = next_ids_variant
  for next_id_variant: Variant in next_ids:
    var next_id: String = String(next_id_variant)
    if next_id.strip_edges() == "":
      continue
    selectable.append(next_id)
  return selectable

func can_select(node_id: String) -> bool:
  return get_selectable_node_ids().has(node_id)

func select_node(node_id: String) -> bool:
  if node_id.strip_edges() == "":
    last_error = "Cannot select a node with an empty id."
    return false
  if not nodes_by_id.has(node_id):
    last_error = "Unknown map node id '%s'." % node_id
    return false
  if not can_select(node_id):
    last_error = "Node '%s' is not reachable from current position." % node_id
    return false

  current_node_id = node_id
  visited_node_ids.append(node_id)
  last_error = ""
  return true

func get_current_node() -> Dictionary:
  if current_node_id == "" or not nodes_by_id.has(current_node_id):
    return {}
  return nodes_by_id[current_node_id].duplicate(true)

func is_at_boss() -> bool:
  if current_node_id == "":
    return false
  var node: Dictionary = nodes_by_id[current_node_id]
  return String(node.get("type", "")) == "boss"

func _failure(error_message: String) -> Dictionary:
  return {
    "ok": false,
    "error": error_message
  }
