extends "res://tests/framework/test_case.gd"

const FLOOR_MAP_SCENE_PATH: String = "res://scenes/map/map.tscn"
const FLOOR_MAP_SCENE_SCRIPT_PATH: String = "res://scripts/map/floor_map_scene.gd"

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
      map_instance.free()
