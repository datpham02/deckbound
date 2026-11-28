extends "res://tests/combat/enemies/enemy_test_support.gd"

# Enemy behaviours driven by the shipped data/enemies and data/encounters files
# (docs/design/enemies.md §9 criteria 3 to 12). Every number asserted here is
# read from data/ by the loaders; the tests only check the note's rules hold.

func test() -> void:
	_test_every_living_enemy_telegraphs_and_acts_on_its_telegraph()
	_test_telegraph_does_not_change_during_player_turn()
	_test_attack_reduces_guard_first_and_multi_hit_applies_twice()
	_test_enemy_guard_absorbs_damage_until_it_next_acts()
	_test_fray_resolves_against_player_guard_and_never_touches_health()
	_test_sever_removes_page_from_run_and_can_target_frayed_binding()
	_test_fray_targets_intact_only_sever_targets_any_and_two_frays_differ()
	_test_fallbacks_without_binding_and_pattern_still_advances()
	_test_foul_adds_stain_pages_to_discard()
	_test_foul_page_id_comes_from_run_stain_ids()
	_test_redactor_switches_to_phase_two_at_half_health_and_never_back()
	_test_start_offsets_place_each_enemy_on_its_pattern_step()

func _test_every_living_enemy_telegraphs_and_acts_on_its_telegraph() -> void:
	var state: Variant = _start_fight(_encounter("clerks_three"), 3, 3)
	assert_equal(state.enemies.size(), 3, "clerks_three fields three enemies.")
	_assert_all_living_enemies_telegraph(state, "at combat start")

	for _turn: int in range(6):
		var expected_damage: int = 0
		var expected_stains: int = 0
		for enemy_variant: Variant in state.enemies:
			if not enemy_variant.is_alive():
				continue
			var telegraph: Dictionary = enemy_variant.telegraph
			var telegraph_type: String = String(telegraph.get("type", ""))
			if telegraph_type == "attack":
				expected_damage += int(telegraph.get("value", 0)) * int(telegraph.get("hits", 1))
			elif telegraph_type == "foul":
				expected_stains += int(telegraph.get("value", 0))
		var health_before: int = state.player_health
		var stains_before: int = _count_stains_in_deck_zones(state)
		state.player_guard = 0
		_end_turn(state)
		if state.is_combat_over():
			break
		assert_equal(health_before - state.player_health, expected_damage, "Enemies deal exactly the attack damage they telegraphed.")
		assert_equal(_count_stains_in_deck_zones(state) - stains_before, expected_stains, "Enemies add exactly the stains they telegraphed.")
		_assert_all_living_enemies_telegraph(state, "after enemy phase %d" % state.turn_number)
	assert_true(state.errors.is_empty(), "A fight run from data should not raise state errors: %s" % str(state.errors))

func _test_telegraph_does_not_change_during_player_turn() -> void:
	var state: Variant = _start_fight(_custom_encounter([["bookmoth", 0], ["bailiff", 0], ["blotter", 1]]), 5, 0)
	assert_equal(_telegraph_type(state, 0), "attack", "With no binding the Bookmoth telegraphs its fallback.")
	var moth_before: Dictionary = state.enemies[0].telegraph.duplicate(true)
	var bailiff_before: Dictionary = state.enemies[1].telegraph.duplicate(true)
	var blotter_before: Dictionary = state.enemies[2].telegraph.duplicate(true)
	var fallback_value: int = int(moth_before.get("value", 0))
	var rap_value: int = int(bailiff_before.get("value", 0))

	state.set_binding(0, COMBAT_CARD_SCRIPT.create_placeholder("bound_late"))
	state.gain_player_guard(fallback_value + 2)
	state.apply_damage_to_enemy(2, 100)
	assert_true(not state.enemies[2].is_alive(), "The Blotter should be dead.")
	assert_true(state.enemies[2].telegraph.is_empty(), "A dead enemy loses its telegraph at once.")
	assert_true(blotter_before.size() > 0, "The Blotter had a telegraph before dying.")
	assert_equal(state.enemies[0].telegraph, moth_before, "Binding, gaining guard and a kill do not change the Bookmoth's telegraph.")
	assert_equal(state.enemies[1].telegraph, bailiff_before, "Binding, gaining guard and a kill do not change the Bailiff's telegraph.")

	_end_turn(state)
	assert_true(not state.binding_slot_is_frayed(0), "The late binding is not frayed: the moth kept its fallback attack.")
	assert_equal(state.player_health, int(state.run_rules.hero_health) - (rap_value - 2), "The fallback attack spent its value from guard and the rap took the rest.")

