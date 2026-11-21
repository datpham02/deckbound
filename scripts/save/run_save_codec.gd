class_name RunSaveCodec
extends RefCounted

const RUN_STATE_SCRIPT := preload("res://scripts/run/run_state.gd")

static func encode(run_state: Variant) -> Dictionary:
  return run_state.to_dictionary()

static func decode(root_variant: Variant) -> Dictionary:
  if typeof(root_variant) != TYPE_DICTIONARY:
    return _failure("Save root must be a JSON object.")

  var root: Dictionary = root_variant
  var schema_version_result: Dictionary = _require_int(root, "schema_version", "$.schema_version")
  if not bool(schema_version_result["ok"]):
    return schema_version_result
  var schema_version: int = int(schema_version_result["value"])
  if schema_version != RUN_STATE_SCRIPT.CURRENT_SCHEMA_VERSION:
    return _failure(
      "Unsupported save schema version %d. Expected %d." % [
        schema_version,
        RUN_STATE_SCRIPT.CURRENT_SCHEMA_VERSION
      ]
    )

  var seed_result: Dictionary = _require_int(root, "seed", "$.seed")
  if not bool(seed_result["ok"]):
    return seed_result

  var health_result: Dictionary = _require_int(root, "health", "$.health")
  if not bool(health_result["ok"]):
    return health_result
  var health: int = int(health_result["value"])
  if health <= 0:
    return _failure("Expected $.health to be > 0.")

  var deck_result: Dictionary = _require_string_array(root, "deck", "$.deck")
  if not bool(deck_result["ok"]):
    return deck_result

  var bindings_result: Dictionary = _require_bindings(root, "bindings", "$.bindings")
  if not bool(bindings_result["ok"]):
    return bindings_result

  var map_position_result: Dictionary = _require_map_position(root, "map_position", "$.map_position")
  if not bool(map_position_result["ok"]):
    return map_position_result

  var run_state: Variant = RUN_STATE_SCRIPT.new()
  run_state.schema_version = schema_version
  run_state.seed = int(seed_result["value"])
  run_state.health = health
  run_state.deck = deck_result["value"]
  run_state.bindings = bindings_result["value"]
  run_state.map_position = map_position_result["value"]

  return {
    "ok": true,
    "run_state": run_state
  }

static func _require_int(data: Dictionary, key: String, field_path: String) -> Dictionary:
  if not data.has(key):
    return _failure("Missing required field %s." % field_path)

  var value: Variant = data[key]
  if typeof(value) == TYPE_INT:
    return {
      "ok": true,
      "value": int(value)
    }

  if typeof(value) == TYPE_FLOAT:
    var float_value: float = value
    if is_equal_approx(float_value, round(float_value)):
      return {
        "ok": true,
        "value": int(round(float_value))
      }
    return _failure("Expected %s to be int, got non-integer float." % field_path)

  return _failure("Expected %s to be int, got %s." % [field_path, type_string(typeof(value))])

static func _require_string(data: Dictionary, key: String, field_path: String) -> Dictionary:
  if not data.has(key):
    return _failure("Missing required field %s." % field_path)

  var value: Variant = data[key]
  if typeof(value) != TYPE_STRING:
    return _failure("Expected %s to be String, got %s." % [field_path, type_string(typeof(value))])

  var string_value: String = value
  if string_value.strip_edges() == "":
    return _failure("Expected %s to be a non-empty string." % field_path)

  return {
    "ok": true,
    "value": string_value
  }

static func _require_string_array(data: Dictionary, key: String, field_path: String) -> Dictionary:
  if not data.has(key):
    return _failure("Missing required field %s." % field_path)

  var array_variant: Variant = data[key]
  if typeof(array_variant) != TYPE_ARRAY:
    return _failure("Expected %s to be Array, got %s." % [field_path, type_string(typeof(array_variant))])

  var array_value: Array = array_variant
  var result: Array[String] = []
  for index: int in range(array_value.size()):
    var item_variant: Variant = array_value[index]
    var item_path: String = "%s[%d]" % [field_path, index]
    if typeof(item_variant) != TYPE_STRING:
      return _failure("Expected %s to be String, got %s." % [item_path, type_string(typeof(item_variant))])
    var item: String = item_variant
    if item.strip_edges() == "":
      return _failure("Expected %s to be a non-empty string." % item_path)
    result.append(item)

  return {
    "ok": true,
    "value": result
  }

