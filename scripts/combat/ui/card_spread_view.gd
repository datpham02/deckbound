class_name CardSpreadView
extends Control
## The open two-page spread (concept "Spread"): Play page left, Bind page right,
## Ink cost at the spine, the rest of the screen dimmed but visible. Owns the
## pointer while open, reports taps and drags to the controller, and draws the
## drop-zone highlights above the dim so enemies, the play area and the slots
## stay readable as targets.

signal tapped_at(global_position: Vector2)
signal drag_moved(global_position: Vector2, dx: float)
signal drag_released(global_position: Vector2, dx: float)

const HINT_OPEN: String = "Drag right to Play, drag left to Bind. Tap outside to close."
const HINT_PLAY: String = "Release on a highlighted target to Play. Release elsewhere to cancel."
const HINT_BIND: String = "Release on a highlighted slot to Bind. Release elsewhere to cancel."
const HINT_PENDING: String = "Tap the lit slot to bind this page. Tap anywhere else to cancel."
const GHOST_PLAY_LABEL: String = "Play >>"
const GHOST_BIND_LABEL: String = "<< Bind"
const PENDING_SLOT_LABEL: String = "Bind"
const PENDING_FILL_ALPHA: float = 0.2
const ACTIVE_FILL_ALPHA: float = 0.1
const BOOK_DRAG_ALPHA: float = 0.25
const PENDING_GHOST_FIT: float = 0.9

@export var settings: CardInteractionSettings

var _recognizer: CardGestureRecognizer = CardGestureRecognizer.new()
var _press_on_book: bool = false
var _zones: Array[Dictionary] = []
var _phase: int = CardInteractionModel.Phase.IDLE
var _hovered: Dictionary = {}
var _pending_rect: Rect2 = Rect2()
var _pointer: Vector2 = Vector2.ZERO
var _dragging: bool = false

@onready var _highlights: Control = $Highlights
@onready var _book: Control = $Book
@onready var _title: Label = $Title
@onready var _play_text: Label = $Book/PlayPage/Rows/Text
@onready var _bind_text: Label = $Book/BindPage/Rows/Text
@onready var _cost: Label = $Book/Spine/Cost
@onready var _hint: Label = $Hint
@onready var _message: Label = $Message
@onready var _ghost: CardView = $Ghost
@onready var _ghost_label: Label = $GhostLabel

func _ready() -> void:
  mouse_filter = Control.MOUSE_FILTER_STOP
  for child: Node in get_children():
    _ignore_mouse_recursive(child)
  _recognizer.configure(settings)
  _ghost.settings = settings
  _highlights.draw.connect(_on_highlights_draw)
  _set_drag_visuals(false)

func open(card: Variant, page: Variant, message: String) -> void:
  _phase = CardInteractionModel.Phase.SPREAD
  _hovered = {}
  _pending_rect = Rect2()
  _dragging = false
  _press_on_book = false
  _recognizer.cancel()
  _title.text = String(page.name) if page != null else String(card.page_id)
  _play_text.text = String(page.play_text) if page != null else ""
  _bind_text.text = String(page.bind_text) if page != null else ""
  _cost.text = str(int(card.cost))
  _message.text = message
  _message.visible = message != ""
  _hint.text = HINT_OPEN
  _ghost.set_card(card, page, -1)
  _book.visible = true
  _book.modulate = Color.WHITE
  _set_drag_visuals(false)
  visible = true
  _highlights.queue_redraw()

## Shows a refusal in the spread's own message row (between title and pages).
func show_message(text: String) -> void:
  _message.text = text
  _message.visible = text != ""

func close() -> void:
  visible = false
  _phase = CardInteractionModel.Phase.IDLE
  _zones.clear()
  _hovered = {}
  _dragging = false
  _recognizer.cancel()
  _set_drag_visuals(false)

## zones: [{kind: Zone, index: int, rect: Rect2 (canvas), active: bool}].
func set_zones(zones: Array[Dictionary], phase: int, hovered: Dictionary) -> void:
  _zones = zones
  _hovered = hovered
  if phase != _phase:
    _phase = phase
    match phase:
      CardInteractionModel.Phase.DRAG_PLAY:
        _hint.text = HINT_PLAY
        _ghost_label.text = GHOST_PLAY_LABEL
      CardInteractionModel.Phase.DRAG_BIND:
        _hint.text = HINT_BIND
        _ghost_label.text = GHOST_BIND_LABEL
      CardInteractionModel.Phase.SPREAD:
        _hint.text = HINT_OPEN
        _ghost_label.text = ""
  _highlights.queue_redraw()

func set_pointer(global_position: Vector2) -> void:
  _pointer = global_position
  if _dragging:
    _place_ghost_at(_pointer, settings.drag_ghost_scale if settings != null else 1.0)

## Starts the drag visuals (ghost card follows the finger, book fades).
func begin_drag() -> void:
  if _dragging or not _book.visible:
    return
  _dragging = true
  _set_drag_visuals(true)

func enter_bind_pending(slot_rect: Rect2) -> void:
  _phase = CardInteractionModel.Phase.BIND_PENDING
  _pending_rect = slot_rect
  _dragging = false
  _book.visible = false
  _hint.text = HINT_PENDING
  _ghost.visible = true
  _ghost_label.visible = false
  var fit: float = minf(slot_rect.size.x / _ghost.size.x, slot_rect.size.y / _ghost.size.y) * PENDING_GHOST_FIT
  _place_ghost_at(slot_rect.get_center(), fit)
  _highlights.queue_redraw()

