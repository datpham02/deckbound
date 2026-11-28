extends "res://tests/combat/enemies/enemy_test_support.gd"

# Resume state per enemy (docs/design/enemies.md §6 and §9 criterion 13). T8
# exposes capture and restore; T17 stores the result. Every snapshot goes
# through JSON.stringify / JSON.parse_string so the saved form is exercised.

const ENEMY_SNAPSHOT_SCRIPT := preload("res://scripts/combat/enemies/enemy_snapshot.gd")

func test() -> void:
	_test_snapshot_round_trip_restores_health_guard_step_and_targets()
	_test_snapshot_round_trip_restores_boss_phase()
	_test_snapshot_keeps_fallback_flag_and_dead_enemies()
	_test_restore_rejects_mismatched_composition()
	_test_restore_reports_bad_phase_and_step()

func _test_snapshot_round_trip_restores_health_guard_step_and_targets() -> void:
	# Offsets of 2 put both moths on unpick and the Bailiff on rap, with guard
	# from its brace, after the first enemy phase: the richest state to save.
	var encounter: Variant = _custom_encounter([["bookmoth", 2], ["bookmoth", 2], ["bailiff", 2]], "snapshot_fight")
	var state: Variant = _start_fight(encounter, 41, 3)
	state.apply_damage_to_enemy(2, 4)
	_end_turn(state)
	state.apply_damage_to_enemy(0, 2)
	assert_true(state.enemies[2].guard > 0, "The Bailiff carries guard from its brace.")
	for position: int in range(2):
		assert_equal(_telegraph_type(state, position), "fray", "Moth %d telegraphs a fray with three intact bindings." % position)
		assert_true(_telegraph_target_slot(state, position) >= 0, "A fray telegraph carries its target slot.")
	assert_true(_telegraph_target_slot(state, 0) != _telegraph_target_slot(state, 1), "The two frays threaten different slots.")

	var snapshots: Array = _round_trip(ENEMY_SNAPSHOT_SCRIPT.capture_enemies(state))
	assert_equal(snapshots.size(), 3, "One snapshot per enemy.")
	assert_equal(int(snapshots[2].get("guard", -1)), int(state.enemies[2].guard), "Guard is captured.")
	assert_equal(int(snapshots[2].get("health", -1)), int(state.enemies[2].max_health) - 4, "Health is captured.")
	assert_equal(int(snapshots[0].get("health", -1)), int(state.enemies[0].max_health) - 2, "Damage taken mid-turn is captured.")
	assert_equal(int(snapshots[1].get("pattern_index", -1)), int(state.enemies[1].pattern_index), "Step index is captured.")
	assert_equal(int(snapshots[0].get("position", -1)), 0, "Position is captured.")
	assert_equal(int(snapshots[0].get("telegraph", {}).get("target_slot", -1)), _telegraph_target_slot(state, 0), "The fray target slot is captured.")

	var restored: Variant = _restored_state(encounter, 3)
	var ok: bool = ENEMY_SNAPSHOT_SCRIPT.restore_enemies(restored, snapshots)
	assert_true(ok, "Restore onto the same composition succeeds.")
	assert_true(restored.errors.is_empty(), "Restore raises no errors: %s" % str(restored.errors))
	_assert_enemies_match(state, restored)

	var recaptured: Array = _round_trip(ENEMY_SNAPSHOT_SCRIPT.capture_enemies(restored))
	assert_equal(JSON.stringify(recaptured), JSON.stringify(snapshots), "Capturing the restored state reproduces the saved snapshots.")

	# Player health belongs to the run snapshot (T17), so compare the damage
	# each fight deals from here on, not the absolute value.
	var state_health_before: int = state.player_health
	var restored_health_before: int = restored.player_health
	state.player_guard = 0
	restored.player_guard = 0
	var core: Variant = COMBAT_CORE_SCRIPT.new()
	core.end_player_turn(state)
	core.end_player_turn(restored)
	assert_true(restored.errors.is_empty(), "The restored fight continues without errors: %s" % str(restored.errors))
	for slot_index: int in range(3):
		assert_equal(restored.binding_slot_is_frayed(slot_index), state.binding_slot_is_frayed(slot_index), "The restored fight resolves the same fray on slot %d." % slot_index)
	assert_equal(restored_health_before - restored.player_health, state_health_before - state.player_health, "The restored fight deals the same damage.")
	_assert_enemies_match(state, restored)

