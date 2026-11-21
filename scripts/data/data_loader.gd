class_name DataLoader
extends RefCounted

const PAGE_PLAY_EFFECT_IDS: PackedStringArray = [
  "damage",
  "damage_all",
  "guard",
  "draw",
  "ink",
  "heal",
  "lose_health",
  "add_page_to_discard",
  "remove_this_page",
  "remove_stains_hand_and_discard",
  "remove_stain_from_hand",
  "remove_enemy_guard",
  "damage_per_empty_slot",
  "damage_per_discard_page",
  "guard_per_binding"
]

const PAGE_BIND_PASSIVE_IDS: PackedStringArray = [
  "played_damage_bonus",
  "start_combat_guard",
  "turn_draw",
  "thorns",
  "turn_ink",
  "on_other_fray_next_turn_ink",
  "absorb_fray",
  "end_turn_damage_all",
  "after_win_remove_stains",
  "retain_highest_cost",
  "enemy_guard_reduction",
  "on_guard_gain_damage_all",
  "start_combat_damage_all",
  "after_win_heal",
  "on_other_fray_guard",
  "turn_guard_per_empty_slot",
  "on_reshuffle_guard",
  "on_stain_added_damage_all",
  "incoming_attack_reduction",
  "turn_draw_lose_health",
  "none"
]

const ENEMY_ACTION_TYPES: PackedStringArray = ["attack", "guard", "fray", "foul", "sever"]
const PAGE_TARGET_TYPES: PackedStringArray = ["enemy", "none"]
const ENEMY_SIZE_CLASSES: PackedStringArray = ["common", "warden", "boss"]

const GAME_DATA_CATALOG_SCRIPT := preload("res://scripts/data/game_data_catalog.gd")
const PAGE_DATA_SCRIPT := preload("res://scripts/data/page_data.gd")
const ENEMY_DATA_SCRIPT := preload("res://scripts/data/enemy_data.gd")
const RUN_RULES_DATA_SCRIPT := preload("res://scripts/data/run_rules_data.gd")

static func load_all(base_path: String = "res://data") -> Variant:
  var catalog: Variant = GAME_DATA_CATALOG_SCRIPT.new()
  catalog.pages = load_pages("%s/pages" % base_path, catalog.errors)
  catalog.enemies = load_enemies("%s/enemies" % base_path, catalog.errors)
  var run_rules_file_path: String = "%s/run/rules.json" % base_path
  var run_rules: Variant = load_run_rules_file(run_rules_file_path, catalog.errors)
  if run_rules != null:
    catalog.run_rules = run_rules
    var known_page_ids: Dictionary = {}
    for page_variant: Variant in catalog.pages:
      var page: Variant = page_variant
      if page.id != "":
        known_page_ids[page.id] = true

    for index: int in range(run_rules.starting_deck.size()):
      var page_id: String = run_rules.starting_deck[index]
      if not known_page_ids.has(page_id):
        _append_error(catalog.errors, run_rules_file_path, "$.starting_deck[%d]" % index, "Unknown page id '%s'." % page_id)
  return catalog

static func load_pages(directory_path: String, errors: Array[String]) -> Array:
  var pages: Array = []
  var file_paths: Array[String] = _list_json_files(directory_path, errors)
  for file_path: String in file_paths:
    var page: Variant = load_page_file(file_path, errors)
    if page != null:
      pages.append(page)
  return pages

static func load_enemies(directory_path: String, errors: Array[String]) -> Array:
  var enemies: Array = []
  var file_paths: Array[String] = _list_json_files(directory_path, errors)
  for file_path: String in file_paths:
    var enemy: Variant = load_enemy_file(file_path, errors)
    if enemy != null:
      enemies.append(enemy)
  return enemies

