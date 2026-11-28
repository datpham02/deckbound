class_name CombatHudController
extends Control
## T13 combat HUD on the T11 combat screen (res://scenes/combat/combat.tscn):
## enemy telegraph icon and number above each head, the fray or sever line to
## the threatened bind slot, bind-slot intact / frayed / severed display, the
## Ink, deck and discard counters, the Scrivener's health and guard, and the
## End turn button wired to T6 CombatCore. Long-press on a telegraph, a slot or
## the status line opens the T12 inspect overlay (E4.5, E9.5).
##
## Usage: add a CombatHudController as a child of the combat scene root
## *before* the T12 CardInteraction node (so the spread stays on top), then call
## setup(state, core, page_library). Call refresh() after anything else changes
## the state (T12 emits state_changed for that). End turn resolves the enemy
## phase through CombatCore and emits turn_ended so the hand can be rebuilt.
##
## Every gameplay number shown comes from the combat state, which is built
## from data/. Display sizes and colours come from CombatHudSettings.

signal state_changed()
signal turn_ended()

const CARD_INSPECT_SCENE: PackedScene = preload("res://scenes/card/card_inspect.tscn")
const GESTURE_SETTINGS_PATH: String = "res://scenes/card/card_interaction_settings.tres"
const ENEMY_ART_DIR: String = "res://assets/placeholder/enemies"

const ENEMIES_PATH: String = "SafeArea/Content/Enemies"
const SLOTS_PATH: String = "SafeArea/Content/Scrivener/SlotColumn"
const STATS_PATH: String = "SafeArea/Content/Scrivener/Stats"
const END_TURN_PATH: String = "SafeArea/Content/EndTurn"
const INK_VALUE_PATH: String = "SafeArea/Content/HandBand/InkAndDeck/Ink/Rows/Value"
const DECK_PATH: String = "SafeArea/Content/HandBand/InkAndDeck/Deck"
const DISCARD_PATH: String = "SafeArea/Content/HandBand/Discard"

@export var settings: CombatHudSettings
## Long-press timing shared with T12; defaults to its settings resource.
@export var gesture_settings: CardInteractionSettings
## The combat scene root holding T11's layout; defaults to this node's parent.
@export var combat_root_path: NodePath = NodePath("..")

var page_library: Dictionary = {}

var _state: Variant = null
var _core: Variant = null
var _enemies_container: Node = null
var _enemy_nodes: Array[Control] = []
var _slot_nodes: Array[Control] = []
var _telegraph_views: Array[TelegraphView] = []
var _slot_views: Array[SlotStatusView] = []
var _end_turn: Button = null
var _ink_value: Label = null
var _deck: Button = null
var _discard: Button = null
var _stats: Label = null
var _stats_target: HudInspectTarget = null
var _lines: TelegraphLineLayer = null
var _inspect: CardInspectView = null
var _severed_marks: Dictionary = {}
var _previous_slot_cards: Dictionary = {}

func _ready() -> void:
  name = "CombatHud"
  mouse_filter = Control.MOUSE_FILTER_IGNORE
  set_anchors_preset(Control.PRESET_FULL_RECT)
  if settings == null:
    settings = CombatHudSettings.load_default()
  if gesture_settings == null and ResourceLoader.exists(GESTURE_SETTINGS_PATH):
    gesture_settings = load(GESTURE_SETTINGS_PATH) as CardInteractionSettings
  _lines = TelegraphLineLayer.new()
  _lines.configure(settings)
  add_child(_lines)
  _inspect = CARD_INSPECT_SCENE.instantiate() as CardInspectView
  add_child(_inspect)

## page_library maps page id to PageData (names and Bind text for slots).
func setup(combat_state: Variant, combat_core: Variant, pages: Dictionary) -> void:
  _state = combat_state
  _core = combat_core
  page_library = pages
  _severed_marks.clear()
  _previous_slot_cards.clear()
  _resolve_combat_nodes()
  _build_views()
  refresh()

## Re-reads the whole state into the HUD.
func refresh() -> void:
  if _state == null:
    return
  _update_severed_marks()
  _refresh_counters()
  _refresh_enemies()
  _refresh_slots()
  _refresh_end_turn()
  _update_lines()
  state_changed.emit()

