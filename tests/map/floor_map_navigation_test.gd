extends "res://tests/framework/test_case.gd"

const FLOOR_MAP_LOADER_SCRIPT := preload("res://scripts/map/floor_map_loader.gd")
const FLOOR_MAP_GENERATOR_SCRIPT := preload("res://scripts/map/floor_map_generator.gd")
const FLOOR_MAP_NAVIGATION_SCRIPT := preload("res://scripts/map/floor_map_navigation.gd")

const FLOOR_DATA_PATH: String = "res://data/run/floor.json"

func test() -> void:
  _test_navigation_starts_from_start_node()
  _test_cannot_select_unreachable_node()
  _test_selecting_reachable_nodes_advances_path()

func _test_navigation_starts_from_start_node() -> void:
  var navigation: Variant = _create_navigation(1337)
  var selectable: Array[String] = navigation.get_selectable_node_ids()
  assert_equal(selectable.size(), 1, "Before movement, only start should be selectable.")
  assert_equal(selectable[0], "r0n0", "Expected start node id from configured row order.")

func _test_cannot_select_unreachable_node() -> void:
  var navigation: Variant = _create_navigation(1337)
  var selected_unreachable: bool = navigation.select_node("r5n1")
  assert_true(not selected_unreachable, "Should reject selecting a non-adjacent node.")
  assert_true(navigation.last_error.find("not reachable") != -1, "Should include reachability error detail.")

func _test_selecting_reachable_nodes_advances_path() -> void:
  var navigation: Variant = _create_navigation(1337)
  var selected_start: bool = navigation.select_node("r0n0")
  assert_true(selected_start, "Should allow selecting start.")
  assert_equal(navigation.current_node_id, "r0n0", "Current node should update to start.")

  var next_options: Array[String] = navigation.get_selectable_node_ids()
  assert_true(next_options.size() >= 1, "Expected at least one selectable node after start.")
  var chosen_next: String = next_options[0]
  var selected_next: bool = navigation.select_node(chosen_next)
  assert_true(selected_next, "Should allow selecting a connected node.")
  assert_equal(navigation.current_node_id, chosen_next, "Current node should advance.")
  assert_equal(
    navigation.visited_node_ids,
    ["r0n0", chosen_next],
    "Visited path should append each valid selection."
  )

func _create_navigation(seed: int) -> Variant:
  var load_result: Dictionary = FLOOR_MAP_LOADER_SCRIPT.load_from_path(FLOOR_DATA_PATH)
  assert_true(bool(load_result.get("ok", false)), "Failed loading floor data fixture: %s" % str(load_result))
  var map_data: Dictionary = FLOOR_MAP_GENERATOR_SCRIPT.generate(load_result["floor_data"], seed)
  var navigation: Variant = FLOOR_MAP_NAVIGATION_SCRIPT.new()
  var setup_result: Dictionary = navigation.setup(map_data)
  assert_true(bool(setup_result.get("ok", false)), "Navigation setup should succeed: %s" % str(setup_result))
  return navigation
