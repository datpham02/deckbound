class_name RunState
extends RefCounted

const CURRENT_SCHEMA_VERSION: int = 1

const BINDING_STATUS_EMPTY: String = "empty"
const BINDING_STATUS_INTACT: String = "intact"
const BINDING_STATUS_FRAYED: String = "frayed"
const BINDING_STATUS_SEVERED: String = "severed"
const BINDING_STATUSES: PackedStringArray = [
  BINDING_STATUS_EMPTY,
  BINDING_STATUS_INTACT,
  BINDING_STATUS_FRAYED,
  BINDING_STATUS_SEVERED
]

var schema_version: int = CURRENT_SCHEMA_VERSION
var seed: int = 0
var health: int = 0
var deck: Array[String] = []
var bindings: Array[Dictionary] = []
var map_position: Dictionary = {
  "act_index": 0,
  "node_id": "start",
  "path": []
}

func to_dictionary() -> Dictionary:
  return {
    "schema_version": schema_version,
    "seed": seed,
    "health": health,
    "deck": deck.duplicate(),
    "bindings": bindings.duplicate(true),
    "map_position": map_position.duplicate(true)
  }
