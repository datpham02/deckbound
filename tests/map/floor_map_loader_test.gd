extends "res://tests/framework/test_case.gd"

const FLOOR_MAP_LOADER_SCRIPT := preload("res://scripts/map/floor_map_loader.gd")

func test() -> void:
  _test_valid_floor_map_loads()
  _test_intro_rows_must_be_fights()
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

func _test_intro_rows_must_be_fights() -> void:
  var path: String = _create_fixture_path("bad_intro")
  var payload: Dictionary = _valid_floor_payload()
  payload["rows"][2]["type"] = "rest"
  _write_json(path, payload)

  var result: Dictionary = FLOOR_MAP_LOADER_SCRIPT.load_from_path(path)
  assert_true(not bool(result.get("ok", false)), "Expected invalid intro rows to fail.")
  var error_message: String = str(result.get("error", ""))
  assert_true(error_message.find("$.rows[2].type") != -1, "Error should point at the invalid intro row.")
  assert_true(error_message.find("Intro rows 1-3 must be 'fight'") != -1, "Error should explain intro fight requirement.")

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
      "origin_x": 180,
      "origin_y": 140,
      "column_spacing": 300,
      "row_spacing": 132
    },
    "touch": {
      "node_diameter": 92,
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