## Ends the player's turn through CombatCore: enemies act, new telegraphs are
## set and the next player turn starts. Returns false when it is not the
## player's turn or combat is over.
func end_turn() -> bool:
  if _state == null or _core == null:
    return false
  if not _state.is_player_turn or _state.is_combat_over():
    return false
  _core.end_player_turn(_state)
  refresh()
  turn_ended.emit()
  return true

## Slots emptied by a sever during this combat (shown as "severed").
func severed_slots() -> Array[int]:
  var slots: Array[int] = []
  for index: int in range(_state.binding_slots.size() if _state != null else 0):
    if _severed_marks.has(index):
      slots.append(index)
  return slots

## Lets a resume restore the "severed" display for a slot (T17).
func mark_slot_severed(slot_index: int) -> void:
  _severed_marks[slot_index] = true

func telegraph_views() -> Array[TelegraphView]:
  return _telegraph_views.duplicate()

func slot_views() -> Array[SlotStatusView]:
  return _slot_views.duplicate()

func line_layer() -> TelegraphLineLayer:
  return _lines

func inspect_view() -> CardInspectView:
  return _inspect

func _process(_delta: float) -> void:
  # Container layout settles after refresh(); keep the line endpoints on it.
  _update_lines()

func _resolve_combat_nodes() -> void:
  var combat_root: Node = get_node_or_null(combat_root_path)
  if combat_root == null:
    push_error("CombatHudController: combat root not found at '%s'." % String(combat_root_path))
    return
  _enemies_container = combat_root.get_node_or_null(ENEMIES_PATH)
  _enemy_nodes = _control_children(_enemies_container)
  _slot_nodes = _control_children(combat_root.get_node_or_null(SLOTS_PATH))
  _stats = combat_root.get_node_or_null(STATS_PATH) as Label
  _end_turn = combat_root.get_node_or_null(END_TURN_PATH) as Button
  _ink_value = combat_root.get_node_or_null(INK_VALUE_PATH) as Label
  _deck = combat_root.get_node_or_null(DECK_PATH) as Button
  _discard = combat_root.get_node_or_null(DISCARD_PATH) as Button
  if _enemy_nodes.is_empty() or _slot_nodes.is_empty() or _stats == null or _end_turn == null or _ink_value == null or _deck == null or _discard == null:
    push_error("CombatHudController: combat scene is missing the enemies, slot column, stats, end turn, Ink, deck or discard nodes.")

func _control_children(parent: Node) -> Array[Control]:
  var controls: Array[Control] = []
  if parent == null:
    return controls
  for child: Node in parent.get_children():
    if child is Control:
      controls.append(child)
  return controls

func _build_views() -> void:
  _clear_views()
  _ensure_enemy_nodes(_state.enemies.size())
  for index: int in range(_enemy_nodes.size()):
    var rows: Node = _enemy_nodes[index].get_node_or_null("Rows")
    if rows == null:
      push_error("CombatHudController: enemy node %d has no Rows container." % index)
      continue
    var old_label: Node = rows.get_node_or_null("Telegraph")
    if old_label is Control:
      (old_label as Control).visible = false
    var view: TelegraphView = TelegraphView.new()
    view.build(settings)
    view.configure_gestures(gesture_settings)
    view.inspect_started.connect(_on_inspect_started)
    view.inspect_ended.connect(_on_inspect_ended)
    rows.add_child(view)
    rows.move_child(view, 0)
    _telegraph_views.append(view)
    if index < _state.enemies.size():
      _place_enemy_art(rows, String(_state.enemies[index].id))

  for index: int in range(_slot_nodes.size()):
    var slot_node: Control = _slot_nodes[index]
    if slot_node is Button:
      (slot_node as Button).text = ""
    var view: SlotStatusView = SlotStatusView.new()
    view.build(settings)
    view.configure_gestures(gesture_settings)
    view.inspect_started.connect(_on_inspect_started)
    view.inspect_ended.connect(_on_inspect_ended)
    slot_node.add_child(view)
    _slot_views.append(view)

  if _stats != null:
    _stats_target = HudInspectTarget.new()
    _stats_target.name = "StatsInspect"
    _stats_target.set_anchors_preset(Control.PRESET_FULL_RECT)
    _stats_target.configure_gestures(gesture_settings)
    _stats_target.inspect_started.connect(_on_inspect_started)
    _stats_target.inspect_ended.connect(_on_inspect_ended)
    _stats.add_child(_stats_target)

  if _end_turn != null and not _end_turn.pressed.is_connected(_on_end_turn_pressed):
    _end_turn.pressed.connect(_on_end_turn_pressed)

