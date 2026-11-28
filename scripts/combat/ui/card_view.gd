class_name CardView
extends Button
## Compact card face in the hand (E9.1): cost, name, one Play line, a divider,
## one Bind line. Recognises tap (opens the spread) and long-press (inspect).
## A drag that starts on a hand card does nothing: Play and Bind drags begin
## from the open spread, so a first touch never acts.

signal tapped(view: CardView)
signal long_press_started(view: CardView)
signal long_press_ended(view: CardView)

@export var settings: CardInteractionSettings

var hand_index: int = -1
var card: Variant = null
var page: Variant = null

var _recognizer: CardGestureRecognizer = CardGestureRecognizer.new()

@onready var _cost_label: Label = $Margin/Rows/Header/Cost
@onready var _name_label: Label = $Margin/Rows/Header/Name
@onready var _play_label: Label = $Margin/Rows/PlayLine
@onready var _bind_label: Label = $Margin/Rows/BindLine

func _ready() -> void:
  focus_mode = Control.FOCUS_NONE
  _recognizer.configure(settings)
  _apply_card_to_labels()

func set_card(card_value: Variant, page_value: Variant, index: int) -> void:
  card = card_value
  page = page_value
  hand_index = index
  if is_node_ready():
    _apply_card_to_labels()

## Dims the face when the page cannot be afforded this turn (cue for E10.8).
func set_affordable(affordable: bool) -> void:
  modulate = Color.WHITE if affordable else Color(0.78, 0.78, 0.78, 0.9)

func display_name() -> String:
  if page != null:
    return String(page.name)
  if card != null:
    return String(card.page_id)
  return ""

func _apply_card_to_labels() -> void:
  if card == null:
    return
  _cost_label.text = str(int(card.cost))
  _name_label.text = display_name()
  if page != null:
    _play_label.text = String(page.compact_play_line)
    _bind_label.text = "Bind: %s" % String(page.compact_bind_line)
  else:
    _play_label.text = ""
    _bind_label.text = ""

func _gui_input(event: InputEvent) -> void:
  var now: float = _now()
  if event is InputEventMouseButton:
    var button_event: InputEventMouseButton = event
    if button_event.button_index != MOUSE_BUTTON_LEFT:
      return
    if button_event.pressed:
      _recognizer.press(button_event.global_position, now)
      return
    var gesture: int = _recognizer.release(button_event.global_position, now)
    match gesture:
      CardGestureRecognizer.Gesture.TAP:
        tapped.emit(self)
      CardGestureRecognizer.Gesture.LONG_PRESS_END:
        long_press_ended.emit(self)
    return
  if event is InputEventMouseMotion:
    var motion_event: InputEventMouseMotion = event
    _recognizer.move(motion_event.global_position, now)

func _process(_delta: float) -> void:
  if not _recognizer.is_pressed:
    return
  if _recognizer.tick(_now()) == CardGestureRecognizer.Gesture.LONG_PRESS:
    long_press_started.emit(self)

func _now() -> float:
  return float(Time.get_ticks_msec()) * 0.001
