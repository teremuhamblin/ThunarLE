#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CERT_DIR="${BASE_DIR}/logs/certs"
LOG_FILE="${BASE_DIR}/logs/thunar-xfce.log"
PASSES="${OPSEC_WIPE_PASSES:-3}"

mkdir -p "$CERT_DIR" "$(dirname "$LOG_FILE")"

TARGET="${1:-}"
FORCE="${2:-}"

[ -z "$TARGET" ] || [ ! -f "$TARGET" ] && { echo "❌ Cible invalide (fichier régulier requis)." >&2; exit 1; }

REAL_TARGET="$(realpath "$TARGET")"
case "$REAL_TARGET" in
    /|/bin/*|/boot/*|/dev/*|/etc/*|/lib*|/proc/*|/root|/sbin/*|/sys/*|/usr/*|"$HOME")
        echo "🛑 [OPSEC GUARD] Chemin système protégé refusé : $REAL_TARGET" >&2
        exit 2
        ;;
esac

if [ "$FORCE" != "--force" ]; then
    read -r -p "⚠️ Destruction irréversible ($PASSES passes) de '$REAL_TARGET' ? [oui/NON] : " CONFIRM
    [ "$CONFIRM" != "oui" ] && { echo "Annulé."; exit 0; }
fi

PRE_HASH="$(sha256sum "$REAL_TARGET" | awk '{print $1}')"
FILE_SIZE="$(stat -c%s "$REAL_TARGET")"
TIMESTAMP="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
CERT_ID="wipe-$(date -u +"%Y%m%d-%H%M%S")-$$"
CERT_FILE="${CERT_DIR}/${CERT_ID}.cert.json"

shred -u -z -n "$PASSES" "$REAL_TARGET"

cat > "$CERT_FILE" << EOF
{
  "certificate_id": "${CERT_ID}",
  "timestamp_utc": "${TIMESTAMP}",
  "operator": "${USER:-unknown}",
  "host": "$(hostname)",
  "target_path": "${REAL_TARGET}",
  "size_bytes": ${FILE_SIZE},
  "pre_wipe_sha256": "${PRE_HASH}",
  "method": "shred -u -z -n ${PASSES}",
  "status": "DESTROYED_VERIFIED"
}
EOF

printf '[%s] [OPSEC-WIPE] %s détruit | Certificat: %s\n' "$TIMESTAMP" "$REAL_TARGET" "$CERT_FILE" >> "$LOG_FILE"
echo "✅ Fichier détruit. Certificat généré : $CERT_FILE"
