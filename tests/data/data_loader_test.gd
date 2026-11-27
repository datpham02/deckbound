extends "res://tests/framework/test_case.gd"

const DATA_LOADER := preload("res://scripts/data/data_loader.gd")

func test() -> void:
  _test_load_all_success()
  _test_missing_field_error_contains_file_and_field()
  _test_unknown_effect_error_contains_file_and_field()
  _test_wrong_type_error_contains_file_and_field()
  _test_invalid_page_target_error_contains_file_and_field()
  _test_enemy_hits_accepts_integer_valued_json_numbers()
  _test_fray_action_without_fallback_error_contains_file_and_field()
  _test_unknown_telegraph_reference_error_contains_file_and_field()
  _test_invalid_enemy_size_class_error_contains_file_and_field()
  _test_starting_deck_unknown_page_id_error_contains_file_and_field()

func _test_load_all_success() -> void:
  var root: String = _create_fixture_root("success")
  _write_json("%s/pages/nib_cut.json" % root, _create_valid_page_payload("nib_cut", "Nib Cut"))
  _write_json("%s/enemies/bailiff.json" % root, _create_valid_enemy_payload("bailiff", "Bailiff"))
  _write_json("%s/run/rules.json" % root, _create_valid_rules_payload(["nib_cut"]))

  var catalog: Variant = DATA_LOADER.load_all(root)
  assert_true(not catalog.has_errors(), "Expected valid fixture to load cleanly: %s" % str(catalog.errors))
  assert_equal(catalog.pages.size(), 1, "Expected one page.")
  assert_equal(catalog.enemies.size(), 1, "Expected one enemy.")
  assert_equal(catalog.run_rules.deck_floor, 5, "Expected rules value from JSON.")
  assert_equal(catalog.run_rules.starting_deck.size(), 1, "Expected starting deck to load.")
  assert_true(catalog.run_rules.stains_persist_after_combat, "Expected stains persistence flag from JSON.")

func _test_missing_field_error_contains_file_and_field() -> void:
  var root: String = _create_fixture_root("missing_field")
  var file_path: String = "%s/pages/missing_name.json" % root
  var payload: Dictionary = _create_valid_page_payload("missing_name", "Missing Name")
  payload.erase("name")
  _write_json(file_path, payload)

  var errors: Array[String] = []
  var page: Variant = DATA_LOADER.load_page_file(file_path, errors)
  assert_true(page == null, "Invalid page should not load.")
  assert_true(_array_contains_substring(errors, file_path), "Error should contain file path.")
  assert_true(_array_contains_substring(errors, "$.name"), "Error should contain missing field path.")

func _test_unknown_effect_error_contains_file_and_field() -> void:
  var root: String = _create_fixture_root("unknown_effect")
  var file_path: String = "%s/pages/unknown_effect.json" % root
  var payload: Dictionary = _create_valid_page_payload("unknown_effect", "Unknown Effect")
  payload["play_effects"] = [{"id": "totally_not_real"}]
  _write_json(file_path, payload)

  var errors: Array[String] = []
  var page: Variant = DATA_LOADER.load_page_file(file_path, errors)
  assert_true(page == null, "Page with unknown effect id should fail.")
  assert_true(_array_contains_substring(errors, "$.play_effects[0].id"), "Error should point at effect id path.")
  assert_true(_array_contains_substring(errors, "Unknown play effect id"), "Error should explain unknown effect id.")

func _test_wrong_type_error_contains_file_and_field() -> void:
  var root: String = _create_fixture_root("wrong_type")
  var file_path: String = "%s/run/rules.json" % root
  var payload: Dictionary = _create_valid_rules_payload(["nib_cut"])
  payload["deck_floor"] = "five"
  _write_json(file_path, payload)

  var errors: Array[String] = []
  var rules: Variant = DATA_LOADER.load_run_rules_file(file_path, errors)
  assert_true(rules == null, "Rules with wrong type should fail.")
  assert_true(_array_contains_substring(errors, file_path), "Error should contain file path.")
  assert_true(_array_contains_substring(errors, "$.deck_floor"), "Error should contain deck_floor field path.")
  assert_true(_array_contains_substring(errors, "Expected int"), "Error should report type mismatch.")

func _test_invalid_page_target_error_contains_file_and_field() -> void:
  var root: String = _create_fixture_root("invalid_target")
  var file_path: String = "%s/pages/invalid_target.json" % root
  var payload: Dictionary = _create_valid_page_payload("invalid_target", "Invalid Target")
  payload["target"] = "ally"
  _write_json(file_path, payload)

  var errors: Array[String] = []
  var page: Variant = DATA_LOADER.load_page_file(file_path, errors)
  assert_true(page == null, "Page with invalid target should fail.")
  assert_true(_array_contains_substring(errors, "$.target"), "Error should include target field path.")
  assert_true(_array_contains_substring(errors, "Unknown target"), "Error should explain invalid target enum.")

