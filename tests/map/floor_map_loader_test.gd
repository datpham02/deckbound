extends "res://tests/framework/test_case.gd"

const FLOOR_MAP_LOADER_SCRIPT := preload("res://scripts/map/floor_map_loader.gd")

func test() -> void:
  _test_valid_floor_map_loads()
  _test_non_fight_intro_rows_are_allowed()
  _test_rejects_small_touch_target()
  _test_requires_exactly_one_warden_row()

func _test_valid_floor_map_loads() -> void:
  var path: String = _create_fixture_path("valid_floor")
  _write_json(path, _valid_floor_payload())

  var result: Dictionary = FLOOR_MAP_LOADER_SCRIPT.load_from_path(path)
  assert_true(bool(result.get("ok", false)), "Expected valid floor map fixture to load: %s" % str(result))
  var floor_data: Dictionary = result.get("floor_data", {})
  var rows: Array = floor_data.get("rows", [])
  assert_equal(rows.size(), 9, "Expected all rows to load.")
  assert_equal(String(rows[6]["type"]), "warden", "Expected warden row at index 6.")
  assert_equal(int(floor_data["branching"]["extra_connection_chance_percent"]), 45, "Expected branching chance from JSON.")

func _test_non_fight_intro_rows_are_allowed() -> void:
  var path: String = _create_fixture_path("non_fight_intro")
  var payload: Dictionary = _valid_floor_payload()
  payload["rows"][2]["type"] = "rest"
  _write_json(path, payload)

  var result: Dictionary = FLOOR_MAP_LOADER_SCRIPT.load_from_path(path)
  assert_true(bool(result.get("ok", false)), "Expected non-fight intro row to load for data-driven tuning.")

func _test_rejects_small_touch_target() -> void:
  var path: String = _create_fixture_path("small_touch_target")
  var payload: Dictionary = _valid_floor_payload()
  payload["touch"]["node_diameter"] = 120
  _write_json(path, payload)

  var result: Dictionary = FLOOR_MAP_LOADER_SCRIPT.load_from_path(path)
  assert_true(not bool(result.get("ok", false)), "Expected small touch target to fail validation.")
  var error_message: String = str(result.get("error", ""))
  assert_true(error_message.find("node_diameter >= 128") != -1, "Error should mention the minimum node diameter.")

func _test_requires_exactly_one_warden_row() -> void:
  var path: String = _create_fixture_path("double_warden")
  var payload: Dictionary = _valid_floor_payload()
  payload["rows"][5]["type"] = "warden"
  _write_json(path, payload)

  var result: Dictionary = FLOOR_MAP_LOADER_SCRIPT.load_from_path(path)
  assert_true(not bool(result.get("ok", false)), "Expected floor with two warden rows to fail.")
  var error_message: String = str(result.get("error", ""))
  assert_true(error_message.find("exactly one warden row") != -1, "Error should explain warden-row requirement.")

func _valid_floor_payload() -> Dictionary:
  return {
    "schema_version": 1,
    "seed_offset": 173,
    "layout": {
      "left_margin_fraction": 0.06,
      "right_margin_fraction": 0.06,
      "top_margin_fraction": 0.08,
      "bottom_margin_fraction": 0.08,
      "row_spacing_fraction": 1.0,
      "slot_spacing_fraction": 0.32
    },
    "touch": {
      "node_diameter": 128,
      "line_width": 4
    },
    "branching": {
      "extra_connection_chance_percent": 45
    },
    "rows": [
      {"type": "start", "node_count": 1},
      {"type": "fight", "node_count": 2},
      {"type": "fight", "node_count": 3},
      {"type": "fight", "node_count": 2},
      {"type": "rest", "node_count": 2},
      {"type": "fight", "node_count": 2},
      {"type": "warden", "node_count": 1},
      {"type": "rest", "node_count": 1},
      {"type": "boss", "node_count": 1}
    ]
  }

func _create_fixture_path(tag: String) -> String:
  var directory: String = "user://tests/map"
  var create_directory_error: int = DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
  assert_equal(create_directory_error, OK, "Could not create test fixture directory for map tests.")
  return "%s/%s_%d.json" % [directory, tag, Time.get_ticks_usec()]

func _write_json(path: String, payload: Variant) -> void:
  var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
  assert_true(file != null, "Could not open floor map fixture file: %s" % path)
  if file == null:
    return
  file.store_string(JSON.stringify(payload))
