class_name CardGestureRecognizer
extends RefCounted
## Classifies one pointer (first touch or left mouse button, which Godot emulates
## from touch) into tap, long-press or drag. Pure: no nodes, no clock. Callers
## pass positions in any single coordinate space and a monotonic time in seconds.
##
## Rules:
## - A press that releases within tap_slop_px and before long_press_seconds is a TAP.
## - A press held still for long_press_seconds becomes LONG_PRESS (reported by
##   tick); its release is LONG_PRESS_END and never a tap.
## - Movement beyond tap_slop_px before the long press starts is DRAG_START, then
##   DRAG_MOVE, and the release is DRAG_END. A drag never turns into a long press.

enum Gesture { NONE, TAP, LONG_PRESS, LONG_PRESS_END, DRAG_START, DRAG_MOVE, DRAG_END }

var tap_slop_px: float = 24.0
var long_press_seconds: float = 0.6

var is_pressed: bool = false
var is_dragging: bool = false
var is_long_pressing: bool = false
var press_position: Vector2 = Vector2.ZERO
var current_position: Vector2 = Vector2.ZERO
var press_time_s: float = 0.0

func configure(settings: CardInteractionSettings) -> void:
  if settings == null:
    return
  tap_slop_px = settings.tap_slop_px
  long_press_seconds = settings.long_press_seconds

func press(position: Vector2, time_s: float) -> int:
  is_pressed = true
  is_dragging = false
  is_long_pressing = false
  press_position = position
  current_position = position
  press_time_s = time_s
  return Gesture.NONE

func move(position: Vector2, _time_s: float) -> int:
  if not is_pressed:
    return Gesture.NONE
  current_position = position
  if is_long_pressing:
    return Gesture.NONE
  if is_dragging:
    return Gesture.DRAG_MOVE
  if position.distance_to(press_position) > tap_slop_px:
    is_dragging = true
    return Gesture.DRAG_START
  return Gesture.NONE

## Call once per frame while a press may be in progress.
func tick(time_s: float) -> int:
  if not is_pressed or is_dragging or is_long_pressing:
    return Gesture.NONE
  if time_s - press_time_s >= long_press_seconds:
    is_long_pressing = true
    return Gesture.LONG_PRESS
  return Gesture.NONE

func release(position: Vector2, time_s: float) -> int:
  if not is_pressed:
    return Gesture.NONE
  current_position = position
  is_pressed = false
  if is_long_pressing:
    is_long_pressing = false
    return Gesture.LONG_PRESS_END
  if is_dragging:
    is_dragging = false
    return Gesture.DRAG_END
  if time_s - press_time_s >= long_press_seconds:
    # Held past the long-press time without a tick: commit nothing.
    return Gesture.NONE
  return Gesture.TAP

func cancel() -> void:
  is_pressed = false
  is_dragging = false
  is_long_pressing = false

func drag_delta() -> Vector2:
  return current_position - press_position
