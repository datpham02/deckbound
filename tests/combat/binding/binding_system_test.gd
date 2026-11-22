extends "res://tests/framework/test_case.gd"

const BINDING_SYSTEM_SCRIPT := preload("res://scripts/combat/binding/binding_system.gd")
const COMBAT_CORE_SCRIPT := preload("res://scripts/combat/core/combat_core.gd")
const COMBAT_CARD_SCRIPT := preload("res://scripts/combat/core/combat_card.gd")
const PAGE_DATA_SCRIPT := preload("res://scripts/data/page_data.gd")
const ENEMY_DATA_SCRIPT := preload("res://scripts/data/enemy_data.gd")
const RUN_RULES_DATA_SCRIPT := preload("res://scripts/data/run_rules_data.gd")

func test() -> void:
	_test_bind_removes_page_from_run_deck_and_fills_slot()
	_test_fray_disables_passives_until_end_of_combat_and_sever_removes_slot()
	_test_unbind_returns_page_to_deck_and_frees_slot()
	_test_deck_floor_refuses_binding_and_empty_draw_stops_cleanly()

func _test_bind_removes_page_from_run_deck_and_fills_slot() -> void:
	var state: Variant = _create_state(0)
	var binding_system: Variant = BINDING_SYSTEM_SCRIPT.new()
	var nib_cut: Variant = _create_page("nib_cut", [{"id": "played_damage_bonus", "params": {"amount": 1}}])
	var inkwell_ward: Variant = _create_page("inkwell_ward")

	state.hand = [
		_create_card(nib_cut),
		_create_card(inkwell_ward),
		_create_card(nib_cut)
	]
	state.draw_pile = [
		_create_card(nib_cut),
		_create_card(inkwell_ward)
	]
	state.discard_pile = [_create_card(nib_cut)]
	var total_before: int = state.hand.size() + state.draw_pile.size() + state.discard_pile.size()

	var bound: bool = binding_system.bind_from_hand(state, 0, 0)

	assert_true(bound, "Binding from hand should succeed when deck floor allows it.")
	assert_true(state.binding_slot_has_card(0), "Bound card should occupy the selected slot.")
	assert_equal(String(state.binding_slots[0]["card"].page_id), "nib_cut", "Selected page should move into the binding slot.")
	assert_true(not state.binding_slot_is_frayed(0), "New bindings should start intact.")
	assert_true(not _zone_contains_page_id(state.hand, "nib_cut"), "Bound page id should be removed from hand.")
	assert_true(not _zone_contains_page_id(state.draw_pile, "nib_cut"), "Bound page id should be removed from draw pile.")
	assert_true(not _zone_contains_page_id(state.discard_pile, "nib_cut"), "Bound page id should be removed from discard pile.")
	assert_equal(
		state.hand.size() + state.draw_pile.size() + state.discard_pile.size(),
		total_before - 4,
		"Deck and discard counts should drop by all removed copies."
	)
	assert_equal(state.removed_from_run.size(), 3, "All non-bound copies should be removed from the run.")

func _test_fray_disables_passives_until_end_of_combat_and_sever_removes_slot() -> void:
	var state: Variant = _create_state(0)
	var binding_system: Variant = BINDING_SYSTEM_SCRIPT.new()
	var guarded_page: Variant = _create_page("inkwell_ward", [{"id": "start_combat_guard", "params": {"amount": 5}}])
	var bound_card: Variant = _create_card(guarded_page)
	state.set_binding(0, bound_card)
	state.hand = [_create_card(_create_page("blank_folio"))]
	state.draw_pile = [_create_card(_create_page("torn_margin"))]
	state.discard_pile = [_create_card(_create_page("water_stain"))]
	var deck_count_before: int = state.hand.size() + state.draw_pile.size() + state.discard_pile.size()

	assert_equal(
		binding_system.collect_active_passives_by_id(state, "start_combat_guard").size(),
		1,
		"Intact bindings should contribute passives."
	)

	var frayed: bool = binding_system.fray_binding_slot(state, 0)

	assert_true(frayed, "Fray should succeed on an occupied slot.")
	assert_true(state.binding_slot_is_frayed(0), "Frayed slot should be marked frayed.")
	assert_equal(
		binding_system.collect_active_passives_by_id(state, "start_combat_guard").size(),
		0,
		"Frayed bindings should stop applying passives."
	)
	assert_equal(
		state.hand.size() + state.draw_pile.size() + state.discard_pile.size(),
		deck_count_before,
		"Fray should not change deck or discard counts."
	)

	binding_system.reset_frayed_bindings(state)
	assert_equal(
		binding_system.collect_active_passives_by_id(state, "start_combat_guard").size(),
		1,
		"Fray should end at end of combat and reactivate passives."
	)

	var severed: bool = binding_system.sever_binding_slot(state, 0)
	assert_true(severed, "Sever should succeed on an occupied slot.")
	assert_true(not state.binding_slot_has_card(0), "Sever should empty the slot.")
	assert_true(_zone_contains_page_id(state.removed_from_run, "inkwell_ward"), "Severed binding should be removed from the run.")
	assert_equal(
		state.hand.size() + state.draw_pile.size() + state.discard_pile.size(),
		deck_count_before,
		"Sever should not put the page back into deck or discard."
	)

