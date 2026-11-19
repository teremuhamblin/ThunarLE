#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONF_FILE="${BASE_DIR}/config/overwatch.conf"
LOG_FILE="${BASE_DIR}/logs/overwatch-daemon.log"
STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/thunar-overwatch-${UID}"
STATE_FILE="${STATE_DIR}/status.env"

mkdir -p "$(dirname "$LOG_FILE")" "$STATE_DIR"

# Valeurs par défaut puis chargement config
WATCH_DIRS="${HOME}/Downloads"
AUTO_HASH_NEW_FILES=true
SUSPICIOUS_EXTENSIONS="exe|bat|cmd|scr|vbs|js|ps1"
QUARANTINE_DIR="${HOME}/.local/share/thunar-xfce/quarantine"
[ -f "$CONF_FILE" ] && source "$CONF_FILE"

mkdir -p "$QUARANTINE_DIR"

if ! command -v inotifywait >/dev/null 2>&1; then
    echo "❌ 'inotifywait' manquant (paquet inotify-tools)." >&2
    exit 1
fi

EVENTS_COUNT=0
ALERTS_COUNT=0

update_state() {
    cat > "$STATE_FILE" << EOF
STATUS="ACTIVE"
PID="$$"
EVENTS="${EVENTS_COUNT}"
ALERTS="${ALERTS_COUNT}"
LAST_EVENT="${1:-none}"
UPDATED_AT="$(date -u +"%H:%M:%S")"
EOF
}

cleanup() {
    echo "STATUS=\"STOPPED\"" > "$STATE_FILE"
    exit 0
}
trap cleanup SIGINT SIGTERM

# Construction de la liste des répertoires existants
IFS=':' read -r -a CANDIDATE_DIRS <<< "$WATCH_DIRS"
ACTIVE_DIRS=()
for d in "${CANDIDATE_DIRS[@]}"; do
    [ -d "$d" ] && ACTIVE_DIRS+=("$d")
done

[ "${#ACTIVE_DIRS[@]}" -eq 0 ] && { echo "❌ Aucun dossier valide à surveiller." >&2; exit 1; }

update_state "daemon_started"
printf '[%s] [OVERWATCH] Démarrage surveillance sur : %s\n' "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" "${ACTIVE_DIRS[*]}" >> "$LOG_FILE"

inotifywait -m -r -q -e close_write,moved_to --format '%w%f' "${ACTIVE_DIRS[@]}" | while IFS= read -r filepath; do
    [ -f "$filepath" ] || continue
    EVENTS_COUNT=$((EVENTS_COUNT + 1))

    filename="$(basename "$filepath")"
    ext="${filename##*.}"
    ext_lower="$(printf '%s' "$ext" | tr '[:upper:]' '[:lower:]')"

    hash_val="skipped"
    if [ "$AUTO_HASH_NEW_FILES" = true ]; then
        hash_val="$(sha256sum "$filepath" 2>/dev/null | awk '{print $1}' || echo "err")"
    fi

    if printf '%s' "$ext_lower" | grep -Eq "^(${SUSPICIOUS_EXTENSIONS})$"; then
        ALERTS_COUNT=$((ALERTS_COUNT + 1))
        printf '[%s] [ALERTE] Extension sensible détectée : %s (sha256=%s)\n' \
            "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" "$filepath" "$hash_val" >> "$LOG_FILE"
        command -v notify-send >/dev/null 2>&1 && \
            notify-send -u critical "🛡️ Overwatch Alerte" "Fichier sensible détecté : $filename" || true
    else
        printf '[%s] [INFO] Fichier indexé : %s (sha256=%s)\n' \
            "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" "$filepath" "$hash_val" >> "$LOG_FILE"
    fi

    update_state "$filename"
done
