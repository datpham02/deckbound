class_name BindingSystem
extends RefCounted

func bind_from_hand(state: Variant, hand_index: int, slot_index: int) -> bool:
	if not _can_bind_from_hand(state, hand_index, slot_index):
		return false

	var selected_card: Variant = state.hand[hand_index]
	var page_id: String = String(selected_card.page_id)
	var deck_floor: int = maxi(0, int(state.run_rules.deck_floor))
	var projected_deck_count: int = _count_deck_cards(state) - 1
	if projected_deck_count < deck_floor:
		state.push_error(
			"Cannot bind '%s': deck floor %d would be broken (%d remaining)." % [
				page_id,
				deck_floor,
				projected_deck_count
			]
		)
		return false

	var bound_card: Variant = state.remove_card_from_hand_at(hand_index)
	if bound_card == null:
		state.push_error("Could not bind '%s' because the source card was not found." % page_id)
		return false

	state.player_ink -= int(bound_card.cost)
	state.set_binding(slot_index, bound_card, false)
	state.add_log("bind:%s:slot_%d" % [page_id, slot_index])
	return true

func unbind_to_draw_pile(state: Variant, slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= state.binding_slots.size():
		state.push_error("Cannot unbind from slot %d because it is out of range." % slot_index)
		return false
	if not state.binding_slot_has_card(slot_index):
		state.push_error("Cannot unbind from slot %d because it is empty." % slot_index)
		return false

	var slot_data: Dictionary = state.binding_slots[slot_index]
	var card: Variant = slot_data.get("card", null)
	state.clear_binding(slot_index)
	if card != null:
		state.draw_pile.append(card)
		state.add_log("unbind:%s:slot_%d" % [String(card.page_id), slot_index])
	return true

func fray_binding_slot(state: Variant, slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= state.binding_slots.size():
		state.push_error("Cannot fray slot %d because it is out of range." % slot_index)
		return false
	if not state.binding_slot_has_card(slot_index):
		state.push_error("Cannot fray slot %d because it is empty." % slot_index)
		return false

	state.fray_binding(slot_index)
	return true

func sever_binding_slot(state: Variant, slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= state.binding_slots.size():
		state.push_error("Cannot sever slot %d because it is out of range." % slot_index)
		return false
	if not state.binding_slot_has_card(slot_index):
		state.push_error("Cannot sever slot %d because it is empty." % slot_index)
		return false

	state.sever_binding(slot_index)
	return true

func reset_frayed_bindings(state: Variant) -> void:
	for index: int in range(state.binding_slots.size()):
		if not state.binding_slot_has_card(index):
			continue
		state.binding_slots[index]["frayed"] = false

func collect_active_passives(state: Variant) -> Array[Dictionary]:
	var passives: Array[Dictionary] = []
	for slot_data_variant: Variant in state.binding_slots:
		if typeof(slot_data_variant) != TYPE_DICTIONARY:
			continue
		var slot_data: Dictionary = slot_data_variant
		if not slot_data.has("card"):
			continue
		if bool(slot_data.get("frayed", false)):
			continue
		var card: Variant = slot_data["card"]
		for passive_variant: Variant in card.bind_passives:
			if typeof(passive_variant) != TYPE_DICTIONARY:
				continue
			var passive_data: Dictionary = passive_variant
			passives.append(passive_data.duplicate(true))
	return passives

func collect_active_passives_by_id(state: Variant, passive_id: String) -> Array[Dictionary]:
	var selected_passives: Array[Dictionary] = []
	for passive_data: Dictionary in collect_active_passives(state):
		if String(passive_data.get("id", "")) == passive_id:
			selected_passives.append(passive_data)
	return selected_passives

func apply_start_of_combat_passives(state: Variant) -> void:
	for passive_data: Dictionary in collect_active_passives(state):
		var passive_id: String = String(passive_data.get("id", ""))
		match passive_id:
			"start_combat_guard":
				state.gain_player_guard(_passive_param_int(passive_data, "amount"))
			"start_combat_damage_all":
				_damage_all_enemies(state, _passive_param_int(passive_data, "amount"))

func apply_start_of_turn_passives(state: Variant) -> void:
	for passive_data: Dictionary in collect_active_passives(state):
		var passive_id: String = String(passive_data.get("id", ""))
		match passive_id:
			"turn_ink":
				state.gain_player_ink(_passive_param_int(passive_data, "amount"))
			"turn_guard_per_empty_slot":
				var per_guard: int = _passive_param_int(passive_data, "per")
				state.gain_player_guard(per_guard * state.count_empty_binding_slots())
			"turn_draw":
				state.draw_cards(_passive_param_int(passive_data, "count"))
			"turn_draw_lose_health":
				state.draw_cards(_passive_param_int(passive_data, "count"))
				state.lose_player_health(_passive_param_int(passive_data, "amount"))

func apply_end_of_turn_passives(state: Variant) -> void:
	for passive_data: Dictionary in collect_active_passives(state):
		if String(passive_data.get("id", "")) != "end_turn_damage_all":
			continue
		_damage_all_enemies(state, _passive_param_int(passive_data, "amount"))

func modify_played_damage(state: Variant, amount: int) -> int:
	var modified: int = maxi(0, amount)
	for passive_data: Dictionary in collect_active_passives_by_id(state, "played_damage_bonus"):
		modified += _passive_param_int(passive_data, "amount")
	return modified

func _can_bind_from_hand(state: Variant, hand_index: int, slot_index: int) -> bool:
	if state.is_combat_over():
		state.push_error("Cannot bind a card because combat is over.")
		return false
	if not state.is_player_turn:
		state.push_error("Cannot bind a card outside the player's turn.")
		return false
	if slot_index < 0 or slot_index >= state.binding_slots.size():
		state.push_error("Cannot bind into slot %d because it is out of range." % slot_index)
		return false
	if state.binding_slot_has_card(slot_index):
		state.push_error("Cannot bind into slot %d because it is already occupied." % slot_index)
		return false
	if hand_index < 0 or hand_index >= state.hand.size():
		state.push_error("Cannot bind hand index %d because it is out of range." % hand_index)
		return false

	var selected_card: Variant = state.hand[hand_index]
	if selected_card == null:
		state.push_error("Cannot bind a null card.")
		return false
	var page_id: String = String(selected_card.page_id)
	if page_id == "":
		state.push_error("Cannot bind a card with an empty page id.")
		return false
	if state.player_ink < int(selected_card.cost):
		state.push_error("Not enough ink to bind '%s'." % page_id)
		return false
	return true

func _count_deck_cards(state: Variant) -> int:
	return state.hand.size() + state.draw_pile.size() + state.discard_pile.size()

func _passive_param_int(passive_data: Dictionary, key: String) -> int:
	var params_variant: Variant = passive_data.get("params", {})
	if typeof(params_variant) != TYPE_DICTIONARY:
		return 0
	var params: Dictionary = params_variant
	return maxi(0, int(params.get(key, 0)))

func _damage_all_enemies(state: Variant, amount: int) -> void:
	var damage: int = maxi(0, amount)
	if damage <= 0:
		return
	for enemy_index: int in range(state.enemies.size()):
		if not state.is_enemy_alive(enemy_index):
			continue
		state.apply_damage_to_enemy(enemy_index, damage)
