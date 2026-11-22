extends "res://tests/framework/test_case.gd"

const COMBAT_CORE_SCRIPT := preload("res://scripts/combat/core/combat_core.gd")
const COMBAT_CARD_SCRIPT := preload("res://scripts/combat/core/combat_card.gd")
const PAGE_DATA_SCRIPT := preload("res://scripts/data/page_data.gd")
const ENEMY_DATA_SCRIPT := preload("res://scripts/data/enemy_data.gd")
const RUN_RULES_DATA_SCRIPT := preload("res://scripts/data/run_rules_data.gd")

func test() -> void:
	_test_start_combat_draws_hand_and_sets_ink()
	_test_play_card_applies_damage_and_spends_ink()
	_test_end_turn_discards_hand_and_runs_enemy_action()
	_test_enemy_telegraph_advances_after_action()
	_test_enemy_telegraph_fallback_without_binding_target()
	_test_enemy_guard_clears_when_enemy_acts()
	_test_phase_switch_starts_at_step_one_and_does_not_revert()
	_test_initial_telegraph_uses_bindings_set_before_start_combat()
	_test_two_fray_telegraphs_pick_distinct_slots_when_possible()
	_test_foul_action_requires_page_id()

func _test_start_combat_draws_hand_and_sets_ink() -> void:
	var rules: Variant = _create_run_rules(20, 3, 3, 8, 3)
	var deck_pages: Array = [
		_create_page("a", 0, "none", []),
		_create_page("b", 0, "none", []),
		_create_page("c", 0, "none", []),
		_create_page("d", 0, "none", []),
		_create_page("e", 0, "none", [])
	]
	var enemies: Array = [_create_enemy("bailiff", 12, [{"id": "rap", "type": "attack", "value": 3}], ["rap"])]

	var core: Variant = COMBAT_CORE_SCRIPT.new()
	var state: Variant = COMBAT_CORE_SCRIPT.create_state(rules, deck_pages, enemies, {}, PackedStringArray(["water_stain"]), 7)
	core.start_combat(state)

	assert_true(state.is_player_turn, "Combat should begin on the player turn.")
	assert_equal(state.turn_number, 1, "Turn number should increment when combat starts.")
	assert_equal(state.player_ink, 3, "Player ink should reset from run rules at turn start.")
	assert_equal(state.hand.size(), 3, "Player should draw run_rules.hand_draw pages.")
	assert_equal(state.result, "ongoing", "Combat should stay active after the opening draw.")

func _test_play_card_applies_damage_and_spends_ink() -> void:
	var rules: Variant = _create_run_rules(20, 3, 1, 8, 3)
	var strike_effects: Array[Dictionary] = [{"id": "damage", "params": {"amount": 6}}]
	var deck_pages: Array = [_create_page("nib_cut", 1, "enemy", strike_effects)]
	var enemies: Array = [_create_enemy("bailiff", 10, [{"id": "brace", "type": "guard", "value": 0}], ["brace"])]

	var core: Variant = COMBAT_CORE_SCRIPT.new()
	var state: Variant = COMBAT_CORE_SCRIPT.create_state(rules, deck_pages, enemies, {}, PackedStringArray(["water_stain"]), 4)
	var enemy: Variant = state.enemies[0]
	enemy.guard = 2
	core.start_combat(state)

	var played: bool = core.play_card(state, 0, 0)
	assert_true(played, "Card should play when target is valid and ink is sufficient.")
	assert_equal(state.player_ink, 2, "Playing a cost-1 card should spend one ink.")
	assert_equal(enemy.guard, 0, "Damage should be absorbed by enemy guard first.")
	assert_equal(enemy.health, 6, "Remaining damage should reduce enemy health.")
	assert_equal(state.hand.size(), 0, "Played card should leave hand.")
	assert_equal(state.discard_pile.size(), 1, "Played card should go to discard unless removed by effect.")

