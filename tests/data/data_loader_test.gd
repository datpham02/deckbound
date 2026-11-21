extends "res://tests/framework/test_case.gd"

const DATA_LOADER := preload("res://scripts/data/data_loader.gd")

func test() -> void:
  _test_load_all_success()
  _test_missing_field_error_contains_file_and_field()
  _test_unknown_effect_error_contains_file_and_field()
  _test_wrong_type_error_contains_file_and_field()

func _test_load_all_success() -> void:
  var root: String = _create_fixture_root("success")
  _write_json(
    "%s/pages/nib_cut.json" % root,
    {
      "id": "nib_cut",
      "name": "Nib Cut",
      "cost": 1,
      "compact": {
        "play": "Deal 6",
        "bind": "Strikes deal 1 more"
      },
      "play_effects": [
        {"id": "damage", "params": {"amount": 6, "target": "enemy"}}
      ],
      "bind_passives": [
        {"id": "played_damage_bonus", "params": {"amount": 1}}
      ]
    }
  )
  _write_json(
    "%s/enemies/bailiff.json" % root,
    {
      "id": "bailiff",
      "name": "Bailiff",
      "stats": {"health": 26},
      "actions": [
        {"id": "rap", "type": "attack", "value": 5},
        {"id": "brace", "type": "guard", "value": 7}
      ],
      "telegraph_pattern": ["rap", "brace"]
    }
  )
  _write_json(
    "%s/run/rules.json" % root,
    {
      "schema_version": 1,
      "hero_health": 50,
      "ink_per_turn": 3,
      "hand_draw": 5,
      "hand_max": 8,
      "bind_slots": 3,
      "deck_floor": 5,
      "blot_persists_after_combat": true
    }
  )

  var catalog: Variant = DATA_LOADER.load_all(root)
  assert_true(not catalog.has_errors(), "Expected valid fixture to load cleanly: %s" % str(catalog.errors))
  assert_equal(catalog.pages.size(), 1, "Expected one page.")
  assert_equal(catalog.enemies.size(), 1, "Expected one enemy.")
  assert_equal(catalog.run_rules.deck_floor, 5, "Expected rules value from JSON.")

func _test_missing_field_error_contains_file_and_field() -> void:
  var root: String = _create_fixture_root("missing_field")
  var file_path: String = "%s/pages/missing_name.json" % root
  _write_json(
    file_path,
    {
      "id": "missing_name",
      "cost": 1,
      "compact": {
        "play": "Deal 1",
        "bind": "None"
      },
      "play_effects": [{"id": "damage"}],
      "bind_passives": [{"id": "none"}]
    }
  )

  var errors: Array[String] = []
  var page: Variant = DATA_LOADER.load_page_file(file_path, errors)
  assert_true(page == null, "Invalid page should not load.")
  assert_true(_array_contains_substring(errors, file_path), "Error should contain file path.")
  assert_true(_array_contains_substring(errors, "$.name"), "Error should contain missing field path.")

func _test_unknown_effect_error_contains_file_and_field() -> void:
  var root: String = _create_fixture_root("unknown_effect")
  var file_path: String = "%s/pages/unknown_effect.json" % root
  _write_json(
    file_path,
    {
      "id": "unknown_effect",
      "name": "Unknown Effect",
      "cost": 1,
      "compact": {
        "play": "Mystery",
        "bind": "None"
      },
      "play_effects": [{"id": "totally_not_real"}],
      "bind_passives": [{"id": "none"}]
    }
  )

  var errors: Array[String] = []
  var page: Variant = DATA_LOADER.load_page_file(file_path, errors)
  assert_true(page == null, "Page with unknown effect id should fail.")
  assert_true(_array_contains_substring(errors, "$.play_effects[0].id"), "Error should point at effect id path.")
  assert_true(_array_contains_substring(errors, "Unknown play effect id"), "Error should explain unknown effect id.")

func _test_wrong_type_error_contains_file_and_field() -> void:
  var root: String = _create_fixture_root("wrong_type")
  var file_path: String = "%s/run/rules.json" % root
  _write_json(
    file_path,
    {
      "schema_version": 1,
      "hero_health": 50,
      "ink_per_turn": 3,
      "hand_draw": 5,
      "hand_max": 8,
      "bind_slots": 3,
      "deck_floor": "five",
      "blot_persists_after_combat": true
    }
  )

  var errors: Array[String] = []
  var rules: Variant = DATA_LOADER.load_run_rules_file(file_path, errors)
  assert_true(rules == null, "Rules with wrong type should fail.")
  assert_true(_array_contains_substring(errors, file_path), "Error should contain file path.")
  assert_true(_array_contains_substring(errors, "$.deck_floor"), "Error should contain deck_floor field path.")
  assert_true(_array_contains_substring(errors, "Expected int"), "Error should report type mismatch.")

func _create_fixture_root(tag: String) -> String:
  var root: String = "user://tests/data/%s_%d" % [tag, Time.get_ticks_usec()]
  var pages_dir_abs: String = ProjectSettings.globalize_path("%s/pages" % root)
  var enemies_dir_abs: String = ProjectSettings.globalize_path("%s/enemies" % root)
  var run_dir_abs: String = ProjectSettings.globalize_path("%s/run" % root)
  var pages_dir_error: int = DirAccess.make_dir_recursive_absolute(pages_dir_abs)
  var enemies_dir_error: int = DirAccess.make_dir_recursive_absolute(enemies_dir_abs)
  var run_dir_error: int = DirAccess.make_dir_recursive_absolute(run_dir_abs)
  assert_equal(pages_dir_error, OK, "Could not create pages fixture directory.")
  assert_equal(enemies_dir_error, OK, "Could not create enemies fixture directory.")
  assert_equal(run_dir_error, OK, "Could not create run fixture directory.")
  return root

func _write_json(path: String, payload: Variant) -> void:
  var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
  assert_true(file != null, "Could not open fixture file: %s" % path)
  if file == null:
    return
  file.store_string(JSON.stringify(payload))

func _array_contains_substring(values: Array[String], target: String) -> bool:
  for value: String in values:
    if value.find(target) != -1:
      return true
  return false
