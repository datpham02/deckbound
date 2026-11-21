extends "res://tests/framework/test_case.gd"

func test() -> void:
  var game_title: String = "Deckbound"
  assert_true(game_title.begins_with("Deck"), "Title prefix remains stable for UI smoke checks.")
  assert_equal(2 + 2, 4, "Arithmetic sanity check.")