func _clear_views() -> void:
  for view: TelegraphView in _telegraph_views:
    view.queue_free()
  for view: SlotStatusView in _slot_views:
    view.queue_free()
  if _stats_target != null:
    _stats_target.queue_free()
  _telegraph_views.clear()
  _slot_views.clear()
  _stats_target = null

## T11 lays out two enemy nodes; a three-enemy composition (E11.5) gets a copy
## of the last one so every enemy has a head to telegraph above.
func _ensure_enemy_nodes(count: int) -> void:
  if _enemies_container == null or _enemy_nodes.is_empty():
    return
  while _enemy_nodes.size() < count:
    var template: Control = _enemy_nodes[_enemy_nodes.size() - 1]
    var copy: Control = template.duplicate() as Control
    copy.name = "Enemy%d" % (_enemy_nodes.size() + 1)
    _enemies_container.add_child(copy)
    _enemy_nodes.append(copy)

func _place_enemy_art(rows: Node, enemy_id: String) -> void:
  var figure: Control = rows.get_node_or_null("Figure") as Control
  if figure == null:
    return
  var existing: Node = figure.get_node_or_null("Art")
  if existing != null:
    existing.queue_free()
  var path: String = "%s/%s.svg" % [ENEMY_ART_DIR, enemy_id]
  if not ResourceLoader.exists(path):
    return
  var art: TextureRect = TextureRect.new()
  art.name = "Art"
  art.texture = load(path) as Texture2D
  art.set_anchors_preset(Control.PRESET_FULL_RECT)
  art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
  art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
  art.mouse_filter = Control.MOUSE_FILTER_IGNORE
  figure.add_child(art)
  if figure is ColorRect:
    var backdrop: ColorRect = figure as ColorRect
    backdrop.color = Color(backdrop.color, 0.0)

func _update_severed_marks() -> void:
  for index: int in range(_state.binding_slots.size()):
    if _state.binding_slot_has_card(index):
      _previous_slot_cards[index] = _state.binding_slots[index]["card"]
      _severed_marks.erase(index)
      continue
    var previous: Variant = _previous_slot_cards.get(index, null)
    if previous != null and _state.removed_from_run.has(previous):
      _severed_marks[index] = true
    _previous_slot_cards.erase(index)

func _refresh_counters() -> void:
  var ink_per_turn: int = int(_state.run_rules.ink_per_turn) if _state.run_rules != null else int(_state.player_ink)
  _set_text(_ink_value, "%d/%d" % [int(_state.player_ink), ink_per_turn])
  _set_text(_deck, "Deck\n%d" % _state.draw_pile.size())
  _set_text(_discard, "Discard\n%d" % _state.discard_pile.size())
  var status: String = "HP %d/%d   Guard %d" % [int(_state.player_health), int(_state.player_max_health), int(_state.player_guard)]
  if _state.is_combat_over():
    status += "\n%s" % String(_state.result).to_upper()
  _set_text(_stats, status)
  if _stats_target != null:
    _stats_target.inspect_title = "Scrivener: %d/%d health, %d guard" % [int(_state.player_health), int(_state.player_max_health), int(_state.player_guard)]
    _stats_target.inspect_body = "Guard absorbs attack damage first and is what a fray or sever is tested against. It resets when your next turn starts."
    _stats_target.inspect_footer = ""

