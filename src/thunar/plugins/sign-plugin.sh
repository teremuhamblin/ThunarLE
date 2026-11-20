#!/usr/bin/env bash
set -euo pipefail

PLUGIN_DIR="${1:-}"
MANIFEST="${PLUGIN_DIR}/plugin.manifest.json"
[ ! -f "$MANIFEST" ] && { echo "Usage: $0 <chemin/vers/plugin>"; exit 1; }

ENTRY_REL="$(jq -r '.entry' "$MANIFEST")"
NEW_SHA="$(sha256sum "${PLUGIN_DIR}/${ENTRY_REL}" | awk '{print $1}')"

TMP_FILE="$(mktemp)"
jq --arg sha "$NEW_SHA" '.sha256 = $sha' "$MANIFEST" > "$TMP_FILE"
mv "$TMP_FILE" "$MANIFEST"

echo "🔐 Manifeste scellé : $MANIFEST (sha256=$NEW_SHA)"
