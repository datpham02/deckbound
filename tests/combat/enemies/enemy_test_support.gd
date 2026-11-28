extends "res://tests/framework/test_case.gd"

# Shared helpers for tests/combat/enemies/*. Not a test case itself (no
# _test.gd suffix). Every helper runs the real data/ files through the real
# loaders so the tests exercise the shipped enemies and compositions.

const DATA_LOADER_SCRIPT := preload("res://scripts/data/data_loader.gd")
const ENCOUNTER_LOADER_SCRIPT := preload("res://scripts/combat/enemies/encounter_loader.gd")
const ENCOUNTER_DATA_SCRIPT := preload("res://scripts/combat/enemies/encounter_data.gd")
const ENCOUNTER_SPAWNER_SCRIPT := preload("res://scripts/combat/enemies/encounter_spawner.gd")
const COMBAT_CORE_SCRIPT := preload("res://scripts/combat/core/combat_core.gd")
const COMBAT_CARD_SCRIPT := preload("res://scripts/combat/core/combat_card.gd")

const STAIN_PAGE_IDS: PackedStringArray = ["water_stain"]

var _catalog: Variant = null
var _encounters: Variant = null
var _enemies_by_id: Dictionary = {}
var _pages_by_id: Dictionary = {}

func _load_data() -> void:
	if _catalog != null:
		return
	_catalog = DATA_LOADER_SCRIPT.load_all()
	assert_true(not _catalog.has_errors(), "res://data should load cleanly: %s" % str(_catalog.errors))
	_enemies_by_id = ENCOUNTER_LOADER_SCRIPT.enemies_by_id_from_list(_catalog.enemies)
	for page_variant: Variant in _catalog.pages:
		_pages_by_id[String(page_variant.id)] = page_variant
	_encounters = ENCOUNTER_LOADER_SCRIPT.load_all(_catalog.enemies)
	assert_true(not _encounters.has_errors(), "res://data/encounters should load cleanly: %s" % str(_encounters.errors))

func _starting_deck_pages() -> Array:
	var pages: Array = []
	for page_id: String in _catalog.run_rules.starting_deck:
		if _pages_by_id.has(page_id):
			pages.append(_pages_by_id[page_id])
	return pages

func _encounter(encounter_id: String) -> Variant:
	_load_data()
	var encounter: Variant = _encounters.get_by_id(encounter_id)
	assert_true(encounter != null, "Encounter '%s' should exist in data/encounters." % encounter_id)
	return encounter

# Builds an in-memory composition from [[enemy_id, start_offset], ...] for
# cases the shipped compositions do not cover (for example two frayers acting
# in the same phase).
func _custom_encounter(entries: Array, encounter_id: String = "custom") -> Variant:
	_load_data()
	var encounter: Variant = ENCOUNTER_DATA_SCRIPT.new()
	encounter.id = encounter_id
	encounter.node = "fight"
	encounter.pool = "mixed"
	encounter.weight = 1
	for entry_variant: Variant in entries:
		var entry: Array = entry_variant
		encounter.enemies.append({"id": String(entry[0]), "start_offset": int(entry[1])})
	return encounter

# Creates a combat state for the encounter with the real run rules, starting
# deck and page library; places `binding_count` placeholder bindings in the
# first slots; then starts combat so initial telegraphs can target them.
func _start_fight(encounter: Variant, seed: int, binding_count: int = 0, frayed_slots: Array[int] = []) -> Variant:
	var state: Variant = _create_fight_state(encounter, seed)
	for slot_index: int in range(binding_count):
		state.set_binding(slot_index, COMBAT_CARD_SCRIPT.create_placeholder("bound_%d" % slot_index), frayed_slots.has(slot_index))
	var core: Variant = COMBAT_CORE_SCRIPT.new()
	core.start_combat(state)
	return state

func _create_fight_state(encounter: Variant, seed: int) -> Variant:
	_load_data()
	return ENCOUNTER_SPAWNER_SCRIPT.create_state(
		encounter,
		_enemies_by_id,
		_catalog.run_rules,
		_starting_deck_pages(),
		_pages_by_id,
		STAIN_PAGE_IDS,
		seed
	)

func _end_turn(state: Variant) -> void:
	var core: Variant = COMBAT_CORE_SCRIPT.new()
	core.end_player_turn(state)

func _telegraph_action_id(state: Variant, enemy_index: int) -> String:
	return String(state.enemies[enemy_index].telegraph.get("action_id", ""))

func _telegraph_type(state: Variant, enemy_index: int) -> String:
	return String(state.enemies[enemy_index].telegraph.get("type", ""))

func _telegraph_value(state: Variant, enemy_index: int) -> int:
	return int(state.enemies[enemy_index].telegraph.get("value", -1))

func _telegraph_target_slot(state: Variant, enemy_index: int) -> int:
	return int(state.enemies[enemy_index].telegraph.get("target_slot", -1))

func _count_page_in_zone(zone: Array, page_id: String) -> int:
	var count: int = 0
	for card_variant: Variant in zone:
		if String(card_variant.page_id) == page_id:
			count += 1
	return count

func _card_is_in_deck_zones(state: Variant, card: Variant) -> bool:
	for zone_variant: Variant in [state.hand, state.draw_pile, state.discard_pile]:
		var zone: Array = zone_variant
		if zone.has(card):
			return true
	return false

func _array_contains_substring(values: Array[String], target: String) -> bool:
	for value: String in values:
		if value.find(target) != -1:
			return true
	return false