static func load_page_file(file_path: String, errors: Array[String]) -> Variant:
  var start_error_count: int = errors.size()
  var root_variant: Variant = _load_json_file(file_path, errors)
  if root_variant == null:
    return null
  if typeof(root_variant) != TYPE_DICTIONARY:
    _append_error(errors, file_path, "$", "Expected a JSON object.")
    return null

  var root: Dictionary = root_variant
  var page: Variant = PAGE_DATA_SCRIPT.new()
  page.id = _require_string(root, "id", file_path, "$.id", errors)
  page.name = _require_string(root, "name", file_path, "$.name", errors)
  page.cost = _require_int(root, "cost", file_path, "$.cost", errors)

  if page.cost < 0:
    _append_error(errors, file_path, "$.cost", "Expected cost >= 0.")

  if not root.has("compact"):
    _append_error(errors, file_path, "$.compact", "Missing required field.")
  else:
    var compact_variant: Variant = root["compact"]
    if typeof(compact_variant) != TYPE_DICTIONARY:
      _append_error(errors, file_path, "$.compact", "Expected Dictionary, got %s." % type_string(typeof(compact_variant)))
    else:
      var compact: Dictionary = compact_variant
      page.compact_play_line = _require_string(compact, "play", file_path, "$.compact.play", errors)
      page.compact_bind_line = _require_string(compact, "bind", file_path, "$.compact.bind", errors)

  page.play_text = _require_string(root, "play_text", file_path, "$.play_text", errors)
  page.bind_text = _require_string(root, "bind_text", file_path, "$.bind_text", errors)
  page.target = _require_string(root, "target", file_path, "$.target", errors)
  if page.target != "" and not PAGE_TARGET_TYPES.has(page.target):
    _append_error(errors, file_path, "$.target", "Unknown target '%s'." % page.target)
  page.pool = _require_bool(root, "pool", file_path, "$.pool", errors)

  if not root.has("play_effects"):
    _append_error(errors, file_path, "$.play_effects", "Missing required field.")
  else:
    var play_effects_variant: Variant = root["play_effects"]
    if typeof(play_effects_variant) != TYPE_ARRAY:
      _append_error(errors, file_path, "$.play_effects", "Expected Array, got %s." % type_string(typeof(play_effects_variant)))
    else:
      var play_effects_array: Array = play_effects_variant
      for index: int in range(play_effects_array.size()):
        var effect_variant: Variant = play_effects_array[index]
        var effect_path: String = "$.play_effects[%d]" % index
        if typeof(effect_variant) != TYPE_DICTIONARY:
          _append_error(errors, file_path, effect_path, "Expected Dictionary, got %s." % type_string(typeof(effect_variant)))
          continue

        var effect_data: Dictionary = effect_variant
        var effect_id: String = _require_string(effect_data, "id", file_path, "%s.id" % effect_path, errors)
        if effect_id != "" and not PAGE_PLAY_EFFECT_IDS.has(effect_id):
          _append_error(errors, file_path, "%s.id" % effect_path, "Unknown play effect id '%s'." % effect_id)
        if effect_data.has("params") and typeof(effect_data["params"]) != TYPE_DICTIONARY:
          _append_error(errors, file_path, "%s.params" % effect_path, "Expected Dictionary, got %s." % type_string(typeof(effect_data["params"])))
        page.play_effects.append(effect_data)

  if not root.has("bind_passives"):
    _append_error(errors, file_path, "$.bind_passives", "Missing required field.")
  else:
    var bind_passives_variant: Variant = root["bind_passives"]
    if typeof(bind_passives_variant) != TYPE_ARRAY:
      _append_error(errors, file_path, "$.bind_passives", "Expected Array, got %s." % type_string(typeof(bind_passives_variant)))
    else:
      var bind_passives_array: Array = bind_passives_variant
      for index: int in range(bind_passives_array.size()):
        var passive_variant: Variant = bind_passives_array[index]
        var passive_path: String = "$.bind_passives[%d]" % index
        if typeof(passive_variant) != TYPE_DICTIONARY:
          _append_error(errors, file_path, passive_path, "Expected Dictionary, got %s." % type_string(typeof(passive_variant)))
          continue

        var passive_data: Dictionary = passive_variant
        var passive_id: String = _require_string(passive_data, "id", file_path, "%s.id" % passive_path, errors)
        if passive_id != "" and not PAGE_BIND_PASSIVE_IDS.has(passive_id):
          _append_error(errors, file_path, "%s.id" % passive_path, "Unknown bind passive id '%s'." % passive_id)
        if passive_data.has("params") and typeof(passive_data["params"]) != TYPE_DICTIONARY:
          _append_error(errors, file_path, "%s.params" % passive_path, "Expected Dictionary, got %s." % type_string(typeof(passive_data["params"])))
        page.bind_passives.append(passive_data)

  if errors.size() > start_error_count:
    return null
  return page

