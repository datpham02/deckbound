class_name EncounterSpawner
extends RefCounted

# Turns an EncounterData into a combat state (M1 T8 "composition loading").
#
# Flow for a fight:
#   var state := EncounterSpawner.create_state(encounter, enemies_by_id, rules, deck_pages, page_library, stain_page_ids, seed)
#   <caller places the run's current bindings>
#   core.start_combat(state)
#
# create_state places the enemies in composition order, starts each one on its
# `start_offset` pattern step (enemies note §3.5) and resolves the page a foul
# action adds: an action may name `page_id` itself; otherwise the run's first
# stain page id is used (the foul page from data/pages/, passed by the caller).

const COMBAT_CORE_SCRIPT := preload("res://scripts/combat/core/combat_core.gd")

static func build_enemy_data_list(encounter: Variant, enemies_by_id: Dictionary, errors: Array[String]) -> Array:
	var enemy_data_list: Array = []
	if encounter == null:
		errors.append("Cannot build enemies for a null encounter.")
		return enemy_data_list
	for position: int in range(encounter.enemy_count()):
		var enemy_id: String = encounter.enemy_id_at(position)
		if not enemies_by_id.has(enemy_id):
			errors.append("Encounter '%s' references unknown enemy id '%s' at position %d." % [String(encounter.id), enemy_id, position])
			continue
		enemy_data_list.append(enemies_by_id[enemy_id])
	return enemy_data_list

static func create_state(
	encounter: Variant,
	enemies_by_id: Dictionary,
	run_rules_data: Variant,
	deck_pages: Array,
	page_library: Dictionary = {},
	stain_page_ids: PackedStringArray = PackedStringArray(),
	seed: int = 1
) -> Variant:
	var build_errors: Array[String] = []
	var enemy_data_list: Array = build_enemy_data_list(encounter, enemies_by_id, build_errors)
	var state: Variant = COMBAT_CORE_SCRIPT.create_state(run_rules_data, deck_pages, enemy_data_list, page_library, stain_page_ids, seed)
	for build_error: String in build_errors:
		state.push_error(build_error)
	if build_errors.is_empty():
		apply_encounter(state, encounter)
	else:
		resolve_foul_page_ids(state)
	return state

# Applies start offsets and foul page ids to a state whose enemies were created
# from `encounter` in order. Call before start_combat (the initial telegraph
# reads the pattern step) and before restoring a snapshot.
static func apply_encounter(state: Variant, encounter: Variant) -> void:
	if encounter != null:
		for position: int in range(mini(state.enemies.size(), encounter.enemy_count())):
			var enemy: Variant = state.enemies[position]
			var pattern_length: int = enemy.telegraph_pattern.size()
			if pattern_length == 0:
				continue
			var start_offset: int = encounter.start_offset_at(position)
			if start_offset >= pattern_length:
				state.push_error("Encounter '%s' start_offset %d is out of range for enemy '%s' (pattern length %d)." % [String(encounter.id), start_offset, String(enemy.id), pattern_length])
				start_offset = start_offset % pattern_length
			enemy.pattern_index = start_offset
	resolve_foul_page_ids(state)

static func default_foul_page_id(state: Variant) -> String:
	if state.stain_page_ids.is_empty():
		return ""
	return String(state.stain_page_ids[0])

static func resolve_foul_page_ids(state: Variant) -> void:
	var foul_page_id: String = default_foul_page_id(state)
	for enemy_variant: Variant in state.enemies:
		var enemy: Variant = enemy_variant
		for action_id_variant: Variant in enemy.actions_by_id.keys():
			var action_data: Dictionary = enemy.actions_by_id[action_id_variant]
			if String(action_data.get("type", "")) != "foul":
				continue
			if String(action_data.get("page_id", "")) != "":
				continue
			if foul_page_id == "":
				state.push_error("Enemy '%s' foul action '%s' has no page_id and the run has no stain page id to use." % [String(enemy.id), String(action_id_variant)])
				continue
			action_data["page_id"] = foul_page_id
