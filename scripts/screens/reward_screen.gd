class_name RewardScreen
extends Control
## Reward node (M1 T15, pages.md §6): offers distinct pages from the pool in
## data/pages/ on T12's compact card face. The player taps a page to select it
## (the first tap never acts), then taps "Take page" to add it to the deck, or
## taps "Take none". The screen writes only to RunState (deck) and emits
## `reward_resolved`; the run flow (T16) saves on the node transition.
##
## The offer is seeded from RunState (seed, node, path length) so a reward
## resumed after a kill shows the same pages (E8). Standalone (no setup()
## before it enters the tree) it builds a preview RunState from rules.json.
## preview_state: "" (nothing selected) or "selected".

signal reward_resolved(result: Dictionary)

const REWARD_LOGIC_SCRIPT := preload("res://scripts/screens/reward_logic.gd")
const SCREEN_DATA_SCRIPT := preload("res://scripts/screens/screen_data.gd")
const RUN_STATE_SCRIPT := preload("res://scripts/run/run_state.gd")
const COMBAT_CARD_SCRIPT := preload("res://scripts/combat/core/combat_card.gd")
const CARD_COMPACT_SCENE: PackedScene = preload("res://scenes/card/card_compact.tscn")

const SELECTED_CARD_COLOR: Color = Color(1.0, 0.9, 0.55)
const UNSELECTED_CARD_COLOR: Color = Color.WHITE
const RESOLVED_CARD_COLOR: Color = Color(0.72, 0.72, 0.76)
const PREVIEW_NODE_ID: String = "fight_01"

@export var preview_state: String = ""
@export var preview_seed: int = 1337

@onready var _subtitle_label: Label = $SafeArea/Layout/Subtitle
@onready var _offer_row: HBoxContainer = $SafeArea/Layout/Offer
@onready var _detail_label: Label = $SafeArea/Layout/Detail
@onready var _take_button: Button = $SafeArea/Layout/Footer/Take
@onready var _none_button: Button = $SafeArea/Layout/Footer/TakeNone
@onready var _status_label: Label = $SafeArea/Layout/Status

var run_state: Variant = null
var page_library: Dictionary = {}
var offer_count: int = 0
var offer: Array = []
var selected_page_id: String = ""
var is_resolved: bool = false
var last_result: Dictionary = {}

var _card_views: Array[Control] = []

func _ready() -> void:
  _take_button.pressed.connect(_on_take_pressed)
  _none_button.pressed.connect(_on_none_pressed)
  if run_state == null:
    _setup_preview()
  else:
    _rebuild_offer()
    _refresh()
  if preview_state == "selected" and not offer.is_empty():
    select_page(String(offer[0].id))

## `next_page_library` maps page id to PageData (ScreenData.load_page_library);
## `next_offer_count` comes from ScreenData.read_reward_offer_count().
func setup(next_run_state: Variant, next_page_library: Dictionary, next_offer_count: int) -> void:
  run_state = next_run_state
  page_library = next_page_library
  offer_count = maxi(0, next_offer_count)
  selected_page_id = ""
  is_resolved = false
  last_result = {}
  offer = REWARD_LOGIC_SCRIPT.build_offer(
    page_library.values(),
    offer_count,
    REWARD_LOGIC_SCRIPT.offer_seed(run_state)
  )
  if is_node_ready():
    _rebuild_offer()
    _refresh()

func select_page(page_id: String) -> bool:
  if is_resolved or not REWARD_LOGIC_SCRIPT.offer_page_ids(offer).has(page_id):
    return false
  selected_page_id = page_id
  _refresh()
  return true

## Adds the selected page to the deck; returns the RewardLogic result.
func confirm_take() -> Dictionary:
  if is_resolved:
    return {"ok": false, "error": "This reward is already resolved."}
  var result: Dictionary = REWARD_LOGIC_SCRIPT.take(run_state, selected_page_id, offer)
  if not bool(result.get("ok", false)):
    _status_label.text = String(result.get("error", "Could not take the page."))
    return result
  result["action"] = "take"
  _resolve(result)
  return result

