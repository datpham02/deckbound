extends "res://tests/framework/test_case.gd"

const BINDING_SYSTEM_SCRIPT := preload("res://scripts/combat/binding/binding_system.gd")
const COMBAT_CORE_SCRIPT := preload("res://scripts/combat/core/combat_core.gd")
const COMBAT_CARD_SCRIPT := preload("res://scripts/combat/core/combat_card.gd")
const PAGE_DATA_SCRIPT := preload("res://scripts/data/page_data.gd")
const ENEMY_DATA_SCRIPT := preload("res://scripts/data/enemy_data.gd")
const RUN_RULES_DATA_SCRIPT := preload("res://scripts/data/run_rules_data.gd")

func test() -> void:
	_test_bind_removes_only_selected_copy_from_deck_and_fills_slot()
	_test_bind_requires_active_player_turn_and_ink_and_spends_cost()
	_test_fray_disables_passives_until_end_of_combat_and_sever_removes_slot()
	_test_unbind_returns_page_to_deck_and_frees_slot()
	_test_deck_floor_refuses_third_bind_at_floor_eight()
	_test_passive_hooks_apply_only_from_intact_bindings()
	_test_draw_passives_stay_bounded_for_fifty_turns()
	_test_empty_draw_stops_cleanly()

func _test_bind_removes_only_selected_copy_from_deck_and_fills_slot() -> void:
	var state: Variant = _create_state(0)
	var binding_system: Variant = BINDING_SYSTEM_SCRIPT.new()
	var nib_cut: Variant = _create_page("nib_cut", [], 1, "enemy")
	var inkwell_ward: Variant = _create_page("inkwell_ward", [], 1)
	var selected_card: Variant = _create_card(nib_cut)
	var hand_copy: Variant = _create_card(nib_cut)
	var draw_copy: Variant = _create_card(nib_cut)
	var discard_copy: Variant = _create_card(nib_cut)

	state.hand = [
		selected_card,
		_create_card(inkwell_ward),
		hand_copy
	]
	state.draw_pile = [
		draw_copy,
		_create_card(inkwell_ward)
	]
	state.discard_pile = [discard_copy]
	state.is_player_turn = true
	state.player_ink = 3
	var total_before: int = _total_deck_count(state)
	var removed_before: int = state.removed_from_run.size()

	var bound: bool = binding_system.bind_from_hand(state, 0, 0)

	assert_true(bound, "Binding from hand should succeed when deck floor allows it.")
	assert_true(state.binding_slot_has_card(0), "Bound card should occupy the selected slot.")
	assert_equal(int(state.binding_slots[0]["card"].uid), int(selected_card.uid), "Bound slot should hold the selected card copy.")
	assert_true(not state.binding_slot_is_frayed(0), "New bindings should start intact.")
	assert_equal(_count_page_id(state.hand, "nib_cut"), 1, "Only the selected hand copy should leave hand.")
	assert_equal(_count_page_id(state.draw_pile, "nib_cut"), 1, "Bind should not strip other copies from draw pile.")
	assert_equal(_count_page_id(state.discard_pile, "nib_cut"), 1, "Bind should not strip other copies from discard.")
	assert_equal(_total_deck_count(state), total_before - 1, "A successful bind should reduce deck zones by exactly one card.")
	assert_equal(state.removed_from_run.size(), removed_before, "Bind should not remove extra copies from the run.")
	assert_equal(state.player_ink, 2, "Bind should spend the bound card cost.")

func _test_bind_requires_active_player_turn_and_ink_and_spends_cost() -> void:
	var state: Variant = _create_state(0)
	var binding_system: Variant = BINDING_SYSTEM_SCRIPT.new()
	var expensive_page: Variant = _create_page("drowned_codicil", [], 1, "enemy")
	state.hand = [_create_card(expensive_page)]
	state.draw_pile.clear()
	state.discard_pile.clear()

	state.is_player_turn = false
	state.player_ink = 1
	var bound_off_turn: bool = binding_system.bind_from_hand(state, 0, 0)
	assert_true(not bound_off_turn, "Bind should fail outside the player's turn.")
	assert_true(_array_contains_substring(state.errors, "outside the player's turn"), "Off-turn bind should surface a turn error.")

	state.errors.clear()
	state.is_player_turn = true
	state.result = "won"
	var bound_after_combat: bool = binding_system.bind_from_hand(state, 0, 0)
	assert_true(not bound_after_combat, "Bind should fail when combat is over.")
	assert_true(_array_contains_substring(state.errors, "combat is over"), "Bind after combat should report a combat-over error.")

	state.errors.clear()
	state.result = "ongoing"
	state.player_ink = 0
	var bound_without_ink: bool = binding_system.bind_from_hand(state, 0, 0)
	assert_true(not bound_without_ink, "Bind should fail when the player has insufficient ink.")
	assert_true(_array_contains_substring(state.errors, "Not enough ink"), "Bind without ink should report an ink error.")
	assert_equal(state.hand.size(), 1, "Refused bind should keep the card in hand.")
	assert_true(not state.binding_slot_has_card(0), "Refused bind should keep the slot empty.")

	state.errors.clear()
	state.player_ink = 1
	var bound_with_ink: bool = binding_system.bind_from_hand(state, 0, 0)
	assert_true(bound_with_ink, "Bind should succeed when turn/combat/ink checks pass.")
	assert_equal(state.player_ink, 0, "Successful bind should spend card cost.")
	assert_true(state.binding_slot_has_card(0), "Successful bind should occupy the requested slot.")
	assert_equal(state.hand.size(), 0, "Successful bind should remove the card from hand.")

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

