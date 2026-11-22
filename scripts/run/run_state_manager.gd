class_name RunStateManager
extends Node

const RUN_SAVE_STORE_SCRIPT := preload("res://scripts/save/run_save_store.gd")

var run_state: Variant = null
var last_error: String = ""

var _save_store: Variant = null

func _init(save_store: Variant = null) -> void:
  _save_store = save_store
  if _save_store == null:
    _save_store = RUN_SAVE_STORE_SCRIPT.new()

func _ready() -> void:
  load_on_start()

func _notification(what: int) -> void:
  if what == NOTIFICATION_APPLICATION_PAUSED:
    save_on_pause()

func load_on_start() -> bool:
  var load_result: Dictionary = _save_store.load()
  if bool(load_result.get("ok", false)):
    run_state = load_result["run_state"]
    last_error = ""
    return true

  if bool(load_result.get("missing", false)):
    run_state = null
    last_error = ""
    return false

  run_state = null
  last_error = "Failed to load run save: %s" % str(load_result.get("error", "Unknown load error."))
  push_warning(last_error)
  return false

func set_run_state(next_run_state: Variant) -> void:
  run_state = next_run_state

func save_on_node_transition(next_node_id: String, act_index: int = -1) -> bool:
  if run_state == null:
    last_error = "Cannot save run state on node transition: run_state is null."
    push_warning(last_error)
    return false
  if next_node_id.strip_edges() == "":
    last_error = "Cannot save run state on node transition: next_node_id is empty."
    push_warning(last_error)
    return false

  run_state.map_position["node_id"] = next_node_id
  if act_index >= 0:
    run_state.map_position["act_index"] = act_index

  var next_path: Array[String] = []
  var existing_path_variant: Variant = run_state.map_position.get("path", [])
  if typeof(existing_path_variant) == TYPE_ARRAY:
    var existing_path: Array = existing_path_variant
    for existing_path_step: Variant in existing_path:
      if typeof(existing_path_step) == TYPE_STRING:
        next_path.append(String(existing_path_step))
  next_path.append(next_node_id)
  run_state.map_position["path"] = next_path

  return _save("node transition")

func save_on_pause() -> bool:
  return _save("application pause")

func _save(reason: String) -> bool:
  if run_state == null:
    last_error = "Cannot save run state on %s: run_state is null." % reason
    push_warning(last_error)
    return false

  var save_result: Dictionary = _save_store.save(run_state)
  if not bool(save_result.get("ok", false)):
    last_error = "Failed to save run state on %s: %s" % [reason, str(save_result.get("error", "Unknown save error."))]
    push_warning(last_error)
    return false

  last_error = ""
  return true
