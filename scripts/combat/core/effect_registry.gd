class_name CombatEffectRegistry
extends RefCounted

const STAIN_PAGE_IDS: PackedStringArray = ["water_stain", "blot"]

var _handlers: Dictionary = {}

func _init() -> void:
	_handlers = {
		"damage": Callable(self, "_effect_damage"),
		"damage_all": Callable(self, "_effect_damage_all"),
		"guard": Callable(self, "_effect_guard"),
		"draw": Callable(self, "_effect_draw"),
		"ink": Callable(self, "_effect_ink"),
		"heal": Callable(self, "_effect_heal"),
		"lose_health": Callable(self, "_effect_lose_health"),
		"add_page_to_discard": Callable(self, "_effect_add_page_to_discard"),
		"remove_this_page": Callable(self, "_effect_remove_this_page"),
		"remove_stains_hand_and_discard": Callable(self, "_effect_remove_stains_hand_and_discard"),
		"remove_stain_from_hand": Callable(self, "_effect_remove_stain_from_hand"),
		"remove_enemy_guard": Callable(self, "_effect_remove_enemy_guard"),
		"damage_per_empty_slot": Callable(self, "_effect_damage_per_empty_slot"),
		"damage_per_discard_page": Callable(self, "_effect_damage_per_discard_page"),
		"guard_per_binding": Callable(self, "_effect_guard_per_binding")
	}

func effect_ids() -> PackedStringArray:
	var ids: PackedStringArray = PackedStringArray()
	for key_variant: Variant in _handlers.keys():
		ids.append(String(key_variant))
	ids.sort()
	return ids

func has_effect(effect_id: String) -> bool:
	return _handlers.has(effect_id)

func apply(effect_id: String, params: Dictionary, state: Variant, source_card: Variant, target_enemy_index: int) -> void:
	if not _handlers.has(effect_id):
		state.push_error("Unknown play effect id '%s'." % effect_id)
		return

	var handler: Callable = _handlers[effect_id]
	handler.call(params, state, source_card, target_enemy_index)

func _effect_damage(params: Dictionary, state: Variant, _source_card: Variant, target_enemy_index: int) -> void:
	var amount: int = _read_int(params, "amount", 0)
	var enemy_index: int = _resolve_enemy_target_index(state, target_enemy_index)
	if enemy_index < 0:
		return
	state.apply_damage_to_enemy(enemy_index, amount)

func _effect_damage_all(params: Dictionary, state: Variant, _source_card: Variant, _target_enemy_index: int) -> void:
	var amount: int = _read_int(params, "amount", 0)
	for enemy_index in range(state.enemies.size()):
		if state.is_enemy_alive(enemy_index):
			state.apply_damage_to_enemy(enemy_index, amount)

func _effect_guard(params: Dictionary, state: Variant, _source_card: Variant, _target_enemy_index: int) -> void:
	state.gain_player_guard(_read_int(params, "amount", 0))

func _effect_draw(params: Dictionary, state: Variant, _source_card: Variant, _target_enemy_index: int) -> void:
	state.draw_cards(_read_int(params, "count", 0))

func _effect_ink(params: Dictionary, state: Variant, _source_card: Variant, _target_enemy_index: int) -> void:
	state.gain_player_ink(_read_int(params, "amount", 0))

func _effect_heal(params: Dictionary, state: Variant, _source_card: Variant, _target_enemy_index: int) -> void:
	state.heal_player(_read_int(params, "amount", 0))

func _effect_lose_health(params: Dictionary, state: Variant, _source_card: Variant, _target_enemy_index: int) -> void:
	state.lose_player_health(_read_int(params, "amount", 0))

func _effect_add_page_to_discard(params: Dictionary, state: Variant, _source_card: Variant, _target_enemy_index: int) -> void:
	var page_id: String = String(params.get("page_id", ""))
	if page_id == "":
		page_id = "water_stain"
	state.add_page_to_discard_by_id(page_id)

func _effect_remove_this_page(_params: Dictionary, state: Variant, _source_card: Variant, _target_enemy_index: int) -> void:
	state.mark_source_card_removed()

func _effect_remove_stains_hand_and_discard(_params: Dictionary, state: Variant, _source_card: Variant, _target_enemy_index: int) -> void:
	state.remove_stains_from_hand_and_discard(STAIN_PAGE_IDS)

func _effect_remove_stain_from_hand(params: Dictionary, state: Variant, _source_card: Variant, _target_enemy_index: int) -> void:
	var count: int = _read_int(params, "count", 1)
	if params.has("amount"):
		count = _read_int(params, "amount", count)
	state.remove_stains_from_hand(count, STAIN_PAGE_IDS)

func _effect_remove_enemy_guard(_params: Dictionary, state: Variant, _source_card: Variant, target_enemy_index: int) -> void:
	var enemy_index: int = _resolve_enemy_target_index(state, target_enemy_index)
	if enemy_index < 0:
		return
	state.clear_enemy_guard(enemy_index)

func _effect_damage_per_empty_slot(params: Dictionary, state: Variant, _source_card: Variant, target_enemy_index: int) -> void:
	var enemy_index: int = _resolve_enemy_target_index(state, target_enemy_index)
	if enemy_index < 0:
		return
	var per_value: int = _read_int(params, "per", _read_int(params, "amount", 0))
	var total_damage: int = per_value * state.count_empty_binding_slots()
	state.apply_damage_to_enemy(enemy_index, total_damage)

func _effect_damage_per_discard_page(params: Dictionary, state: Variant, _source_card: Variant, target_enemy_index: int) -> void:
	var enemy_index: int = _resolve_enemy_target_index(state, target_enemy_index)
	if enemy_index < 0:
		return
	var per_value: int = _read_int(params, "per", _read_int(params, "amount", 0))
	var total_damage: int = per_value * state.discard_pile.size()
	state.apply_damage_to_enemy(enemy_index, total_damage)

func _effect_guard_per_binding(params: Dictionary, state: Variant, _source_card: Variant, _target_enemy_index: int) -> void:
	var per_value: int = _read_int(params, "per", _read_int(params, "amount", 0))
	var total_guard: int = per_value * state.count_occupied_bindings()
	state.gain_player_guard(total_guard)

func _read_int(data: Dictionary, key: String, fallback: int) -> int:
	if not data.has(key):
		return fallback
	return int(data[key])

func _resolve_enemy_target_index(state: Variant, preferred_index: int) -> int:
	if state.is_enemy_alive(preferred_index):
		return preferred_index
	return state.first_living_enemy_index()