static func load_enemy_file(file_path: String, errors: Array[String]) -> Variant:
  var start_error_count: int = errors.size()
  var root_variant: Variant = _load_json_file(file_path, errors)
  if root_variant == null:
    return null
  if typeof(root_variant) != TYPE_DICTIONARY:
    _append_error(errors, file_path, "$", "Expected a JSON object.")
    return null

  var root: Dictionary = root_variant
  var enemy: Variant = ENEMY_DATA_SCRIPT.new()
  enemy.id = _require_string(root, "id", file_path, "$.id", errors)
  enemy.name = _require_string(root, "name", file_path, "$.name", errors)
  enemy.size_class = _require_string(root, "size_class", file_path, "$.size_class", errors)
  if enemy.size_class != "" and not ENEMY_SIZE_CLASSES.has(enemy.size_class):
    _append_error(errors, file_path, "$.size_class", "Unknown size_class '%s'." % enemy.size_class)

  if not root.has("stats"):
    _append_error(errors, file_path, "$.stats", "Missing required field.")
  else:
    var stats_variant: Variant = root["stats"]
    if typeof(stats_variant) != TYPE_DICTIONARY:
      _append_error(errors, file_path, "$.stats", "Expected Dictionary, got %s." % type_string(typeof(stats_variant)))
    else:
      var stats: Dictionary = stats_variant
      enemy.health = _require_int(stats, "health", file_path, "$.stats.health", errors)
      if enemy.health <= 0:
        _append_error(errors, file_path, "$.stats.health", "Expected health > 0.")

  var action_ids: Dictionary = {}
  if not root.has("actions"):
    _append_error(errors, file_path, "$.actions", "Missing required field.")
  else:
    var actions_variant: Variant = root["actions"]
    if typeof(actions_variant) != TYPE_ARRAY:
      _append_error(errors, file_path, "$.actions", "Expected Array, got %s." % type_string(typeof(actions_variant)))
    else:
      var actions_array: Array = actions_variant
      for index: int in range(actions_array.size()):
        var action_variant: Variant = actions_array[index]
        var action_path: String = "$.actions[%d]" % index
        if typeof(action_variant) != TYPE_DICTIONARY:
          _append_error(errors, file_path, action_path, "Expected Dictionary, got %s." % type_string(typeof(action_variant)))
          continue

        var action_data: Dictionary = action_variant
        var action_id: String = _require_string(action_data, "id", file_path, "%s.id" % action_path, errors)
        if action_id != "":
          if action_ids.has(action_id):
            _append_error(errors, file_path, "%s.id" % action_path, "Duplicate action id '%s'." % action_id)
          else:
            action_ids[action_id] = true

        var action_type: String = _require_string(action_data, "type", file_path, "%s.type" % action_path, errors)
        if action_type != "" and not ENEMY_ACTION_TYPES.has(action_type):
          _append_error(errors, file_path, "%s.type" % action_path, "Unknown enemy action type '%s'." % action_type)

        var action_value: int = _require_int(action_data, "value", file_path, "%s.value" % action_path, errors)
        if action_value < 0:
          _append_error(errors, file_path, "%s.value" % action_path, "Expected value >= 0." )

        if action_data.has("hits"):
          var hits_variant: Variant = action_data["hits"]
          if typeof(hits_variant) != TYPE_INT:
            _append_error(errors, file_path, "%s.hits" % action_path, "Expected int, got %s." % type_string(typeof(hits_variant)))
          elif int(hits_variant) <= 0:
            _append_error(errors, file_path, "%s.hits" % action_path, "Expected hits > 0.")

        if action_type == "fray" or action_type == "sever":
          if not action_data.has("fallback"):
            _append_error(errors, file_path, "%s.fallback" % action_path, "Missing required field.")
          else:
            var fallback_variant: Variant = action_data["fallback"]
            if typeof(fallback_variant) != TYPE_DICTIONARY:
              _append_error(errors, file_path, "%s.fallback" % action_path, "Expected Dictionary, got %s." % type_string(typeof(fallback_variant)))
            else:
              var fallback_data: Dictionary = fallback_variant
              var fallback_type: String = _require_string(fallback_data, "type", file_path, "%s.fallback.type" % action_path, errors)
              if fallback_type != "" and fallback_type != "attack":
                _append_error(errors, file_path, "%s.fallback.type" % action_path, "Expected 'attack', got '%s'." % fallback_type)
              var fallback_value: int = _require_int(fallback_data, "value", file_path, "%s.fallback.value" % action_path, errors)
              if fallback_value < 0:
                _append_error(errors, file_path, "%s.fallback.value" % action_path, "Expected value >= 0.")
              if fallback_data.has("hits"):
                var fallback_hits_variant: Variant = fallback_data["hits"]
                if typeof(fallback_hits_variant) != TYPE_INT:
                  _append_error(errors, file_path, "%s.fallback.hits" % action_path, "Expected int, got %s." % type_string(typeof(fallback_hits_variant)))
                elif int(fallback_hits_variant) <= 0:
                  _append_error(errors, file_path, "%s.fallback.hits" % action_path, "Expected hits > 0.")
        enemy.actions.append(action_data)

  if not root.has("telegraph_pattern"):
    _append_error(errors, file_path, "$.telegraph_pattern", "Missing required field.")
  else:
    enemy.telegraph_pattern = _validate_telegraph_pattern(root["telegraph_pattern"], action_ids, file_path, "$.telegraph_pattern", errors)

  if root.has("phases"):
    var phases_variant: Variant = root["phases"]
    if typeof(phases_variant) != TYPE_ARRAY:
      _append_error(errors, file_path, "$.phases", "Expected Array, got %s." % type_string(typeof(phases_variant)))
    else:
      var phases_array: Array = phases_variant
      for index: int in range(phases_array.size()):
        var phase_variant: Variant = phases_array[index]
        var phase_path: String = "$.phases[%d]" % index
        if typeof(phase_variant) != TYPE_DICTIONARY:
          _append_error(errors, file_path, phase_path, "Expected Dictionary, got %s." % type_string(typeof(phase_variant)))
          continue

        var phase_data: Dictionary = phase_variant
        var health_at_or_below: int = _require_int(phase_data, "health_at_or_below", file_path, "%s.health_at_or_below" % phase_path, errors)
        if health_at_or_below <= 0:
          _append_error(errors, file_path, "%s.health_at_or_below" % phase_path, "Expected health_at_or_below > 0.")

        if not phase_data.has("telegraph_pattern"):
          _append_error(errors, file_path, "%s.telegraph_pattern" % phase_path, "Missing required field.")
        else:
          _validate_telegraph_pattern(phase_data["telegraph_pattern"], action_ids, file_path, "%s.telegraph_pattern" % phase_path, errors)

        enemy.phases.append(phase_data)

  if errors.size() > start_error_count:
    return null
  return enemy

