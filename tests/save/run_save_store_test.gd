extends "res://tests/framework/test_case.gd"

const RUN_STATE_SCRIPT := preload("res://scripts/run/run_state.gd")
const RUN_SAVE_STORE_SCRIPT := preload("res://scripts/save/run_save_store.gd")

func test() -> void:
  _test_save_and_load_round_trip_every_field()
  _test_old_schema_save_fails_with_clear_error()
  _test_corrupt_json_fails_with_clear_error()

func _test_save_and_load_round_trip_every_field() -> void:
  var save_path: String = _create_save_path("round_trip")
  var store: Variant = RUN_SAVE_STORE_SCRIPT.new(save_path)

  var run_state: Variant = RUN_STATE_SCRIPT.new()
  run_state.seed = 91357
  run_state.health = 42
  var deck: Array[String] = ["nib_cut", "pressed_thorn", "inkwell_ward"]
  run_state.deck = deck
  var bindings: Array[Dictionary] = [
    {"slot_index": 0, "page_id": "nib_cut", "status": RUN_STATE_SCRIPT.BINDING_STATUS_INTACT},
    {"slot_index": 1, "page_id": "pressed_thorn", "status": RUN_STATE_SCRIPT.BINDING_STATUS_FRAYED},
    {"slot_index": 2, "page_id": "", "status": RUN_STATE_SCRIPT.BINDING_STATUS_EMPTY}
  ]
  run_state.bindings = bindings
  var map_path: Array[String] = ["start", "fight_01", "reward_01", "rest_03"]
  run_state.map_position = {
    "act_index": 2,
    "node_id": "rest_03",
    "path": map_path
  }

  var save_result: Dictionary = store.save(run_state)
  assert_true(bool(save_result.get("ok", false)), "Expected save to succeed: %s" % str(save_result))

  var load_result: Dictionary = store.load()
  assert_true(bool(load_result.get("ok", false)), "Expected load to succeed: %s" % str(load_result))
  assert_true(load_result.has("run_state"), "Expected load result to include run_state.")

  var loaded_state: Variant = load_result["run_state"]
  assert_equal(loaded_state.schema_version, run_state.schema_version, "schema_version should round-trip.")
  assert_equal(loaded_state.seed, run_state.seed, "seed should round-trip.")
  assert_equal(loaded_state.health, run_state.health, "health should round-trip.")
  assert_equal(loaded_state.deck, run_state.deck, "deck should round-trip.")
  assert_equal(loaded_state.bindings, run_state.bindings, "bindings should round-trip.")
  assert_equal(loaded_state.map_position, run_state.map_position, "map_position should round-trip.")

func _test_old_schema_save_fails_with_clear_error() -> void:
  var save_path: String = _create_save_path("old_schema")
  _write_text(
    save_path,
    JSON.stringify({
      "schema_version": 0,
      "seed": 3,
      "health": 10,
      "deck": ["nib_cut"],
      "bindings": [{"slot_index": 0, "page_id": "", "status": "empty"}],
      "map_position": {"act_index": 0, "node_id": "start", "path": ["start"]}
    })
  )

  var store: Variant = RUN_SAVE_STORE_SCRIPT.new(save_path)
  var load_result: Dictionary = store.load()
  assert_true(not bool(load_result.get("ok", false)), "Expected old-schema save to fail.")
  assert_true(_contains(str(load_result.get("error", "")), "Unsupported save schema version"), "Expected old-schema error message.")

func _test_corrupt_json_fails_with_clear_error() -> void:
  var save_path: String = _create_save_path("corrupt_json")
  _write_text(save_path, "{ \"schema_version\": 1, \"seed\": 11,")

  var store: Variant = RUN_SAVE_STORE_SCRIPT.new(save_path)
  var load_result: Dictionary = store.load()
  assert_true(not bool(load_result.get("ok", false)), "Expected corrupt save to fail.")
  assert_true(_contains(str(load_result.get("error", "")), "Save file is corrupt"), "Expected corrupt-json error message.")

func _create_save_path(tag: String) -> String:
  _ensure_save_test_dir()
  return "user://tests/save/%s_%d.json" % [tag, Time.get_ticks_usec()]

func _ensure_save_test_dir() -> void:
  var test_dir_path: String = "user://tests/save"
  var error_code: int = DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(test_dir_path))
  assert_equal(error_code, OK, "Could not create save test directory.")

func _write_text(path: String, value: String) -> void:
  var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
  assert_true(file != null, "Could not open save fixture path: %s" % path)
  if file == null:
    return
  file.store_string(value)

func _contains(value: String, target: String) -> bool:
  return value.find(target) != -1
