class_name CardInteractionSettings
extends Resource
## Pointer-feel tunables for card gestures (tap slop, long-press time, drag
## direction threshold, highlight colours). Edit the shared instance at
## res://scenes/card/card_interaction_settings.tres.
##
## Gameplay numbers (Ink, costs, slot count, deck floor) are never stored here:
## the interaction reads them from the combat state, which is built from data/.

## Finger travel, in canvas pixels, below which a press still counts as a tap.
@export var tap_slop_px: float = 24.0
## Hold time, in seconds, after which a still press becomes a long-press inspect.
@export var long_press_seconds: float = 0.6
## Horizontal travel from the spread, in canvas pixels, before a drag commits to
## the Play side (right) or the Bind side (left).
@export var drag_direction_threshold_px: float = 48.0
## Scale of the compact card ghost that follows the finger while dragging.
@export var drag_ghost_scale: float = 0.85
## How long a refusal cue ("Not enough Ink") stays on screen, in seconds.
@export var refusal_message_seconds: float = 1.6
## Highlight colour for Play drop zones (enemies, play area).
@export var play_highlight_color: Color = Color(0.98, 0.8, 0.35, 1.0)
## Highlight colour for Bind drop zones (bind slots).
@export var bind_highlight_color: Color = Color(0.45, 0.88, 0.8, 1.0)
## Border alpha of candidate zones while the spread is open but no direction is chosen.
@export var idle_highlight_alpha: float = 0.45
## Fill alpha of the zone under the finger.
@export var hover_fill_alpha: float = 0.3
## Border width of a highlighted zone, in canvas pixels.
@export var highlight_border_px: float = 6.0