func _test_attack_reduces_guard_first_and_multi_hit_applies_twice() -> void:
	var state: Variant = _start_fight(_encounter("bailiff_solo"), 7, 0)
	assert_equal(_telegraph_action_id(state, 0), "rap", "bailiff_solo opens on rap.")
	var rap: int = _telegraph_value(state, 0)
	state.player_guard = 2
	_end_turn(state)
	assert_equal(state.player_health, int(state.run_rules.hero_health) - (rap - 2), "Attack N spends guard first and health takes the remainder.")
	assert_equal(state.player_guard, 0, "Guard is used up by the rap.")

	var registrar_state: Variant = _start_fight(_custom_encounter([["registrar", 4]]), 7, 0)
	assert_equal(_telegraph_action_id(registrar_state, 0), "seal_press", "Offset 4 starts the Registrar on seal_press.")
	var hit_value: int = _telegraph_value(registrar_state, 0)
	assert_equal(int(registrar_state.enemies[0].telegraph.get("hits", 1)), 2, "seal_press telegraphs two hits.")
	registrar_state.player_guard = hit_value + 2
	_end_turn(registrar_state)
	assert_equal(registrar_state.player_guard, 0, "Two hits exhaust the guard.")
	assert_equal(registrar_state.player_health, int(registrar_state.run_rules.hero_health) - (hit_value - 2), "The second hit lands on health after guard is gone.")

func _test_enemy_guard_absorbs_damage_until_it_next_acts() -> void:
	var state: Variant = _start_fight(_custom_encounter([["bailiff", 2]]), 11, 0)
	assert_equal(_telegraph_action_id(state, 0), "brace", "Offset 2 starts the Bailiff on brace.")
	var brace: int = _telegraph_value(state, 0)
	_end_turn(state)
	var enemy: Variant = state.enemies[0]
	assert_equal(enemy.guard, brace, "Guard N gives the enemy N guard.")
	assert_equal(_telegraph_action_id(state, 0), "rap", "The pattern wraps from brace to rap.")

	state.apply_damage_to_enemy(0, brace + 3)
	assert_equal(enemy.guard, 0, "Player damage is absorbed by enemy guard first.")
	assert_equal(enemy.health, int(enemy.max_health) - 3, "Only the remainder reaches enemy health.")

	var guarded_state: Variant = _start_fight(_custom_encounter([["bailiff", 2]]), 11, 0)
	_end_turn(guarded_state)
	assert_equal(guarded_state.enemies[0].guard, brace, "Guard is still up through the player's turn.")
	_end_turn(guarded_state)
	assert_equal(guarded_state.enemies[0].guard, 0, "Guard is cleared when the enemy next acts.")

func _test_fray_resolves_against_player_guard_and_never_touches_health() -> void:
	var fray_value: int = 0
	var hero_health: int = 0

	var frayed_state: Variant = _start_fight(_custom_encounter([["bookmoth", 0]]), 13, 1)
	assert_equal(_telegraph_type(frayed_state, 0), "fray", "The Bookmoth frays when an intact binding exists.")
	assert_equal(_telegraph_target_slot(frayed_state, 0), 0, "The only intact binding is the target.")
	fray_value = _telegraph_value(frayed_state, 0)
	hero_health = int(frayed_state.run_rules.hero_health)
	frayed_state.player_guard = fray_value - 1
	_end_turn(frayed_state)
	assert_true(frayed_state.binding_slot_is_frayed(0), "Guard below N: the binding is frayed.")
	assert_true(frayed_state.binding_slot_has_card(0), "A frayed binding stays in its slot.")
	assert_equal(frayed_state.player_guard, 0, "Guard drops to 0, not below.")
	assert_equal(frayed_state.player_health, hero_health, "Fray never deals health damage.")

	var held_state: Variant = _start_fight(_custom_encounter([["bookmoth", 0]]), 13, 1)
	held_state.player_guard = fray_value + 2
	_end_turn(held_state)
	assert_true(not held_state.binding_slot_is_frayed(0), "Guard at or above N: the binding stays intact.")
	assert_equal(held_state.player_health, hero_health, "Fray never deals health damage even when stopped.")

	# The Scrivener's guard resets at the start of the next turn, so a Bailiff
	# acting after the moth measures how much guard the fray spent.
	var pair: Array = [["bookmoth", 0], ["bailiff", 0]]
	var spent_state: Variant = _start_fight(_custom_encounter(pair), 13, 1)
	var rap_value: int = _telegraph_value(spent_state, 1)
	spent_state.player_guard = fray_value + 2
	_end_turn(spent_state)
	assert_true(not spent_state.binding_slot_is_frayed(0), "Guard above N keeps the binding intact.")
	assert_equal(spent_state.player_health, hero_health - (rap_value - 2), "Guard drops by exactly N before the next enemy acts.")

	var exact_state: Variant = _start_fight(_custom_encounter(pair), 13, 1)
	exact_state.player_guard = fray_value
	_end_turn(exact_state)
	assert_true(not exact_state.binding_slot_is_frayed(0), "Guard equal to N stops the fray.")
	assert_equal(exact_state.player_health, hero_health - rap_value, "Guard equal to N is fully spent.")

