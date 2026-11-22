extends "res://tests/framework/test_case.gd"

const FLOOR_MAP_SCENE_PATH: String = "res://scenes/map/map.tscn"
const FLOOR_MAP_SCENE_SCRIPT_PATH: String = "res://scripts/map/floor_map_scene.gd"
const FLOOR_MAP_LOADER_SCRIPT := preload("res://scripts/map/floor_map_loader.gd")
const FLOOR_MAP_GENERATOR_SCRIPT := preload("res://scripts/map/floor_map_generator.gd")
const FLOOR_DATA_PATH: String = "res://data/run/floor.json"

func test() -> void:
  var scene_script: Script = load(FLOOR_MAP_SCENE_SCRIPT_PATH) as Script
  assert_true(scene_script != null, "Floor map scene script should load.")
  if scene_script != null:
    assert_true(scene_script.can_instantiate(), "Floor map scene script should compile and instantiate.")

  var map_scene: PackedScene = load(FLOOR_MAP_SCENE_PATH) as PackedScene
  assert_true(map_scene != null, "Floor map scene should load.")
  if map_scene != null:
    var map_instance: Node = map_scene.instantiate()
    assert_true(map_instance != null, "Floor map scene should instantiate.")
    if map_instance != null:
      _test_scene_uses_safe_area_margin(map_instance)
      map_instance.free()

  _test_button_layout_fits_supported_layer_sizes()

func _test_scene_uses_safe_area_margin(map_instance: Node) -> void:
  var safe_area: Node = map_instance.get_node_or_null("SafeArea")
  assert_true(safe_area != null, "Map scene should include a SafeArea node.")
  assert_true(safe_area is SafeAreaMargin, "SafeArea node should use SafeAreaMargin.")
  assert_true(map_instance.get_node_or_null("SafeArea/Layout/Header") != null, "Header should be inside SafeArea.")
  assert_true(map_instance.get_node_or_null("SafeArea/Layout/Status") != null, "Status should be inside SafeArea.")
  assert_true(map_instance.get_node_or_null("SafeArea/Layout/Nodes") != null, "Nodes layer should be inside SafeArea.")

func _test_button_layout_fits_supported_layer_sizes() -> void:
  var load_result: Dictionary = FLOOR_MAP_LOADER_SCRIPT.load_from_path(FLOOR_DATA_PATH)
  assert_true(bool(load_result.get("ok", false)), "Failed loading floor data fixture: %s" % str(load_result))
  if not bool(load_result.get("ok", false)):
    return

  var floor_data: Dictionary = load_result["floor_data"]
  var seeds: Array[int] = [1337, 404, 73]
  var layer_sizes: Array[Vector2] = [Vector2(1920, 1080), Vector2(2400, 1080), Vector2(2640, 1080)]

  for seed: int in seeds:
    var map_data: Dictionary = FLOOR_MAP_GENERATOR_SCRIPT.generate(floor_data, seed)
    var nodes: Array = map_data.get("nodes", [])
    for layer_size: Vector2 in layer_sizes:
      var layer_rect: Rect2 = Rect2(Vector2.ZERO, layer_size)
      var button_rects: Dictionary = FloorMapScene.compute_node_button_rects(map_data, layer_rect)
      assert_equal(
        button_rects.size(),
        nodes.size(),
        "Expected one button rect per node for seed %d and size %s." % [seed, str(layer_size)]
      )

      var node_ids: Array = button_rects.keys()
      for node_id_variant: Variant in node_ids:
        var node_id: String = String(node_id_variant)
        var button_rect: Rect2 = button_rects[node_id]
        assert_true(
          _rect_inside(layer_rect, button_rect),
          "Node %s should stay inside nodes layer for seed %d and size %s." % [node_id, seed, str(layer_size)]
        )
        assert_true(
          button_rect.size.x >= 128.0 and button_rect.size.y >= 128.0,
          "Node %s should keep touch target >= 128x128 for seed %d and size %s." % [node_id, seed, str(layer_size)]
        )

      for first_index: int in range(node_ids.size()):
        for second_index: int in range(first_index + 1, node_ids.size()):
          var first_id: String = String(node_ids[first_index])
          var second_id: String = String(node_ids[second_index])
          var first_rect: Rect2 = button_rects[first_id]
          var second_rect: Rect2 = button_rects[second_id]
          assert_true(
            not first_rect.intersects(second_rect),
            "Node rects should not overlap (%s vs %s) for seed %d and size %s." % [
              first_id,
              second_id,
              seed,
              str(layer_size)
            ]
          )

func _rect_inside(container_rect: Rect2, content_rect: Rect2) -> bool:
  var epsilon: float = 0.001
  return (
    content_rect.position.x >= container_rect.position.x - epsilon
    and content_rect.position.y >= container_rect.position.y - epsilon
    and content_rect.end.x <= container_rect.end.x + epsilon
    and content_rect.end.y <= container_rect.end.y + epsilon
  )
