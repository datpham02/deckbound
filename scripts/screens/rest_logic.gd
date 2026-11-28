class_name RestLogic
extends RefCounted
## Pure rest rules (concept AC5 / E5): unbind one bound page so it returns to the
## deck and its slot frees, or skip. Works directly on RunState.bindings, a list
## of {slot_index, page_id, status} that may omit empty slots.

const RUN_STATE_SCRIPT := preload("res://scripts/run/run_state.gd")

## One entry per slot in [0, slot_count), filled from RunState.bindings.
static func slot_entries(run_state: Variant, slot_count: int) -> Array[Dictionary]:
  var entries: Array[Dictionary] = []
  for slot_index: int in range(maxi(0, slot_count)):
    entries.append(_empty_entry(slot_index))
  if run_state == null:
    return entries
  for binding_variant: Variant in run_state.bindings:
    if typeof(binding_variant) != TYPE_DICTIONARY:
      continue
    var binding: Dictionary = binding_variant
    var slot_index: int = int(binding.get("slot_index", -1))
    if slot_index < 0 or slot_index >= entries.size():
      continue
    entries[slot_index] = {
      "slot_index": slot_index,
      "page_id": String(binding.get("page_id", "")),
      "status": String(binding.get("status", RUN_STATE_SCRIPT.BINDING_STATUS_EMPTY))
    }
  return entries

## A slot can be unbound when it holds a page that is intact or frayed. A severed
## binding is gone from the run (E3) and an empty slot holds nothing.
static func can_unbind(run_state: Variant, slot_index: int) -> bool:
  var binding: Dictionary = _find_binding(run_state, slot_index)
  if binding.is_empty():
    return false
  if String(binding.get("page_id", "")) == "":
    return false
  var status: String = String(binding.get("status", ""))
  return status == RUN_STATE_SCRIPT.BINDING_STATUS_INTACT or status == RUN_STATE_SCRIPT.BINDING_STATUS_FRAYED

static func unbindable_slot_indices(run_state: Variant, slot_count: int) -> Array[int]:
  var indices: Array[int] = []
  for slot_index: int in range(maxi(0, slot_count)):
    if can_unbind(run_state, slot_index):
      indices.append(slot_index)
  return indices

## Returns the page in `slot_index` to the deck and empties the slot.
## Result: {ok, slot_index, page_id} or {ok: false, error}.
static func unbind(run_state: Variant, slot_index: int) -> Dictionary:
  if run_state == null:
    return _failure("Cannot unbind without a run state.")
  if not can_unbind(run_state, slot_index):
    return _failure("Slot %d holds no page that can be unbound." % (slot_index + 1))

  var binding: Dictionary = _find_binding(run_state, slot_index)
  var page_id: String = String(binding["page_id"])
  binding["page_id"] = ""
  binding["status"] = RUN_STATE_SCRIPT.BINDING_STATUS_EMPTY
  run_state.deck.append(page_id)
  return {
    "ok": true,
    "slot_index": slot_index,
    "page_id": page_id
  }

static func _find_binding(run_state: Variant, slot_index: int) -> Dictionary:
  if run_state == null:
    return {}
  for binding_variant: Variant in run_state.bindings:
    if typeof(binding_variant) != TYPE_DICTIONARY:
      continue
    var binding: Dictionary = binding_variant
    if int(binding.get("slot_index", -1)) == slot_index:
      return binding
  return {}

static func _empty_entry(slot_index: int) -> Dictionary:
  return {
    "slot_index": slot_index,
    "page_id": "",
    "status": RUN_STATE_SCRIPT.BINDING_STATUS_EMPTY
  }

static func _failure(error_message: String) -> Dictionary:
  return {
    "ok": false,
    "error": error_message
  }
