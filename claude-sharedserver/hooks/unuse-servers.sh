#!/usr/bin/env bash
# SessionEnd hook: for each entry in the user's sharedserver config,
# run `sharedserver unuse <name> --pid $PPID`. Fast and best-effort —
# if it fails or never runs, sharedserver's dead-client poller will
# reap the refcount within ~5s.

set -u

config="${CLAUDE_SHAREDSERVER_CONFIG:-$HOME/.config/claude/sharedserver.json}"
[[ ! -f "$config" ]] && exit 0

ss_bin="${CLAUDE_PLUGIN_ROOT}/bin/sharedserver"

if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi
if ! command -v envsubst >/dev/null 2>&1; then
  exit 0
fi

while IFS= read -r name; do
  [[ -z "$name" ]] && continue
  "$ss_bin" unuse "$name" --pid "$PPID" >/dev/null 2>&1 || true
done < <(envsubst <"$config" | jq -r '.servers // {} | keys[]')

exit 0
