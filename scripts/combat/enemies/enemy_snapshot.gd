class_name EnemySnapshot
extends RefCounted

# Per-enemy resume state (docs/design/enemies.md §6): T8 exposes it, T17 saves
# it. Snapshots are plain Dictionaries of ints, bools and Strings so they
# survive a JSON round trip; restore_enemies casts every field back.
#
# Restore expects a state whose enemies were created from the same composition
# (same ids in the same order), normally through EncounterSpawner.create_state
# so foul page ids are already resolved.

const TELEGRAPH_INT_KEYS: PackedStringArray = ["value", "hits", "target_slot"]

static func capture_enemies(state: Variant) -> Array[Dictionary]:
	var snapshots: Array[Dictionary] = []
	for position: int in range(state.enemies.size()):
		snapshots.append(capture_enemy(state.enemies[position], position))
	return snapshots

static func capture_enemy(enemy: Variant, position: int) -> Dictionary:
	return {
		"id": String(enemy.id),
		"position": position,
		"health": int(enemy.health),
		"guard": int(enemy.guard),
		"phase": phase_number(enemy),
		"phase_threshold": int(enemy.active_phase_threshold),
		"pattern_index": int(enemy.pattern_index),
		"telegraph": _normalise_telegraph(enemy.telegraph)
	}

static func restore_enemies(state: Variant, snapshots: Array) -> bool:
	if snapshots.size() != state.enemies.size():
		state.push_error("Cannot restore %d enemy snapshots onto %d enemies." % [snapshots.size(), state.enemies.size()])
		return false

	for position: int in range(snapshots.size()):
		var snapshot_variant: Variant = snapshots[position]
		if typeof(snapshot_variant) != TYPE_DICTIONARY:
			state.push_error("Enemy snapshot at position %d is not a Dictionary." % position)
			return false
		var snapshot: Dictionary = snapshot_variant
		var enemy: Variant = state.enemies[position]
		var snapshot_id: String = String(snapshot.get("id", ""))
		if snapshot_id != String(enemy.id):
			state.push_error("Enemy snapshot at position %d is for '%s' but the composition has '%s'." % [position, snapshot_id, String(enemy.id)])
			return false

	for position: int in range(snapshots.size()):
		restore_enemy(state.enemies[position], snapshots[position], state)

	state.update_result()
	return true

static func restore_enemy(enemy: Variant, snapshot: Dictionary, state: Variant) -> void:
	enemy.health = clampi(int(snapshot.get("health", enemy.health)), 0, int(enemy.max_health))
	enemy.guard = maxi(0, int(snapshot.get("guard", 0)))

	var phase_threshold: int = int(snapshot.get("phase_threshold", -1))
	enemy.active_phase_threshold = -1
	enemy.telegraph_pattern = enemy.base_telegraph_pattern.duplicate()
	if phase_threshold != -1:
		var phase_pattern: Variant = _phase_pattern_for_threshold(enemy, phase_threshold)
		if phase_pattern == null:
			state.push_error("Enemy '%s' has no phase with health_at_or_below %d." % [String(enemy.id), phase_threshold])
		else:
			enemy.active_phase_threshold = phase_threshold
			enemy.telegraph_pattern = phase_pattern

	var pattern_length: int = enemy.telegraph_pattern.size()
	var pattern_index: int = int(snapshot.get("pattern_index", 0))
	if pattern_length > 0 and (pattern_index < 0 or pattern_index >= pattern_length):
		state.push_error("Enemy '%s' snapshot pattern_index %d is out of range (pattern length %d)." % [String(enemy.id), pattern_index, pattern_length])
		pattern_index = posmod(pattern_index, pattern_length)
	enemy.pattern_index = maxi(0, pattern_index)

	var telegraph_variant: Variant = snapshot.get("telegraph", {})
	if typeof(telegraph_variant) == TYPE_DICTIONARY and enemy.is_alive():
		enemy.telegraph = _normalise_telegraph(telegraph_variant)
	else:
		enemy.telegraph = {}

# 1 for the base pattern; 2, 3, ... for phases ordered from highest threshold
# down (the Redactor's half-health pattern is phase 2).
static func phase_number(enemy: Variant) -> int:
	var threshold: int = int(enemy.active_phase_threshold)
	if threshold == -1:
		return 1
	var thresholds: Array[int] = []
	for phase_variant: Variant in enemy.phases:
		if typeof(phase_variant) != TYPE_DICTIONARY:
			continue
		var phase_data: Dictionary = phase_variant
		var phase_threshold: int = int(phase_data.get("health_at_or_below", 0))
		if phase_threshold > 0 and not thresholds.has(phase_threshold):
			thresholds.append(phase_threshold)
	thresholds.sort()
	thresholds.reverse()
	var index: int = thresholds.find(threshold)
	if index == -1:
		return 1
	return index + 2

static func _phase_pattern_for_threshold(enemy: Variant, threshold: int) -> Variant:
	for phase_variant: Variant in enemy.phases:
		if typeof(phase_variant) != TYPE_DICTIONARY:
			continue
		var phase_data: Dictionary = phase_variant
		if int(phase_data.get("health_at_or_below", 0)) != threshold:
			continue
		var pattern: Array[String] = []
		var pattern_variant: Variant = phase_data.get("telegraph_pattern", [])
		if typeof(pattern_variant) == TYPE_ARRAY:
			for step_variant: Variant in pattern_variant:
				pattern.append(String(step_variant))
		return pattern
	return null

static func _normalise_telegraph(telegraph: Dictionary) -> Dictionary:
	if telegraph.is_empty():
		return {}
	var normalised: Dictionary = {
		"action_id": String(telegraph.get("action_id", "")),
		"type": String(telegraph.get("type", "")),
		"value": int(telegraph.get("value", 0)),
		"hits": maxi(1, int(telegraph.get("hits", 1))),
		"fallback_used": bool(telegraph.get("fallback_used", false)),
		"target_slot": int(telegraph.get("target_slot", -1))
	}
	if telegraph.has("page_id"):
		normalised["page_id"] = String(telegraph["page_id"])
	return normalised