func is_bind_pending() -> bool:
  return _phase == CardInteractionModel.Phase.BIND_PENDING

func book_center() -> Vector2:
  return _book.get_global_rect().get_center()

func _gui_input(event: InputEvent) -> void:
  var now: float = _now()
  if event is InputEventMouseButton:
    var button_event: InputEventMouseButton = event
    if button_event.button_index != MOUSE_BUTTON_LEFT:
      return
    accept_event()
    if button_event.pressed:
      _recognizer.press(button_event.global_position, now)
      _press_on_book = _book.visible and _book.get_global_rect().has_point(button_event.global_position)
      return
    var gesture: int = _recognizer.release(button_event.global_position, now)
    match gesture:
      CardGestureRecognizer.Gesture.TAP:
        tapped_at.emit(button_event.global_position)
      CardGestureRecognizer.Gesture.DRAG_END:
        if _dragging:
          _dragging = false
          drag_released.emit(button_event.global_position, _recognizer.drag_delta().x)
    return
  if event is InputEventMouseMotion:
    var motion_event: InputEventMouseMotion = event
    var gesture: int = _recognizer.move(motion_event.global_position, now)
    if gesture == CardGestureRecognizer.Gesture.DRAG_START and _press_on_book:
      begin_drag()
    if _dragging and (gesture == CardGestureRecognizer.Gesture.DRAG_START or gesture == CardGestureRecognizer.Gesture.DRAG_MOVE):
      set_pointer(motion_event.global_position)
      drag_moved.emit(motion_event.global_position, _recognizer.drag_delta().x)

func _process(_delta: float) -> void:
  if visible:
    _highlights.queue_redraw()

func _set_drag_visuals(dragging: bool) -> void:
  _ghost.visible = dragging
  _ghost_label.visible = dragging
  if _book.visible:
    _book.modulate = Color(1, 1, 1, BOOK_DRAG_ALPHA) if dragging else Color.WHITE

func _place_ghost_at(global_center: Vector2, ghost_scale: float) -> void:
  _ghost.scale = Vector2.ONE * ghost_scale
  var local_center: Vector2 = get_global_transform().affine_inverse() * global_center
  _ghost.position = local_center - _ghost.size * ghost_scale * 0.5
  _ghost_label.position = Vector2(local_center.x - _ghost_label.size.x * 0.5, _ghost.position.y - _ghost_label.size.y)

func _on_highlights_draw() -> void:
  if settings == null:
    return
  var to_local: Transform2D = _highlights.get_global_transform().affine_inverse()
  var border: float = settings.highlight_border_px
  if _phase == CardInteractionModel.Phase.BIND_PENDING:
    var rect: Rect2 = to_local * _pending_rect
    var color: Color = settings.bind_highlight_color
    _highlights.draw_rect(rect, Color(color, PENDING_FILL_ALPHA), true)
    _highlights.draw_rect(rect, color, false, border)
    var font: Font = get_theme_default_font()
    var font_size: int = get_theme_default_font_size()
    var text_size: Vector2 = font.get_string_size(PENDING_SLOT_LABEL, HORIZONTAL_ALIGNMENT_CENTER, -1.0, font_size)
    var text_pos: Vector2 = Vector2(rect.get_center().x - text_size.x * 0.5, rect.position.y - border - text_size.y * 0.3)
    _highlights.draw_string(font, text_pos, PENDING_SLOT_LABEL, HORIZONTAL_ALIGNMENT_CENTER, -1.0, font_size, color)
    return
  for zone: Dictionary in _zones:
    if not bool(zone.get("active", false)):
      continue
    var kind: int = int(zone.get("kind", CardInteractionModel.Zone.NONE))
    var is_bind_zone: bool = kind == CardInteractionModel.Zone.SLOT
    if _phase == CardInteractionModel.Phase.DRAG_PLAY and is_bind_zone:
      continue
    if _phase == CardInteractionModel.Phase.DRAG_BIND and not is_bind_zone:
      continue
    var color: Color = settings.bind_highlight_color if is_bind_zone else settings.play_highlight_color
    var rect: Rect2 = to_local * Rect2(zone.get("rect", Rect2()))
    var strong: bool = _phase == CardInteractionModel.Phase.DRAG_PLAY or _phase == CardInteractionModel.Phase.DRAG_BIND
    var is_hovered: bool = strong and not _hovered.is_empty() \
      and int(_hovered.get("kind", -1)) == kind and int(_hovered.get("index", -2)) == int(zone.get("index", -3))
    if is_hovered:
      _highlights.draw_rect(rect, Color(color, settings.hover_fill_alpha), true)
    elif strong:
      _highlights.draw_rect(rect, Color(color, ACTIVE_FILL_ALPHA), true)
    var border_color: Color = color if strong else Color(color, settings.idle_highlight_alpha)
    _highlights.draw_rect(rect, border_color, false, border)

func _ignore_mouse_recursive(node: Node) -> void:
  if node is Control:
    var control: Control = node
    control.mouse_filter = Control.MOUSE_FILTER_IGNORE
  for child: Node in node.get_children():
    _ignore_mouse_recursive(child)

func _now() -> float:
  return float(Time.get_ticks_msec()) * 0.001