func _refresh_enemies() -> void:
  for index: int in range(_enemy_nodes.size()):
    var node: Control = _enemy_nodes[index]
    var shown: bool = index < _state.enemies.size()
    node.visible = shown
    if not shown:
      continue
    var enemy: Variant = _state.enemies[index]
    if index < _telegraph_views.size():
      _telegraph_views[index].set_telegraph(enemy, index, page_library)
    var rows: Node = node.get_node_or_null("Rows")
    if rows == null:
      continue
    var health: Label = rows.get_node_or_null("Health") as Label
    var alive: bool = enemy.is_alive()
    var guard_text: String = "   Guard %d" % int(enemy.guard) if alive and int(enemy.guard) > 0 else ""
    _set_text(health, "%s\nHP %d/%d%s" % [String(enemy.name), int(enemy.health), int(enemy.max_health), guard_text] if alive else "%s\ndown" % String(enemy.name))
    var figure: Control = rows.get_node_or_null("Figure") as Control
    if figure != null:
      figure.modulate = Color.WHITE if alive else settings.dead_enemy_tint

func _refresh_slots() -> void:
  var threats: Dictionary = {}
  for index: int in range(_state.enemies.size()):
    var enemy: Variant = _state.enemies[index]
    if not enemy.is_alive():
      continue
    var action_type: String = String(enemy.telegraph.get("type", ""))
    if action_type != "fray" and action_type != "sever":
      continue
    var target_slot: int = int(enemy.telegraph.get("target_slot", -1))
    if target_slot < 0:
      continue
    # A sever outranks a fray on the same slot; otherwise the first enemy wins.
    if threats.has(target_slot) and String(threats[target_slot]["type"]) == "sever":
      continue
    threats[target_slot] = {"type": action_type, "value": int(enemy.telegraph.get("value", 0))}

  for index: int in range(_slot_views.size()):
    var view: SlotStatusView = _slot_views[index]
    var shown: bool = index < _state.binding_slots.size()
    _slot_nodes[index].visible = shown
    if not shown:
      continue
    view.set_slot(index, _state, page_library, _severed_marks.has(index))
    if threats.has(index):
      var threat: Dictionary = threats[index]
      view.set_threat(String(threat["type"]), int(threat["value"]))
    else:
      view.set_threat("")

func _refresh_end_turn() -> void:
  if _end_turn == null:
    return
  _end_turn.disabled = (not _state.is_player_turn) or _state.is_combat_over()

func _update_lines() -> void:
  if _lines == null or _state == null:
    return
  var lines: Array[Dictionary] = []
  for view: TelegraphView in _telegraph_views:
    if not view.visible or view.threat_type == "":
      continue
    var slot: int = view.target_slot
    if slot < 0 or slot >= _slot_views.size() or not _slot_nodes[slot].visible:
      continue
    lines.append({
      "from": view.line_anchor_global(),
      "to": _slot_views[slot].line_anchor_global(),
      "type": view.threat_type
    })
  _lines.set_lines(lines)

func _on_end_turn_pressed() -> void:
  end_turn()

func _on_inspect_started(target: HudInspectTarget) -> void:
  if _inspect == null:
    return
  _inspect.show_text(target.inspect_title, target.inspect_body, target.inspect_footer, target.get_global_rect())

func _on_inspect_ended(_target: HudInspectTarget) -> void:
  if _inspect != null:
    _inspect.hide_inspect()

func _set_text(node: Node, text: String) -> void:
  if node is Label:
    (node as Label).text = text
  elif node is Button:
    (node as Button).text = text

# --- Preview helpers -------------------------------------------------------
# Used by res://scripts/combat/ui/hud_demo.tscn to put the screen into a state
# for the QA screenshot tool. They drive the same handlers as real input.

func preview_inspect_telegraph(enemy_index: int) -> void:
  if enemy_index >= 0 and enemy_index < _telegraph_views.size():
    _telegraph_views[enemy_index].preview_inspect()

func preview_inspect_slot(slot_index: int) -> void:
  if slot_index >= 0 and slot_index < _slot_views.size():
    _slot_views[slot_index].preview_inspect()

func preview_inspect_stats() -> void:
  if _stats_target != null:
    _stats_target.preview_inspect()