func _test_end_turn_discards_hand_and_runs_enemy_action() -> void:
	var rules: Variant = _create_run_rules(12, 1, 2, 8, 3)
	var deck_pages: Array = [
		_create_page("note_a", 0, "none", []),
		_create_page("note_b", 0, "none", [])
	]
	var enemy_actions: Array[Dictionary] = [{"id": "slam", "type": "attack", "value": 12}]
	var enemies: Array = [_create_enemy("warden", 20, enemy_actions, ["slam"])]

	var core: Variant = COMBAT_CORE_SCRIPT.new()
	var state: Variant = COMBAT_CORE_SCRIPT.create_state(rules, deck_pages, enemies, {}, PackedStringArray(["water_stain"]), 11)
	core.start_combat(state)

	var played: bool = core.play_card(state, 0, -1)
	assert_true(played, "Zero-cost non-target card should play cleanly.")
	assert_equal(state.hand.size(), 1, "One card should remain in hand before end turn.")
	core.end_player_turn(state)

	assert_equal(state.result, "lost", "Enemy telegraph action should resolve during enemy phase.")
	assert_equal(state.player_health, 0, "Lethal enemy action should reduce player health to zero.")
	assert_equal(state.hand.size(), 0, "Unplayed cards should be discarded at end of turn.")
	assert_equal(state.discard_pile.size(), 2, "Both played and unplayed cards should be in discard.")

func _test_enemy_telegraph_advances_after_action() -> void:
	var rules: Variant = _create_run_rules(20, 1, 1, 8, 3)
	var deck_pages: Array = [_create_page("blank", 0, "none", [])]
	var enemy_actions: Array[Dictionary] = [
		{"id": "jab", "type": "attack", "value": 2},
		{"id": "brace", "type": "guard", "value": 3}
	]
	var enemies: Array = [_create_enemy("bailiff", 20, enemy_actions, ["jab", "brace"])]

	var core: Variant = COMBAT_CORE_SCRIPT.new()
	var state: Variant = COMBAT_CORE_SCRIPT.create_state(rules, deck_pages, enemies, {}, PackedStringArray(["water_stain"]), 19)
	core.start_combat(state)

	var enemy: Variant = state.enemies[0]
	assert_equal(String(enemy.telegraph.get("type", "")), "attack", "Enemy should telegraph the first pattern step at combat start.")

	core.end_player_turn(state)

	assert_equal(state.player_health, 18, "Attack telegraph should deal damage during enemy phase.")
	assert_equal(state.turn_number, 2, "Combat should advance to the next player turn after enemy phase.")
	assert_equal(String(enemy.telegraph.get("type", "")), "guard", "Enemy telegraph should advance to the next pattern step.")
	assert_equal(int(enemy.telegraph.get("value", 0)), 3, "Next telegraph should preserve configured action values.")

func _test_enemy_telegraph_fallback_without_binding_target() -> void:
	var rules: Variant = _create_run_rules(20, 1, 1, 8, 3)
	var deck_pages: Array = [_create_page("blank", 0, "none", [])]
	var enemy_actions: Array[Dictionary] = [
		{
			"id": "unpick",
			"type": "fray",
			"value": 4,
			"fallback": {"type": "attack", "value": 5}
		}
	]
	var enemies: Array = [_create_enemy("bookmoth", 10, enemy_actions, ["unpick"])]

	var core: Variant = COMBAT_CORE_SCRIPT.new()
	var state: Variant = COMBAT_CORE_SCRIPT.create_state(rules, deck_pages, enemies, {}, PackedStringArray(["water_stain"]), 23)
	core.start_combat(state)

	var enemy: Variant = state.enemies[0]
	assert_equal(String(enemy.telegraph.get("type", "")), "attack", "Fray without intact bindings should fall back to attack telegraph.")
	assert_true(bool(enemy.telegraph.get("fallback_used", false)), "Fallback telegraph should be flagged for deterministic replay.")

	core.end_player_turn(state)
	assert_equal(state.player_health, 15, "Fallback attack should resolve from telegraph during enemy phase.")

