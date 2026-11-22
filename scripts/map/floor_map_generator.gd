class_name FloorMapGenerator
extends RefCounted

static func generate(floor_data: Dictionary, seed: int) -> Dictionary:
  var rows: Array = floor_data.get("rows", [])
  var layout: Dictionary = floor_data.get("layout", {})
  var branching: Dictionary = floor_data.get("branching", {})
  var touch: Dictionary = floor_data.get("touch", {})
  var map_seed: int = seed + int(floor_data.get("seed_offset", 0))

  var rng: RandomNumberGenerator = RandomNumberGenerator.new()
  rng.seed = map_seed

  var nodes: Array[Dictionary] = []
  var row_node_ids: Array = []
  var node_index_by_id: Dictionary = {}

  for row_index: int in range(rows.size()):
    var row: Dictionary = rows[row_index]
    var row_type: String = String(row.get("type", "fight"))
    var node_count: int = int(row.get("node_count", 1))
    var ids_for_row: Array[String] = []
    for node_slot: int in range(node_count):
      var node_id: String = "r%dn%d" % [row_index, node_slot]
      var node_position: Vector2 = _node_position(layout, row_index, node_slot, node_count)
      var node: Dictionary = {
        "id": node_id,
        "row_index": row_index,
        "slot_index": node_slot,
        "type": row_type,
        "position": node_position,
        "next_ids": []
      }
      node_index_by_id[node_id] = nodes.size()
      nodes.append(node)
      ids_for_row.append(node_id)
    row_node_ids.append(ids_for_row)

  var extra_connection_chance_percent: int = int(branching.get("extra_connection_chance_percent", 0))
  var extra_connection_count: int = 0
  for row_index: int in range(row_node_ids.size() - 1):
    var from_row_ids: Array[String] = row_node_ids[row_index]
    var to_row_ids: Array[String] = row_node_ids[row_index + 1]
    var incoming_counts: Dictionary = {}
    for to_id: String in to_row_ids:
      incoming_counts[to_id] = 0

    for from_index: int in range(from_row_ids.size()):
      var from_id: String = from_row_ids[from_index]
      var primary_target_index: int = _primary_target_index(from_index, from_row_ids.size(), to_row_ids.size())
      var primary_id: String = to_row_ids[primary_target_index]
      if _connect(nodes, node_index_by_id, from_id, primary_id):
        incoming_counts[primary_id] = int(incoming_counts[primary_id]) + 1

      if to_row_ids.size() > 1 and extra_connection_chance_percent > 0:
        if rng.randi_range(0, 99) < extra_connection_chance_percent:
          var secondary_target_index: int = _secondary_target_index(primary_target_index, to_row_ids.size(), rng)
          if secondary_target_index != primary_target_index:
            var secondary_id: String = to_row_ids[secondary_target_index]
            if _connect(nodes, node_index_by_id, from_id, secondary_id):
              incoming_counts[secondary_id] = int(incoming_counts[secondary_id]) + 1
              extra_connection_count += 1

    for to_index: int in range(to_row_ids.size()):
      var candidate_to_id: String = to_row_ids[to_index]
      if int(incoming_counts[candidate_to_id]) > 0:
        continue
      var nearest_from_index: int = _nearest_from_index(to_index, from_row_ids.size(), to_row_ids.size())
      var nearest_from_id: String = from_row_ids[nearest_from_index]
      if _connect(nodes, node_index_by_id, nearest_from_id, candidate_to_id):
        incoming_counts[candidate_to_id] = int(incoming_counts[candidate_to_id]) + 1

  if extra_connection_count == 0:
    _force_one_extra_branch(nodes, node_index_by_id, row_node_ids)

  for node_index: int in range(nodes.size()):
    var node: Dictionary = nodes[node_index]
    var next_ids: Array = node.get("next_ids", [])
    next_ids.sort()
    node["next_ids"] = next_ids
    nodes[node_index] = node

  var start_node_id: String = ""
  if row_node_ids.size() > 0 and row_node_ids[0].size() > 0:
    start_node_id = String(row_node_ids[0][0])
  var boss_node_id: String = ""
  var last_row: int = row_node_ids.size() - 1
  if last_row >= 0 and row_node_ids[last_row].size() > 0:
    boss_node_id = String(row_node_ids[last_row][0])

  return {
    "seed": map_seed,
    "nodes": nodes,
    "rows": rows.duplicate(true),
    "row_node_ids": row_node_ids,
    "start_node_id": start_node_id,
    "boss_node_id": boss_node_id,
    "touch": touch.duplicate(true)
  }

