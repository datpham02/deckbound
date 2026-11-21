class_name CombatCore
extends RefCounted

const COMBAT_STATE_SCRIPT := preload("res://scripts/combat/core/combat_state.gd")
const EFFECT_REGISTRY_SCRIPT := preload("res://scripts/combat/core/effect_registry.gd")

var effect_registry: Variant = EFFECT_REGISTRY_SCRIPT.new()

static func create_state(
	run_rules_data: Variant,
	deck_pages: Array,
	enemy_data_list: Array,
	page_library: Dictionary = {},
	stain_page_ids: PackedStringArray = PackedStringArray(),
	seed: int = 1
) -> Variant:
	return COMBAT_STATE_SCRIPT.create(run_rules_data, deck_pages, enemy_data_list, page_library, stain_page_ids, seed)

func start_combat(state: Variant) -> void:
	# Callers should place current bindings before start_combat so initial telegraphs can target them.
	state.set_initial_enemy_telegraphs()
	state.start_player_turn()

func play_card(state: Variant, hand_index: int, target_enemy_index: int = -1) -> bool:
	if state.is_combat_over():
		state.push_error("Cannot play a card because combat is over.")
		return false
	if not state.is_player_turn:
		state.push_error("Cannot play a card outside the player's turn.")
		return false
	if hand_index < 0 or hand_index >= state.hand.size():
		state.push_error("Hand index %d is out of range." % hand_index)
		return false

	var card: Variant = state.hand[hand_index]
	if state.player_ink < int(card.cost):
		state.push_error("Not enough ink to play '%s'." % String(card.page_id))
		return false
	if String(card.target) == "enemy" and not state.is_enemy_alive(target_enemy_index):
		state.push_error("Card '%s' requires a living enemy target." % String(card.page_id))
		return false

	var played_card: Variant = state.remove_card_from_hand_at(hand_index)
	if played_card == null:
		return false

	state.player_ink -= int(played_card.cost)
	state.source_card_removed = false

	for effect_variant: Variant in played_card.play_effects:
		if typeof(effect_variant) != TYPE_DICTIONARY:
			state.push_error("Card '%s' has a malformed play effect entry." % String(played_card.page_id))
			continue
		var effect_data: Dictionary = effect_variant
		var effect_id: String = String(effect_data.get("id", ""))
		var effect_params: Dictionary = {}
		if effect_data.has("params") and typeof(effect_data["params"]) == TYPE_DICTIONARY:
			effect_params = effect_data["params"]
		effect_registry.apply(effect_id, effect_params, state, played_card, target_enemy_index)
		if state.is_combat_over():
			break

	if state.source_card_removed:
		state.removed_from_run.append(played_card)
	else:
		state.discard_card(played_card)
	state.source_card_removed = false

	state.update_result()
	return true

func end_player_turn(state: Variant) -> void:
	if state.is_combat_over():
		return
	if not state.is_player_turn:
		state.push_error("Cannot end turn outside the player's turn.")
		return

	state.discard_hand()
	state.is_player_turn = false
	_resolve_enemy_phase(state)

	if not state.is_combat_over():
		state.start_player_turn()

func registry_effect_ids() -> PackedStringArray:
	return effect_registry.effect_ids()

func _resolve_enemy_phase(state: Variant) -> void:
	for enemy_variant: Variant in state.enemies:
		var enemy: Variant = enemy_variant
		if not enemy.is_alive():
			continue
		enemy.act_from_telegraph(state)
		if state.is_combat_over():
			break

	if state.is_combat_over():
		return

	var reserved_fray_slots: Array[int] = []
	for enemy_variant: Variant in state.enemies:
		var enemy: Variant = enemy_variant
		if not enemy.is_alive():
			continue
		enemy.advance_telegraph(state, reserved_fray_slots)
		if String(enemy.telegraph.get("type", "")) == "fray":
			var target_slot: int = int(enemy.telegraph.get("target_slot", -1))
			if target_slot >= 0 and not reserved_fray_slots.has(target_slot):
				reserved_fray_slots.append(target_slot)