func _test_enemy_guard_clears_when_enemy_acts() -> void:
	var rules: Variant = _create_run_rules(30, 0, 1, 8, 3)
	var deck_pages: Array = [_create_page("blank", 0, "none", [])]
	var enemy_actions: Array[Dictionary] = [
		{"id": "brace", "type": "guard", "value": 7},
		{"id": "jab", "type": "attack", "value": 5}
	]
	var enemies: Array = [_create_enemy("bailiff", 20, enemy_actions, ["brace", "jab"])]

	var core: Variant = COMBAT_CORE_SCRIPT.new()
	var state: Variant = COMBAT_CORE_SCRIPT.create_state(rules, deck_pages, enemies, {}, PackedStringArray(["water_stain"]), 29)
	core.start_combat(state)

	var enemy: Variant = state.enemies[0]
	assert_equal(String(enemy.telegraph.get("type", "")), "guard", "Enemy should begin on guard telegraph.")
	core.end_player_turn(state)
	assert_equal(enemy.guard, 7, "Guard action should leave guard available through the following player turn.")
	assert_equal(String(enemy.telegraph.get("type", "")), "attack", "Telegraph should advance to attack after guard action.")

	core.end_player_turn(state)
	assert_equal(enemy.guard, 0, "Enemy guard should clear when the enemy next acts.")

func _test_phase_switch_starts_at_step_one_and_does_not_revert() -> void:
	var rules: Variant = _create_run_rules(40, 0, 1, 8, 3)
	var deck_pages: Array = [_create_page("blank", 0, "none", [])]
	var enemy_actions: Array[Dictionary] = [
		{"id": "phase_one_attack", "type": "attack", "value": 3},
		{
			"id": "phase_two_sever",
			"type": "sever",
			"value": 10,
			"fallback": {"type": "attack", "value": 8}
		},
		{"id": "phase_two_attack", "type": "attack", "value": 11}
	]
	var phases: Array[Dictionary] = [
		{"health_at_or_below": 48, "telegraph_pattern": ["phase_two_sever", "phase_two_attack"]}
	]
	var enemies: Array = [_create_enemy("redactor", 60, enemy_actions, ["phase_one_attack"], phases)]

	var core: Variant = COMBAT_CORE_SCRIPT.new()
	var state: Variant = COMBAT_CORE_SCRIPT.create_state(rules, deck_pages, enemies, {}, PackedStringArray(["water_stain"]), 31)
	state.set_binding(0, COMBAT_CARD_SCRIPT.create_placeholder("bound_page"))
	core.start_combat(state)

	var enemy: Variant = state.enemies[0]
	assert_equal(String(enemy.telegraph.get("action_id", "")), "phase_one_attack", "Enemy should begin in phase one.")

	enemy.health = 48
	core.end_player_turn(state)
	assert_equal(String(enemy.telegraph.get("action_id", "")), "phase_two_sever", "Phase switch should start at phase-two step one.")

	enemy.health = 60
	core.end_player_turn(state)
	assert_equal(String(enemy.telegraph.get("action_id", "")), "phase_two_attack", "Enemy should stay in phase two after switching.")

func _test_initial_telegraph_uses_bindings_set_before_start_combat() -> void:
	var rules: Variant = _create_run_rules(20, 1, 1, 8, 3)
	var deck_pages: Array = [_create_page("blank", 0, "none", [])]
	var enemy_actions: Array[Dictionary] = [
		{
			"id": "fray_opening",
			"type": "fray",
			"value": 4,
			"fallback": {"type": "attack", "value": 5}
		}
	]
	var enemies: Array = [_create_enemy("bookmoth", 10, enemy_actions, ["fray_opening"])]

	var core: Variant = COMBAT_CORE_SCRIPT.new()
	var state: Variant = COMBAT_CORE_SCRIPT.create_state(rules, deck_pages, enemies, {}, PackedStringArray(["water_stain"]), 37)
	state.set_binding(0, COMBAT_CARD_SCRIPT.create_placeholder("bound_page"))
	core.start_combat(state)

	var enemy: Variant = state.enemies[0]
	assert_equal(String(enemy.telegraph.get("type", "")), "fray", "Initial telegraph should use bound slots present before start_combat.")
	assert_equal(int(enemy.telegraph.get("target_slot", -1)), 0, "Initial fray telegraph should target the pre-existing binding slot.")