func _test_unbind_returns_page_to_deck_and_frees_slot() -> void:
	var state: Variant = _create_state(0)
	var binding_system: Variant = BINDING_SYSTEM_SCRIPT.new()
	var page: Variant = _create_page("torn_margin", [{"id": "turn_draw", "params": {"count": 1}}])
	var card: Variant = _create_card(page)
	state.set_binding(1, card)
	state.draw_pile.clear()
	state.hand.clear()
	state.discard_pile.clear()

	var unbound: bool = binding_system.unbind_to_draw_pile(state, 1)

	assert_true(unbound, "Unbind should succeed for occupied slots.")
	assert_true(not state.binding_slot_has_card(1), "Unbind should free the slot.")
	assert_equal(state.draw_pile.size(), 1, "Unbound page should return to the deck.")
	assert_equal(String(state.draw_pile[0].page_id), "torn_margin", "Unbound page id should stay intact.")

	var drawn: int = state.draw_cards(1)
	assert_equal(drawn, 1, "Returned page should be drawable.")
	assert_true(_zone_contains_page_id(state.hand, "torn_margin"), "Returned page should enter hand when drawn.")

func _test_deck_floor_refuses_binding_and_empty_draw_stops_cleanly() -> void:
	var state: Variant = _create_state(5)
	var binding_system: Variant = BINDING_SYSTEM_SCRIPT.new()
	var nib_cut: Variant = _create_page("nib_cut")
	var inkwell_ward: Variant = _create_page("inkwell_ward")

	state.hand = [_create_card(nib_cut)]
	state.draw_pile = [
		_create_card(nib_cut),
		_create_card(inkwell_ward),
		_create_card(inkwell_ward),
		_create_card(inkwell_ward),
		_create_card(inkwell_ward)
	]
	state.discard_pile.clear()

	var bound: bool = binding_system.bind_from_hand(state, 0, 0)

	assert_true(not bound, "Binding should be refused when deck floor would be broken.")
	assert_true(not state.binding_slot_has_card(0), "Refused bind should not occupy any slot.")
	assert_true(_zone_contains_page_id(state.hand, "nib_cut"), "Refused bind should keep card in hand.")
	assert_true(_zone_contains_page_id(state.draw_pile, "nib_cut"), "Refused bind should not strip draw pile.")
	assert_true(_array_contains_substring(state.errors, "deck floor"), "Refused bind should report a deck floor error.")

	state.hand.clear()
	state.draw_pile.clear()
	state.discard_pile.clear()
	var drawn: int = state.draw_cards(3)
	assert_equal(drawn, 0, "Draw should return zero when both draw and discard are empty.")
	assert_equal(state.hand.size(), 0, "Empty draw should not mutate hand size.")

func _create_state(deck_floor: int) -> Variant:
	var rules: Variant = _create_run_rules(deck_floor)
	var deck_pages: Array = [_create_page("setup_page")]
	var enemies: Array = [_create_enemy("dummy", 20, [{"id": "idle", "type": "guard", "value": 0}], ["idle"])]
	return COMBAT_CORE_SCRIPT.create_state(rules, deck_pages, enemies, {}, PackedStringArray(["water_stain"]), 17)

func _create_run_rules(deck_floor: int) -> Variant:
	var rules: Variant = RUN_RULES_DATA_SCRIPT.new()
	rules.schema_version = 1
	rules.hero_health = 20
	rules.ink_per_turn = 3
	rules.hand_draw = 1
	rules.hand_max = 8
	rules.bind_slots = 3
	rules.deck_floor = deck_floor
	var starting_deck: Array[String] = []
	rules.starting_deck = starting_deck
	rules.stains_persist_after_combat = true
	return rules

func _create_page(page_id: String, bind_passives: Array[Dictionary] = []) -> Variant:
	var page: Variant = PAGE_DATA_SCRIPT.new()
	page.id = page_id
	page.name = page_id
	page.cost = 0
	page.compact_play_line = ""
	page.compact_bind_line = ""
	page.play_text = ""
	page.bind_text = ""
	page.target = "none"
	page.pool = false
	var play_effects: Array[Dictionary] = []
	page.play_effects = play_effects
	page.bind_passives = bind_passives
	return page

func _create_enemy(
	enemy_id: String,
	health: int,
	actions: Array[Dictionary],
	telegraph_pattern: Array[String]
) -> Variant:
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

func _create_card(page_data: Variant) -> Variant:
	return COMBAT_CARD_SCRIPT.from_page_data(page_data)

func _zone_contains_page_id(zone: Array[Variant], page_id: String) -> bool:
	for card_variant: Variant in zone:
		if String(card_variant.page_id) == page_id:
			return true
	return false

func _array_contains_substring(values: Array[String], target: String) -> bool:
	for value: String in values:
		if value.find(target) != -1:
			return true
	return false
