class_name CombatState
extends RefCounted

const COMBAT_CARD_SCRIPT := preload("res://scripts/combat/core/combat_card.gd")
const COMBAT_ENEMY_SCRIPT := preload("res://scripts/combat/core/combat_enemy.gd")

var run_rules: Variant = null
var player_health: int = 0
var player_max_health: int = 0
var player_guard: int = 0
var player_ink: int = 0
var turn_number: int = 0
var is_player_turn: bool = false
var result: String = "ongoing"
var draw_pile: Array[Variant] = []
var hand: Array[Variant] = []
var discard_pile: Array[Variant] = []
var removed_from_run: Array[Variant] = []
var enemies: Array[Variant] = []
var binding_slots: Array[Dictionary] = []
var page_library: Dictionary = {}
var stain_page_ids: PackedStringArray = PackedStringArray()
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var logs: Array[String] = []
var errors: Array[String] = []
var source_card_removed: bool = false

static func create(
	run_rules_data: Variant,
	deck_pages: Array,
	enemy_data_list: Array,
	page_library_override: Dictionary = {},
	stain_page_ids_override: PackedStringArray = PackedStringArray(),
	seed: int = 1
) -> Variant:
	var state: Variant = new()
	state.run_rules = run_rules_data
	state.player_max_health = int(run_rules_data.hero_health)
	state.player_health = int(run_rules_data.hero_health)
	state.player_guard = 0
	state.player_ink = 0
	state.turn_number = 0
	state.result = "ongoing"
	state.rng.seed = seed
	state.stain_page_ids = stain_page_ids_override.duplicate()

	if page_library_override.is_empty():
		for deck_page_variant: Variant in deck_pages:
			var page_id: String = String(deck_page_variant.id)
			if page_id != "":
				state.page_library[page_id] = deck_page_variant
	else:
		for page_id_variant: Variant in page_library_override.keys():
			var page_id: String = String(page_id_variant)
			state.page_library[page_id] = page_library_override[page_id_variant]

	for deck_page_variant: Variant in deck_pages:
		var card: Variant = COMBAT_CARD_SCRIPT.from_page_data(deck_page_variant)
		state.draw_pile.append(card)
		var page_id: String = String(deck_page_variant.id)
		if page_id != "":
			state.page_library[page_id] = deck_page_variant

	state._shuffle_array_in_place(state.draw_pile)

	for enemy_data_variant: Variant in enemy_data_list:
		var enemy: Variant = COMBAT_ENEMY_SCRIPT.from_enemy_data(enemy_data_variant)
		state.enemies.append(enemy)

	var bind_slot_count: int = maxi(0, int(run_rules_data.bind_slots))
	for _slot in range(bind_slot_count):
		state.binding_slots.append({})

	return state

func set_initial_enemy_telegraphs() -> void:
	var reserved_fray_slots: Array[int] = []
	for enemy_variant: Variant in enemies:
		var enemy: Variant = enemy_variant
		if not enemy.is_alive():
			continue
		enemy.set_initial_telegraph(self, reserved_fray_slots)
		if String(enemy.telegraph.get("type", "")) == "fray":
			var target_slot: int = int(enemy.telegraph.get("target_slot", -1))
			if target_slot >= 0 and not reserved_fray_slots.has(target_slot):
				reserved_fray_slots.append(target_slot)

func start_player_turn() -> void:
	if is_combat_over():
		return
	turn_number += 1
	is_player_turn = true
	player_guard = 0
	player_ink = int(run_rules.ink_per_turn)
	draw_cards(int(run_rules.hand_draw))
	update_result()

func draw_cards(count: int) -> int:
	var draws: int = maxi(0, count)
	var drawn: int = 0
	for _index in range(draws):
		if hand.size() >= int(run_rules.hand_max):
			break
		if not _draw_one_card():
			break
		drawn += 1
	return drawn

func discard_hand() -> void:
	for card_variant: Variant in hand:
		discard_pile.append(card_variant)
	hand.clear()

func discard_card(card: Variant) -> void:
	if card != null:
		discard_pile.append(card)

