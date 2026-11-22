class_name BindingSystem
extends RefCounted

func bind_from_hand(state: Variant, hand_index: int, slot_index: int) -> bool:
	if not _can_bind_from_hand(state, hand_index, slot_index):
		return false

	var selected_card: Variant = state.hand[hand_index]
	var selected_uid: int = int(selected_card.uid)
	var page_id: String = String(selected_card.page_id)
	var deck_floor: int = maxi(0, int(state.run_rules.deck_floor))
	var removable_count: int = _count_matching_cards(state.hand, page_id)
	removable_count += _count_matching_cards(state.draw_pile, page_id)
	removable_count += _count_matching_cards(state.discard_pile, page_id)
	var projected_deck_count: int = _count_deck_cards(state) - removable_count
	if projected_deck_count < deck_floor:
		state.push_error(
			"Cannot bind '%s': deck floor %d would be broken (%d remaining)." % [
				page_id,
				deck_floor,
				projected_deck_count
			]
		)
		return false

	var bound_card: Variant = _remove_card_from_hand_for_binding(state, page_id, selected_uid)
	if bound_card == null:
		state.push_error("Could not bind '%s' because the source card was not found." % page_id)
		return false

	_remove_matching_cards_to_removed(state.draw_pile, page_id, state.removed_from_run)
	_remove_matching_cards_to_removed(state.discard_pile, page_id, state.removed_from_run)
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

func _can_bind_from_hand(state: Variant, hand_index: int, slot_index: int) -> bool:
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
	return true

func _count_deck_cards(state: Variant) -> int:
	return state.hand.size() + state.draw_pile.size() + state.discard_pile.size()

func _count_matching_cards(zone: Array[Variant], page_id: String) -> int:
	var count: int = 0
	for card_variant: Variant in zone:
		if _matches_page_id(card_variant, page_id):
			count += 1
	return count

func _remove_card_from_hand_for_binding(state: Variant, page_id: String, selected_uid: int) -> Variant:
	var bound_card: Variant = null
	var index: int = state.hand.size() - 1
	while index >= 0:
		var card_variant: Variant = state.hand[index]
		if _matches_page_id(card_variant, page_id):
			var removed_card: Variant = state.hand[index]
			state.hand.remove_at(index)
			if bound_card == null and int(removed_card.uid) == selected_uid:
				bound_card = removed_card
			else:
				state.removed_from_run.append(removed_card)
		index -= 1

	return bound_card

func _remove_matching_cards_to_removed(zone: Array[Variant], page_id: String, removed_zone: Array[Variant]) -> void:
	var index: int = zone.size() - 1
	while index >= 0:
		var card_variant: Variant = zone[index]
		if _matches_page_id(card_variant, page_id):
			var removed_card: Variant = zone[index]
			zone.remove_at(index)
			removed_zone.append(removed_card)
		index -= 1

func _matches_page_id(card_variant: Variant, page_id: String) -> bool:
	if card_variant == null:
		return false
	return String(card_variant.page_id) == page_id
