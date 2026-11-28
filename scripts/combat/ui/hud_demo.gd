extends Control
## Demo harness for the T13 HUD (manual check and QA screenshots). Instances
## T11's combat screen, builds a fight from data/ (pages, run rules, enemies
## through the T3 loader and the T8 EncounterSpawner), places bindings, starts
## it with CombatCore, then adds the CombatHudController and T12's
## CardInteractionController. Not part of the run flow: T16 wires the real
## combat entry the same way.
##
## enemy_entries lists "enemy_id:start_offset" per enemy slot (composition
## order). bound_page_ids fills the bind slots before combat starts (and takes
## one copy of each page out of the draw pile, as a real bind would).
## preview_state puts the screen into one state on load: "", "frayed",
## "severed", "after_enemy_turn", "inspect_telegraph", "inspect_slot",
## "inspect_stats".

const COMBAT_SCENE: PackedScene = preload("res://scenes/combat/combat.tscn")
const CARD_INTERACTION_SCENE: PackedScene = preload("res://scenes/card/card_interaction.tscn")
const DATA_LOADER_SCRIPT := preload("res://scripts/data/data_loader.gd")
const ENCOUNTER_LOADER_SCRIPT := preload("res://scripts/combat/enemies/encounter_loader.gd")
const ENCOUNTER_DATA_SCRIPT := preload("res://scripts/combat/enemies/encounter_data.gd")
const ENCOUNTER_SPAWNER_SCRIPT := preload("res://scripts/combat/enemies/encounter_spawner.gd")
const COMBAT_CORE_SCRIPT := preload("res://scripts/combat/core/combat_core.gd")
const COMBAT_CARD_SCRIPT := preload("res://scripts/combat/core/combat_card.gd")
const BINDING_SYSTEM_SCRIPT := preload("res://scripts/combat/binding/binding_system.gd")

const STAIN_PAGE_ID: String = "water_stain"

@export var preview_state: String = ""
@export var enemy_entries: PackedStringArray = PackedStringArray(["bookmoth:0", "blotter:0"])
@export var bound_page_ids: PackedStringArray = PackedStringArray(["pressed_thorn", "tally_mark"])
@export var combat_seed: int = 1

var _combat: Control = null
var _hud: CombatHudController = null
var _controller: CardInteractionController = null
var _core: Variant = null
var _binding_system: Variant = null
var _state: Variant = null
var _page_library: Dictionary = {}

func _ready() -> void:
  _combat = COMBAT_SCENE.instantiate() as Control
  add_child(_combat)
  _hud = CombatHudController.new()
  _combat.add_child(_hud)
  _controller = CARD_INTERACTION_SCENE.instantiate() as CardInteractionController
  _combat.add_child(_controller)

  var catalog: Variant = DATA_LOADER_SCRIPT.load_all()
  for error: String in catalog.errors:
    push_error(error)
  if catalog.has_errors() or catalog.pages.is_empty() or catalog.enemies.is_empty():
    push_error("HUD demo: data/ could not be loaded.")
    return
  for page: Variant in catalog.pages:
    _page_library[String(page.id)] = page
  var deck_pages: Array = []
  for page_id: String in catalog.run_rules.starting_deck:
    if _page_library.has(page_id):
      deck_pages.append(_page_library[page_id])
  var enemies_by_id: Dictionary = ENCOUNTER_LOADER_SCRIPT.enemies_by_id_from_list(catalog.enemies)

  _core = COMBAT_CORE_SCRIPT.new()
  _binding_system = BINDING_SYSTEM_SCRIPT.new()
  _state = ENCOUNTER_SPAWNER_SCRIPT.create_state(
    _build_encounter(),
    enemies_by_id,
    catalog.run_rules,
    deck_pages,
    _page_library,
    PackedStringArray([STAIN_PAGE_ID]),
    combat_seed
  )
  _place_bindings()
  _core.start_combat(_state)
  for error: String in _state.errors:
    push_error("HUD demo: %s" % error)

  _hud.setup(_state, _core, _page_library)
  _controller.setup(_state, _core, _binding_system, _page_library)
  _hud.turn_ended.connect(_controller.refresh)
  _controller.state_changed.connect(_hud.refresh)

  if preview_state != "":
    await get_tree().process_frame
    _apply_preview_state()

func hud() -> CombatHudController:
  return _hud

func card_controller() -> CardInteractionController:
  return _controller

func state() -> Variant:
  return _state

func _build_encounter() -> Variant:
  var encounter: Variant = ENCOUNTER_DATA_SCRIPT.new()
  encounter.id = "hud_demo"
  encounter.node = "fight"
  encounter.pool = "mixed"
  encounter.weight = 1
  for entry: String in enemy_entries:
    var parts: PackedStringArray = entry.split(":", false, 1)
    if parts.is_empty():
      continue
    var start_offset: int = int(parts[1]) if parts.size() > 1 and parts[1].is_valid_int() else 0
    encounter.enemies.append({"id": parts[0].strip_edges(), "start_offset": start_offset})
  return encounter

func _place_bindings() -> void:
  for index: int in range(mini(bound_page_ids.size(), _state.binding_slots.size())):
    var page_id: String = bound_page_ids[index]
    if not _page_library.has(page_id):
      push_warning("HUD demo: unknown page id '%s' for slot %d." % [page_id, index + 1])
      continue
    var card: Variant = _take_from_draw_pile(page_id)
    if card == null:
      card = COMBAT_CARD_SCRIPT.from_page_data(_page_library[page_id])
    _state.set_binding(index, card)

func _take_from_draw_pile(page_id: String) -> Variant:
  for index: int in range(_state.draw_pile.size()):
    var card: Variant = _state.draw_pile[index]
    if String(card.page_id) == page_id:
      _state.draw_pile.remove_at(index)
      return card
  return null

func _apply_preview_state() -> void:
  match preview_state:
    "frayed":
      _state.fray_binding(0)
      _hud.refresh()
    "severed":
      _state.sever_binding(0)
      _hud.refresh()
      _controller.refresh()
    "after_enemy_turn":
      _hud.end_turn()
    "inspect_telegraph":
      _hud.preview_inspect_telegraph(0)
    "inspect_slot":
      _hud.preview_inspect_slot(0)
    "inspect_stats":
      _hud.preview_inspect_stats()
    _:
      push_warning("HUD demo: unknown preview_state '%s'." % preview_state)
