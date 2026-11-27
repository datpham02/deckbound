class_name CardInteractionController
extends Control
## Wires the combat rules (T6 CombatCore, T7 BindingSystem) into the combat
## screen layout (T11) for the hand: builds compact cards from the combat
## state, routes their gestures through CardInteractionModel, shows the spread
## and inspect overlays, hit-tests drops against T11's enemies, play area and
## bind slots, and rebuilds the hand after a Play or Bind.
##
## Usage: instance res://scenes/card/card_interaction.tscn as the last child of
## the combat scene root (res://scenes/combat/combat.tscn) and call setup().
## HUD counters (Ink, deck, discard, enemy health) belong to T13; listen to
## state_changed to refresh them.

signal state_changed()
signal action_refused(message: String)

const CARD_COMPACT_SCENE: PackedScene = preload("res://scenes/card/card_compact.tscn")
const HAND_PATH: String = "SafeArea/Content/HandBand/Hand"
const ENEMIES_PATH: String = "SafeArea/Content/Enemies"
const SLOTS_PATH: String = "SafeArea/Content/Scrivener/SlotColumn"
const PLAY_AREA_PATH: String = "SafeArea/Content/PlayArea"

@export var settings: CardInteractionSettings
## The combat scene root holding T11's layout; defaults to this node's parent.
@export var combat_root_path: NodePath = NodePath("..")

var model: CardInteractionModel = CardInteractionModel.new()
var page_library: Dictionary = {}

var _state: Variant = null
var _hand_container: Control = null
var _play_area: Control = null
var _enemy_nodes: Array[Control] = []
var _slot_nodes: Array[Control] = []
var _message_seconds_left: float = 0.0

@onready var _spread: CardSpreadView = $Spread
@onready var _inspect: CardInspectView = $Inspect
@onready var _message: Label = $Message

func _ready() -> void:
  mouse_filter = Control.MOUSE_FILTER_IGNORE
  _spread.settings = settings
  _spread.visible = false
  _message.visible = false
  _spread.tapped_at.connect(_on_spread_tapped)
  _spread.drag_moved.connect(_on_spread_drag_moved)
  _spread.drag_released.connect(_on_spread_drag_released)
  model.spread_opened.connect(_on_spread_opened)
  model.spread_closed.connect(_on_spread_closed)
  model.drag_mode_changed.connect(func(_phase: int) -> void: _update_spread_zones())
  model.bind_pending.connect(_on_bind_pending)
  model.card_played.connect(_on_card_played)
  model.card_bound.connect(_on_card_bound)
  model.action_refused.connect(_on_action_refused)

## page_library maps page id to PageData (for names and full text).
func setup(combat_state: Variant, combat_core: Variant, binding_system: Variant, pages: Dictionary) -> void:
  _state = combat_state
  page_library = pages
  model.setup(combat_state, combat_core, binding_system)
  _resolve_combat_nodes()
  refresh()

## Rebuilds the hand from the combat state and tells the HUD to refresh.
func refresh() -> void:
  model.cancel()
  _rebuild_hand()
  _sync_target_nodes()
  state_changed.emit()

func hand_views() -> Array[CardView]:
  var views: Array[CardView] = []
  if _hand_container == null:
    return views
  for child: Node in _hand_container.get_children():
    if child is CardView:
      views.append(child)
  return views

func _process(delta: float) -> void:
  if _message_seconds_left > 0.0:
    _message_seconds_left -= delta
    if _message_seconds_left <= 0.0:
      _message.visible = false
  if _spread.visible:
    _update_spread_zones()

func _resolve_combat_nodes() -> void:
  var combat_root: Node = get_node_or_null(combat_root_path)
  if combat_root == null:
    push_error("CardInteractionController: combat root not found at '%s'." % String(combat_root_path))
    return
  _hand_container = combat_root.get_node_or_null(HAND_PATH) as Control
  _play_area = combat_root.get_node_or_null(PLAY_AREA_PATH) as Control
  _enemy_nodes = _control_children(combat_root.get_node_or_null(ENEMIES_PATH))
  _slot_nodes = _control_children(combat_root.get_node_or_null(SLOTS_PATH))
  if _hand_container == null or _play_area == null or _enemy_nodes.is_empty() or _slot_nodes.is_empty():
    push_error("CardInteractionController: combat scene is missing the hand, play area, enemies or slot column.")

