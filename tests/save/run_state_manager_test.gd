extends "res://tests/framework/test_case.gd"

const RUN_STATE_SCRIPT := preload("res://scripts/run/run_state.gd")
const RUN_STATE_MANAGER_SCRIPT := preload("res://scripts/run/run_state_manager.gd")
const RUN_SAVE_STORE_SCRIPT := preload("res://scripts/save/run_save_store.gd")

func test() -> void:
  _test_load_on_start_uses_existing_save()
  _test_save_on_node_transition_updates_map_position_and_persists()
  _test_pause_notification_saves_current_run_state()
  _test_load_on_start_sets_clear_error_for_invalid_save()

func _test_load_on_start_uses_existing_save() -> void:
  var save_path: String = _create_save_path("load_on_start")
  var store: Variant = RUN_SAVE_STORE_SCRIPT.new(save_path)
  var expected_state: Variant = _build_state()
  expected_state.seed = 999
  expected_state.health = 61

  var save_result: Dictionary = store.save(expected_state)
  assert_true(bool(save_result.get("ok", false)), "Fixture save should succeed: %s" % str(save_result))

  var manager: Variant = RUN_STATE_MANAGER_SCRIPT.new(store)
  var loaded: bool = manager.load_on_start()
  assert_true(loaded, "load_on_start should load existing save.")
  assert_true(manager.run_state != null, "run_state should be populated after load.")
  assert_equal(manager.run_state.seed, expected_state.seed, "Loaded seed should match save.")
  assert_equal(manager.run_state.health, expected_state.health, "Loaded health should match save.")
  assert_equal(manager.last_error, "", "last_error should stay empty on successful load.")
  manager.free()

func _test_save_on_node_transition_updates_map_position_and_persists() -> void:
  var save_path: String = _create_save_path("node_transition")
  var store: Variant = RUN_SAVE_STORE_SCRIPT.new(save_path)
  var manager: Variant = RUN_STATE_MANAGER_SCRIPT.new(store)
  var run_state: Variant = _build_state()
  manager.set_run_state(run_state)

  var saved: bool = manager.save_on_node_transition("fight_02", 1)
  assert_true(saved, "save_on_node_transition should succeed.")
  assert_equal(manager.run_state.map_position["node_id"], "fight_02", "node_id should update on transition.")
  assert_equal(manager.run_state.map_position["act_index"], 1, "act_index should update when provided.")

  var load_result: Dictionary = store.load()
  assert_true(bool(load_result.get("ok", false)), "Saved transition state should be readable.")
  var persisted_state: Variant = load_result["run_state"]
  var expected_path: Array[String] = ["start", "fight_01", "fight_02"]
  assert_equal(persisted_state.map_position["node_id"], "fight_02", "Persisted node_id should match transition target.")
  assert_equal(
    persisted_state.map_position["path"],
    expected_path,
    "Transition target should be appended to path."
  )
  manager.free()

func _test_pause_notification_saves_current_run_state() -> void:
  var save_path: String = _create_save_path("pause_notification")
  var store: Variant = RUN_SAVE_STORE_SCRIPT.new(save_path)
  var manager: Variant = RUN_STATE_MANAGER_SCRIPT.new(store)
  var run_state: Variant = _build_state()
  run_state.health = 27
  manager.set_run_state(run_state)

  manager._notification(Node.NOTIFICATION_APPLICATION_PAUSED)

  var load_result: Dictionary = store.load()
  assert_true(bool(load_result.get("ok", false)), "Pause notification should trigger a save.")
  var persisted_state: Variant = load_result["run_state"]
  assert_equal(persisted_state.health, 27, "Pause save should persist current health.")
  assert_equal(manager.last_error, "", "last_error should stay empty on pause save success.")
  manager.free()

func _test_load_on_start_sets_clear_error_for_invalid_save() -> void:
  var save_path: String = _create_save_path("invalid_load")
  _write_text(save_path, "{ \"schema_version\": 1, \"seed\":")
  var store: Variant = RUN_SAVE_STORE_SCRIPT.new(save_path)
  var manager: Variant = RUN_STATE_MANAGER_SCRIPT.new(store)

  var loaded: bool = manager.load_on_start()
  assert_true(not loaded, "load_on_start should fail for corrupt saves.")
  assert_true(_contains(manager.last_error, "Failed to load run save"), "last_error should include failure prefix.")
  assert_true(_contains(manager.last_error, "Save file is corrupt"), "last_error should include corruption details.")
  manager.free()

func _build_state() -> Variant:
  var run_state: Variant = RUN_STATE_SCRIPT.new()
  run_state.seed = 1024
  run_state.health = 55
  var deck: Array[String] = ["nib_cut", "inkwell_ward", "pressed_thorn"]
  run_state.deck = deck
  var bindings: Array[Dictionary] = [
    {"slot_index": 0, "page_id": "nib_cut", "status": RUN_STATE_SCRIPT.BINDING_STATUS_INTACT},
    {"slot_index": 1, "page_id": "", "status": RUN_STATE_SCRIPT.BINDING_STATUS_EMPTY},
    {"slot_index": 2, "page_id": "", "status": RUN_STATE_SCRIPT.BINDING_STATUS_EMPTY}
  ]
  run_state.bindings = bindings
  var path: Array[String] = ["start", "fight_01"]
  run_state.map_position = {
    "act_index": 0,
    "node_id": "fight_01",
    "path": path
  }
  return run_state

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
