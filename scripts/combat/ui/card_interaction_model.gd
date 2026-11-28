class_name CardInteractionModel
extends RefCounted
## Interaction state machine for one hand card (M1 T12, concept "Input"):
## tap opens the spread; from the spread a drag right is Play and a drag left is
## Bind; a drop on a bind slot only lights the slot and a second tap on it
## confirms; any other release cancels. The model owns no nodes and knows no
## geometry: the controller turns gestures and screen rectangles into calls
## here, and this class is the only place that calls CombatCore.play_card and
## BindingSystem.bind_from_hand from the UI.

enum Phase { IDLE, SPREAD, DRAG_PLAY, DRAG_BIND, BIND_PENDING }
enum Zone { NONE, ENEMY, PLAY_AREA, SLOT }

signal spread_opened(hand_index: int)
signal spread_closed()
signal drag_mode_changed(phase: int)
signal bind_pending(hand_index: int, slot_index: int)
signal card_played(hand_index: int, enemy_index: int)
signal card_bound(hand_index: int, slot_index: int)
signal action_refused(message: String)

var state: Variant = null
var core: Variant = null
var binding_system: Variant = null
var phase: int = Phase.IDLE
var hand_index: int = -1
var pending_slot_index: int = -1

func setup(combat_state: Variant, combat_core: Variant, binding: Variant) -> void:
  state = combat_state
  core = combat_core
  binding_system = binding
  phase = Phase.IDLE
  hand_index = -1
  pending_slot_index = -1

func can_interact() -> bool:
  if state == null or core == null or binding_system == null:
    return false
  return not state.is_combat_over() and state.is_player_turn

func selected_card() -> Variant:
  if state == null or hand_index < 0 or hand_index >= state.hand.size():
    return null
  return state.hand[hand_index]

func is_open() -> bool:
  return phase != Phase.IDLE

## A first tap on a hand card only opens the spread; it never acts (E9).
func open_spread(index: int) -> bool:
  if phase != Phase.IDLE:
    return false
  if not can_interact():
    return false
  if index < 0 or index >= state.hand.size():
    return false
  hand_index = index
  phase = Phase.SPREAD
  spread_opened.emit(index)
  return true

## dx is the horizontal finger travel from where the drag began on the spread.
func update_drag(dx: float, direction_threshold_px: float) -> void:
  if phase != Phase.SPREAD and phase != Phase.DRAG_PLAY and phase != Phase.DRAG_BIND:
    return
  var next_phase: int = Phase.SPREAD
  if dx >= direction_threshold_px:
    next_phase = Phase.DRAG_PLAY
  elif dx <= -direction_threshold_px:
    next_phase = Phase.DRAG_BIND
  if next_phase == phase:
    return
  phase = next_phase
  drag_mode_changed.emit(phase)

## Finger released over a zone (or Zone.NONE). Returns true when an action
## happened or became pending; false means the drag cancelled or was refused.
func drop(zone: int, index: int) -> bool:
  match phase:
    Phase.DRAG_PLAY:
      return _drop_play(zone, index)
    Phase.DRAG_BIND:
      return _drop_bind(zone, index)
    Phase.SPREAD:
      cancel()
      return false
    _:
      return false

## A tap while the spread is open or a bind is pending.
func tap(zone: int, index: int) -> bool:
  match phase:
    Phase.BIND_PENDING:
      if zone == Zone.SLOT and index == pending_slot_index:
        return confirm_bind()
      cancel()
      return false
    Phase.SPREAD, Phase.DRAG_PLAY, Phase.DRAG_BIND:
      cancel()
      return false
    _:
      return false

func confirm_bind() -> bool:
  if phase != Phase.BIND_PENDING:
    return false
  var bound_index: int = hand_index
  var slot_index: int = pending_slot_index
  var reason: String = bind_refusal_reason(slot_index)
  if reason != "":
    _refuse(reason)
    return false
  var bound: bool = binding_system.bind_from_hand(state, bound_index, slot_index)
  if not bound:
    _refuse(_last_state_error("That page cannot be bound."))
    return false
  _reset()
  card_bound.emit(bound_index, slot_index)
  spread_closed.emit()
  return true

