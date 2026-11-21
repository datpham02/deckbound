class_name CombatEnemy
extends RefCounted

var id: String = ""
var name: String = ""
var size_class: String = ""
var max_health: int = 0
var health: int = 0
var guard: int = 0
var actions_by_id: Dictionary = {}
var base_telegraph_pattern: Array[String] = []
var telegraph_pattern: Array[String] = []
var phases: Array[Dictionary] = []
var pattern_index: int = 0
var telegraph: Dictionary = {}

static func from_enemy_data(enemy_data: Variant) -> Variant:
	var enemy: Variant = new()
	enemy.id = String(enemy_data.id)
	enemy.name = String(enemy_data.name)
	enemy.size_class = String(enemy_data.size_class)
	enemy.max_health = int(enemy_data.health)
	enemy.health = int(enemy_data.health)

	for action_variant: Variant in enemy_data.actions:
		if typeof(action_variant) != TYPE_DICTIONARY:
			continue
		var action_data: Dictionary = action_variant
		var action_id: String = String(action_data.get("id", ""))
		if action_id == "":
			continue
		enemy.actions_by_id[action_id] = action_data.duplicate(true)

	enemy.base_telegraph_pattern = enemy_data.telegraph_pattern.duplicate()
	enemy.telegraph_pattern = enemy_data.telegraph_pattern.duplicate()

	for phase_variant: Variant in enemy_data.phases:
		if typeof(phase_variant) == TYPE_DICTIONARY:
			var phase_data: Dictionary = phase_variant
			enemy.phases.append(phase_data.duplicate(true))

	return enemy

func is_alive() -> bool:
	return health > 0

func set_initial_telegraph(state: Variant) -> void:
	if not is_alive():
		telegraph.clear()
		return
	_refresh_pattern_for_health()
	_set_telegraph_for_current_step(state)

func advance_telegraph(state: Variant) -> void:
	if not is_alive():
		telegraph.clear()
		return

	_refresh_pattern_for_health()
	if telegraph_pattern.is_empty():
		telegraph.clear()
		return

	pattern_index = (pattern_index + 1) % telegraph_pattern.size()
	_set_telegraph_for_current_step(state)

func act_from_telegraph(state: Variant) -> void:
	if not is_alive():
		return
	if telegraph.is_empty():
		return

	var action_type: String = String(telegraph.get("type", ""))
	var action_value: int = maxi(0, int(telegraph.get("value", 0)))
	match action_type:
		"attack":
			var hits: int = maxi(1, int(telegraph.get("hits", 1)))
			for _hit in range(hits):
				state.apply_attack_to_player(action_value)
				if state.is_player_dead():
					break
		"guard":
			guard += action_value
		"fray":
			_resolve_binding_action(state, action_value, false)
		"foul":
			_resolve_foul_action(state, action_value)
		"sever":
			_resolve_binding_action(state, action_value, true)
		_:
			state.push_error("Unknown enemy action type '%s' on enemy '%s'." % [action_type, id])

	state.update_result()

func _resolve_binding_action(state: Variant, value: int, sever: bool) -> void:
	var target_slot: int = int(telegraph.get("target_slot", -1))
	if target_slot >= 0 and state.binding_slot_has_card(target_slot):
		if state.player_guard < value:
			if sever:
				state.sever_binding(target_slot)
			else:
				state.fray_binding(target_slot)

	state.player_guard = maxi(0, state.player_guard - value)

func _resolve_foul_action(state: Variant, value: int) -> void:
	var page_id: String = String(telegraph.get("page_id", "water_stain"))
	for _index in range(value):
		state.add_page_to_discard_by_id(page_id)

func _refresh_pattern_for_health() -> void:
	if phases.is_empty():
		return

	var selected_pattern: Array[String] = base_telegraph_pattern.duplicate()
	var selected_threshold: int = 2147483647
	for phase_variant: Variant in phases:
		if typeof(phase_variant) != TYPE_DICTIONARY:
			continue

		var phase_data: Dictionary = phase_variant
		var threshold: int = int(phase_data.get("health_at_or_below", 0))
		if threshold <= 0:
			continue
		if health > threshold:
			continue
		if threshold >= selected_threshold:
			continue

		selected_threshold = threshold
		selected_pattern = _to_string_array(phase_data.get("telegraph_pattern", []))

	if telegraph_pattern != selected_pattern:
		telegraph_pattern = selected_pattern
		pattern_index = 0

func _set_telegraph_for_current_step(state: Variant) -> void:
	if telegraph_pattern.is_empty():
		telegraph.clear()
		return

	var action_id: String = telegraph_pattern[pattern_index]
	if not actions_by_id.has(action_id):
		telegraph.clear()
		state.push_error("Enemy '%s' telegraph references unknown action id '%s'." % [id, action_id])
		return

	var action_data: Dictionary = actions_by_id[action_id]
	telegraph = _build_telegraph(action_id, action_data, state)

func _build_telegraph(action_id: String, action_data: Dictionary, state: Variant) -> Dictionary:
	var action_type: String = String(action_data.get("type", ""))
	var telegraph_data: Dictionary = {
		"action_id": action_id,
		"type": action_type,
		"value": maxi(0, int(action_data.get("value", 0))),
		"hits": maxi(1, int(action_data.get("hits", 1))),
		"fallback_used": false,
		"target_slot": -1
	}
	if action_data.has("page_id"):
		telegraph_data["page_id"] = String(action_data["page_id"])

	if action_type != "fray" and action_type != "sever":
		return telegraph_data

	var candidate_slots: Array[int] = []
	if action_type == "fray":
		candidate_slots = state.get_intact_binding_slots()
	else:
		candidate_slots = state.get_occupied_binding_slots()

	if candidate_slots.is_empty():
		if action_data.has("fallback") and typeof(action_data["fallback"]) == TYPE_DICTIONARY:
			var fallback_data: Dictionary = action_data["fallback"]
			telegraph_data["type"] = String(fallback_data.get("type", "attack"))
			telegraph_data["value"] = maxi(0, int(fallback_data.get("value", 0)))
			telegraph_data["hits"] = maxi(1, int(fallback_data.get("hits", 1)))
			telegraph_data["fallback_used"] = true
		return telegraph_data

	telegraph_data["target_slot"] = state.pick_binding_slot(candidate_slots)
	return telegraph_data

func _to_string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if typeof(value) != TYPE_ARRAY:
		return result
	var value_array: Array = value
	for entry_variant: Variant in value_array:
		result.append(String(entry_variant))
	return result
