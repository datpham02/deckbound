extends "res://tests/framework/test_case.gd"

func test() -> void:
  assert_equal(1, 2, "Intentional failure fixture for exit-code proof.")