func take_none() -> Dictionary:
  if is_resolved:
    return {"ok": false, "error": "This reward is already resolved."}
  var result: Dictionary = {"ok": true, "action": "none"}
  _resolve(result)
  return result

func _resolve(result: Dictionary) -> void:
  is_resolved = true
  last_result = result
  selected_page_id = ""
  _refresh()
  reward_resolved.emit(result)

func _on_take_pressed() -> void:
  confirm_take()

func _on_none_pressed() -> void:
  take_none()

func _on_card_tapped(view: Control) -> void:
  if view.page == null:
    return
  select_page(String(view.page.id))

func _rebuild_offer() -> void:
  for view: Control in _card_views:
    view.queue_free()
  _card_views.clear()
  for index: int in range(offer.size()):
    var page: Variant = offer[index]
    var view: Control = CARD_COMPACT_SCENE.instantiate() as Control
    view.name = "Offer%d" % (index + 1)
    view.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    view.set_card(COMBAT_CARD_SCRIPT.from_page_data(page), page, index)
    view.tapped.connect(_on_card_tapped)
    _offer_row.add_child(view)
    _card_views.append(view)

func _refresh() -> void:
  for view: Control in _card_views:
    var page_id: String = String(view.page.id) if view.page != null else ""
    if is_resolved:
      view.modulate = RESOLVED_CARD_COLOR
    elif page_id == selected_page_id:
      view.modulate = SELECTED_CARD_COLOR
    else:
      view.modulate = UNSELECTED_CARD_COLOR
    view.disabled = is_resolved

  _take_button.disabled = is_resolved or selected_page_id == ""
  _none_button.disabled = is_resolved
  _subtitle_label.text = _subtitle_text()
  _detail_label.text = _detail_text()
  _status_label.text = _status_text()

func _subtitle_text() -> String:
  if offer.is_empty():
    return "No page can be offered."
  return "Choose one page for your deck, or take none."

func _detail_text() -> String:
  if is_resolved:
    if String(last_result.get("action", "")) == "take":
      return "%s joins the deck." % _page_name(String(last_result.get("page_id", "")))
    return "You take nothing."
  if selected_page_id == "":
    return "Tap a page to read it."
  var page: Variant = page_library.get(selected_page_id, null)
  if page == null:
    return ""
  return "%s (%d Ink)\nPlay: %s\nBind: %s" % [
    String(page.name),
    int(page.cost),
    String(page.play_text),
    String(page.bind_text)
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
## deck from rules.json, empty slots, one fight behind.
func _setup_preview() -> void:
  var errors: Array[String] = []
  var library: Dictionary = SCREEN_DATA_SCRIPT.load_page_library(errors)
  var rules: Variant = SCREEN_DATA_SCRIPT.load_run_rules(errors)
  for error: String in errors:
    push_error(error)
  if rules == null:
    push_error("Reward screen preview: data/run/rules.json could not be loaded.")
    return

  var state: Variant = RUN_STATE_SCRIPT.new()
  state.seed = preview_seed
  state.health = int(rules.hero_health)
  state.deck = rules.starting_deck.duplicate()
  var bindings: Array[Dictionary] = []
  for slot_index: int in range(int(rules.bind_slots)):
    bindings.append({
      "slot_index": slot_index,
      "page_id": "",
      "status": RUN_STATE_SCRIPT.BINDING_STATUS_EMPTY
    })
  state.bindings = bindings
  var path: Array[String] = ["start", PREVIEW_NODE_ID]
  state.map_position = {
    "act_index": 0,
    "node_id": PREVIEW_NODE_ID,
    "path": path
  }
  setup(state, library, SCREEN_DATA_SCRIPT.read_reward_offer_count())
