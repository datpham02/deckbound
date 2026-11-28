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

const BASE_SIZE: Vector2 = Vector2(260.0, 290.0)
const BASE_MARGIN_X: int = 14
const BASE_MARGIN_Y: int = 8
const BASE_COST_WIDTH: float = 56.0
const MIN_NAME_FONT: int = 20

var _recognizer: CardGestureRecognizer = CardGestureRecognizer.new()
var _layout_scale: float = 1.0
var _visible_width: float = BASE_SIZE.x
var _name_base: int = 38
var _line_base: int = 32

@onready var _margin: MarginContainer = $Margin
@onready var _cost_label: Label = $Margin/Rows/Header/Cost
@onready var _name_label: Label = $Margin/Rows/Header/Name
@onready var _play_label: Label = $Margin/Rows/PlayLine
@onready var _bind_label: Label = $Margin/Rows/BindLine

func _ready() -> void:
  focus_mode = Control.FOCUS_NONE
  _recognizer.configure(settings)
  _name_base = _name_label.get_theme_font_size("font_size")
  _line_base = _play_label.get_theme_font_size("font_size")
  _apply_card_to_labels()
  _apply_layout()

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

## Sizes the face for the hand. card_scale scales the whole face (size, margins
## and text together); revealed_width is how much of the face a neighbour leaves
## uncovered, so the name is fitted into it and never cut off.
func set_hand_layout(card_scale: float, revealed_width: float) -> void:
  _layout_scale = card_scale
  _visible_width = revealed_width
  if is_node_ready():
    _apply_layout()

func _apply_layout() -> void:
  var s: float = _layout_scale
  custom_minimum_size = BASE_SIZE * s
  size = custom_minimum_size
  for side: String in ["margin_left", "margin_right"]:
    _margin.add_theme_constant_override(side, roundi(BASE_MARGIN_X * s))
  for side: String in ["margin_top", "margin_bottom"]:
    _margin.add_theme_constant_override(side, roundi(BASE_MARGIN_Y * s))
  _cost_label.custom_minimum_size.x = BASE_COST_WIDTH * s
  _cost_label.add_theme_font_size_override("font_size", roundi(_name_base * s))
  _play_label.add_theme_font_size_override("font_size", roundi(_line_base * s))
  _bind_label.add_theme_font_size_override("font_size", roundi(_line_base * s))
  _fit_name()

# Shrinks the name until it fits on one line in the uncovered strip; if even the
# smallest size does not fit, it wraps onto more lines. Never clipped.
func _fit_name() -> void:
  var s: float = _layout_scale
  _name_label.clip_text = false
  _name_label.autowrap_mode = TextServer.AUTOWRAP_OFF
  var font: Font = _name_label.get_theme_font("font")
  var text: String = _name_label.text
  var avail: float = minf(_visible_width, BASE_SIZE.x * s) - 2.0 * BASE_MARGIN_X * s - BASE_COST_WIDTH * s - 4.0
  var size_px: int = roundi(_name_base * s)
  while size_px > MIN_NAME_FONT and font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, size_px).x > avail:
    size_px -= 1
  _name_label.add_theme_font_size_override("font_size", size_px)
  if font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, size_px).x > avail:
    _name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _name_label.custom_minimum_size.x = maxf(avail, 1.0)
  else:
    _name_label.custom_minimum_size.x = 0.0

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
  _fit_name()

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
