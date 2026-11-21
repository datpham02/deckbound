class_name GameDataCatalog
extends RefCounted

const RUN_RULES_DATA_SCRIPT := preload("res://scripts/data/run_rules_data.gd")

var pages: Array = []
var enemies: Array = []
var run_rules: RefCounted = RUN_RULES_DATA_SCRIPT.new()
var errors: Array[String] = []

func has_errors() -> bool:
  return not errors.is_empty()