func _test_deck_floor_refuses_third_bind_at_floor_eight() -> void:
	var state: Variant = _create_state(8)
	var binding_system: Variant = BINDING_SYSTEM_SCRIPT.new()
	var nib_cut: Variant = _create_page("nib_cut", [], 1, "enemy")
	var inkwell_ward: Variant = _create_page("inkwell_ward", [], 1)
	var torn_margin: Variant = _create_page("torn_margin", [], 1)
	var blank_folio: Variant = _create_page("blank_folio", [], 1, "enemy")

	state.hand = [
		_create_card(nib_cut),
		_create_card(inkwell_ward),
		_create_card(torn_margin)
	]
	state.draw_pile = [
		_create_card(blank_folio),
		_create_card(blank_folio),
		_create_card(blank_folio),
		_create_card(blank_folio),
		_create_card(blank_folio),
		_create_card(blank_folio),
		_create_card(blank_folio)
	]
	state.discard_pile.clear()
	state.is_player_turn = true
	state.player_ink = 3

	var first_bind: bool = binding_system.bind_from_hand(state, 0, 0)
	var second_bind: bool = binding_system.bind_from_hand(state, 0, 1)
	assert_true(first_bind, "First bind should succeed at deck floor 8.")
	assert_true(second_bind, "Second bind should still succeed with deck count at 8.")
	assert_equal(_total_deck_count(state), 8, "After two binds, deck zones should be at floor 8.")

	var hand_before: Array[int] = _zone_uids(state.hand)
	var draw_before: Array[int] = _zone_uids(state.draw_pile)
	var discard_before: Array[int] = _zone_uids(state.discard_pile)
	var ink_before: int = state.player_ink

	var third_bind: bool = binding_system.bind_from_hand(state, 0, 2)
	assert_true(not third_bind, "Third bind should be refused when deck would drop below floor 8.")
	assert_true(not state.binding_slot_has_card(2), "Refused bind should not occupy a new slot.")
	assert_equal(_zone_uids(state.hand), hand_before, "Refused bind should not mutate hand.")
	assert_equal(_zone_uids(state.draw_pile), draw_before, "Refused bind should not mutate draw pile.")
	assert_equal(_zone_uids(state.discard_pile), discard_before, "Refused bind should not mutate discard pile.")
	assert_equal(_total_deck_count(state), 8, "Refused bind should leave deck count unchanged.")
	assert_equal(state.player_ink, ink_before, "Refused bind should not spend ink.")
	assert_true(_array_contains_substring(state.errors, "deck floor"), "Refused bind should report a deck floor error.")

