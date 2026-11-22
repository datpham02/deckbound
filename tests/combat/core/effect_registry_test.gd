extends "res://tests/framework/test_case.gd"

const COMBAT_CORE_SCRIPT := preload("res://scripts/combat/core/combat_core.gd")
const COMBAT_CARD_SCRIPT := preload("res://scripts/combat/core/combat_card.gd")
const DATA_LOADER_SCRIPT := preload("res://scripts/data/data_loader.gd")
const PAGE_DATA_SCRIPT := preload("res://scripts/data/page_data.gd")
const ENEMY_DATA_SCRIPT := preload("res://scripts/data/enemy_data.gd")
const RUN_RULES_DATA_SCRIPT := preload("res://scripts/data/run_rules_data.gd")

func test() -> void:
	_test_registry_covers_all_loader_play_effect_ids()
	_test_remove_this_page_effect_removes_played_card_from_run()
	_test_scaling_effects_use_discard_and_binding_counts()
	_test_add_page_to_discard_effect_uses_page_id_param()
	_test_add_page_to_discard_effect_requires_page_id()

func _test_registry_covers_all_loader_play_effect_ids() -> void:
	var core: Variant = COMBAT_CORE_SCRIPT.new()
	var actual_ids: PackedStringArray = core.registry_effect_ids()
	var expected_ids: PackedStringArray = DATA_LOADER_SCRIPT.PAGE_PLAY_EFFECT_IDS

	assert_equal(actual_ids.size(), expected_ids.size(), "Registry should implement every play effect id accepted by DataLoader.")
	for expected_id: String in expected_ids:
		assert_true(actual_ids.has(expected_id), "Registry missing '%s'." % expected_id)
	for actual_id: String in actual_ids:
		assert_true(expected_ids.has(actual_id), "Registry has unexpected id '%s'." % actual_id)

func _test_remove_this_page_effect_removes_played_card_from_run() -> void:
	var core: Variant = COMBAT_CORE_SCRIPT.new()
	var rules: Variant = _create_run_rules()
	var page_effects: Array[Dictionary] = [{"id": "remove_this_page"}]
	var deck_pages: Array = [_create_page("water_stain", 0, "none", page_effects)]
	var enemies: Array = [_create_enemy("dummy", 20, [{"id": "idle", "type": "guard", "value": 0}], ["idle"])]

	var state: Variant = COMBAT_CORE_SCRIPT.create_state(rules, deck_pages, enemies, {}, PackedStringArray(["water_stain"]), 31)
	core.start_combat(state)
	var played: bool = core.play_card(state, 0, -1)

	assert_true(played, "Card with remove_this_page should still play.")
	assert_equal(state.discard_pile.size(), 0, "remove_this_page should bypass discard.")
	assert_equal(state.removed_from_run.size(), 1, "Played card should move to removed_from_run.")
	assert_equal(String(state.removed_from_run[0].page_id), "water_stain", "Removed card id should match played card.")

func _test_scaling_effects_use_discard_and_binding_counts() -> void:
	var core: Variant = COMBAT_CORE_SCRIPT.new()
	var rules: Variant = _create_run_rules()
	var scaling_effects: Array[Dictionary] = [
		{"id": "damage_per_discard_page", "params": {"per": 2}},
		{"id": "guard_per_binding", "params": {"per": 3}}
	]
	var deck_pages: Array = [_create_page("ledger", 0, "enemy", scaling_effects)]
	var enemies: Array = [_create_enemy("target", 20, [{"id": "idle", "type": "guard", "value": 0}], ["idle"])]

	var state: Variant = COMBAT_CORE_SCRIPT.create_state(
		rules,
		deck_pages,
		enemies,
		{"junk": _create_page("junk", 0, "none", [])},
		PackedStringArray(["water_stain"]),
		37
	)
	state.add_page_to_discard_by_id("junk")
	state.add_page_to_discard_by_id("junk")
	state.set_binding(0, COMBAT_CARD_SCRIPT.create_placeholder("bind_a"))
	state.set_binding(1, COMBAT_CARD_SCRIPT.create_placeholder("bind_b"), true)

	core.start_combat(state)
	var played: bool = core.play_card(state, 0, 0)
	var enemy: Variant = state.enemies[0]

	assert_true(played, "Scaling test card should play on enemy target.")
	assert_equal(enemy.health, 16, "damage_per_discard_page should scale with current discard pile size.")
	assert_equal(state.player_guard, 6, "guard_per_binding should scale with occupied bindings.")

