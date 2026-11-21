class_name RunSaveStore
extends RefCounted

const RUN_SAVE_CODEC_SCRIPT := preload("res://scripts/save/run_save_codec.gd")

const DEFAULT_SAVE_PATH: String = "user://run_state.json"

var _save_path: String = DEFAULT_SAVE_PATH

func _init(save_path: String = DEFAULT_SAVE_PATH) -> void:
  _save_path = save_path

func get_save_path() -> String:
  return _save_path

func save(run_state: Variant) -> Dictionary:
  var file: FileAccess = FileAccess.open(_save_path, FileAccess.WRITE)
  if file == null:
    var open_error: int = FileAccess.get_open_error()
    return _failure("Could not open save file for writing at %s (%s)." % [_save_path, error_string(open_error)])

  var payload: Dictionary = RUN_SAVE_CODEC_SCRIPT.encode(run_state)
  file.store_string(JSON.stringify(payload, "\t"))
  return {"ok": true}

func load() -> Dictionary:
  if not FileAccess.file_exists(_save_path):
    return _failure("No save file found at %s." % _save_path, true)

  var file: FileAccess = FileAccess.open(_save_path, FileAccess.READ)
  if file == null:
    var open_error: int = FileAccess.get_open_error()
    return _failure("Could not open save file for reading at %s (%s)." % [_save_path, error_string(open_error)])

  var json_text: String = file.get_as_text()
  var parser: JSON = JSON.new()
  var parse_error: int = parser.parse(json_text)
  if parse_error != OK:
    return _failure(
      "Save file is corrupt (invalid JSON at line %d: %s)." % [
        parser.get_error_line(),
        parser.get_error_message()
      ]
    )

  var decode_result: Dictionary = RUN_SAVE_CODEC_SCRIPT.decode(parser.data)
  if not bool(decode_result.get("ok", false)):
    return _failure("Save file is invalid: %s" % str(decode_result.get("error", "Unknown decode error.")))

  return {
    "ok": true,
    "run_state": decode_result["run_state"]
  }

func clear() -> Dictionary:
  if not FileAccess.file_exists(_save_path):
    return {"ok": true}

  var absolute_path: String = ProjectSettings.globalize_path(_save_path)
  var remove_error: int = DirAccess.remove_absolute(absolute_path)
  if remove_error != OK:
    return _failure("Could not delete save file at %s (%s)." % [_save_path, error_string(remove_error)])

  return {"ok": true}

func _failure(error_message: String, missing: bool = false) -> Dictionary:
  return {
    "ok": false,
    "error": error_message,
    "missing": missing
  }
