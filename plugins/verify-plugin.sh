#!/usr/bin/env bash
set -euo pipefail

PLUGIN_DIR="${1:-}"
MANIFEST="${PLUGIN_DIR}/plugin.manifest.json"
ALLOW_NETWORK="${THUNAR_PLUGIN_ALLOW_NETWORK:-false}"
ALLOW_PKEXEC="${THUNAR_PLUGIN_ALLOW_PKEXEC:-false}"

[ ! -d "$PLUGIN_DIR" ] && { echo "❌ Dossier plugin invalide : $PLUGIN_DIR" >&2; exit 1; }

if [ ! -f "$MANIFEST" ]; then
    echo "⚠️  Aucun plugin.manifest.json dans $(basename "$PLUGIN_DIR") (mode legacy v2)." >&2
    exit 2
fi

if ! command -v jq >/dev/null 2>&1; then
    echo "❌ 'jq' requis pour vérifier les manifestes JSON v3.0." >&2
    exit 1
fi

PLUGIN_ID="$(jq -r '.id // empty' "$MANIFEST")"
ENTRY_REL="$(jq -r '.entry // empty' "$MANIFEST")"
EXPECTED_SHA="$(jq -r '.sha256 // empty' "$MANIFEST")"
PERM_NET="$(jq -r '.permissions.network // false' "$MANIFEST")"
PERM_PKEXEC="$(jq -r '.permissions.pkexec // false' "$MANIFEST")"

ENTRY_PATH="${PLUGIN_DIR}/${ENTRY_REL}"
[ ! -f "$ENTRY_PATH" ] && { echo "❌ Point d'entrée introuvable : $ENTRY_PATH" >&2; exit 1; }

ACTUAL_SHA="$(sha256sum "$ENTRY_PATH" | awk '{print $1}')"

if [ "$ACTUAL_SHA" != "$EXPECTED_SHA" ]; then
    echo "🛑 [INTÉGRITÉ ÉCHOUÉE] Plugin '$PLUGIN_ID' bloqué !" >&2
    echo "   Attendu : $EXPECTED_SHA" >&2
    echo "   Calculé : $ACTUAL_SHA" >&2
    exit 3
fi

if [ "$PERM_NET" = "true" ] && [ "$ALLOW_NETWORK" != "true" ]; then
    echo "🛑 [OPSEC] Plugin '$PLUGIN_ID' requiert 'network' (refusé par la politique)." >&2
    exit 4
fi

if [ "$PERM_PKEXEC" = "true" ] && [ "$ALLOW_PKEXEC" != "true" ]; then
    echo "🛑 [OPSEC] Plugin '$PLUGIN_ID' requiert 'pkexec' (refusé par la politique)." >&2
    exit 4
fi

echo "✅ Plugin '$PLUGIN_ID' vérifié (SHA-256 OK, permissions conformes)."
