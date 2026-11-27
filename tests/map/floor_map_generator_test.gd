extends "res://tests/framework/test_case.gd"

const FLOOR_MAP_LOADER_SCRIPT := preload("res://scripts/map/floor_map_loader.gd")
const FLOOR_MAP_GENERATOR_SCRIPT := preload("res://scripts/map/floor_map_generator.gd")

const FLOOR_DATA_PATH: String = "res://data/run/floor.json"

func test() -> void:
  _test_generation_is_seeded_and_repeatable()
  _test_generated_map_has_required_nodes_and_branching()
  _test_every_path_reaches_boss()

func _test_generation_is_seeded_and_repeatable() -> void:
  var floor_data: Dictionary = _load_floor_data()
  var map_a: Dictionary = FLOOR_MAP_GENERATOR_SCRIPT.generate(floor_data, 404)
  var map_b: Dictionary = FLOOR_MAP_GENERATOR_SCRIPT.generate(floor_data, 404)
  var map_c: Dictionary = FLOOR_MAP_GENERATOR_SCRIPT.generate(floor_data, 405)

  assert_equal(_edge_signature(map_a), _edge_signature(map_b), "Expected same seed to produce identical edges.")
  assert_true(_edge_signature(map_a) != _edge_signature(map_c), "Expected different seeds to produce different branch edges.")

func _test_generated_map_has_required_nodes_and_branching() -> void:
  var floor_data: Dictionary = _load_floor_data()
  var map_data: Dictionary = FLOOR_MAP_GENERATOR_SCRIPT.generate(floor_data, 1337)
  var nodes: Array = map_data.get("nodes", [])

  assert_true(not nodes.is_empty(), "Expected generated map to include nodes.")
  var warden_count: int = 0
  var boss_count: int = 0
  var has_branch: bool = false

  for node_variant: Variant in nodes:
    var node: Dictionary = node_variant
    var node_type: String = String(node.get("type", ""))
    var next_ids: Array = node.get("next_ids", [])
    if node_type == "warden":
      warden_count += 1
    if node_type == "boss":
      boss_count += 1
    if next_ids.size() > 1:
      has_branch = true

  assert_equal(warden_count, 1, "Expected exactly one warden node.")
  assert_equal(boss_count, 1, "Expected exactly one boss node.")
  assert_true(has_branch, "Expected at least one branching choice in the generated floor.")

func _test_every_path_reaches_boss() -> void:
  var floor_data: Dictionary = _load_floor_data()
  var map_data: Dictionary = FLOOR_MAP_GENERATOR_SCRIPT.generate(floor_data, 73)
  var nodes_by_id: Dictionary = _nodes_by_id(map_data.get("nodes", []))
  var start_node_id: String = String(map_data.get("start_node_id", ""))
  var boss_node_id: String = String(map_data.get("boss_node_id", ""))

  assert_true(start_node_id != "", "Map must have a start node id.")
  assert_true(boss_node_id != "", "Map must have a boss node id.")

  var visited: Dictionary = {}
  var queue: Array[String] = [start_node_id]
  while not queue.is_empty():
    var current_id: String = queue.pop_front()
    if visited.has(current_id):
      continue
    visited[current_id] = true

    var node: Dictionary = nodes_by_id.get(current_id, {})
    var next_ids: Array = node.get("next_ids", [])
    for next_id_variant: Variant in next_ids:
      var next_id: String = String(next_id_variant)
      if not visited.has(next_id):
        queue.append(next_id)

  assert_true(visited.has(boss_node_id), "Boss node should be reachable from start.")
  for node_variant: Variant in map_data.get("nodes", []):
    var node: Dictionary = node_variant
    var node_id: String = String(node.get("id", ""))
    if not visited.has(node_id):
      continue
    if node_id == boss_node_id:
      continue
    var next_ids: Array = node.get("next_ids", [])
    assert_true(not next_ids.is_empty(), "Every reachable non-boss node should connect forward: %s" % node_id)

func _load_floor_data() -> Dictionary:
  var load_result: Dictionary = FLOOR_MAP_LOADER_SCRIPT.load_from_path(FLOOR_DATA_PATH)
  assert_true(bool(load_result.get("ok", false)), "Failed loading floor data fixture: %s" % str(load_result))
  return load_result.get("floor_data", {})

func _nodes_by_id(nodes: Array) -> Dictionary:
  var index: Dictionary = {}
  for node_variant: Variant in nodes:
    var node: Dictionary = node_variant
    index[String(node.get("id", ""))] = node
  return index

func _edge_signature(map_data: Dictionary) -> PackedStringArray:
  var entries: Array[String] = []
  var nodes: Array = map_data.get("nodes", [])
  for node_variant: Variant in nodes:
    var node: Dictionary = node_variant
    var node_id: String = String(node.get("id", ""))
    var next_ids: Array = node.get("next_ids", [])
    for next_id_variant: Variant in next_ids:
      entries.append("%s>%s" % [node_id, String(next_id_variant)])
  entries.sort()
  return PackedStringArray(entries)