func _test_passive_hooks_apply_only_from_intact_bindings() -> void:
	var state: Variant = _create_state(0)
	var binding_system: Variant = BINDING_SYSTEM_SCRIPT.new()
	var guard_page: Variant = _create_page("inkwell_ward", [{"id": "start_combat_guard", "params": {"amount": 5}}])
	var damage_page: Variant = _create_page(
		"lantern_oath",
		[
			{"id": "start_combat_damage_all", "params": {"amount": 6}},
			{"id": "end_turn_damage_all", "params": {"amount": 2}}
		]
	)
	var turn_page: Variant = _create_page(
		"flooded_index",
		[
			{"id": "turn_ink", "params": {"amount": 1}},
			{"id": "turn_draw", "params": {"count": 1}},
			{"id": "turn_draw_lose_health", "params": {"count": 1, "amount": 1}},
			{"id": "played_damage_bonus", "params": {"amount": 2}}
		]
	)
	var empty_slot_guard_page: Variant = _create_page("blank_folio", [{"id": "turn_guard_per_empty_slot", "params": {"per": 2}}])

	state.set_binding(0, _create_card(guard_page))
	state.set_binding(1, _create_card(damage_page))
	state.set_binding(2, _create_card(turn_page))
	state.player_ink = 3
	state.player_health = 20
	state.draw_pile = [
		_create_card(_create_page("setup_a")),
		_create_card(_create_page("setup_b")),
		_create_card(_create_page("setup_c"))
	]
	state.hand.clear()
	state.discard_pile.clear()
	var enemy_health_before: int = int(state.enemies[0].health)

	binding_system.apply_start_of_combat_passives(state)
	assert_equal(state.player_guard, 5, "Start-of-combat guard passive should apply from intact bindings.")
	assert_equal(int(state.enemies[0].health), enemy_health_before - 6, "Start-of-combat damage passive should apply from intact bindings.")

	binding_system.apply_start_of_turn_passives(state)
	assert_equal(state.player_ink, 4, "Start-of-turn ink passive should apply from intact bindings.")
	assert_equal(state.player_health, 19, "turn_draw_lose_health should apply its health cost.")
	assert_equal(state.hand.size(), 2, "Start-of-turn draw passives should draw their configured counts.")
	assert_equal(binding_system.modify_played_damage(state, 6), 8, "played_damage_bonus should modify played damage.")

	binding_system.apply_end_of_turn_passives(state)
	assert_equal(int(state.enemies[0].health), enemy_health_before - 8, "End-of-turn damage passive should apply from intact bindings.")

	var frayed_guard: bool = binding_system.fray_binding_slot(state, 0)
	var frayed_damage: bool = binding_system.fray_binding_slot(state, 1)
	var frayed_turn: bool = binding_system.fray_binding_slot(state, 2)
	assert_true(frayed_guard and frayed_damage and frayed_turn, "Fray should succeed for all occupied slots.")

	state.player_guard = 0
	state.player_ink = 3
	state.player_health = 20
	state.draw_pile = [
		_create_card(_create_page("setup_d")),
		_create_card(_create_page("setup_e"))
	]
	state.hand.clear()
	state.discard_pile.clear()
	var enemy_health_after_fray: int = int(state.enemies[0].health)

	binding_system.apply_start_of_combat_passives(state)
	binding_system.apply_start_of_turn_passives(state)
	binding_system.apply_end_of_turn_passives(state)
	assert_equal(state.player_guard, 0, "Frayed slots should not apply start-of-combat or guard passives.")
	assert_equal(state.player_ink, 3, "Frayed slots should not apply turn_ink.")
	assert_equal(state.player_health, 20, "Frayed slots should not apply turn_draw_lose_health.")
	assert_equal(state.hand.size(), 0, "Frayed slots should not apply turn_draw.")
	assert_equal(int(state.enemies[0].health), enemy_health_after_fray, "Frayed slots should not apply damage passives.")
	assert_equal(binding_system.modify_played_damage(state, 6), 6, "Frayed slots should not modify played damage.")

	var guard_per_empty_state: Variant = _create_state(0)
	guard_per_empty_state.set_binding(0, _create_card(empty_slot_guard_page))
	guard_per_empty_state.player_guard = 0
	binding_system.apply_start_of_turn_passives(guard_per_empty_state)
	assert_equal(guard_per_empty_state.player_guard, 4, "turn_guard_per_empty_slot should scale with empty binding slots.")
	binding_system.fray_binding_slot(guard_per_empty_state, 0)
	guard_per_empty_state.player_guard = 0
	binding_system.apply_start_of_turn_passives(guard_per_empty_state)
	assert_equal(guard_per_empty_state.player_guard, 0, "Frayed turn_guard_per_empty_slot should not apply.")

