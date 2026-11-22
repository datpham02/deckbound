class_name FloorMapLoader
extends RefCounted

const ALLOWED_ROW_TYPES: PackedStringArray = ["start", "fight", "rest", "warden", "boss"]
const EXPECTED_SCHEMA_VERSION: int = 1

static func load_from_path(file_path: String) -> Dictionary:
  if not FileAccess.file_exists(file_path):
    return _failure("Missing floor map file at %s." % file_path)

  var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
  if file == null:
    return _failure("Could not open floor map file at %s." % file_path)

  var json_text: String = file.get_as_text()
  var parser: JSON = JSON.new()
  var parse_error: int = parser.parse(json_text)
  if parse_error != OK:
    return _failure(
      "Floor map JSON is invalid at line %d: %s." % [parser.get_error_line(), parser.get_error_message()]
    )

  return _validate_root(parser.data, file_path)

static func _validate_root(root_variant: Variant, file_path: String) -> Dictionary:
  if typeof(root_variant) != TYPE_DICTIONARY:
    return _failure("%s :: $ :: Expected a JSON object." % file_path)

  var root: Dictionary = root_variant
  var schema_version_result: Dictionary = _require_int(root, "schema_version", file_path, "$.schema_version")
  if not bool(schema_version_result["ok"]):
    return schema_version_result
  var schema_version: int = int(schema_version_result["value"])
  if schema_version != EXPECTED_SCHEMA_VERSION:
    return _failure(
      "%s :: $.schema_version :: Expected schema_version %d, got %d." % [
        file_path,
        EXPECTED_SCHEMA_VERSION,
        schema_version
      ]
    )

  var seed_offset_result: Dictionary = _require_int(root, "seed_offset", file_path, "$.seed_offset")
  if not bool(seed_offset_result["ok"]):
    return seed_offset_result

  var layout_result: Dictionary = _require_layout(root, file_path)
  if not bool(layout_result["ok"]):
    return layout_result

  var touch_result: Dictionary = _require_touch(root, file_path)
  if not bool(touch_result["ok"]):
    return touch_result

  var branching_result: Dictionary = _require_branching(root, file_path)
  if not bool(branching_result["ok"]):
    return branching_result

  var rows_result: Dictionary = _require_rows(root, file_path)
  if not bool(rows_result["ok"]):
    return rows_result

  return {
    "ok": true,
    "floor_data": {
      "schema_version": schema_version,
      "seed_offset": int(seed_offset_result["value"]),
      "layout": layout_result["value"],
      "touch": touch_result["value"],
      "branching": branching_result["value"],
      "rows": rows_result["value"]
    }
  }

static func _require_layout(root: Dictionary, file_path: String) -> Dictionary:
  if not root.has("layout"):
    return _failure("%s :: $.layout :: Missing required field." % file_path)
  if typeof(root["layout"]) != TYPE_DICTIONARY:
    return _failure("%s :: $.layout :: Expected Dictionary." % file_path)

  var layout: Dictionary = root["layout"]
  var origin_x_result: Dictionary = _require_int(layout, "origin_x", file_path, "$.layout.origin_x")
  if not bool(origin_x_result["ok"]):
    return origin_x_result
  var origin_y_result: Dictionary = _require_int(layout, "origin_y", file_path, "$.layout.origin_y")
  if not bool(origin_y_result["ok"]):
    return origin_y_result
  var column_spacing_result: Dictionary = _require_int(layout, "column_spacing", file_path, "$.layout.column_spacing")
  if not bool(column_spacing_result["ok"]):
    return column_spacing_result
  var row_spacing_result: Dictionary = _require_int(layout, "row_spacing", file_path, "$.layout.row_spacing")
  if not bool(row_spacing_result["ok"]):
    return row_spacing_result

  var column_spacing: int = int(column_spacing_result["value"])
  var row_spacing: int = int(row_spacing_result["value"])
  if column_spacing <= 0:
    return _failure("%s :: $.layout.column_spacing :: Expected column_spacing > 0." % file_path)
  if row_spacing <= 0:
    return _failure("%s :: $.layout.row_spacing :: Expected row_spacing > 0." % file_path)

  return {
    "ok": true,
    "value": {
      "origin_x": int(origin_x_result["value"]),
      "origin_y": int(origin_y_result["value"]),
      "column_spacing": column_spacing,
      "row_spacing": row_spacing
    }
  }

