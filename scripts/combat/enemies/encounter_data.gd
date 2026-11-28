class_name EncounterData
extends RefCounted

# One fight composition loaded from data/encounters/<id>.json (M1 T8).
# Entries in `enemies` are {"id": String, "start_offset": int}; array order is
# screen order left to right and action order (docs/design/enemies.md §3.1).

var id: String = ""
var node: String = ""
var pool: String = ""
var weight: int = 0
var enemies: Array[Dictionary] = []

func enemy_count() -> int:
	return enemies.size()

func enemy_id_at(position: int) -> String:
	if position < 0 or position >= enemies.size():
		return ""
	return String(enemies[position].get("id", ""))

func start_offset_at(position: int) -> int:
	if position < 0 or position >= enemies.size():
		return 0
	return maxi(0, int(enemies[position].get("start_offset", 0)))

func enemy_ids() -> Array[String]:
	var ids: Array[String] = []
	for entry: Dictionary in enemies:
		ids.append(String(entry.get("id", "")))
	return ids
