extends Control
## Demo harness for the card interaction (T12 manual check and QA screenshots).
## Instances T11's combat screen, builds a combat from data/ (pages and run
## rules through DataLoader), starts it with CombatCore and adds the
## CardInteractionController. Not part of the run flow: T16 wires the real
## combat entry. The small HUD refresh here stands in for T13.
##
## preview_state puts the screen into one interaction state on load so the QA
## screenshot tool can capture it: "", "spread", "drag_play", "drag_bind",
## "bind_pending", "inspect", "no_ink".

const COMBAT_SCENE: PackedScene = preload("res://scenes/combat/combat.tscn")
const CARD_INTERACTION_SCENE: PackedScene = preload("res://scenes/card/card_interaction.tscn")
const DATA_LOADER_SCRIPT := preload("res://scripts/data/data_loader.gd")
const ENEMY_DATA_SCRIPT := preload("res://scripts/data/enemy_data.gd")
const COMBAT_CORE_SCRIPT := preload("res://scripts/combat/core/combat_core.gd")
const BINDING_SYSTEM_SCRIPT := preload("res://scripts/combat/binding/binding_system.gd")

const PAGES_DIR: String = "res://data/pages"
const ENEMIES_DIR: String = "res://data/enemies"
const RULES_FILE: String = "res://data/run/rules.json"
const STAIN_PAGE_ID: String = "water_stain"
const DEMO_ENEMY_COUNT: int = 2

@export var preview_state: String = ""
@export var combat_seed: int = 1

var _combat: Control = null
var _controller: CardInteractionController = null
var _core: Variant = null
var _binding_system: Variant = null
var _state: Variant = null
var _rules: Variant = null
var _page_library: Dictionary = {}

func _ready() -> void:
  _combat = COMBAT_SCENE.instantiate() as Control
  add_child(_combat)
  _controller = CARD_INTERACTION_SCENE.instantiate() as CardInteractionController
  _combat.add_child(_controller)
  _controller.state_changed.connect(_refresh_hud)

  var errors: Array[String] = []
  var pages: Array = DATA_LOADER_SCRIPT.load_pages(PAGES_DIR, errors)
  _rules = DATA_LOADER_SCRIPT.load_run_rules_file(RULES_FILE, errors)
  var enemies: Array = _load_enemies(errors)
  for error: String in errors:
    push_error(error)
  if _rules == null or pages.is_empty():
    push_error("Card interaction demo: data/ could not be loaded.")
    return

  for page: Variant in pages:
    _page_library[String(page.id)] = page
  var deck_pages: Array = []
  for page_id: String in _rules.starting_deck:
    if _page_library.has(page_id):
      deck_pages.append(_page_library[page_id])

  _core = COMBAT_CORE_SCRIPT.new()
  _binding_system = BINDING_SYSTEM_SCRIPT.new()
  _state = COMBAT_CORE_SCRIPT.create_state(_rules, deck_pages, enemies, _page_library, PackedStringArray([STAIN_PAGE_ID]), combat_seed)
  _core.start_combat(_state)

  var end_turn: Button = _combat.get_node_or_null("SafeArea/Content/EndTurn") as Button
  if end_turn != null:
    end_turn.pressed.connect(_on_end_turn_pressed)

  _controller.setup(_state, _core, _binding_system, _page_library)
  if preview_state != "":
    await get_tree().process_frame
    _apply_preview_state()

func _load_enemies(errors: Array[String]) -> Array:
  if DirAccess.dir_exists_absolute(ENEMIES_DIR):
    var enemies: Array = DATA_LOADER_SCRIPT.load_enemies(ENEMIES_DIR, errors)
    if not enemies.is_empty():
      return enemies.slice(0, DEMO_ENEMY_COUNT)
  # data/enemies/ lands with T5b. Until then the demo stands two training
  # targets in the T11 enemy slots; they use the hero's starting health from
  # rules.json and never act, so no enemy number is invented here.
  var stand_ins: Array = []
  for index: int in range(DEMO_ENEMY_COUNT):
    var enemy: Variant = ENEMY_DATA_SCRIPT.new()
    enemy.id = "stand_in_%d" % (index + 1)
    enemy.name = "Stand-in %d" % (index + 1)
    enemy.size_class = "common"
    enemy.health = int(_rules.hero_health) if _rules != null else 1
    var actions: Array[Dictionary] = [{"id": "wait", "type": "guard", "value": 0}]
    enemy.actions = actions
    var pattern: Array[String] = ["wait"]
    enemy.telegraph_pattern = pattern
    var phases: Array[Dictionary] = []
    enemy.phases = phases
    stand_ins.append(enemy)
  return stand_ins