static func load_run_rules_file(file_path: String, errors: Array[String]) -> Variant:
  var start_error_count: int = errors.size()
  var root_variant: Variant = _load_json_file(file_path, errors)
  if root_variant == null:
    return null
  if typeof(root_variant) != TYPE_DICTIONARY:
    _append_error(errors, file_path, "$", "Expected a JSON object.")
    return null

  var root: Dictionary = root_variant
  var run_rules: Variant = RUN_RULES_DATA_SCRIPT.new()
  run_rules.schema_version = _require_int(root, "schema_version", file_path, "$.schema_version", errors)
  run_rules.hero_health = _require_int(root, "hero_health", file_path, "$.hero_health", errors)
  run_rules.ink_per_turn = _require_int(root, "ink_per_turn", file_path, "$.ink_per_turn", errors)
  run_rules.hand_draw = _require_int(root, "hand_draw", file_path, "$.hand_draw", errors)
  run_rules.hand_max = _require_int(root, "hand_max", file_path, "$.hand_max", errors)
  run_rules.bind_slots = _require_int(root, "bind_slots", file_path, "$.bind_slots", errors)
  run_rules.deck_floor = _require_int(root, "deck_floor", file_path, "$.deck_floor", errors)
  run_rules.starting_deck = _require_string_array(root, "starting_deck", file_path, "$.starting_deck", errors)
  run_rules.stains_persist_after_combat = _require_bool(root, "stains_persist_after_combat", file_path, "$.stains_persist_after_combat", errors)

  if run_rules.schema_version < 1:
    _append_error(errors, file_path, "$.schema_version", "Expected schema_version >= 1.")
  if run_rules.hero_health <= 0:
    _append_error(errors, file_path, "$.hero_health", "Expected hero_health > 0.")
  if run_rules.ink_per_turn < 0:
    _append_error(errors, file_path, "$.ink_per_turn", "Expected ink_per_turn >= 0.")
  if run_rules.hand_draw <= 0:
    _append_error(errors, file_path, "$.hand_draw", "Expected hand_draw > 0.")
  if run_rules.hand_max <= 0:
    _append_error(errors, file_path, "$.hand_max", "Expected hand_max > 0.")
  if run_rules.hand_max < run_rules.hand_draw:
    _append_error(errors, file_path, "$.hand_max", "Expected hand_max >= hand_draw.")
  if run_rules.bind_slots <= 0:
    _append_error(errors, file_path, "$.bind_slots", "Expected bind_slots > 0.")
  if run_rules.deck_floor < 0:
    _append_error(errors, file_path, "$.deck_floor", "Expected deck_floor >= 0.")
  if run_rules.starting_deck.is_empty():
    _append_error(errors, file_path, "$.starting_deck", "Expected at least one page id.")

  if errors.size() > start_error_count:
    return null
  return run_rules

