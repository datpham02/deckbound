class_name ScreenData
extends RefCounted
## What the rest and reward screens read from data/ through the T3 loader: the
## page library keyed by id, the run rules, and the reward offer count.

const DATA_LOADER_SCRIPT := preload("res://scripts/data/data_loader.gd")

const PAGES_DIR: String = "res://data/pages"
const RULES_FILE: String = "res://data/run/rules.json"
const REWARD_OFFER_COUNT_KEY: String = "reward_offer_count"
## docs/design/pages.md §6: the reward offers three distinct pool pages. Applies
## only while data/run/rules.json carries no `reward_offer_count` key (data/ is
## outside T15's write set; T19's tuning sheet may add the key without a code change).
const DEFAULT_REWARD_OFFER_COUNT: int = 3

static func load_page_library(errors: Array[String]) -> Dictionary:
  var library: Dictionary = {}
  var pages: Array = DATA_LOADER_SCRIPT.load_pages(PAGES_DIR, errors)
  for page: Variant in pages:
    library[String(page.id)] = page
  return library

static func load_run_rules(errors: Array[String]) -> Variant:
  return DATA_LOADER_SCRIPT.load_run_rules_file(RULES_FILE, errors)

## Reads the optional integer `reward_offer_count` (>= 1) from the run rules file.
static func read_reward_offer_count(rules_path: String = RULES_FILE) -> int:
  if not FileAccess.file_exists(rules_path):
    return DEFAULT_REWARD_OFFER_COUNT
  var file: FileAccess = FileAccess.open(rules_path, FileAccess.READ)
  if file == null:
    return DEFAULT_REWARD_OFFER_COUNT
  var parser: JSON = JSON.new()
  if parser.parse(file.get_as_text()) != OK:
    return DEFAULT_REWARD_OFFER_COUNT
  if typeof(parser.data) != TYPE_DICTIONARY:
    return DEFAULT_REWARD_OFFER_COUNT
  var root: Dictionary = parser.data
  if not root.has(REWARD_OFFER_COUNT_KEY):
    return DEFAULT_REWARD_OFFER_COUNT
  var value: Variant = root[REWARD_OFFER_COUNT_KEY]
  if typeof(value) != TYPE_INT and typeof(value) != TYPE_FLOAT:
    push_warning("%s :: $.%s :: Expected int, got %s." % [rules_path, REWARD_OFFER_COUNT_KEY, type_string(typeof(value))])
    return DEFAULT_REWARD_OFFER_COUNT
  var count: int = int(round(float(value)))
  if count < 1:
    push_warning("%s :: $.%s :: Expected >= 1, got %d." % [rules_path, REWARD_OFFER_COUNT_KEY, count])
    return DEFAULT_REWARD_OFFER_COUNT
  return count
