class_name HudInspectTarget
extends Control
## A HUD element that opens the inspect overlay on long-press (E4.5, E9.5):
## telegraphs, bind slots and the Scrivener's status line extend or embed it.
## The overlay text is held here so the controller can show it without knowing
## the element. A tap does nothing and a drag does nothing: inspecting never
## commits an action, and releasing the finger closes the overlay.

signal inspect_started(target: HudInspectTarget)
signal inspect_ended(target: HudInspectTarget)

var inspect_title: String = ""
var inspect_body: String = ""
var inspect_footer: String = ""

var _recognizer: CardGestureRecognizer = CardGestureRecognizer.new()
var _inspecting: bool = false

func _ready() -> void:
  mouse_filter = Control.MOUSE_FILTER_STOP
  focus_mode = Control.FOCUS_NONE

## Shares the T12 long-press timing and tap slop.
func configure_gestures(settings: CardInteractionSettings) -> void:
  _recognizer.configure(settings)

func is_inspecting() -> bool:
  return _inspecting

## Opens the overlay as a long-press would (QA screenshot previews).
func preview_inspect() -> void:
  if _inspecting:
    return
  _inspecting = true
  inspect_started.emit(self)

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
    if gesture == CardGestureRecognizer.Gesture.LONG_PRESS_END:
      _end_inspect()
    return
  if event is InputEventMouseMotion:
    var motion_event: InputEventMouseMotion = event
    _recognizer.move(motion_event.global_position, now)

func _process(_delta: float) -> void:
  if not _recognizer.is_pressed:
    return
  if _recognizer.tick(_now()) == CardGestureRecognizer.Gesture.LONG_PRESS:
    _inspecting = true
    inspect_started.emit(self)

func _end_inspect() -> void:
  if not _inspecting:
    return
  _inspecting = false
  inspect_ended.emit(self)

func _now() -> float:
  return float(Time.get_ticks_msec()) * 0.001