func _test_draw_passives_stay_bounded_for_fifty_turns() -> void:
	var state: Variant = _create_state(0, 5, 8, 3, 3)
	var binding_system: Variant = BINDING_SYSTEM_SCRIPT.new()
	var torn_margin: Variant = _create_page("torn_margin", [{"id": "turn_draw", "params": {"count": 1}}])
	var flooded_index: Variant = _create_page("flooded_index", [{"id": "turn_draw_lose_health", "params": {"count": 1, "amount": 1}}])
	var tally_mark: Variant = _create_page("tally_mark", [{"id": "turn_ink", "params": {"amount": 1}}])

	state.set_binding(0, _create_card(torn_margin))
	state.set_binding(1, _create_card(flooded_index))
	state.set_binding(2, _create_card(tally_mark))
	state.hand.clear()
	state.discard_pile.clear()
	state.draw_pile = [
		_create_card(_create_page("deck_a")),
		_create_card(_create_page("deck_b")),
		_create_card(_create_page("deck_c")),
		_create_card(_create_page("deck_d")),
		_create_card(_create_page("deck_e"))
	]
	state.player_max_health = 200
	state.player_health = 200
	var max_requested_draws: int = 0

	for _turn in range(50):
		state.player_ink = int(state.run_rules.ink_per_turn)
		var passive_draw_requests: int = _count_passive_draw_requests(binding_system.collect_active_passives(state))
		var total_draw_requests: int = passive_draw_requests + int(state.run_rules.hand_draw)
		max_requested_draws = maxi(max_requested_draws, total_draw_requests)
		assert_true(total_draw_requests <= 7, "Per-turn draw requests should stay bounded at 7 or less.")

		binding_system.apply_start_of_turn_passives(state)
		state.draw_cards(int(state.run_rules.hand_draw))
		assert_true(state.hand.size() <= int(state.run_rules.hand_max), "Start-of-turn draw should respect hand cap.")
		assert_equal(_total_deck_count(state), 5, "Deck zones should remain stable during repeated draw cycles.")
		assert_true(state.player_health > 0, "Repeated turn_draw_lose_health should stay bounded over 50 turns.")

		state.discard_hand()

	assert_equal(max_requested_draws, 7, "Torn Margin + Flooded Index + hand_draw should request exactly 7 draws per turn.")

func _test_empty_draw_stops_cleanly() -> void:
	var state: Variant = _create_state(5)
	state.hand.clear()
	state.draw_pile.clear()
	state.discard_pile.clear()
	var drawn: int = state.draw_cards(3)
	assert_equal(drawn, 0, "Draw should return zero when both draw and discard are empty.")
	assert_equal(state.hand.size(), 0, "Empty draw should not mutate hand size.")

func _create_state(
	deck_floor: int,
	hand_draw: int = 1,
	hand_max: int = 8,
	bind_slots: int = 3,
	ink_per_turn: int = 3
) -> Variant:
	var rules: Variant = _create_run_rules(deck_floor, hand_draw, hand_max, bind_slots, ink_per_turn)
	var deck_pages: Array = [_create_page("setup_page")]
	var enemies: Array = [_create_enemy("dummy", 20, [{"id": "idle", "type": "guard", "value": 0}], ["idle"])]
	return COMBAT_CORE_SCRIPT.create_state(rules, deck_pages, enemies, {}, PackedStringArray(["water_stain"]), 17)

func _create_run_rules(
	deck_floor: int,
	hand_draw: int = 1,
	hand_max: int = 8,
	bind_slots: int = 3,
	ink_per_turn: int = 3
) -> Variant:
	var rules: Variant = RUN_RULES_DATA_SCRIPT.new()
	rules.schema_version = 1
	rules.hero_health = 20
	rules.ink_per_turn = ink_per_turn
	rules.hand_draw = hand_draw
	rules.hand_max = hand_max
	rules.bind_slots = bind_slots
	rules.deck_floor = deck_floor
	var starting_deck: Array[String] = []
	rules.starting_deck = starting_deck
	rules.stains_persist_after_combat = true
	return rules

func _create_page(
	page_id: String,
	bind_passives: Array[Dictionary] = [],
	cost: int = 0,
	target: String = "none"
) -> Variant:
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

func _count_page_id(zone: Array[Variant], page_id: String) -> int:
	var count: int = 0
	for card_variant: Variant in zone:
		if String(card_variant.page_id) == page_id:
			count += 1
	return count

func _total_deck_count(state: Variant) -> int:
	return state.hand.size() + state.draw_pile.size() + state.discard_pile.size()

func _zone_uids(zone: Array[Variant]) -> Array[int]:
	var uids: Array[int] = []
	for card_variant: Variant in zone:
		uids.append(int(card_variant.uid))
	return uids

func _zone_contains_page_id(zone: Array[Variant], page_id: String) -> bool:
	for card_variant: Variant in zone:
		if String(card_variant.page_id) == page_id:
			return true
	return false

func _count_passive_draw_requests(passives: Array[Dictionary]) -> int:
	var requests: int = 0
	for passive_data: Dictionary in passives:
		var passive_id: String = String(passive_data.get("id", ""))
		if passive_id != "turn_draw" and passive_id != "turn_draw_lose_health":
			continue
		var params_variant: Variant = passive_data.get("params", {})
		if typeof(params_variant) != TYPE_DICTIONARY:
			continue
		var params: Dictionary = params_variant
		requests += maxi(0, int(params.get("count", 0)))
	return requests

func _array_contains_substring(values: Array[String], target: String) -> bool:
	for value: String in values:
		if value.find(target) != -1:
			return true
	return false