static func _require_touch(root: Dictionary, file_path: String) -> Dictionary:
  if not root.has("touch"):
    return _failure("%s :: $.touch :: Missing required field." % file_path)
  if typeof(root["touch"]) != TYPE_DICTIONARY:
    return _failure("%s :: $.touch :: Expected Dictionary." % file_path)

  var touch: Dictionary = root["touch"]
  var node_diameter_result: Dictionary = _require_int(touch, "node_diameter", file_path, "$.touch.node_diameter")
  if not bool(node_diameter_result["ok"]):
    return node_diameter_result
  var line_width_result: Dictionary = _require_int(touch, "line_width", file_path, "$.touch.line_width")
  if not bool(line_width_result["ok"]):
    return line_width_result

  var node_diameter: int = int(node_diameter_result["value"])
  var line_width: int = int(line_width_result["value"])
  if node_diameter <= 0:
    return _failure("%s :: $.touch.node_diameter :: Expected node_diameter > 0." % file_path)
  if line_width <= 0:
    return _failure("%s :: $.touch.line_width :: Expected line_width > 0." % file_path)

  return {
    "ok": true,
    "value": {
      "node_diameter": node_diameter,
      "line_width": line_width
    }
  }

static func _require_branching(root: Dictionary, file_path: String) -> Dictionary:
  if not root.has("branching"):
    return _failure("%s :: $.branching :: Missing required field." % file_path)
  if typeof(root["branching"]) != TYPE_DICTIONARY:
    return _failure("%s :: $.branching :: Expected Dictionary." % file_path)

  var branching: Dictionary = root["branching"]
  var chance_result: Dictionary = _require_int(
    branching,
    "extra_connection_chance_percent",
    file_path,
    "$.branching.extra_connection_chance_percent"
  )
  if not bool(chance_result["ok"]):
    return chance_result

  var chance: int = int(chance_result["value"])
  if chance < 0 or chance > 100:
    return _failure(
      "%s :: $.branching.extra_connection_chance_percent :: Expected value in [0, 100], got %d." % [
        file_path,
        chance
      ]
    )

  return {
    "ok": true,
    "value": {
      "extra_connection_chance_percent": chance
    }
  }

