extends Node

const TEST_CASES_DIR: String = "res://tests/cases"
const DEFAULT_TEST_SUFFIX: String = "_test.gd"
var _argument_error: String = ""

func _ready() -> void:
  var explicit_case_paths: Array[String] = _parse_explicit_case_paths(OS.get_cmdline_user_args())
  if _argument_error != "":
    printerr(_argument_error)
    printerr("Result: FAILED (invalid arguments).")
    _finish(1)
    return
  var test_case_paths: Array[String] = _discover_default_test_case_paths()

  for case_path: String in explicit_case_paths:
    if not test_case_paths.has(case_path):
      test_case_paths.append(case_path)

  test_case_paths.sort()

  if test_case_paths.is_empty():
    printerr("No test cases found.")
    printerr("Result: FAILED (no test cases found).")
    _finish(1)
    return

  var failures: Array[String] = []
  var passed_count: int = 0

  for test_case_path: String in test_case_paths:
    var case_failures: Array[String] = _run_case(test_case_path)
    if case_failures.is_empty():
      passed_count += 1
      print("PASS %s" % test_case_path)
      continue

    printerr("FAIL %s" % test_case_path)
    for case_failure: String in case_failures:
      failures.append("%s :: %s" % [test_case_path, case_failure])

  if failures.is_empty():
    print("All tests passed (%d case(s))." % passed_count)
    _finish(0)
    return

  printerr("")
  printerr("Test failures:")
  for failure: String in failures:
    printerr("- %s" % failure)
  printerr("Result: FAILED (%d failure(s) across %d case(s))." % [failures.size(), test_case_paths.size()])
  _finish(1)

func _finish(exit_code: int) -> void:
  if OS.has_method("set_exit_code"):
    OS.call("set_exit_code", exit_code)
  get_tree().quit(exit_code)

func _parse_explicit_case_paths(args: PackedStringArray) -> Array[String]:
  var paths: Array[String] = []
  var index: int = 0

  while index < args.size():
    var arg: String = args[index]

    if arg == "--case":
      if index + 1 >= args.size():
        _argument_error = "Flag --case requires a value."
        return []
      paths.append(args[index + 1])
      index += 2
      continue

    if arg.begins_with("--case="):
      paths.append(arg.trim_prefix("--case="))

    index += 1

  return paths

func _discover_default_test_case_paths() -> Array[String]:
  var paths: Array[String] = []
  var directory: DirAccess = DirAccess.open(TEST_CASES_DIR)

  if directory == null:
    return paths

  directory.list_dir_begin()
  var entry: String = directory.get_next()

  while entry != "":
    if not directory.current_is_dir() and entry.ends_with(DEFAULT_TEST_SUFFIX):
      paths.append("%s/%s" % [TEST_CASES_DIR, entry])
    entry = directory.get_next()

  directory.list_dir_end()
  return paths

func _run_case(test_case_path: String) -> Array[String]:
  var failures: Array[String] = []
  var script_resource: Script = load(test_case_path) as Script

  if script_resource == null:
    failures.append("Could not load script.")
    return failures

  if not script_resource.can_instantiate():
    failures.append("Script has parse errors or cannot be instantiated.")
    return failures

  var instance: Object = script_resource.new()
  if instance == null:
    failures.append("Could not instantiate script.")
    return failures

  if not instance.has_method("run"):
    failures.append("Missing run() method.")
    return failures

  var run_result: Variant = instance.call("run")
  if typeof(run_result) != TYPE_ARRAY:
    failures.append("run() must return Array[String].")
    return failures

  var run_failures: Array = run_result
  for run_failure: Variant in run_failures:
    failures.append(str(run_failure))

  return failures
