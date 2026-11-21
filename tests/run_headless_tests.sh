#!/usr/bin/env bash
set -euo pipefail

godot_bin="${GODOT_BIN:-godot}"
log_file="$(mktemp)"
"$godot_bin" --headless --path . --scene res://tests/test_runner.tscn -- "$@" 2>&1 | tee "$log_file"

if grep -q "Result: FAILED" "$log_file"; then
  rm -f "$log_file"
  exit 1
fi

rm -f "$log_file"