func _test_sever_removes_page_from_run_and_can_target_frayed_binding() -> void:
	var frayed_slots: Array[int] = [0]
	var state: Variant = _start_fight(_custom_encounter([["redactor", 1]]), 17, 1, frayed_slots)
	assert_equal(_telegraph_type(state, 0), "sever", "The Redactor severs when any binding exists.")
	assert_equal(_telegraph_target_slot(state, 0), 0, "A frayed binding is a valid sever target.")
	var bound_card: Variant = state.binding_slots[0]["card"]
	var sever_value: int = _telegraph_value(state, 0)
	state.player_guard = sever_value - 1
	_end_turn(state)
	assert_true(not state.binding_slot_has_card(0), "Sever empties the slot.")
	assert_true(state.removed_from_run.has(bound_card), "The severed page is removed from the run.")
	assert_true(not _card_is_in_deck_zones(state, bound_card), "The severed page is in no pile.")
	assert_equal(state.player_health, int(state.run_rules.hero_health), "Sever never deals health damage.")

	var held_state: Variant = _start_fight(_custom_encounter([["redactor", 1], ["bailiff", 0]]), 17, 1)
	var rap_value: int = _telegraph_value(held_state, 1)
	held_state.player_guard = sever_value + 2
	_end_turn(held_state)
	assert_true(held_state.binding_slot_has_card(0), "Guard above N stops the sever.")
	assert_equal(held_state.removed_from_run.size(), 0, "Nothing leaves the run when the sever is stopped.")
	assert_equal(held_state.player_health, int(held_state.run_rules.hero_health) - (rap_value - 2), "Sever spends N guard like fray.")

func _test_fray_targets_intact_only_sever_targets_any_and_two_frays_differ() -> void:
	var frayed_slots: Array[int] = [0]
	for seed: int in range(1, 13):
		var fray_state: Variant = _start_fight(_custom_encounter([["bookmoth", 0]]), seed, 2, frayed_slots)
		assert_equal(_telegraph_type(fray_state, 0), "fray", "Fray is telegraphed while an intact binding exists (seed %d)." % seed)
		assert_equal(_telegraph_target_slot(fray_state, 0), 1, "Fray never targets the frayed slot (seed %d)." % seed)

	var sever_targets: Dictionary = {}
	for seed: int in range(1, 25):
		var sever_state: Variant = _start_fight(_custom_encounter([["redactor", 1]]), seed, 2, frayed_slots)
		var target: int = _telegraph_target_slot(sever_state, 0)
		assert_true(target == 0 or target == 1, "Sever targets an occupied slot (seed %d)." % seed)
		sever_targets[target] = true
	assert_true(sever_targets.has(0) and sever_targets.has(1), "Across seeds sever reaches both the frayed and the intact binding.")

	for seed: int in range(1, 13):
		var pair_state: Variant = _start_fight(_custom_encounter([["bookmoth", 0], ["bookmoth", 0]]), seed, 2)
		assert_equal(_telegraph_type(pair_state, 0), "fray", "First moth frays (seed %d)." % seed)
		assert_equal(_telegraph_type(pair_state, 1), "fray", "Second moth frays (seed %d)." % seed)
		assert_true(_telegraph_target_slot(pair_state, 0) != _telegraph_target_slot(pair_state, 1), "Two frays in one phase pick different slots (seed %d)." % seed)
		_end_turn(pair_state)
		assert_true(pair_state.binding_slot_is_frayed(0) and pair_state.binding_slot_is_frayed(1), "Both bindings are frayed with no guard (seed %d)." % seed)

	var single_slot_state: Variant = _start_fight(_custom_encounter([["bookmoth", 0], ["bookmoth", 0]]), 3, 1)
	assert_equal(_telegraph_target_slot(single_slot_state, 0), 0, "With one intact binding the first moth targets it.")
	assert_equal(_telegraph_target_slot(single_slot_state, 1), 0, "With one intact binding the second moth targets the same slot.")
	single_slot_state.player_guard = 0
	_end_turn(single_slot_state)
	assert_true(single_slot_state.binding_slot_is_frayed(0), "The shared target is frayed once.")
	assert_true(single_slot_state.binding_slot_has_card(0), "A second fray on an already frayed binding does nothing further.")