func _control_children(parent: Node) -> Array[Control]:
  var controls: Array[Control] = []
  if parent == null:
    return controls
  for child: Node in parent.get_children():
    if child is Control:
      controls.append(child)
  return controls

func _rebuild_hand() -> void:
  if _hand_container == null or _state == null:
    return
  for child: Node in _hand_container.get_children():
    _hand_container.remove_child(child)
    child.queue_free()
  var can_interact: bool = model.can_interact()
  for index: int in range(_state.hand.size()):
    var card: Variant = _state.hand[index]
    var view: CardView = CARD_COMPACT_SCENE.instantiate() as CardView
    view.settings = settings
    view.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    view.set_card(card, page_library.get(String(card.page_id), null), index)
    view.set_affordable(can_interact and int(_state.player_ink) >= int(card.cost))
    view.tapped.connect(_on_card_tapped)
    view.long_press_started.connect(_on_card_long_press_started)
    view.long_press_ended.connect(_on_card_long_press_ended)
    _hand_container.add_child(view)

func _sync_target_nodes() -> void:
  if _state == null:
    return
  for index: int in range(_enemy_nodes.size()):
    _enemy_nodes[index].visible = index < _state.enemies.size()
  for index: int in range(_slot_nodes.size()):
    _slot_nodes[index].visible = index < _state.binding_slots.size()

func _on_card_tapped(view: CardView) -> void:
  if _inspect.visible:
    return
  model.open_spread(view.hand_index)

func _on_card_long_press_started(view: CardView) -> void:
  if model.is_open():
    return
  _inspect.show_card(view.card, view.page, view.get_global_rect())

func _on_card_long_press_ended(_view: CardView) -> void:
  _inspect.hide_inspect()

func _on_spread_opened(index: int) -> void:
  var card: Variant = _state.hand[index]
  var page: Variant = page_library.get(String(card.page_id), null)
  var message: String = "" if model.has_ink_for_selected() else model.ink_refusal_reason()
  _spread.open(card, page, message)
  _update_spread_zones()

func _on_spread_closed() -> void:
  _spread.close()

func _on_bind_pending(_hand_index: int, slot_index: int) -> void:
  if slot_index >= 0 and slot_index < _slot_nodes.size():
    _spread.enter_bind_pending(_slot_nodes[slot_index].get_global_rect())

func _on_card_played(_hand_index: int, _enemy_index: int) -> void:
  refresh()

func _on_card_bound(_hand_index: int, _slot_index: int) -> void:
  refresh()

func _on_action_refused(message: String) -> void:
  _show_message(message)
  action_refused.emit(message)

func _on_spread_tapped(global_position: Vector2) -> void:
  if model.phase == CardInteractionModel.Phase.BIND_PENDING:
    var zone: Dictionary = _zone_at(global_position, CardInteractionModel.Phase.DRAG_BIND)
    model.tap(int(zone.get("kind", CardInteractionModel.Zone.NONE)), int(zone.get("index", -1)))
    return
  model.tap(CardInteractionModel.Zone.NONE, -1)

func _on_spread_drag_moved(global_position: Vector2, dx: float) -> void:
  model.update_drag(dx, _direction_threshold())
  _update_spread_zones(global_position)

func _on_spread_drag_released(global_position: Vector2, dx: float) -> void:
  model.update_drag(dx, _direction_threshold())
  var zone: Dictionary = _zone_at(global_position, model.phase)
  model.drop(int(zone.get("kind", CardInteractionModel.Zone.NONE)), int(zone.get("index", -1)))

func _direction_threshold() -> float:
  return settings.drag_direction_threshold_px if settings != null else 48.0