func remove_card_from_hand_at(index: int) -> Variant:
	if index < 0 or index >= hand.size():
		push_error("Hand index %d is out of range." % index)
		return null
	var card: Variant = hand[index]
	hand.remove_at(index)
	return card

func add_page_to_discard_by_id(page_id: String) -> void:
	var card: Variant = null
	if page_library.has(page_id):
		card = COMBAT_CARD_SCRIPT.from_page_data(page_library[page_id])
	else:
		card = COMBAT_CARD_SCRIPT.create_placeholder(page_id)
	discard_pile.append(card)

func remove_stains_from_hand_and_discard(stain_ids: PackedStringArray) -> int:
	var removed: int = 0
	removed += _remove_cards_from_zone_by_ids(hand, stain_ids)
	removed += _remove_cards_from_zone_by_ids(discard_pile, stain_ids)
	return removed

func remove_stains_from_hand(max_count: int, stain_ids: PackedStringArray) -> int:
	var removed: int = 0
	var index: int = hand.size() - 1
	while index >= 0 and removed < max_count:
		var card: Variant = hand[index]
		if _card_matches_any_page_id(card, stain_ids):
			var removed_card: Variant = hand[index]
			hand.remove_at(index)
			removed_from_run.append(removed_card)
			removed += 1
		index -= 1
	return removed

func apply_damage_to_enemy(enemy_index: int, amount: int) -> void:
	var damage: int = maxi(0, amount)
	if damage <= 0:
		return
	if not is_enemy_alive(enemy_index):
		return

	var enemy: Variant = enemies[enemy_index]
	var remaining: int = damage
	if enemy.guard > 0:
		var absorbed_by_guard: int = mini(enemy.guard, remaining)
		enemy.guard -= absorbed_by_guard
		remaining -= absorbed_by_guard

	if remaining > 0:
		enemy.health = maxi(0, enemy.health - remaining)
		if enemy.health == 0:
			enemy.telegraph.clear()

	update_result()

func apply_attack_to_player(amount: int) -> void:
	var damage: int = maxi(0, amount)
	if damage <= 0:
		return

	var remaining: int = damage
	if player_guard > 0:
		var absorbed_by_guard: int = mini(player_guard, remaining)
		player_guard -= absorbed_by_guard
		remaining -= absorbed_by_guard

	if remaining > 0:
		player_health = maxi(0, player_health - remaining)

	update_result()

func heal_player(amount: int) -> void:
	var value: int = maxi(0, amount)
	player_health = mini(player_max_health, player_health + value)

func lose_player_health(amount: int) -> void:
	var value: int = maxi(0, amount)
	player_health = maxi(0, player_health - value)
	update_result()

func gain_player_guard(amount: int) -> void:
	player_guard += maxi(0, amount)

func gain_player_ink(amount: int) -> void:
	player_ink += maxi(0, amount)

func clear_enemy_guard(enemy_index: int) -> void:
	if not is_enemy_alive(enemy_index):
		return
	var enemy: Variant = enemies[enemy_index]
	enemy.guard = 0

func update_result() -> void:
	if player_health <= 0:
		result = "lost"
		is_player_turn = false
		return

	for enemy_variant: Variant in enemies:
		var enemy: Variant = enemy_variant
		if enemy.is_alive():
			result = "ongoing"
			return

	result = "won"
	is_player_turn = false

func is_combat_over() -> bool:
	return result != "ongoing"

func is_player_dead() -> bool:
	return player_health <= 0

func is_enemy_alive(enemy_index: int) -> bool:
	if enemy_index < 0 or enemy_index >= enemies.size():
		return false
	var enemy: Variant = enemies[enemy_index]
	return enemy.is_alive()

func first_living_enemy_index() -> int:
	for index in range(enemies.size()):
		if is_enemy_alive(index):
			return index
	return -1

func count_occupied_bindings() -> int:
	var occupied: int = 0
	for slot_data: Dictionary in binding_slots:
		if slot_data.has("card"):
			occupied += 1
	return occupied

