class_name TestCase
extends RefCounted

var _failures: Array[String] = []

func run() -> Array[String]:
  _failures.clear()
  test()
  var result: Array[String] = []
  for failure: String in _failures:
    result.append(failure)
  return result

func test() -> void:
  _record_failure("Missing test() implementation.")

func assert_true(condition: bool, message: String = "") -> void:
  if condition:
    return
  var details: String = "Expected condition to be true."
  if message != "":
    details = "%s (%s)" % [details, message]
  _record_failure(details)

func assert_equal(actual: Variant, expected: Variant, message: String = "") -> void:
  if actual == expected:
    return
  var details: String = "Expected <%s>, got <%s>." % [str(expected), str(actual)]
  if message != "":
    details = "%s (%s)" % [details, message]
  _record_failure(details)

func _record_failure(message: String) -> void:
  _failures.append(message)