static func _list_json_files(directory_path: String, errors: Array[String]) -> Array[String]:
  var file_paths: Array[String] = []
  var directory: DirAccess = DirAccess.open(directory_path)
  if directory == null:
    _append_error(errors, directory_path, "$", "Missing directory.")
    return file_paths

  directory.list_dir_begin()
  var entry: String = directory.get_next()
  while entry != "":
    if not directory.current_is_dir() and entry.ends_with(".json"):
      file_paths.append("%s/%s" % [directory_path, entry])
    entry = directory.get_next()
  directory.list_dir_end()

  file_paths.sort()
  return file_paths

static func _load_json_file(file_path: String, errors: Array[String]) -> Variant:
  if not FileAccess.file_exists(file_path):
    _append_error(errors, file_path, "$", "Missing file.")
    return null

  var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
  if file == null:
    _append_error(errors, file_path, "$", "Could not open file for reading.")
    return null

  var json_text: String = file.get_as_text()
  var json_parser: JSON = JSON.new()
  var parse_status: int = json_parser.parse(json_text)
  if parse_status != OK:
    _append_error(
      errors,
      file_path,
      "$",
      "Invalid JSON at line %d: %s." % [json_parser.get_error_line(), json_parser.get_error_message()]
    )
    return null

  return json_parser.data

