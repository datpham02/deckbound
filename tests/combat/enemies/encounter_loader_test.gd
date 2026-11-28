extends "res://tests/combat/enemies/enemy_test_support.gd"

# Composition loading (docs/design/enemies.md §9 criteria 1 and 2, §5.2) and
# loader validation against the schema in data/encounters/README.md.

const TEMP_DIRECTORY: String = "user://t8_encounter_loader_test"

# id -> [pool, node, weight, [[enemy_id, start_offset], ...]] from enemies note §5.2.
const EXPECTED_COMPOSITIONS: Dictionary = {
	"bailiff_solo": ["intro_1", "fight", 1, [["bailiff", 0]]],
	"bookmoth_pair": ["intro_2", "fight", 1, [["bookmoth", 0], ["bookmoth", 1]]],
	"blotter_solo": ["intro_3", "fight", 1, [["blotter", 0]]],
	"bailiff_pair": ["mixed", "fight", 2, [["bailiff", 0], ["bailiff", 1]]],
	"bailiff_bookmoth": ["mixed", "fight", 2, [["bookmoth", 0], ["bailiff", 0]]],
	"bailiff_blotter": ["mixed", "fight", 2, [["blotter", 0], ["bailiff", 1]]],
	"bookmoth_blotter": ["mixed", "fight", 2, [["bookmoth", 1], ["blotter", 0]]],
	"bookmoth_pair_bailiff": ["mixed", "fight", 1, [["bookmoth", 0], ["bookmoth", 1], ["bailiff", 2]]],
	"clerks_three": ["mixed", "fight", 1, [["bookmoth", 0], ["blotter", 0], ["bailiff", 1]]],
	"registrar": ["warden", "warden", 1, [["registrar", 0]]],
	"redactor": ["boss", "boss", 1, [["redactor", 0]]]
}

# id -> [health, size_class, telegraph_pattern] from enemies note §4.
const EXPECTED_ENEMIES: Dictionary = {
	"bailiff": [26, "common", ["rap", "rap", "brace"]],
	"bookmoth": [12, "common", ["unpick", "nibble", "nibble"]],
	"blotter": [22, "common", ["file", "smear", "smear", "brace"]],
	"registrar": [58, "warden", ["strike", "press", "strike", "brace", "seal_press"]],
	"redactor": [96, "boss", ["p1_strike_1", "p1_strike_out", "p1_brace", "p1_strike_2"]]
}

func test() -> void:
	_test_five_enemies_load_with_note_values()
	_test_eleven_compositions_load_with_note_values()
	_test_pool_lookups_and_weighted_pick_are_seeded()
	_test_pick_from_pool_excludes_previous_id_when_pool_offers_another()
	_test_loader_reports_schema_errors()
	_test_loader_reports_missing_directory_and_misnamed_copies()

func _test_five_enemies_load_with_note_values() -> void:
	_load_data()
	assert_equal(_enemies_by_id.size(), EXPECTED_ENEMIES.size(), "data/enemies should hold exactly the five M1 enemies.")
	for enemy_id_variant: Variant in EXPECTED_ENEMIES.keys():
		var enemy_id: String = String(enemy_id_variant)
		assert_true(_enemies_by_id.has(enemy_id), "Enemy '%s' should load." % enemy_id)
		if not _enemies_by_id.has(enemy_id):
			continue
		var expected: Array = EXPECTED_ENEMIES[enemy_id]
		var enemy_data: Variant = _enemies_by_id[enemy_id]
		assert_equal(int(enemy_data.health), int(expected[0]), "Health of '%s'." % enemy_id)
		assert_equal(String(enemy_data.size_class), String(expected[1]), "Size class of '%s'." % enemy_id)
		assert_equal(Array(enemy_data.telegraph_pattern), Array(expected[2]), "Telegraph pattern of '%s'." % enemy_id)

	var redactor: Variant = _enemies_by_id.get("redactor", null)
	if redactor != null:
		assert_equal(redactor.phases.size(), 1, "The Redactor should have one phase entry.")
		if redactor.phases.size() == 1:
			var phase: Dictionary = redactor.phases[0]
			assert_equal(int(phase.get("health_at_or_below", 0)), 48, "The Redactor switches phase at 48 health.")
			assert_equal(Array(phase.get("telegraph_pattern", [])), ["p2_strike_out", "p2_strike_1", "p2_brace", "p2_strike_2"], "Phase 2 pattern.")