func _test_fallbacks_without_binding_and_pattern_still_advances() -> void:
	var expected_fallbacks: Dictionary = {
		"bookmoth": [0, "unpick"],
		"registrar": [1, "press"],
		"redactor": [1, "p1_strike_out"]
	}
	for enemy_id_variant: Variant in expected_fallbacks.keys():
		var enemy_id: String = String(enemy_id_variant)
		var entry: Array = expected_fallbacks[enemy_id]
		var offset: int = int(entry[0])
		var action_id: String = String(entry[1])
		var state: Variant = _start_fight(_custom_encounter([[enemy_id, offset]]), 19, 0)
		var action_data: Dictionary = state.enemies[0].actions_by_id[action_id]
		var fallback: Dictionary = action_data["fallback"]
		assert_equal(_telegraph_action_id(state, 0), action_id, "%s starts on its binding action." % enemy_id)
		assert_equal(_telegraph_type(state, 0), "attack", "%s with no binding telegraphs the fallback attack." % enemy_id)
		assert_equal(_telegraph_value(state, 0), int(fallback.get("value", -1)), "%s fallback value comes from data." % enemy_id)
		assert_true(bool(state.enemies[0].telegraph.get("fallback_used", false)), "%s fallback is flagged." % enemy_id)
		var health_before: int = state.player_health
		_end_turn(state)
		assert_equal(health_before - state.player_health, int(fallback.get("value", -1)), "%s fallback attack lands." % enemy_id)
		assert_equal(state.enemies[0].pattern_index, (offset + 1) % state.enemies[0].telegraph_pattern.size(), "%s pattern still advances past the fallback." % enemy_id)

	var phase_two_state: Variant = _create_fight_state(_encounter("redactor"), 19)
	var redactor: Variant = phase_two_state.enemies[0]
	redactor.health = int(redactor.phases[0].get("health_at_or_below", 0))
	var core: Variant = COMBAT_CORE_SCRIPT.new()
	core.start_combat(phase_two_state)
	assert_equal(_telegraph_action_id(phase_two_state, 0), "p2_strike_out", "At or below the phase threshold the Redactor opens on phase 2 step 1.")
	var phase_two_fallback: Dictionary = redactor.actions_by_id["p2_strike_out"]["fallback"]
	assert_equal(_telegraph_type(phase_two_state, 0), "attack", "Phase 2 sever with no binding falls back to attack.")
	assert_equal(_telegraph_value(phase_two_state, 0), int(phase_two_fallback.get("value", -1)), "Phase 2 fallback value comes from data.")

func _test_foul_adds_stain_pages_to_discard() -> void:
	var state: Variant = _start_fight(_encounter("blotter_solo"), 23, 0)
	assert_equal(_telegraph_action_id(state, 0), "file", "blotter_solo opens on file.")
	assert_equal(_telegraph_type(state, 0), "foul", "file is a foul action.")
	assert_equal(String(state.enemies[0].telegraph.get("page_id", "")), STAIN_PAGE_IDS[0], "The foul telegraph carries the resolved stain page id.")
	var foul_count: int = _telegraph_value(state, 0)
	var hand_size: int = state.hand.size()
	var stains_before: int = _count_page_in_zone(state.discard_pile, STAIN_PAGE_IDS[0])
	_end_turn(state)
	assert_equal(_count_page_in_zone(state.discard_pile, STAIN_PAGE_IDS[0]) - stains_before, foul_count, "Foul N puts N stain pages into the discard.")
	assert_equal(state.discard_pile.size(), hand_size + foul_count, "The discard holds the discarded hand plus the stains.")
	assert_equal(state.player_health, int(state.run_rules.hero_health), "Foul deals no damage.")
	var stain_card: Variant = null
	for card_variant: Variant in state.discard_pile:
		if String(card_variant.page_id) == STAIN_PAGE_IDS[0]:
			stain_card = card_variant
	assert_true(stain_card != null and int(stain_card.cost) == int(_pages_by_id[STAIN_PAGE_IDS[0]].cost), "The stain is built from the real page data, not a placeholder.")