func _test_add_page_to_discard_effect_uses_page_id_param() -> void:
	var core: Variant = COMBAT_CORE_SCRIPT.new()
	var rules: Variant = _create_run_rules()
	var spawn_effects: Array[Dictionary] = [
		{"id": "add_page_to_discard", "params": {"page_id": "water_stain"}}
	]
	var deck_pages: Array = [_create_page("candle_debt", 0, "enemy", spawn_effects)]
	var page_library: Dictionary = {"water_stain": _create_page("water_stain", 0, "none", [{"id": "remove_this_page"}])}
	var enemies: Array = [_create_enemy("target", 30, [{"id": "idle", "type": "guard", "value": 0}], ["idle"])]

	var state: Variant = COMBAT_CORE_SCRIPT.create_state(rules, deck_pages, enemies, page_library, PackedStringArray(["water_stain"]), 41)
	core.start_combat(state)
	var played: bool = core.play_card(state, 0, 0)

	assert_true(played, "Card that adds discard pages should play.")
	assert_equal(state.discard_pile.size(), 2, "Discard should contain both generated page and the played page.")
	assert_true(_discard_contains_page_id(state.discard_pile, "water_stain"), "Discard should include generated page id.")
	assert_true(_discard_contains_page_id(state.discard_pile, "candle_debt"), "Discard should include the played card id.")

func _test_add_page_to_discard_effect_requires_page_id() -> void:
	var core: Variant = COMBAT_CORE_SCRIPT.new()
	var rules: Variant = _create_run_rules()
	var spawn_effects: Array[Dictionary] = [{"id": "add_page_to_discard"}]
	var deck_pages: Array = [_create_page("missing_param", 0, "none", spawn_effects)]
	var enemies: Array = [_create_enemy("target", 30, [{"id": "idle", "type": "guard", "value": 0}], ["idle"])]

	var state: Variant = COMBAT_CORE_SCRIPT.create_state(rules, deck_pages, enemies, {}, PackedStringArray(["water_stain"]), 43)
	core.start_combat(state)
	var played: bool = core.play_card(state, 0, -1)

	assert_true(played, "Card should still play even if add_page_to_discard params are invalid.")
	assert_equal(state.discard_pile.size(), 1, "Only the played card should be discarded when page_id is missing.")
	assert_true(
		_array_contains_substring(state.errors, "add_page_to_discard"),
		"State errors should report the missing page_id requirement."
	)

func _create_run_rules() -> Variant:
	var rules: Variant = RUN_RULES_DATA_SCRIPT.new()
	rules.schema_version = 1
	rules.hero_health = 30
	rules.ink_per_turn = 3
	rules.hand_draw = 1
	rules.hand_max = 8
	rules.bind_slots = 3
	rules.deck_floor = 0
	var starting_deck: Array[String] = []
	rules.starting_deck = starting_deck
	rules.stains_persist_after_combat = true
	return rules

func _create_page(page_id: String, cost: int, target: String, play_effects: Array[Dictionary]) -> Variant:
	var page: Variant = PAGE_DATA_SCRIPT.new()
	page.id = page_id
	page.name = page_id
	page.cost = cost
	page.compact_play_line = ""
	page.compact_bind_line = ""
	page.play_text = ""
	page.bind_text = ""
	page.target = target
	page.pool = false
	page.play_effects = play_effects
	var bind_passives: Array[Dictionary] = []
	page.bind_passives = bind_passives
	return page

func _create_enemy(enemy_id: String, health: int, actions: Array[Dictionary], telegraph_pattern: Array[String]) -> Variant:
	var enemy: Variant = ENEMY_DATA_SCRIPT.new()
	enemy.id = enemy_id
	enemy.name = enemy_id
	enemy.size_class = "common"
	enemy.health = health
	enemy.actions = actions
	enemy.telegraph_pattern = telegraph_pattern
	var phases: Array[Dictionary] = []
	enemy.phases = phases
	return enemy

func _discard_contains_page_id(discard_pile: Array, page_id: String) -> bool:
	for card_variant: Variant in discard_pile:
		if String(card_variant.page_id) == page_id:
			return true
	return false

func _array_contains_substring(values: Array[String], target: String) -> bool:
	for value: String in values:
		if value.find(target) != -1:
			return true
	return false