static func _node_position(layout: Dictionary, row_index: int, node_slot: int, node_count: int) -> Vector2:
  var origin_x: float = float(layout.get("origin_x", 0))
  var origin_y: float = float(layout.get("origin_y", 0))
  var column_spacing: float = float(layout.get("column_spacing", 280))
  var row_spacing: float = float(layout.get("row_spacing", 120))
  var x: float = origin_x + (column_spacing * float(row_index))

  if node_count <= 1:
    return Vector2(x, origin_y)

  var row_span: float = row_spacing * float(node_count - 1)
  var top_y: float = origin_y - (row_span * 0.5)
  var y: float = top_y + (row_spacing * float(node_slot))
  return Vector2(x, y)

static func _primary_target_index(from_index: int, from_count: int, to_count: int) -> int:
  if to_count <= 1:
    return 0
  if from_count <= 1:
    return int(round(float(to_count - 1) * 0.5))

  var from_ratio: float = float(from_index) / float(from_count - 1)
  return clampi(int(round(from_ratio * float(to_count - 1))), 0, to_count - 1)

static func _secondary_target_index(primary_index: int, to_count: int, rng: RandomNumberGenerator) -> int:
  if to_count <= 1:
    return primary_index
  if primary_index <= 0:
    return 1
  if primary_index >= to_count - 1:
    return to_count - 2
  if rng.randi_range(0, 1) == 0:
    return primary_index - 1
  return primary_index + 1

static func _nearest_from_index(to_index: int, from_count: int, to_count: int) -> int:
  if from_count <= 1:
    return 0
  if to_count <= 1:
    return int(round(float(from_count - 1) * 0.5))

  var to_ratio: float = float(to_index) / float(to_count - 1)
  return clampi(int(round(to_ratio * float(from_count - 1))), 0, from_count - 1)

static func _connect(nodes: Array[Dictionary], node_index_by_id: Dictionary, from_id: String, to_id: String) -> bool:
  var from_node_index: int = int(node_index_by_id[from_id])
  var from_node: Dictionary = nodes[from_node_index]
  var next_ids: Array = from_node.get("next_ids", [])
  if next_ids.has(to_id):
    return false
  next_ids.append(to_id)
  from_node["next_ids"] = next_ids
  nodes[from_node_index] = from_node
  return true

static func _force_one_extra_branch(nodes: Array[Dictionary], node_index_by_id: Dictionary, row_node_ids: Array) -> void:
  for row_index: int in range(row_node_ids.size() - 1):
    var from_row_ids: Array[String] = row_node_ids[row_index]
    var to_row_ids: Array[String] = row_node_ids[row_index + 1]
    if from_row_ids.is_empty() or to_row_ids.size() < 2:
      continue
    var from_id: String = from_row_ids[0]
    var from_node: Dictionary = nodes[int(node_index_by_id[from_id])]
    var next_ids: Array = from_node.get("next_ids", [])
    if next_ids.is_empty():
      continue

    var first_target_id: String = String(next_ids[0])
    var first_target_index: int = to_row_ids.find(first_target_id)
    var alternative_index: int = 1
    if first_target_index == 1:
      alternative_index = 0
    if alternative_index >= 0 and alternative_index < to_row_ids.size():
      var alternative_id: String = to_row_ids[alternative_index]
      _connect(nodes, node_index_by_id, from_id, alternative_id)
      return