func _test_foul_page_id_comes_from_run_stain_ids() -> void:
	_load_data()
	var no_stain_state: Variant = ENCOUNTER_SPAWNER_SCRIPT.create_state(
		_encounter("blotter_solo"), _enemies_by_id, _catalog.run_rules, _starting_deck_pages(), _pages_by_id, PackedStringArray(), 1
	)
	assert_true(_array_contains_substring(no_stain_state.errors, "no stain page id"), "A run without a stain page id reports the unresolved foul action.")

	var explicit_state: Variant = ENCOUNTER_SPAWNER_SCRIPT.create_state(
		_encounter("blotter_solo"), _enemies_by_id, _catalog.run_rules, _starting_deck_pages(), _pages_by_id, PackedStringArray(["tally_mark"]), 1
	)
	var file_action: Dictionary = explicit_state.enemies[0].actions_by_id["file"]
	assert_equal(String(file_action.get("page_id", "")), "tally_mark", "The run's first stain id is written onto the foul action.")
	assert_true(not _enemies_by_id["blotter"].actions[0].has("page_id"), "Resolving the foul page does not mutate the shared EnemyData.")

	var unknown_state: Variant = ENCOUNTER_SPAWNER_SCRIPT.create_state(
		_custom_encounter([["archivist", 0]]), _enemies_by_id, _catalog.run_rules, _starting_deck_pages(), _pages_by_id, STAIN_PAGE_IDS, 1
	)
	assert_equal(unknown_state.enemies.size(), 0, "Unknown enemy ids spawn nothing.")
	assert_true(_array_contains_substring(unknown_state.errors, "unknown enemy id 'archivist'"), "Unknown enemy ids are reported on the state.")

func _test_redactor_switches_to_phase_two_at_half_health_and_never_back() -> void:
	var state: Variant = _start_fight(_encounter("redactor"), 29, 1)
	var redactor: Variant = state.enemies[0]
	var threshold: int = int(redactor.phases[0].get("health_at_or_below", 0))
	assert_equal(_telegraph_action_id(state, 0), "p1_strike_1", "The Redactor opens in phase 1.")
	assert_equal(redactor.active_phase_threshold, -1, "No phase is active at full health.")

	redactor.health = threshold + 1
	_end_turn(state)
	assert_equal(_telegraph_action_id(state, 0), "p1_strike_out", "One above the threshold stays in phase 1.")

	redactor.health = threshold
	_end_turn(state)
	assert_equal(_telegraph_action_id(state, 0), "p2_strike_out", "At the threshold the next telegraph is phase 2 step 1.")
	assert_equal(redactor.active_phase_threshold, threshold, "The phase threshold is recorded.")
	assert_equal(redactor.pattern_index, 0, "Phase 2 starts from its step 1.")

	redactor.health = int(redactor.max_health)
	_end_turn(state)
	assert_equal(_telegraph_action_id(state, 0), "p2_strike_1", "Healing above the threshold never reverts the phase.")
	_end_turn(state)
	assert_equal(_telegraph_action_id(state, 0), "p2_brace", "Phase 2 continues in order.")

func _test_start_offsets_place_each_enemy_on_its_pattern_step() -> void:
	var state: Variant = _start_fight(_encounter("bookmoth_pair_bailiff"), 31, 3)
	assert_equal(_telegraph_action_id(state, 0), "unpick", "Position 0 starts on step 1.")
	assert_equal(_telegraph_action_id(state, 1), "nibble", "Position 1 starts on step 2.")
	assert_equal(_telegraph_action_id(state, 2), "brace", "Position 2 starts on step 3.")
	assert_equal(state.enemies[1].pattern_index, 1, "Start offsets set the pattern index.")

	var out_of_range: Variant = _create_fight_state(_custom_encounter([["bailiff", 7]]), 31)
	assert_true(_array_contains_substring(out_of_range.errors, "start_offset 7 is out of range"), "An out-of-range offset is reported on the state.")
	assert_equal(out_of_range.enemies[0].pattern_index, 1, "An out-of-range offset wraps so the fight still runs.")

func _count_stains_in_deck_zones(state: Variant) -> int:
	var count: int = 0
	for zone_variant: Variant in [state.hand, state.draw_pile, state.discard_pile]:
		count += _count_page_in_zone(zone_variant, STAIN_PAGE_IDS[0])
	return count

func _assert_all_living_enemies_telegraph(state: Variant, moment: String) -> void:
	for position: int in range(state.enemies.size()):
		var enemy: Variant = state.enemies[position]
		if not enemy.is_alive():
			assert_true(enemy.telegraph.is_empty(), "Dead enemy at %d has no telegraph %s." % [position, moment])
			continue
		assert_true(not enemy.telegraph.is_empty(), "Living enemy at %d has a telegraph %s." % [position, moment])
		assert_true(["attack", "guard", "fray", "foul", "sever"].has(_telegraph_type(state, position)), "Telegraph type at %d is one of the five kinds %s." % [position, moment])