static func _require_rows(root: Dictionary, file_path: String) -> Dictionary:
  if not root.has("rows"):
    return _failure("%s :: $.rows :: Missing required field." % file_path)
  if typeof(root["rows"]) != TYPE_ARRAY:
    return _failure("%s :: $.rows :: Expected Array." % file_path)

  var rows_variant: Array = root["rows"]
  if rows_variant.size() < 5:
    return _failure("%s :: $.rows :: Expected at least 5 rows." % file_path)

  var rows: Array[Dictionary] = []
  var warden_row_count: int = 0
  var rest_row_count: int = 0

  for row_index: int in range(rows_variant.size()):
    var row_variant: Variant = rows_variant[row_index]
    var row_path: String = "$.rows[%d]" % row_index
    if typeof(row_variant) != TYPE_DICTIONARY:
      return _failure("%s :: %s :: Expected Dictionary." % [file_path, row_path])

    var row_data: Dictionary = row_variant
    var type_result: Dictionary = _require_string(row_data, "type", file_path, "%s.type" % row_path)
    if not bool(type_result["ok"]):
      return type_result
    var row_type: String = String(type_result["value"])
    if not ALLOWED_ROW_TYPES.has(row_type):
      return _failure(
        "%s :: %s.type :: Expected one of [%s], got '%s'." % [
          file_path,
          row_path,
          ", ".join(ALLOWED_ROW_TYPES),
          row_type
        ]
      )

    var node_count_result: Dictionary = _require_int(row_data, "node_count", file_path, "%s.node_count" % row_path)
    if not bool(node_count_result["ok"]):
      return node_count_result
    var node_count: int = int(node_count_result["value"])
    if node_count <= 0:
      return _failure("%s :: %s.node_count :: Expected node_count > 0." % [file_path, row_path])

    if row_type == "warden":
      warden_row_count += 1
    if row_type == "rest":
      rest_row_count += 1
    rows.append({
      "type": row_type,
      "node_count": node_count
    })

  if String(rows[0]["type"]) != "start":
    return _failure("%s :: $.rows[0].type :: First row must be 'start'." % file_path)
  if int(rows[0]["node_count"]) != 1:
    return _failure("%s :: $.rows[0].node_count :: Start row must contain exactly 1 node." % file_path)

  var boss_index: int = rows.size() - 1
  if String(rows[boss_index]["type"]) != "boss":
    return _failure("%s :: $.rows[%d].type :: Last row must be 'boss'." % [file_path, boss_index])
  if int(rows[boss_index]["node_count"]) != 1:
    return _failure("%s :: $.rows[%d].node_count :: Boss row must contain exactly 1 node." % [file_path, boss_index])

  if warden_row_count != 1:
    return _failure("%s :: $.rows :: Expected exactly one warden row, got %d." % [file_path, warden_row_count])
  if rest_row_count < 1:
    return _failure("%s :: $.rows :: Expected at least one rest row." % file_path)

  if rows.size() < 4:
    return _failure("%s :: $.rows :: Expected enough rows to contain intro fights." % file_path)
  for intro_row_index: int in [1, 2, 3]:
    if intro_row_index >= rows.size():
      break
    if String(rows[intro_row_index]["type"]) != "fight":
      return _failure(
        "%s :: $.rows[%d].type :: Intro rows 1-3 must be 'fight' to satisfy encounter coverage." % [
          file_path,
          intro_row_index
        ]
      )

  for mid_row_index: int in range(1, rows.size() - 1):
    var mid_type: String = String(rows[mid_row_index]["type"])
    if mid_type == "start":
      return _failure("%s :: $.rows[%d].type :: 'start' may only appear in the first row." % [file_path, mid_row_index])
    if mid_type == "boss":
      return _failure("%s :: $.rows[%d].type :: 'boss' may only appear in the last row." % [file_path, mid_row_index])

  return {
    "ok": true,
    "value": rows
  }

static func _require_int(data: Dictionary, key: String, file_path: String, field_path: String) -> Dictionary:
  if not data.has(key):
    return _failure("%s :: %s :: Missing required field." % [file_path, field_path])

  var value: Variant = data[key]
  if typeof(value) == TYPE_INT:
    return {"ok": true, "value": int(value)}
  if typeof(value) == TYPE_FLOAT:
    var float_value: float = value
    if is_equal_approx(float_value, round(float_value)):
      return {"ok": true, "value": int(round(float_value))}
    return _failure("%s :: %s :: Expected int, got non-integer float." % [file_path, field_path])

  return _failure("%s :: %s :: Expected int, got %s." % [file_path, field_path, type_string(typeof(value))])

static func _require_string(data: Dictionary, key: String, file_path: String, field_path: String) -> Dictionary:
  if not data.has(key):
    return _failure("%s :: %s :: Missing required field." % [file_path, field_path])

  var value: Variant = data[key]
  if typeof(value) != TYPE_STRING:
    return _failure("%s :: %s :: Expected String, got %s." % [file_path, field_path, type_string(typeof(value))])

  var string_value: String = String(value)
  if string_value.strip_edges() == "":
    return _failure("%s :: %s :: Expected a non-empty string." % [file_path, field_path])

  return {"ok": true, "value": string_value}

static func _failure(error_message: String) -> Dictionary:
  return {
    "ok": false,
    "error": error_message
  }
