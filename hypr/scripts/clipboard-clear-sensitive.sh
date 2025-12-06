#!/usr/bin/env bash
set -euo pipefail

# Clear potentially sensitive items from clipboard history
# Patterns: passwords, tokens, API keys, credit cards, etc.

count=0

# Get last 100 items, filter for sensitive patterns
while IFS= read -r line; do
  if echo "$line" | grep -qiE '(password|token|api[_-]?key|secret|bearer|authorization|auth|card.*number|ssn|social.*security)'; then
    cliphist delete-query "$line"
    ((count++))
  fi
done < <(cliphist list | head -100)

if [ $count -eq 0 ]; then
  notify-send "Clipboard" "No sensitive items found"
else
  notify-send "Clipboard" "Cleared $count sensitive item(s)"
fi
