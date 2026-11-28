class_name EncounterLoader
extends RefCounted

# Loads and validates data/encounters/*.json (schema: data/encounters/README.md).
# Errors use the same "<file> :: <field> :: <reason>" format as DataLoader.

const ENCOUNTER_NODE_TYPES: PackedStringArray = ["fight", "warden", "boss"]
const ENCOUNTER_POOLS: PackedStringArray = ["intro_1", "intro_2", "intro_3", "mixed", "warden", "boss"]
const POOL_NODE_TYPES: Dictionary = {
	"intro_1": "fight",
	"intro_2": "fight",
	"intro_3": "fight",
	"mixed": "fight",
	"warden": "warden",
	"boss": "boss"
}
const MAX_ENEMIES_PER_ENCOUNTER: int = 3

const ENCOUNTER_DATA_SCRIPT := preload("res://scripts/combat/enemies/encounter_data.gd")
const ENCOUNTER_CATALOG_SCRIPT := preload("res://scripts/combat/enemies/encounter_catalog.gd")

# `enemy_data_list` is GameDataCatalog.enemies (EnemyData instances) so enemy
# references and start offsets can be checked against the loaded patterns.
static func load_all(enemy_data_list: Array, directory_path: String = "res://data/encounters") -> Variant:
	var catalog: Variant = ENCOUNTER_CATALOG_SCRIPT.new()
	var enemies_by_id: Dictionary = enemies_by_id_from_list(enemy_data_list)
	var seen_ids: Dictionary = {}

	for file_path: String in _list_json_files(directory_path, catalog.errors):
		var encounter: Variant = load_encounter_file(file_path, enemies_by_id, catalog.errors)
		if encounter == null:
			continue
		if seen_ids.has(encounter.id):
			_append_error(catalog.errors, file_path, "$.id", "Duplicate encounter id '%s' (also in %s)." % [encounter.id, String(seen_ids[encounter.id])])
			continue
		seen_ids[encounter.id] = file_path
		catalog.encounters.append(encounter)

	return catalog

static func enemies_by_id_from_list(enemy_data_list: Array) -> Dictionary:
	var enemies_by_id: Dictionary = {}
	for enemy_data_variant: Variant in enemy_data_list:
		if enemy_data_variant == null:
			continue
		var enemy_id: String = String(enemy_data_variant.id)
		if enemy_id != "":
			enemies_by_id[enemy_id] = enemy_data_variant
	return enemies_by_id

static func load_encounter_file(file_path: String, enemies_by_id: Dictionary, errors: Array[String]) -> Variant:
	var start_error_count: int = errors.size()
	var root_variant: Variant = _load_json_file(file_path, errors)
	if root_variant == null:
		return null
	if typeof(root_variant) != TYPE_DICTIONARY:
		_append_error(errors, file_path, "$", "Expected a JSON object.")
		return null

	var root: Dictionary = root_variant
	var encounter: Variant = ENCOUNTER_DATA_SCRIPT.new()
	encounter.id = _require_string(root, "id", file_path, "$.id", errors)
	if encounter.id != "" and file_path.get_file() != "%s.json" % encounter.id:
		_append_error(errors, file_path, "$.id", "Expected the file to be named '%s.json'." % encounter.id)

	encounter.node = _require_string(root, "node", file_path, "$.node", errors)
	if encounter.node != "" and not ENCOUNTER_NODE_TYPES.has(encounter.node):
		_append_error(errors, file_path, "$.node", "Unknown node '%s'." % encounter.node)

	encounter.pool = _require_string(root, "pool", file_path, "$.pool", errors)
	if encounter.pool != "" and not ENCOUNTER_POOLS.has(encounter.pool):
		_append_error(errors, file_path, "$.pool", "Unknown pool '%s'." % encounter.pool)
	elif encounter.pool != "" and encounter.node != "" and ENCOUNTER_NODE_TYPES.has(encounter.node):
		var expected_node: String = String(POOL_NODE_TYPES.get(encounter.pool, ""))
		if expected_node != encounter.node:
			_append_error(errors, file_path, "$.node", "Pool '%s' belongs on node '%s', got '%s'." % [encounter.pool, expected_node, encounter.node])

	var weight_error_count: int = errors.size()
	encounter.weight = _require_int(root, "weight", file_path, "$.weight", errors)
	if errors.size() == weight_error_count and encounter.weight <= 0:
		_append_error(errors, file_path, "$.weight", "Expected weight > 0.")

	if not root.has("enemies"):
		_append_error(errors, file_path, "$.enemies", "Missing required field.")
	else:
		var enemies_variant: Variant = root["enemies"]
		if typeof(enemies_variant) != TYPE_ARRAY:
			_append_error(errors, file_path, "$.enemies", "Expected Array, got %s." % type_string(typeof(enemies_variant)))
		else:
			var enemies_array: Array = enemies_variant
			if enemies_array.is_empty():
				_append_error(errors, file_path, "$.enemies", "Expected at least one enemy.")
			if enemies_array.size() > MAX_ENEMIES_PER_ENCOUNTER:
				_append_error(errors, file_path, "$.enemies", "Expected at most %d enemies, got %d." % [MAX_ENEMIES_PER_ENCOUNTER, enemies_array.size()])
			for index: int in range(enemies_array.size()):
				var entry_path: String = "$.enemies[%d]" % index
				var entry_variant: Variant = enemies_array[index]
				if typeof(entry_variant) != TYPE_DICTIONARY:
					_append_error(errors, file_path, entry_path, "Expected Dictionary, got %s." % type_string(typeof(entry_variant)))
					continue
				var entry: Dictionary = entry_variant
				var enemy_id: String = _require_string(entry, "id", file_path, "%s.id" % entry_path, errors)
				var offset_error_count: int = errors.size()
				var start_offset: int = _require_int(entry, "start_offset", file_path, "%s.start_offset" % entry_path, errors)
				var offset_is_valid: bool = errors.size() == offset_error_count
				if offset_is_valid and start_offset < 0:
					_append_error(errors, file_path, "%s.start_offset" % entry_path, "Expected start_offset >= 0.")
					offset_is_valid = false
				if enemy_id != "":
					if not enemies_by_id.has(enemy_id):
						_append_error(errors, file_path, "%s.id" % entry_path, "Unknown enemy id '%s'." % enemy_id)
					elif offset_is_valid:
						var pattern_length: int = enemies_by_id[enemy_id].telegraph_pattern.size()
						if start_offset >= pattern_length:
							_append_error(errors, file_path, "%s.start_offset" % entry_path, "Expected start_offset < telegraph_pattern length %d for enemy '%s'." % [pattern_length, enemy_id])
				encounter.enemies.append({"id": enemy_id, "start_offset": maxi(0, start_offset)})

	if errors.size() > start_error_count:
		return null
	return encounter