func _test_enemy_hits_accepts_integer_valued_json_numbers() -> void:
  var root: String = _create_fixture_root("enemy_hits_float_json_number")
  var file_path: String = "%s/enemies/registrar.json" % root
  var payload: Dictionary = _create_valid_enemy_payload("registrar", "Registrar")
  payload["actions"] = [
    {"id": "double_rap", "type": "attack", "value": 3, "hits": 2},
    {
      "id": "fray_press",
      "type": "fray",
      "value": 1,
      "fallback": {"type": "attack", "value": 4, "hits": 2}
    }
  ]
  payload["telegraph_pattern"] = ["double_rap", "fray_press"]
  _write_json(file_path, payload)

  var errors: Array[String] = []
  var enemy: Variant = DATA_LOADER.load_enemy_file(file_path, errors)
  assert_true(enemy != null, "Enemy with integer-valued hits should load.")
  assert_equal(errors.size(), 0, "Expected no errors for integer-valued hits JSON numbers.")
  assert_equal(typeof(enemy.actions[0]["hits"]), TYPE_INT, "Action hits should be stored as an int.")
  assert_equal(enemy.actions[0]["hits"], 2, "Expected attack action to keep hits.")
  assert_equal(typeof(enemy.actions[1]["fallback"]["hits"]), TYPE_INT, "Fallback hits should be stored as an int.")
  assert_equal(enemy.actions[1]["fallback"]["hits"], 2, "Expected fallback action to keep hits.")

func _test_fray_action_without_fallback_error_contains_file_and_field() -> void:
  var root: String = _create_fixture_root("missing_fallback")
  var file_path: String = "%s/enemies/missing_fallback.json" % root
  var payload: Dictionary = _create_valid_enemy_payload("blotter", "Blotter")
  payload["actions"] = [{"id": "fray_now", "type": "fray", "value": 2}]
  payload["telegraph_pattern"] = ["fray_now"]
  _write_json(file_path, payload)

  var errors: Array[String] = []
  var enemy: Variant = DATA_LOADER.load_enemy_file(file_path, errors)
  assert_true(enemy == null, "Fray action without fallback should fail.")
  assert_true(_array_contains_substring(errors, "$.actions[0].fallback"), "Error should include fallback field path.")
  assert_true(_array_contains_substring(errors, "Missing required field"), "Error should explain missing fallback.")

func _test_unknown_telegraph_reference_error_contains_file_and_field() -> void:
  var root: String = _create_fixture_root("unknown_telegraph")
  var file_path: String = "%s/enemies/unknown_telegraph.json" % root
  var payload: Dictionary = _create_valid_enemy_payload("marginalia", "Marginalia")
  payload["telegraph_pattern"] = ["not_an_action"]
  _write_json(file_path, payload)

  var errors: Array[String] = []
  var enemy: Variant = DATA_LOADER.load_enemy_file(file_path, errors)
  assert_true(enemy == null, "Enemy with unknown telegraph reference should fail.")
  assert_true(_array_contains_substring(errors, "$.telegraph_pattern[0]"), "Error should include telegraph field path.")
  assert_true(_array_contains_substring(errors, "Unknown action reference"), "Error should explain unknown action id.")

func _test_invalid_enemy_size_class_error_contains_file_and_field() -> void:
  var root: String = _create_fixture_root("invalid_size_class")
  var file_path: String = "%s/enemies/invalid_size_class.json" % root
  var payload: Dictionary = _create_valid_enemy_payload("redactor", "Redactor")
  payload["size_class"] = "elite"
  _write_json(file_path, payload)

  var errors: Array[String] = []
  var enemy: Variant = DATA_LOADER.load_enemy_file(file_path, errors)
  assert_true(enemy == null, "Enemy with invalid size_class should fail.")
  assert_true(_array_contains_substring(errors, "$.size_class"), "Error should include size_class field path.")
  assert_true(_array_contains_substring(errors, "Unknown size_class"), "Error should explain invalid size class enum.")

func _test_starting_deck_unknown_page_id_error_contains_file_and_field() -> void:
  var root: String = _create_fixture_root("unknown_starting_deck_page")
  _write_json("%s/pages/nib_cut.json" % root, _create_valid_page_payload("nib_cut", "Nib Cut"))
  _write_json("%s/run/rules.json" % root, _create_valid_rules_payload(["ghost_page"]))

  var catalog: Variant = DATA_LOADER.load_all(root)
  assert_true(catalog.has_errors(), "Unknown starting deck page id should produce load errors.")
  assert_true(_array_contains_substring(catalog.errors, "$.starting_deck[0]"), "Error should include starting_deck index field path.")
  assert_true(_array_contains_substring(catalog.errors, "Unknown page id 'ghost_page'"), "Error should explain unknown page id.")

func _create_valid_page_payload(id: String, name: String) -> Dictionary:
  return {
    "id": id,
    "name": name,
    "cost": 1,
    "compact": {
      "play": "Deal 6",
      "bind": "Strike +1"
    },
    "play_text": "Deal 6 damage.",
    "bind_text": "Your strikes deal 1 more damage.",
    "target": "enemy",
    "pool": true,
    "play_effects": [
      {"id": "damage", "params": {"amount": 6, "target": "enemy"}}
    ],
    "bind_passives": [
      {"id": "played_damage_bonus", "params": {"amount": 1}}
    ]
  }

func _create_valid_enemy_payload(id: String, name: String) -> Dictionary:
  return {
    "id": id,
    "name": name,
    "size_class": "common",
    "stats": {"health": 26},
    "actions": [
      {"id": "rap", "type": "attack", "value": 5},
      {"id": "brace", "type": "guard", "value": 7}
    ],
    "telegraph_pattern": ["rap", "brace"]
  }

func _create_valid_rules_payload(starting_deck: Array[String]) -> Dictionary:
  return {
    "schema_version": 1,
    "hero_health": 80,
    "ink_per_turn": 3,
    "hand_draw": 5,
    "hand_max": 8,
    "bind_slots": 3,
    "deck_floor": 5,
    "starting_deck": starting_deck,
    "stains_persist_after_combat": true
  }

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