func count_empty_binding_slots() -> int:
	return maxi(0, binding_slots.size() - count_occupied_bindings())

func get_intact_binding_slots() -> Array[int]:
	var slots: Array[int] = []
	for index in range(binding_slots.size()):
		if not binding_slots[index].has("card"):
			continue
		if bool(binding_slots[index].get("frayed", false)):
			continue
		slots.append(index)
	return slots

func get_occupied_binding_slots() -> Array[int]:
	var slots: Array[int] = []
	for index in range(binding_slots.size()):
		if binding_slots[index].has("card"):
			slots.append(index)
	return slots

func pick_binding_slot(slots: Array[int]) -> int:
	if slots.is_empty():
		return -1
	var random_index: int = rng.randi_range(0, slots.size() - 1)
	return slots[random_index]

func binding_slot_has_card(slot_index: int) -> bool:
	if not _is_binding_slot_valid(slot_index):
		return false
	return binding_slots[slot_index].has("card")

func binding_slot_is_frayed(slot_index: int) -> bool:
	if not _is_binding_slot_valid(slot_index):
		return false
	if not binding_slots[slot_index].has("card"):
		return false
	return bool(binding_slots[slot_index].get("frayed", false))

func set_binding(slot_index: int, card: Variant, frayed: bool = false) -> void:
	if not _is_binding_slot_valid(slot_index):
		push_error("Binding slot %d is out of range." % slot_index)
		return
	binding_slots[slot_index] = {
		"card": card,
		"frayed": frayed
	}

func clear_binding(slot_index: int) -> void:
	if not _is_binding_slot_valid(slot_index):
		return
	binding_slots[slot_index].clear()

func fray_binding(slot_index: int) -> void:
	if not binding_slot_has_card(slot_index):
		return
	if binding_slot_is_frayed(slot_index):
		return
	binding_slots[slot_index]["frayed"] = true

func sever_binding(slot_index: int) -> void:
	if not binding_slot_has_card(slot_index):
		return
	var slot_data: Dictionary = binding_slots[slot_index]
	removed_from_run.append(slot_data["card"])
	binding_slots[slot_index].clear()

func mark_source_card_removed() -> void:
	source_card_removed = true

func push_error(message: String) -> void:
	errors.append(message)

func add_log(message: String) -> void:
	logs.append(message)

func _draw_one_card() -> bool:
	if hand.size() >= int(run_rules.hand_max):
		return false

	if draw_pile.is_empty():
		_reshuffle_discard_into_draw()
	if draw_pile.is_empty():
		return false

	var next_card: Variant = draw_pile.pop_back()
	hand.append(next_card)
	return true

func _reshuffle_discard_into_draw() -> void:
	if discard_pile.is_empty():
		return
	for card_variant: Variant in discard_pile:
		draw_pile.append(card_variant)
	discard_pile.clear()
	_shuffle_array_in_place(draw_pile)
	add_log("reshuffle")

func _shuffle_array_in_place(values: Array[Variant]) -> void:
	var index: int = values.size() - 1
	while index > 0:
		var swap_index: int = rng.randi_range(0, index)
		var temp: Variant = values[index]
		values[index] = values[swap_index]
		values[swap_index] = temp
		index -= 1

func _remove_cards_from_zone_by_ids(zone: Array[Variant], page_ids: PackedStringArray) -> int:
	var removed: int = 0
	var index: int = zone.size() - 1
	while index >= 0:
		var card: Variant = zone[index]
		if _card_matches_any_page_id(card, page_ids):
			var removed_card: Variant = zone[index]
			zone.remove_at(index)
			removed_from_run.append(removed_card)
			removed += 1
		index -= 1
	return removed

func _card_matches_any_page_id(card: Variant, page_ids: PackedStringArray) -> bool:
	if card == null:
		return false
	var card_page_id: String = String(card.page_id)
	return page_ids.has(card_page_id)

func _is_binding_slot_valid(slot_index: int) -> bool:
	return slot_index >= 0 and slot_index < binding_slots.size()
