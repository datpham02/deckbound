class_name RewardLogic
extends RefCounted
## Pure reward rules (docs/design/pages.md §6): offer distinct pages from the
## pool (`pool: true` in data/pages/) at equal weight, or take none. The offer is
## seeded from the run and the map position so a reward resumed after a kill
## (E8) shows the same three pages. Duplicates of pages already owned may be
## offered; the pool never offers a page marked `pool: false`.

## Pool pages in id order, so the seeded pick does not depend on load order.
static func pool_pages(pages: Array) -> Array:
  var pool: Array = []
  for page: Variant in pages:
    if page != null and bool(page.pool):
      pool.append(page)
  pool.sort_custom(func(left: Variant, right: Variant) -> bool: return String(left.id) < String(right.id))
  return pool

## Deterministic seed for this reward: run seed, current node and path length.
static func offer_seed(run_state: Variant) -> int:
  if run_state == null:
    return 0
  var map_position: Dictionary = run_state.map_position
  var node_id: String = String(map_position.get("node_id", ""))
  var path_size: int = 0
  var path_variant: Variant = map_position.get("path", [])
  if typeof(path_variant) == TYPE_ARRAY:
    var path: Array = path_variant
    path_size = path.size()
  return hash("%d|%s|%d" % [int(run_state.seed), node_id, path_size])

## Up to `offer_count` distinct pool pages, equal weight, from `seed`.
static func build_offer(pages: Array, offer_count: int, seed: int) -> Array:
  var remaining: Array = pool_pages(pages)
  var offer: Array = []
  var rng: RandomNumberGenerator = RandomNumberGenerator.new()
  rng.seed = seed
  while offer.size() < offer_count and not remaining.is_empty():
    var index: int = rng.randi_range(0, remaining.size() - 1)
    offer.append(remaining[index])
    remaining.remove_at(index)
  return offer

static func offer_page_ids(offer: Array) -> Array[String]:
  var ids: Array[String] = []
  for page: Variant in offer:
    if page != null:
      ids.append(String(page.id))
  return ids

## Adds the chosen page to the run deck. Result: {ok, page_id} or {ok: false, error}.
static func take(run_state: Variant, page_id: String, offer: Array) -> Dictionary:
  if run_state == null:
    return _failure("Cannot take a page without a run state.")
  if page_id.strip_edges() == "":
    return _failure("Cannot take a page with an empty id.")
  if not offer_page_ids(offer).has(page_id):
    return _failure("Page '%s' is not part of this offer." % page_id)
  run_state.deck.append(page_id)
  return {
    "ok": true,
    "page_id": page_id
  }

static func _failure(error_message: String) -> Dictionary:
  return {
    "ok": false,
    "error": error_message
  }