func _on_end_turn_pressed() -> void:
  if _state == null:
    return
  _core.end_player_turn(_state)
  _controller.refresh()

func _refresh_hud() -> void:
  if _state == null:
    return
  _set_label("SafeArea/Content/HandBand/InkAndDeck/Ink/Rows/Value", "%d/%d" % [int(_state.player_ink), int(_rules.ink_per_turn)])
  _set_label("SafeArea/Content/HandBand/InkAndDeck/Deck", "Deck\n%d" % _state.draw_pile.size())
  _set_label("SafeArea/Content/HandBand/Discard", "Discard\n%d" % _state.discard_pile.size())
  var status: String = "HP %d/%d   Guard %d" % [int(_state.player_health), int(_state.player_max_health), int(_state.player_guard)]
  if _state.is_combat_over():
    status += "\n%s" % String(_state.result).to_upper()
  _set_label("SafeArea/Content/Scrivener/Stats", status)
  for index: int in range(_state.enemies.size()):
    var enemy: Variant = _state.enemies[index]
    var base: String = "SafeArea/Content/Enemies/Enemy%d" % (index + 1)
    var telegraph_type: String = String(enemy.telegraph.get("type", ""))
    var telegraph_text: String = enemy.name if telegraph_type == "" else "%s %d" % [telegraph_type.capitalize(), int(enemy.telegraph.get("value", 0))]
    _set_label("%s/Rows/Telegraph" % base, telegraph_text)
    _set_label("%s/Rows/Health" % base, "HP %d" % int(enemy.health) if enemy.is_alive() else "down")
  for index: int in range(_state.binding_slots.size()):
    var slot_text: String = "Slot %d\nempty" % (index + 1)
    if _state.binding_slot_has_card(index):
      var card: Variant = _state.binding_slots[index]["card"]
      var page: Variant = _page_library.get(String(card.page_id), null)
      var page_name: String = String(page.name) if page != null else String(card.page_id)
      slot_text = "%s\n%s" % [page_name, "frayed" if _state.binding_slot_is_frayed(index) else "intact"]
    _set_label("SafeArea/Content/Scrivener/SlotColumn/Slot%d" % (index + 1), slot_text)

func _set_label(path: String, text: String) -> void:
  var node: Node = _combat.get_node_or_null(path)
  if node is Label:
    (node as Label).text = text
  elif node is Button:
    (node as Button).text = text

func _apply_preview_state() -> void:
  match preview_state:
    "spread":
      _controller.preview_open_spread(_hand_index_with_target("enemy"))
    "drag_play":
      _controller.preview_open_spread(_hand_index_with_target("enemy"))
      _controller.preview_drag_to_zone(CardInteractionModel.Zone.ENEMY, 0)
    "drag_bind":
      _controller.preview_open_spread(0)
      _controller.preview_drag_to_zone(CardInteractionModel.Zone.SLOT, 0)
    "bind_pending":
      _controller.preview_open_spread(0)
      _controller.preview_drop_on_zone(CardInteractionModel.Zone.SLOT, 0)
    "inspect":
      _controller.preview_inspect(0)
    "no_ink":
      _state.player_ink = 0
      _controller.refresh()
      _controller.preview_open_spread(0)
    _:
      push_warning("Card interaction demo: unknown preview_state '%s'." % preview_state)

func _hand_index_with_target(target: String) -> int:
  for index: int in range(_state.hand.size()):
    if String(_state.hand[index].target) == target:
      return index
  return 0