func cancel() -> void:
  if phase == Phase.IDLE:
    return
  _reset()
  spread_closed.emit()

func has_ink_for_selected() -> bool:
  var card: Variant = selected_card()
  if card == null:
    return false
  return int(state.player_ink) >= int(card.cost)

func selected_needs_enemy_target() -> bool:
  var card: Variant = selected_card()
  if card == null:
    return false
  return String(card.target) == "enemy"

func can_play_on_enemy(enemy_index: int) -> bool:
  return selected_needs_enemy_target() and play_refusal_reason(Zone.ENEMY, enemy_index) == ""

func can_play_on_area() -> bool:
  return not selected_needs_enemy_target() and play_refusal_reason(Zone.PLAY_AREA, -1) == ""

func can_bind_into_slot(slot_index: int) -> bool:
  return bind_refusal_reason(slot_index) == ""

func any_slot_bindable() -> bool:
  if state == null:
    return false
  for slot_index: int in range(state.binding_slots.size()):
    if can_bind_into_slot(slot_index):
      return true
  return false

func play_refusal_reason(zone: int, enemy_index: int) -> String:
  var card: Variant = selected_card()
  if card == null:
    return "No page selected."
  if not can_interact():
    return "Not your turn."
  if not has_ink_for_selected():
    return ink_refusal_reason()
  if String(card.target) == "enemy":
    if zone != Zone.ENEMY:
      return "This page needs an enemy target."
    if not state.is_enemy_alive(enemy_index):
      return "That enemy is already down."
  elif zone != Zone.ENEMY and zone != Zone.PLAY_AREA:
    return "Drop this page on the play area."
  return ""

func bind_refusal_reason(slot_index: int) -> String:
  var card: Variant = selected_card()
  if card == null:
    return "No page selected."
  if not can_interact():
    return "Not your turn."
  if not has_ink_for_selected():
    return ink_refusal_reason()
  if slot_index < 0 or slot_index >= state.binding_slots.size():
    return "Drop this page on a bind slot."
  if state.binding_slot_has_card(slot_index):
    if state.count_empty_binding_slots() == 0:
      return "All bind slots are full."
    return "That slot already holds a page."
  var deck_floor: int = maxi(0, int(state.run_rules.deck_floor))
  var remaining_after_bind: int = _deck_count() - 1
  if remaining_after_bind < deck_floor:
    return "Deck floor: binding would leave %d pages, at least %d must stay." % [remaining_after_bind, deck_floor]
  return ""

func ink_refusal_reason() -> String:
  var card: Variant = selected_card()
  if card == null:
    return "No page selected."
  return "Not enough Ink: costs %d, you have %d." % [int(card.cost), int(state.player_ink)]

func _drop_play(zone: int, index: int) -> bool:
  if zone != Zone.ENEMY and zone != Zone.PLAY_AREA:
    cancel()
    return false
  var reason: String = play_refusal_reason(zone, index)
  if reason != "":
    _refuse(reason)
    return false
  var played_index: int = hand_index
  var target_index: int = index if zone == Zone.ENEMY else -1
  if not selected_needs_enemy_target():
    target_index = -1
  var played: bool = core.play_card(state, played_index, target_index)
  if not played:
    _refuse(_last_state_error("That page cannot be played."))
    return false
  _reset()
  card_played.emit(played_index, target_index)
  spread_closed.emit()
  return true

func _drop_bind(zone: int, index: int) -> bool:
  if zone != Zone.SLOT:
    cancel()
    return false
  var reason: String = bind_refusal_reason(index)
  if reason != "":
    _refuse(reason)
    return false
  phase = Phase.BIND_PENDING
  pending_slot_index = index
  bind_pending.emit(hand_index, index)
  return true

func _refuse(reason: String) -> void:
  action_refused.emit(reason)
  cancel()

func _reset() -> void:
  phase = Phase.IDLE
  hand_index = -1
  pending_slot_index = -1

func _deck_count() -> int:
  return state.hand.size() + state.draw_pile.size() + state.discard_pile.size()

func _last_state_error(fallback: String) -> String:
  if state != null and not state.errors.is_empty():
    return String(state.errors.back())
  return fallback