func _test_snapshot_round_trip_restores_boss_phase() -> void:
	var encounter: Variant = _encounter("redactor")
	var state: Variant = _start_fight(encounter, 43, 2)
	var redactor: Variant = state.enemies[0]
	var threshold: int = int(redactor.phases[0].get("health_at_or_below", 0))
	assert_equal(ENEMY_SNAPSHOT_SCRIPT.phase_number(redactor), 1, "Full health is phase 1.")
	redactor.health = threshold - 5
	_end_turn(state)
	assert_equal(ENEMY_SNAPSHOT_SCRIPT.phase_number(redactor), 2, "Below the threshold is phase 2.")
	assert_equal(_telegraph_type(state, 0), "sever", "Phase 2 opens with a sever when a binding exists.")
	var target_slot: int = _telegraph_target_slot(state, 0)

	var snapshots: Array = _round_trip(ENEMY_SNAPSHOT_SCRIPT.capture_enemies(state))
	assert_equal(int(snapshots[0].get("phase", 0)), 2, "The phase number is saved.")
	assert_equal(int(snapshots[0].get("phase_threshold", 0)), threshold, "The phase threshold is saved.")
	assert_equal(int(snapshots[0].get("telegraph", {}).get("target_slot", -1)), target_slot, "The sever target slot is saved.")

	var restored: Variant = _restored_state(encounter, 2)
	assert_true(ENEMY_SNAPSHOT_SCRIPT.restore_enemies(restored, snapshots), "Boss restore succeeds.")
	var restored_redactor: Variant = restored.enemies[0]
	assert_equal(restored_redactor.active_phase_threshold, threshold, "The phase latch is restored.")
	assert_equal(Array(restored_redactor.telegraph_pattern), Array(redactor.telegraph_pattern), "The phase 2 pattern is restored.")
	assert_equal(_telegraph_target_slot(restored, 0), target_slot, "The same slot is threatened after resume.")
	_assert_enemies_match(state, restored)

	restored_redactor.health = int(restored_redactor.max_health)
	_end_turn(restored)
	assert_equal(_telegraph_action_id(restored, 0), "p2_strike_1", "A restored phase 2 never reverts to phase 1.")

func _test_snapshot_keeps_fallback_flag_and_dead_enemies() -> void:
	var encounter: Variant = _custom_encounter([["bookmoth", 0], ["bailiff", 0]])
	var state: Variant = _start_fight(encounter, 47, 0)
	assert_true(bool(state.enemies[0].telegraph.get("fallback_used", false)), "With no binding the moth telegraphs its fallback.")
	state.apply_damage_to_enemy(1, 100)
	assert_true(not state.enemies[1].is_alive(), "The Bailiff is dead.")

	var snapshots: Array = _round_trip(ENEMY_SNAPSHOT_SCRIPT.capture_enemies(state))
	assert_true(bool(snapshots[0].get("telegraph", {}).get("fallback_used", false)), "The fallback flag is saved.")
	assert_equal(int(snapshots[1].get("health", -1)), 0, "A dead enemy is saved at 0 health.")
	assert_true(Dictionary(snapshots[1].get("telegraph", {"x": 1})).is_empty(), "A dead enemy has no telegraph to save.")

	var restored: Variant = _create_fight_state(encounter, 2)
	assert_true(ENEMY_SNAPSHOT_SCRIPT.restore_enemies(restored, snapshots), "Restore with a dead enemy succeeds.")
	assert_true(not restored.enemies[1].is_alive(), "The dead enemy stays dead.")
	assert_true(restored.enemies[1].telegraph.is_empty(), "The dead enemy stays without a telegraph.")
	assert_true(bool(restored.enemies[0].telegraph.get("fallback_used", false)), "The fallback flag survives resume.")
	assert_equal(restored.result, "ongoing", "The fight is still on with one living enemy.")

	state.apply_damage_to_enemy(0, 100)
	var won_snapshots: Array = _round_trip(ENEMY_SNAPSHOT_SCRIPT.capture_enemies(state))
	var won_restored: Variant = _create_fight_state(encounter, 3)
	assert_true(ENEMY_SNAPSHOT_SCRIPT.restore_enemies(won_restored, won_snapshots), "Restore of a finished fight succeeds.")
	assert_equal(won_restored.result, "won", "Restoring all enemies dead updates the result.")

