class_name PageData
extends RefCounted

var id: String = ""
var name: String = ""
var cost: int = 0
var compact_play_line: String = ""
var compact_bind_line: String = ""
var play_text: String = ""
var bind_text: String = ""
var target: String = "none"
var pool: bool = false
var play_effects: Array[Dictionary] = []
var bind_passives: Array[Dictionary] = []