static func _require_bindings(data: Dictionary, key: String, field_path: String) -> Dictionary:
  if not data.has(key):
    return _failure("Missing required field %s." % field_path)

  var bindings_variant: Variant = data[key]
  if typeof(bindings_variant) != TYPE_ARRAY:
    return _failure("Expected %s to be Array, got %s." % [field_path, type_string(typeof(bindings_variant))])

  var seen_slots: Dictionary = {}
  var bindings_array: Array = bindings_variant
  var bindings: Array[Dictionary] = []
  for index: int in range(bindings_array.size()):
    var binding_variant: Variant = bindings_array[index]
    var binding_path: String = "%s[%d]" % [field_path, index]
    if typeof(binding_variant) != TYPE_DICTIONARY:
      return _failure("Expected %s to be Dictionary, got %s." % [binding_path, type_string(typeof(binding_variant))])

    var binding_data: Dictionary = binding_variant
    var slot_result: Dictionary = _require_int(binding_data, "slot_index", "%s.slot_index" % binding_path)
    if not bool(slot_result["ok"]):
      return slot_result
    var slot_index: int = int(slot_result["value"])
    if slot_index < 0:
      return _failure("Expected %s.slot_index to be >= 0." % binding_path)
    if seen_slots.has(slot_index):
      return _failure("Duplicate binding slot_index %d in %s." % [slot_index, field_path])
    seen_slots[slot_index] = true

    var page_id_result: Dictionary = _require_optional_string(binding_data, "page_id", "%s.page_id" % binding_path)
    if not bool(page_id_result["ok"]):
      return page_id_result

    var status_result: Dictionary = _require_string(binding_data, "status", "%s.status" % binding_path)
    if not bool(status_result["ok"]):
      return status_result
    var status: String = status_result["value"]
    if not RUN_STATE_SCRIPT.BINDING_STATUSES.has(status):
      return _failure(
        "Expected %s.status to be one of [%s], got '%s'." % [
          binding_path,
          ", ".join(RUN_STATE_SCRIPT.BINDING_STATUSES),
          status
        ]
      )

    bindings.append({
      "slot_index": slot_index,
      "page_id": page_id_result["value"],
      "status": status
    })

  return {
    "ok": true,
    "value": bindings
  }

static func _require_map_position(data: Dictionary, key: String, field_path: String) -> Dictionary:
  if not data.has(key):
    return _failure("Missing required field %s." % field_path)

  var map_position_variant: Variant = data[key]
  if typeof(map_position_variant) != TYPE_DICTIONARY:
    return _failure("Expected %s to be Dictionary, got %s." % [field_path, type_string(typeof(map_position_variant))])

  var map_position_data: Dictionary = map_position_variant
  var act_index_result: Dictionary = _require_int(map_position_data, "act_index", "%s.act_index" % field_path)
  if not bool(act_index_result["ok"]):
    return act_index_result
  var act_index: int = int(act_index_result["value"])
  if act_index < 0:
    return _failure("Expected %s.act_index to be >= 0." % field_path)

  var node_id_result: Dictionary = _require_string(map_position_data, "node_id", "%s.node_id" % field_path)
  if not bool(node_id_result["ok"]):
    return node_id_result

  var path_result: Dictionary = _require_string_array(map_position_data, "path", "%s.path" % field_path)
  if not bool(path_result["ok"]):
    return path_result

  return {
    "ok": true,
    "value": {
      "act_index": act_index,
      "node_id": node_id_result["value"],
      "path": path_result["value"]
    }
  }

static func _require_optional_string(data: Dictionary, key: String, field_path: String) -> Dictionary:
  if not data.has(key):
    return {
      "ok": true,
      "value": ""
    }

  var value: Variant = data[key]
  if typeof(value) != TYPE_STRING:
    return _failure("Expected %s to be String, got %s." % [field_path, type_string(typeof(value))])

  return {
    "ok": true,
    "value": String(value)
  }

static func _failure(error_message: String) -> Dictionary:
  return {
    "ok": false,
    "error": error_message
  }