func _test_restore_rejects_mismatched_composition() -> void:
	var state: Variant = _start_fight(_encounter("bailiff_pair"), 53, 0)
	var snapshots: Array = _round_trip(ENEMY_SNAPSHOT_SCRIPT.capture_enemies(state))

	var wrong_count: Variant = _create_fight_state(_encounter("bailiff_solo"), 1)
	assert_true(not ENEMY_SNAPSHOT_SCRIPT.restore_enemies(wrong_count, snapshots), "A different enemy count is refused.")
	assert_true(_array_contains_substring(wrong_count.errors, "Cannot restore 2 enemy snapshots onto 1 enemies"), "The count mismatch is reported.")

	var wrong_ids: Variant = _create_fight_state(_encounter("bookmoth_pair"), 1)
	assert_true(not ENEMY_SNAPSHOT_SCRIPT.restore_enemies(wrong_ids, snapshots), "Different enemy ids are refused.")
	assert_true(_array_contains_substring(wrong_ids.errors, "is for 'bailiff' but the composition has 'bookmoth'"), "The id mismatch is reported.")
	assert_equal(int(wrong_ids.enemies[0].health), int(wrong_ids.enemies[0].max_health), "A refused restore changes nothing.")

	var not_dictionaries: Variant = _create_fight_state(_encounter("bailiff_pair"), 1)
	assert_true(not ENEMY_SNAPSHOT_SCRIPT.restore_enemies(not_dictionaries, [1, 2]), "Non-dictionary snapshots are refused.")

func _test_restore_reports_bad_phase_and_step() -> void:
	var encounter: Variant = _encounter("redactor")
	var state: Variant = _start_fight(encounter, 59, 0)
	var snapshots: Array = _round_trip(ENEMY_SNAPSHOT_SCRIPT.capture_enemies(state))
	snapshots[0]["phase_threshold"] = 12
	snapshots[0]["pattern_index"] = 9

	var restored: Variant = _create_fight_state(encounter, 1)
	assert_true(ENEMY_SNAPSHOT_SCRIPT.restore_enemies(restored, snapshots), "Bad phase and step values are repaired, not fatal.")
	assert_true(_array_contains_substring(restored.errors, "has no phase with health_at_or_below 12"), "An unknown phase threshold is reported.")
	assert_true(_array_contains_substring(restored.errors, "pattern_index 9 is out of range"), "An out-of-range step is reported.")
	assert_equal(restored.enemies[0].active_phase_threshold, -1, "An unknown phase falls back to the base pattern.")
	assert_equal(restored.enemies[0].pattern_index, 9 % restored.enemies[0].telegraph_pattern.size(), "An out-of-range step wraps.")

# A fresh state for the same composition, mid player turn, with `binding_count`
# intact bindings: what T17 rebuilds before restoring the enemies.
func _restored_state(encounter: Variant, binding_count: int) -> Variant:
	var restored: Variant = _create_fight_state(encounter, 999)
	for slot_index: int in range(binding_count):
		restored.set_binding(slot_index, COMBAT_CARD_SCRIPT.create_placeholder("bound_%d" % slot_index))
	restored.is_player_turn = true
	restored.turn_number = 2
	return restored

func _round_trip(snapshots: Array[Dictionary]) -> Array:
	var text: String = JSON.stringify(snapshots)
	var parsed: Variant = JSON.parse_string(text)
	assert_true(typeof(parsed) == TYPE_ARRAY, "Snapshots survive a JSON round trip.")
	if typeof(parsed) != TYPE_ARRAY:
		return []
	return parsed

func _assert_enemies_match(expected_state: Variant, actual_state: Variant) -> void:
	assert_equal(actual_state.enemies.size(), expected_state.enemies.size(), "Enemy count matches.")
	for position: int in range(mini(actual_state.enemies.size(), expected_state.enemies.size())):
		var expected: Variant = expected_state.enemies[position]
		var actual: Variant = actual_state.enemies[position]
		assert_equal(String(actual.id), String(expected.id), "Enemy id at %d." % position)
		assert_equal(int(actual.health), int(expected.health), "Health at %d." % position)
		assert_equal(int(actual.guard), int(expected.guard), "Guard at %d." % position)
		assert_equal(int(actual.pattern_index), int(expected.pattern_index), "Step index at %d." % position)
		assert_equal(int(actual.active_phase_threshold), int(expected.active_phase_threshold), "Phase at %d." % position)
		assert_equal(Array(actual.telegraph_pattern), Array(expected.telegraph_pattern), "Pattern at %d." % position)
		assert_equal(JSON.stringify(actual.telegraph), JSON.stringify(expected.telegraph), "Telegraph at %d." % position)
