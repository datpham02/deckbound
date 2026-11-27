class_name CombatCard
extends RefCounted

static var _next_uid: int = 1

var uid: int = 0
var page_id: String = ""
var cost: int = 0
var target: String = "none"
var play_effects: Array[Dictionary] = []
var bind_passives: Array[Dictionary] = []

static func from_page_data(page_data: Variant) -> Variant:
	var card: Variant = new()
	card.uid = _next_uid
	_next_uid += 1

	if page_data == null:
		return card

	card.page_id = String(page_data.id)
	card.cost = int(page_data.cost)
	card.target = String(page_data.target)

	for effect_variant: Variant in page_data.play_effects:
		if typeof(effect_variant) == TYPE_DICTIONARY:
			var effect_data: Dictionary = effect_variant
			card.play_effects.append(effect_data.duplicate(true))

	for passive_variant: Variant in page_data.bind_passives:
		if typeof(passive_variant) == TYPE_DICTIONARY:
			var passive_data: Dictionary = passive_variant
			card.bind_passives.append(passive_data.duplicate(true))

	return card

static func create_placeholder(page_id_value: String) -> Variant:
	var card: Variant = new()
	card.uid = _next_uid
	_next_uid += 1
	card.page_id = page_id_value
	card.cost = 0
	card.target = "none"
	return card
