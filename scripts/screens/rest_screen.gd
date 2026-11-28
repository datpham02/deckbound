class_name RestScreen
extends Control
## Rest node (M1 T15, E5): the Scrivener's bind slots are shown; the player taps
## a bound page, then taps "Unbind" to return it to the deck and free the slot,
## or taps "Skip". A first tap only selects, it never acts. The screen writes
## only to RunState (bindings and deck) and emits `rest_resolved`; the run flow
## (T16) saves on the node transition and leaves the screen.
##
## Standalone (no setup() before it enters the tree) it builds a preview
## RunState from data/run/rules.json so the scene runs in the editor and in the
## QA screenshot tool. preview_state: "" (nothing selected) or "selected".

signal rest_resolved(result: Dictionary)

const REST_LOGIC_SCRIPT := preload("res://scripts/screens/rest_logic.gd")
const SCREEN_DATA_SCRIPT := preload("res://scripts/screens/screen_data.gd")
const RUN_STATE_SCRIPT := preload("res://scripts/run/run_state.gd")

const SLOT_BUTTON_MIN_SIZE: Vector2 = Vector2(420, 220)
const SELECTED_SLOT_COLOR: Color = Color(1.0, 0.9, 0.55)
const SELECTABLE_SLOT_COLOR: Color = Color.WHITE
const DISABLED_SLOT_COLOR: Color = Color(0.72, 0.72, 0.76)
const PREVIEW_BOUND_PAGE_IDS: PackedStringArray = ["pressed_thorn", "tally_mark"]
const PREVIEW_NODE_ID: String = "rest_01"

@export var preview_state: String = ""
@export var preview_seed: int = 1337

@onready var _subtitle_label: Label = $SafeArea/Layout/Subtitle
@onready var _slots_row: HBoxContainer = $SafeArea/Layout/Slots
@onready var _detail_label: Label = $SafeArea/Layout/Detail
@onready var _unbind_button: Button = $SafeArea/Layout/Footer/Unbind
@onready var _skip_button: Button = $SafeArea/Layout/Footer/Skip
@onready var _status_label: Label = $SafeArea/Layout/Status

var run_state: Variant = null
var page_library: Dictionary = {}
var slot_count: int = 0
var selected_slot_index: int = -1
var is_resolved: bool = false
var last_result: Dictionary = {}

var _slot_buttons: Array[Button] = []

func _ready() -> void:
  _unbind_button.pressed.connect(_on_unbind_pressed)
  _skip_button.pressed.connect(_on_skip_pressed)
  if run_state == null:
    _setup_preview()
  else:
    _rebuild_slots()
    _refresh()
  if preview_state == "selected":
    var candidates: Array[int] = REST_LOGIC_SCRIPT.unbindable_slot_indices(run_state, slot_count)
    if not candidates.is_empty():
      select_slot(candidates[0])

## `next_page_library` maps page id to PageData (ScreenData.load_page_library);
## `next_slot_count` is rules.bind_slots.
func setup(next_run_state: Variant, next_page_library: Dictionary, next_slot_count: int) -> void:
  run_state = next_run_state
  page_library = next_page_library
  slot_count = maxi(0, next_slot_count)
  selected_slot_index = -1
  is_resolved = false
  last_result = {}
  if is_node_ready():
    _rebuild_slots()
    _refresh()

func select_slot(slot_index: int) -> bool:
  if is_resolved or not REST_LOGIC_SCRIPT.can_unbind(run_state, slot_index):
    return false
  selected_slot_index = slot_index
  _refresh()
  return true

## Unbinds the selected slot; returns the RestLogic result.
func confirm_unbind() -> Dictionary:
  if is_resolved:
    return {"ok": false, "error": "This rest is already resolved."}
  var result: Dictionary = REST_LOGIC_SCRIPT.unbind(run_state, selected_slot_index)
  if not bool(result.get("ok", false)):
    _status_label.text = String(result.get("error", "Could not unbind."))
    return result
  result["action"] = "unbind"
  _resolve(result)
  return result

func skip() -> Dictionary:
  if is_resolved:
    return {"ok": false, "error": "This rest is already resolved."}
  var result: Dictionary = {"ok": true, "action": "skip"}
  _resolve(result)
  return result

func _resolve(result: Dictionary) -> void:
  is_resolved = true
  last_result = result
  selected_slot_index = -1
  _refresh()
  rest_resolved.emit(result)

func _on_unbind_pressed() -> void:
  confirm_unbind()

func _on_skip_pressed() -> void:
  skip()

func _on_slot_pressed(slot_index: int) -> void:
  select_slot(slot_index)

func _rebuild_slots() -> void:
  for button: Button in _slot_buttons:
    button.queue_free()
  _slot_buttons.clear()
  for slot_index: int in range(slot_count):
    var button: Button = Button.new()
    button.name = "Slot%d" % (slot_index + 1)
    button.custom_minimum_size = SLOT_BUTTON_MIN_SIZE
    button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    button.focus_mode = Control.FOCUS_NONE
    button.pressed.connect(_on_slot_pressed.bind(slot_index))
    _slots_row.add_child(button)
    _slot_buttons.append(button)

