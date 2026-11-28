class_name EncounterCatalog
extends RefCounted

# All compositions loaded from data/encounters/ plus pool lookups (M1 T8).
# Pool draws are weighted and take the caller's seeded RandomNumberGenerator so
# a resumed run reproduces the same picks (docs/design/enemies.md §5.2).

var encounters: Array = []
var errors: Array[String] = []

func has_errors() -> bool:
	return not errors.is_empty()

func get_by_id(encounter_id: String) -> Variant:
	for encounter_variant: Variant in encounters:
		if String(encounter_variant.id) == encounter_id:
			return encounter_variant
	return null

func get_pool(pool: String) -> Array:
	var members: Array = []
	for encounter_variant: Variant in encounters:
		if String(encounter_variant.pool) == pool:
			members.append(encounter_variant)
	return members

func pool_names() -> Array[String]:
	var names: Array[String] = []
	for encounter_variant: Variant in encounters:
		var pool: String = String(encounter_variant.pool)
		if not names.has(pool):
			names.append(pool)
	names.sort()
	return names

# Weighted draw from a pool. `exclude_id` is left out when the pool offers
# another composition (enemies note §5.2 rule 4); when it is the only member it
# is returned anyway. Returns null for an empty pool.
func pick_from_pool(pool: String, rng: RandomNumberGenerator, exclude_id: String = "") -> Variant:
	var candidates: Array = get_pool(pool)
	if candidates.is_empty():
		return null

	if exclude_id != "" and candidates.size() > 1:
		var filtered: Array = []
		for encounter_variant: Variant in candidates:
			if String(encounter_variant.id) != exclude_id:
				filtered.append(encounter_variant)
		if not filtered.is_empty():
			candidates = filtered

	var total_weight: int = 0
	for encounter_variant: Variant in candidates:
		total_weight += maxi(0, int(encounter_variant.weight))
	if total_weight <= 0:
		return candidates[0]

	var roll: int = rng.randi_range(1, total_weight)
	var accumulated: int = 0
	for encounter_variant: Variant in candidates:
		accumulated += maxi(0, int(encounter_variant.weight))
		if roll <= accumulated:
			return encounter_variant
	return candidates[candidates.size() - 1]