func _test_two_fray_telegraphs_pick_distinct_slots_when_possible() -> void:
	var rules: Variant = _create_run_rules(20, 1, 1, 8, 3)
	var deck_pages: Array = [_create_page("blank", 0, "none", [])]
	var enemy_actions: Array[Dictionary] = [
		{
			"id": "fray_now",
			"type": "fray",
			"value": 4,
			"fallback": {"type": "attack", "value": 5}
		}
	]
	var enemies: Array = [
		_create_enemy("bookmoth_a", 10, enemy_actions, ["fray_now"]),
		_create_enemy("bookmoth_b", 10, enemy_actions, ["fray_now"])
	]

	var core: Variant = COMBAT_CORE_SCRIPT.new()
	var state: Variant = COMBAT_CORE_SCRIPT.create_state(rules, deck_pages, enemies, {}, PackedStringArray(["water_stain"]), 41)
	state.set_binding(0, COMBAT_CARD_SCRIPT.create_placeholder("bind_a"))
	state.set_binding(1, COMBAT_CARD_SCRIPT.create_placeholder("bind_b"))
	core.start_combat(state)

	var enemy_a: Variant = state.enemies[0]
	var enemy_b: Variant = state.enemies[1]
	assert_equal(String(enemy_a.telegraph.get("type", "")), "fray", "First enemy should telegraph fray.")
	assert_equal(String(enemy_b.telegraph.get("type", "")), "fray", "Second enemy should telegraph fray.")
	assert_true(
		int(enemy_a.telegraph.get("target_slot", -1)) != int(enemy_b.telegraph.get("target_slot", -1)),
		"Fray telegraphs should target different slots when multiple intact slots exist."
	)

func _test_foul_action_requires_page_id() -> void:
	var rules: Variant = _create_run_rules(20, 1, 1, 8, 3)
	var deck_pages: Array = [_create_page("blank", 0, "none", [])]
	var enemy_actions: Array[Dictionary] = [{"id": "foul_now", "type": "foul", "value": 1}]
	var enemies: Array = [_create_enemy("blotter", 10, enemy_actions, ["foul_now"])]

	var core: Variant = COMBAT_CORE_SCRIPT.new()
	var state: Variant = COMBAT_CORE_SCRIPT.create_state(rules, deck_pages, enemies, {}, PackedStringArray(["water_stain"]), 43)
	core.start_combat(state)
	core.end_player_turn(state)

	assert_equal(state.hand.size(), 1, "Only the original deck card should remain in circulation after foul with missing page_id.")
	assert_true(not _zones_contain_page_id(state, "water_stain"), "Missing page_id should not inject water_stain into any zone.")
	assert_true(not _zones_contain_page_id(state, "blot"), "Missing page_id should not inject blot into any zone.")
	assert_true(_array_contains_substring(state.errors, "missing required page_id"), "Foul without page_id should produce a state error.")

func _create_run_rules(hero_health: int, ink_per_turn: int, hand_draw: int, hand_max: int, bind_slots: int) -> Variant:
	var rules: Variant = RUN_RULES_DATA_SCRIPT.new()
	rules.schema_version = 1
	rules.hero_health = hero_health
	rules.ink_per_turn = ink_per_turn
	rules.hand_draw = hand_draw
	rules.hand_max = hand_max
	rules.bind_slots = bind_slots
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

func _create_enemy(
	enemy_id: String,
	health: int,
	actions: Array[Dictionary],
	telegraph_pattern: Array[String],
	phases: Array[Dictionary] = []
) -> Variant:
	var enemy: Variant = ENEMY_DATA_SCRIPT.new()
	enemy.id = enemy_id
	enemy.name = enemy_id
	enemy.size_class = "common"
	enemy.health = health
	enemy.actions = actions
	enemy.telegraph_pattern = telegraph_pattern
	enemy.phases = phases
	return enemy

func _array_contains_substring(values: Array[String], target: String) -> bool:
	for value: String in values:
		if value.find(target) != -1:
			return true
	return false

func _zones_contain_page_id(state: Variant, page_id: String) -> bool:
	for zone_variant: Variant in [state.hand, state.draw_pile, state.discard_pile, state.removed_from_run]:
		var zone: Array = zone_variant
		for card_variant: Variant in zone:
			if String(card_variant.page_id) == page_id:
				return true
	return false