static func _require_string(data: Dictionary, key: String, file_path: String, field_path: String, errors: Array[String]) -> String:
  if not data.has(key):
    _append_error(errors, file_path, field_path, "Missing required field.")
    return ""

  var value: Variant = data[key]
  if typeof(value) != TYPE_STRING:
    _append_error(errors, file_path, field_path, "Expected String, got %s." % type_string(typeof(value)))
    return ""

  var string_value: String = value
  if string_value.strip_edges() == "":
    _append_error(errors, file_path, field_path, "Expected a non-empty string.")
  return string_value

static func _require_int(data: Dictionary, key: String, file_path: String, field_path: String, errors: Array[String]) -> int:
  if not data.has(key):
    _append_error(errors, file_path, field_path, "Missing required field.")
    return 0

  var value: Variant = data[key]
  if typeof(value) == TYPE_INT:
    return int(value)
  if typeof(value) == TYPE_FLOAT:
    var float_value: float = value
    if is_equal_approx(float_value, round(float_value)):
      return int(round(float_value))
    _append_error(errors, file_path, field_path, "Expected int, got non-integer float.")
    return 0

  _append_error(errors, file_path, field_path, "Expected int, got %s." % type_string(typeof(value)))
  return 0

static func _require_bool(data: Dictionary, key: String, file_path: String, field_path: String, errors: Array[String]) -> bool:
  if not data.has(key):
    _append_error(errors, file_path, field_path, "Missing required field.")
    return false

  var value: Variant = data[key]
  if typeof(value) != TYPE_BOOL:
    _append_error(errors, file_path, field_path, "Expected bool, got %s." % type_string(typeof(value)))
    return false
  return bool(value)

static func _require_string_array(data: Dictionary, key: String, file_path: String, field_path: String, errors: Array[String]) -> Array[String]:
  if not data.has(key):
    _append_error(errors, file_path, field_path, "Missing required field.")
    return []

  var value: Variant = data[key]
  if typeof(value) != TYPE_ARRAY:
    _append_error(errors, file_path, field_path, "Expected Array, got %s." % type_string(typeof(value)))
    return []

  var values: Array[String] = []
  var array_value: Array = value
  for index: int in range(array_value.size()):
    var item_variant: Variant = array_value[index]
    var item_path: String = "%s[%d]" % [field_path, index]
    if typeof(item_variant) != TYPE_STRING:
      _append_error(errors, file_path, item_path, "Expected String, got %s." % type_string(typeof(item_variant)))
      continue

    var item: String = item_variant
    if item.strip_edges() == "":
      _append_error(errors, file_path, item_path, "Expected a non-empty string.")
      continue

    values.append(item)

  return values

static func _validate_telegraph_pattern(pattern_variant: Variant, action_ids: Dictionary, file_path: String, field_path: String, errors: Array[String]) -> Array[String]:
  var pattern: Array[String] = []
  if typeof(pattern_variant) != TYPE_ARRAY:
    _append_error(errors, file_path, field_path, "Expected Array, got %s." % type_string(typeof(pattern_variant)))
    return pattern

  var pattern_array: Array = pattern_variant
  for index: int in range(pattern_array.size()):
    var pattern_step_variant: Variant = pattern_array[index]
    var pattern_path: String = "%s[%d]" % [field_path, index]
    if typeof(pattern_step_variant) != TYPE_STRING:
      _append_error(errors, file_path, pattern_path, "Expected String, got %s." % type_string(typeof(pattern_step_variant)))
      continue

    var pattern_step: String = pattern_step_variant
    pattern.append(pattern_step)
    if not action_ids.has(pattern_step):
      _append_error(errors, file_path, pattern_path, "Unknown action reference '%s'." % pattern_step)

  return pattern

static func _append_error(errors: Array[String], file_path: String, field_path: String, reason: String) -> void:
  errors.append("%s :: %s :: %s" % [file_path, field_path, reason])