func _test_eleven_compositions_load_with_note_values() -> void:
	_load_data()
	assert_equal(_encounters.encounters.size(), EXPECTED_COMPOSITIONS.size(), "data/encounters should hold exactly the eleven M1 compositions.")
	for encounter_id_variant: Variant in EXPECTED_COMPOSITIONS.keys():
		var encounter_id: String = String(encounter_id_variant)
		var encounter: Variant = _encounters.get_by_id(encounter_id)
		assert_true(encounter != null, "Composition '%s' should load." % encounter_id)
		if encounter == null:
			continue
		var expected: Array = EXPECTED_COMPOSITIONS[encounter_id]
		assert_equal(String(encounter.pool), String(expected[0]), "Pool of '%s'." % encounter_id)
		assert_equal(String(encounter.node), String(expected[1]), "Node of '%s'." % encounter_id)
		assert_equal(int(encounter.weight), int(expected[2]), "Weight of '%s'." % encounter_id)
		var expected_enemies: Array = expected[3]
		assert_equal(encounter.enemy_count(), expected_enemies.size(), "Enemy count of '%s'." % encounter_id)
		for position: int in range(mini(encounter.enemy_count(), expected_enemies.size())):
			var expected_entry: Array = expected_enemies[position]
			assert_equal(encounter.enemy_id_at(position), String(expected_entry[0]), "Enemy at position %d of '%s'." % [position, encounter_id])
			assert_equal(encounter.start_offset_at(position), int(expected_entry[1]), "Start offset at position %d of '%s'." % [position, encounter_id])

	assert_equal(_encounters.get_by_id("missing"), null, "Unknown composition ids resolve to null.")
	assert_equal(_encounters.pool_names(), ["boss", "intro_1", "intro_2", "intro_3", "mixed", "warden"], "All six pools are present.")

func _test_pool_lookups_and_weighted_pick_are_seeded() -> void:
	_load_data()
	assert_equal(_encounters.get_pool("mixed").size(), 6, "The mixed pool offers six compositions.")
	assert_equal(_encounters.get_pool("intro_2").size(), 1, "intro_2 offers one composition.")
	assert_equal(_encounters.get_pool("no_such_pool").size(), 0, "Unknown pools are empty.")
	assert_equal(_encounters.pick_from_pool("no_such_pool", RandomNumberGenerator.new()), null, "Picking from an empty pool returns null.")

	var first_rng: RandomNumberGenerator = RandomNumberGenerator.new()
	first_rng.seed = 2026
	var second_rng: RandomNumberGenerator = RandomNumberGenerator.new()
	second_rng.seed = 2026
	var picked_ids: Dictionary = {}
	for _draw: int in range(40):
		var first_pick: Variant = _encounters.pick_from_pool("mixed", first_rng)
		var second_pick: Variant = _encounters.pick_from_pool("mixed", second_rng)
		assert_true(first_pick != null and second_pick != null, "Mixed pool picks should never be null.")
		if first_pick == null or second_pick == null:
			continue
		assert_equal(String(first_pick.id), String(second_pick.id), "The same seed reproduces the same pool draws.")
		assert_equal(String(first_pick.pool), "mixed", "Pool picks come from the requested pool.")
		picked_ids[String(first_pick.id)] = true
	assert_true(picked_ids.size() >= 2, "Forty seeded draws from a weighted six-member pool should reach more than one composition.")

func _test_pick_from_pool_excludes_previous_id_when_pool_offers_another() -> void:
	_load_data()
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 99
	for _draw: int in range(40):
		var pick: Variant = _encounters.pick_from_pool("mixed", rng, "bailiff_pair")
		assert_true(pick != null and String(pick.id) != "bailiff_pair", "Rule 4: the previous composition is excluded while the pool offers another.")

	var only_member: Variant = _encounters.pick_from_pool("warden", rng, "registrar")
	assert_true(only_member != null and String(only_member.id) == "registrar", "A single-member pool returns its member even when it is excluded.")

