extends Node

const DEFAULT_SCENE_PATH: String = "res://scenes/main/main.tscn"
const DEFAULT_SIZES_CSV: String = "1920x1080,2400x1080,2640x1080"
const OUTPUT_DIR_RELATIVE: String = ".godot/qa"
const FRAME_WAIT_COUNT: int = 2
const EXIT_SUCCESS: int = 0
const EXIT_FAILURE: int = 1

var _reference_viewport_size: Vector2i = Vector2i.ZERO

func _ready() -> void:
  _reference_viewport_size = Vector2i(
    int(ProjectSettings.get_setting("display/window/size/viewport_width")),
    int(ProjectSettings.get_setting("display/window/size/viewport_height"))
  )

  var run_error: String = await _run_capture()
  if run_error.is_empty():
    get_tree().quit(EXIT_SUCCESS)
    return

  printerr("QA screenshot capture failed: %s" % run_error)
  get_tree().quit(EXIT_FAILURE)

func _run_capture() -> String:
  if _reference_viewport_size.x <= 0 or _reference_viewport_size.y <= 0:
    return "Project viewport size must be positive in project settings."

  var user_args: PackedStringArray = OS.get_cmdline_user_args()
  if user_args.size() > 2:
    return "Expected at most 2 user args: [scene_path] [WxH,WxH,...]."

  var scene_path: String = DEFAULT_SCENE_PATH
  var sizes_csv: String = DEFAULT_SIZES_CSV
  if user_args.size() >= 1 and not user_args[0].strip_edges().is_empty():
    scene_path = user_args[0].strip_edges()
  if user_args.size() >= 2 and not user_args[1].strip_edges().is_empty():
    sizes_csv = user_args[1].strip_edges()

  if not ResourceLoader.exists(scene_path):
    return "Missing scene: %s" % scene_path

  var scene_resource: Resource = load(scene_path)
  var target_scene: PackedScene = scene_resource as PackedScene
  if target_scene == null:
    return "Scene is not a PackedScene: %s" % scene_path

  var target_sizes: Array[Vector2i] = []
  var parse_error: String = _parse_sizes(sizes_csv, target_sizes)
  if not parse_error.is_empty():
    return parse_error

  var output_dir_absolute: String = ProjectSettings.globalize_path("res://%s" % OUTPUT_DIR_RELATIVE)
  var make_dir_error: Error = DirAccess.make_dir_recursive_absolute(output_dir_absolute)
  if make_dir_error != OK:
    return "Failed to create output directory `%s`: %s" % [OUTPUT_DIR_RELATIVE, error_string(make_dir_error)]

  var scene_name: String = scene_path.get_file().get_basename()
  for target_size: Vector2i in target_sizes:
    var capture_error: String = await _capture_scene_size(target_scene, scene_name, target_size, output_dir_absolute)
    if not capture_error.is_empty():
      return capture_error

  return ""

func _parse_sizes(sizes_csv: String, out_sizes: Array[Vector2i]) -> String:
  out_sizes.clear()
  var entries: PackedStringArray = sizes_csv.split(",", true)
  if entries.is_empty():
    return "No sizes provided. Expected `WxH,WxH,...`."

  for entry: String in entries:
    var trimmed_entry: String = entry.strip_edges()
    if trimmed_entry.is_empty():
      return "Malformed sizes list `%s`: empty size entry." % sizes_csv

    var dimensions: PackedStringArray = trimmed_entry.split("x", false, 2)
    if dimensions.size() != 2:
      return "Malformed size `%s`: expected `WxH`." % trimmed_entry

    var width_text: String = dimensions[0]
    var height_text: String = dimensions[1]
    if not width_text.is_valid_int() or not height_text.is_valid_int():
      return "Malformed size `%s`: width and height must be integers." % trimmed_entry

    var width: int = width_text.to_int()
    var height: int = height_text.to_int()
    if width <= 0 or height <= 0:
      return "Malformed size `%s`: width and height must be greater than zero." % trimmed_entry

    out_sizes.append(Vector2i(width, height))

  return ""

func _capture_scene_size(target_scene: PackedScene, scene_name: String, target_size: Vector2i, output_dir_absolute: String) -> String:
  var simulated_canvas_size: Vector2i = _compute_canvas_size_for_expand(target_size)

  var capture_viewport: SubViewport = SubViewport.new()
  capture_viewport.name = "QaCaptureViewport"
  capture_viewport.disable_3d = true
  capture_viewport.size = simulated_canvas_size
  capture_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
  add_child(capture_viewport)

  var scene_instance: Node = target_scene.instantiate()
  capture_viewport.add_child(scene_instance)

  for _frame_index in FRAME_WAIT_COUNT:
    await get_tree().process_frame
    await RenderingServer.frame_post_draw

  var image: Image = capture_viewport.get_texture().get_image()
  remove_child(capture_viewport)
  capture_viewport.queue_free()

  if image == null or image.is_empty():
    return "Failed to read rendered image for %dx%d." % [target_size.x, target_size.y]

  if simulated_canvas_size != target_size:
    image.resize(target_size.x, target_size.y, Image.INTERPOLATE_LANCZOS)

  if image.get_width() != target_size.x or image.get_height() != target_size.y:
    return "Rendered image size mismatch for %dx%d (got %dx%d)." % [
      target_size.x,
      target_size.y,
      image.get_width(),
      image.get_height()
    ]

  var output_filename: String = "%s-%dx%d.png" % [scene_name, target_size.x, target_size.y]
  var output_path_absolute: String = output_dir_absolute.path_join(output_filename)
  var output_path_relative: String = OUTPUT_DIR_RELATIVE.path_join(output_filename)

  var save_error: Error = image.save_png(output_path_absolute)
  if save_error != OK:
    return "Failed to save screenshot `%s`: %s" % [output_path_relative, error_string(save_error)]

  print("Saved screenshot: %s" % output_path_relative)
  return ""

func _compute_canvas_size_for_expand(target_size: Vector2i) -> Vector2i:
  var width_ratio: float = float(target_size.x) / float(_reference_viewport_size.x)
  var height_ratio: float = float(target_size.y) / float(_reference_viewport_size.y)
  var stretch_scale: float = min(width_ratio, height_ratio)
  if stretch_scale <= 0.0:
    return target_size

  var canvas_width: int = int(round(float(target_size.x) / stretch_scale))
  var canvas_height: int = int(round(float(target_size.y) / stretch_scale))
  return Vector2i(max(canvas_width, 1), max(canvas_height, 1))