func _refresh() -> void:
  var entries: Array[Dictionary] = REST_LOGIC_SCRIPT.slot_entries(run_state, slot_count)
  for slot_index: int in range(_slot_buttons.size()):
    var button: Button = _slot_buttons[slot_index]
    var entry: Dictionary = entries[slot_index]
    var page_id: String = String(entry.get("page_id", ""))
    var status: String = String(entry.get("status", RUN_STATE_SCRIPT.BINDING_STATUS_EMPTY))
    var can_unbind: bool = REST_LOGIC_SCRIPT.can_unbind(run_state, slot_index) and not is_resolved
    button.text = "Slot %d\n%s" % [slot_index + 1, _slot_line(page_id, status)]
    button.disabled = not can_unbind
    if slot_index == selected_slot_index:
      button.modulate = SELECTED_SLOT_COLOR
    elif can_unbind:
      button.modulate = SELECTABLE_SLOT_COLOR
    else:
      button.modulate = DISABLED_SLOT_COLOR

  _unbind_button.disabled = is_resolved or selected_slot_index < 0
  _skip_button.disabled = is_resolved
  _detail_label.text = _detail_text()
  _status_label.text = _status_text()
  _subtitle_label.text = "Unbind one page to return it to your deck, or skip."

func _slot_line(page_id: String, status: String) -> String:
  if page_id == "":
    return status if status != RUN_STATE_SCRIPT.BINDING_STATUS_EMPTY else "empty"
  var page_name: String = _page_name(page_id)
  if status == RUN_STATE_SCRIPT.BINDING_STATUS_INTACT:
    return page_name
  return "%s\n%s" % [page_name, status]

func _detail_text() -> String:
  if is_resolved:
    if String(last_result.get("action", "")) == "unbind":
      return "%s returns to the deck. Slot %d is free." % [
        _page_name(String(last_result.get("page_id", ""))),
        int(last_result.get("slot_index", 0)) + 1
      ]
    return "You rest. Nothing changes."
  if selected_slot_index < 0:
    if REST_LOGIC_SCRIPT.unbindable_slot_indices(run_state, slot_count).is_empty():
      return "No page is bound. Skip to move on."
    return "Tap a bound page to choose it."
  var entry: Dictionary = REST_LOGIC_SCRIPT.slot_entries(run_state, slot_count)[selected_slot_index]
  var page_id: String = String(entry.get("page_id", ""))
  var page: Variant = page_library.get(page_id, null)
  var bind_text: String = String(page.bind_text) if page != null else ""
  return "%s\nBind: %s\nUnbind to return it to the deck and free slot %d." % [
    _page_name(page_id),
    bind_text,
    selected_slot_index + 1
  ]

func _status_text() -> String:
  if run_state == null:
    return ""
  return "Deck: %d pages" % run_state.deck.size()

func _page_name(page_id: String) -> String:
  var page: Variant = page_library.get(page_id, null)
  if page != null:
    return String(page.name)
  return page_id

## Preview run state for the editor and the QA screenshot tool: the starting
## deck from rules.json with two of its bindable pages worn in the first slots.
func _setup_preview() -> void:
  var errors: Array[String] = []
  var library: Dictionary = SCREEN_DATA_SCRIPT.load_page_library(errors)
  var rules: Variant = SCREEN_DATA_SCRIPT.load_run_rules(errors)
  for error: String in errors:
    push_error(error)
  if rules == null:
    push_error("Rest screen preview: data/run/rules.json could not be loaded.")
    return

  var state: Variant = RUN_STATE_SCRIPT.new()
  state.seed = preview_seed
  state.health = int(rules.hero_health)
  var deck: Array[String] = []
  var bound: Array[String] = []
  for page_id: String in rules.starting_deck:
    if PREVIEW_BOUND_PAGE_IDS.has(page_id) and not bound.has(page_id) and bound.size() < int(rules.bind_slots):
      bound.append(page_id)
    else:
      deck.append(page_id)
  state.deck = deck
  var bindings: Array[Dictionary] = []
  for slot_index: int in range(int(rules.bind_slots)):
    var page_id: String = bound[slot_index] if slot_index < bound.size() else ""
    bindings.append({
      "slot_index": slot_index,
      "page_id": page_id,
      "status": RUN_STATE_SCRIPT.BINDING_STATUS_INTACT if page_id != "" else RUN_STATE_SCRIPT.BINDING_STATUS_EMPTY
    })
  state.bindings = bindings
  var path: Array[String] = ["start", "fight_01", PREVIEW_NODE_ID]
  state.map_position = {
    "act_index": 0,
    "node_id": PREVIEW_NODE_ID,
    "path": path
  }
  setup(state, library, int(rules.bind_slots))