func _test_loader_reports_schema_errors() -> void:
	_load_data()
	_reset_temp_directory()
	_write_temp_json("bad_pool.json", {
		"id": "bad_pool", "node": "fight", "pool": "warden", "weight": 1,
		"enemies": [{"id": "bailiff", "start_offset": 0}]
	})
	_write_temp_json("bad_offset.json", {
		"id": "bad_offset", "node": "fight", "pool": "mixed", "weight": 1,
		"enemies": [{"id": "bailiff", "start_offset": 3}]
	})
	_write_temp_json("unknown_enemy.json", {
		"id": "unknown_enemy", "node": "fight", "pool": "mixed", "weight": 1,
		"enemies": [{"id": "archivist", "start_offset": 0}]
	})
	_write_temp_json("too_many.json", {
		"id": "too_many", "node": "fight", "pool": "mixed", "weight": 1,
		"enemies": [
			{"id": "bailiff", "start_offset": 0}, {"id": "bailiff", "start_offset": 0},
			{"id": "bailiff", "start_offset": 0}, {"id": "bailiff", "start_offset": 0}
		]
	})
	_write_temp_json("zero_weight.json", {
		"id": "zero_weight", "node": "fight", "pool": "mixed", "weight": 0,
		"enemies": [{"id": "bailiff", "start_offset": 0}]
	})
	_write_temp_json("misnamed.json", {
		"id": "other_name", "node": "fight", "pool": "mixed", "weight": 1,
		"enemies": [{"id": "bailiff", "start_offset": 0}]
	})
	_write_temp_json("missing_fields.json", {"id": "missing_fields"})
	_write_temp_json("float_offset.json", {
		"id": "float_offset", "node": "fight", "pool": "mixed", "weight": 1.0,
		"enemies": [{"id": "bailiff", "start_offset": 1.0}]
	})
	_write_temp_text("not_json.json", "{ not json")

	var catalog: Variant = ENCOUNTER_LOADER_SCRIPT.load_all(_catalog.enemies, TEMP_DIRECTORY)
	_remove_temp_directory()

	assert_true(catalog.has_errors(), "Malformed compositions should produce errors.")
	assert_equal(catalog.encounters.size(), 1, "Only the integer-valued float composition should load.")
	assert_true(catalog.get_by_id("float_offset") != null, "Integer-valued JSON floats are accepted for weight and start_offset.")
	if catalog.get_by_id("float_offset") != null:
		assert_equal(catalog.get_by_id("float_offset").start_offset_at(0), 1, "Float start_offset should convert to int.")

	assert_true(_array_contains_substring(catalog.errors, "bad_pool.json :: $.node :: Pool 'warden' belongs on node 'warden', got 'fight'."), "Pool and node must agree.")
	assert_true(_array_contains_substring(catalog.errors, "bad_offset.json :: $.enemies[0].start_offset :: Expected start_offset < telegraph_pattern length 3 for enemy 'bailiff'."), "Offsets beyond the pattern are rejected.")
	assert_true(_array_contains_substring(catalog.errors, "unknown_enemy.json :: $.enemies[0].id :: Unknown enemy id 'archivist'."), "Unknown enemy ids are rejected.")
	assert_true(_array_contains_substring(catalog.errors, "too_many.json :: $.enemies :: Expected at most 3 enemies, got 4."), "More than three enemies are rejected.")
	assert_true(_array_contains_substring(catalog.errors, "zero_weight.json :: $.weight :: Expected weight > 0."), "Zero weight is rejected.")
	assert_true(_array_contains_substring(catalog.errors, "misnamed.json :: $.id :: Expected the file to be named 'other_name.json'."), "File name must match id.")
	assert_true(_array_contains_substring(catalog.errors, "missing_fields.json :: $.node :: Missing required field."), "Missing node is reported.")
	assert_true(_array_contains_substring(catalog.errors, "missing_fields.json :: $.pool :: Missing required field."), "Missing pool is reported.")
	assert_true(_array_contains_substring(catalog.errors, "missing_fields.json :: $.weight :: Missing required field."), "Missing weight is reported.")
	assert_true(_array_contains_substring(catalog.errors, "missing_fields.json :: $.enemies :: Missing required field."), "Missing enemies is reported.")
	assert_true(_array_contains_substring(catalog.errors, "not_json.json :: $ :: Invalid JSON"), "Unparseable files are reported with the file path.")

func _test_loader_reports_missing_directory_and_misnamed_copies() -> void:
	_load_data()
	var missing: Variant = ENCOUNTER_LOADER_SCRIPT.load_all(_catalog.enemies, "user://t8_no_such_directory")
	assert_true(_array_contains_substring(missing.errors, "user://t8_no_such_directory :: $ :: Missing directory."), "A missing folder is one error, not a crash.")
	assert_equal(missing.encounters.size(), 0, "A missing folder loads nothing.")

	_reset_temp_directory()
	var duplicate: Dictionary = {
		"id": "bailiff_solo", "node": "fight", "pool": "intro_1", "weight": 1,
		"enemies": [{"id": "bailiff", "start_offset": 0}]
	}
	_write_temp_json("bailiff_solo.json", duplicate)
	var copy: Dictionary = duplicate.duplicate(true)
	_write_temp_json("bailiff_solo_copy.json", copy)
	var catalog: Variant = ENCOUNTER_LOADER_SCRIPT.load_all(_catalog.enemies, TEMP_DIRECTORY)
	_remove_temp_directory()
	assert_true(_array_contains_substring(catalog.errors, "bailiff_solo_copy.json :: $.id :: Expected the file to be named 'bailiff_solo.json'."), "The misnamed copy fails its name check.")
	assert_equal(catalog.encounters.size(), 1, "Only the correctly named composition loads.")

	# Two correctly named files cannot share an id on one disk (the file name
	# carries the id), so the loader's duplicate-id guard is defensive only.
	var first: Variant = catalog.get_by_id("bailiff_solo")
	assert_true(first != null, "The well-formed composition should load.")

func _reset_temp_directory() -> void:
	_remove_temp_directory()
	var created: int = DirAccess.make_dir_recursive_absolute(TEMP_DIRECTORY)
	assert_equal(created, OK, "Temp directory should be creatable under user://.")

func _remove_temp_directory() -> void:
	var directory: DirAccess = DirAccess.open(TEMP_DIRECTORY)
	if directory == null:
		return
	for file_name: String in directory.get_files():
		directory.remove(file_name)
	DirAccess.remove_absolute(TEMP_DIRECTORY)

func _write_temp_json(file_name: String, content: Dictionary) -> void:
	_write_temp_text(file_name, JSON.stringify(content, "  "))

func _write_temp_text(file_name: String, text: String) -> void:
	var file: FileAccess = FileAccess.open("%s/%s" % [TEMP_DIRECTORY, file_name], FileAccess.WRITE)
	assert_true(file != null, "Temp file '%s' should be writable." % file_name)
	if file == null:
		return
	file.store_string(text)
	file.close()