static func _list_json_files(directory_path: String, errors: Array[String]) -> Array[String]:
	var file_paths: Array[String] = []
	var directory: DirAccess = DirAccess.open(directory_path)
	if directory == null:
		_append_error(errors, directory_path, "$", "Missing directory.")
		return file_paths

	directory.list_dir_begin()
	var entry: String = directory.get_next()
	while entry != "":
		if not directory.current_is_dir() and entry.ends_with(".json"):
			file_paths.append("%s/%s" % [directory_path, entry])
		entry = directory.get_next()
	directory.list_dir_end()

	file_paths.sort()
	return file_paths

static func _load_json_file(file_path: String, errors: Array[String]) -> Variant:
	if not FileAccess.file_exists(file_path):
		_append_error(errors, file_path, "$", "Missing file.")
		return null

	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		_append_error(errors, file_path, "$", "Could not open file for reading.")
		return null

	var json_parser: JSON = JSON.new()
	var parse_status: int = json_parser.parse(file.get_as_text())
	if parse_status != OK:
		_append_error(errors, file_path, "$", "Invalid JSON at line %d: %s." % [json_parser.get_error_line(), json_parser.get_error_message()])
		return null
	return json_parser.data

static func _require_string(data: Dictionary, key: String, file_path: String, field_path: String, errors: Array[String]) -> String:
	if not data.has(key):
		_append_error(errors, file_path, field_path, "Missing required field.")
		return ""
	var value: Variant = data[key]
	if typeof(value) != TYPE_STRING:
		_append_error(errors, file_path, field_path, "Expected String, got %s." % type_string(typeof(value)))
		return ""
	var string_value: String = value
	if string_value.strip_edges() == "":
		_append_error(errors, file_path, field_path, "Expected a non-empty string.")
	return string_value

static func _require_int(data: Dictionary, key: String, file_path: String, field_path: String, errors: Array[String]) -> int:
	if not data.has(key):
		_append_error(errors, file_path, field_path, "Missing required field.")
		return 0
	var value: Variant = data[key]
	if typeof(value) == TYPE_INT:
		return int(value)
	if typeof(value) == TYPE_FLOAT:
		var float_value: float = value
		if is_equal_approx(float_value, round(float_value)):
			return int(round(float_value))
		_append_error(errors, file_path, field_path, "Expected int, got non-integer float.")
		return 0
	_append_error(errors, file_path, field_path, "Expected int, got %s." % type_string(typeof(value)))
	return 0

static func _append_error(errors: Array[String], file_path: String, field_path: String, reason: String) -> void:
	errors.append("%s :: %s :: %s" % [file_path, field_path, reason])