func _update_spread_zones(pointer: Vector2 = Vector2(-1.0, -1.0)) -> void:
  if not _spread.visible or model.phase == CardInteractionModel.Phase.IDLE:
    return
  var zones: Array[Dictionary] = _collect_zones()
  var hovered: Dictionary = {}
  if pointer.x >= 0.0:
    hovered = _zone_at(pointer, model.phase, zones)
    _spread.set_pointer(pointer)
  _spread.set_zones(zones, model.phase, hovered)

func _collect_zones() -> Array[Dictionary]:
  var zones: Array[Dictionary] = []
  if _state == null:
    return zones
  for index: int in range(mini(_state.enemies.size(), _enemy_nodes.size())):
    zones.append({
      "kind": CardInteractionModel.Zone.ENEMY,
      "index": index,
      "rect": _enemy_nodes[index].get_global_rect(),
      "active": model.can_play_on_enemy(index)
    })
  if _play_area != null:
    zones.append({
      "kind": CardInteractionModel.Zone.PLAY_AREA,
      "index": -1,
      "rect": _play_area.get_global_rect(),
      "active": model.can_play_on_area()
    })
  for index: int in range(mini(_state.binding_slots.size(), _slot_nodes.size())):
    zones.append({
      "kind": CardInteractionModel.Zone.SLOT,
      "index": index,
      "rect": _slot_nodes[index].get_global_rect(),
      "active": model.can_bind_into_slot(index)
    })
  return zones

## The zone under a point on the side that the current drag direction allows.
## Right (Play) never reaches a slot and left (Bind) never reaches an enemy (E10.7).
func _zone_at(global_position: Vector2, phase: int, zones: Array[Dictionary] = []) -> Dictionary:
  if zones.is_empty():
    zones = _collect_zones()
  for zone: Dictionary in zones:
    var kind: int = int(zone.get("kind", CardInteractionModel.Zone.NONE))
    var is_bind_zone: bool = kind == CardInteractionModel.Zone.SLOT
    if phase == CardInteractionModel.Phase.DRAG_PLAY and is_bind_zone:
      continue
    if phase == CardInteractionModel.Phase.DRAG_BIND and not is_bind_zone:
      continue
    if phase == CardInteractionModel.Phase.SPREAD:
      continue
    var rect: Rect2 = zone.get("rect", Rect2())
    if rect.has_point(global_position):
      return zone
  return {}

func _show_message(text: String) -> void:
  _message.text = text
  _message.visible = true
  _message_seconds_left = settings.refusal_message_seconds if settings != null else 1.6

# --- Preview helpers -------------------------------------------------------
# Used by res://scenes/card/card_interaction_demo.tscn to put the screen into
# a given interaction state for the QA screenshot tool. They drive the same
# handlers as real gestures.

func preview_open_spread(index: int) -> bool:
  return model.open_spread(index)

func preview_drag_to_zone(kind: int, index: int) -> void:
  var rect: Rect2 = _zone_rect(kind, index)
  if rect.size == Vector2.ZERO:
    return
  var target: Vector2 = rect.get_center()
  var dx: float = target.x - _spread.book_center().x
  _spread.begin_drag()
  _on_spread_drag_moved(target, dx)

func preview_drop_on_zone(kind: int, index: int) -> void:
  var rect: Rect2 = _zone_rect(kind, index)
  if rect.size == Vector2.ZERO:
    return
  var target: Vector2 = rect.get_center()
  var dx: float = target.x - _spread.book_center().x
  _spread.begin_drag()
  _on_spread_drag_moved(target, dx)
  _on_spread_drag_released(target, dx)

func preview_inspect(index: int) -> void:
  var views: Array[CardView] = hand_views()
  if index < 0 or index >= views.size():
    return
  _on_card_long_press_started(views[index])

func _zone_rect(kind: int, index: int) -> Rect2:
  for zone: Dictionary in _collect_zones():
    if int(zone.get("kind", -1)) == kind and int(zone.get("index", -2)) == index:
      return zone.get("rect", Rect2())
  return Rect2()
