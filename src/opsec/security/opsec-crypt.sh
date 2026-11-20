#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_FILE="${BASE_DIR}/logs/thunar-xfce.log"

log_opsec() {
    mkdir -p "$(dirname "$LOG_FILE")"
    printf '[%s] [OPSEC-CRYPT] %s\n' "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" "$1" >> "$LOG_FILE"
}

usage() {
    echo "Usage: $0 <encrypt|decrypt> <fichier>"
    exit 1
}

[ "$#" -lt 2 ] && usage
MODE="$1"
TARGET="$2"

[ ! -e "$TARGET" ] && { echo "❌ Fichier introuvable : $TARGET" >&2; exit 1; }

if command -v age >/dev/null 2>&1; then
    case "$MODE" in
        encrypt)
            OUT="${TARGET}.age"
            age -p -o "$OUT" "$TARGET"
            log_opsec "ENCRYPT (age) : $(basename "$TARGET") -> $(basename "$OUT")"
            ;;
        decrypt)
            OUT="${TARGET%.age}"
            [ "$OUT" = "$TARGET" ] && OUT="${TARGET}.decrypted"
            age -d -o "$OUT" "$TARGET"
            log_opsec "DECRYPT (age) : $(basename "$TARGET") -> $(basename "$OUT")"
            ;;
        *) usage ;;
    esac
elif command -v gpg >/dev/null 2>&1; then
    case "$MODE" in
        encrypt)
            OUT="${TARGET}.gpg"
            gpg --symmetric --cipher-algo AES256 --output "$OUT" "$TARGET"
            log_opsec "ENCRYPT (gpg-AES256) : $(basename "$TARGET") -> $(basename "$OUT")"
            ;;
        decrypt)
            OUT="${TARGET%.gpg}"
            [ "$OUT" = "$TARGET" ] && OUT="${TARGET}.decrypted"
            gpg --decrypt --output "$OUT" "$TARGET"
            log_opsec "DECRYPT (gpg) : $(basename "$TARGET") -> $(basename "$OUT")"
            ;;
        *) usage ;;
    esac
else
    echo "❌ Aucun moteur cryptographique trouvé (installez 'age' ou 'gnupg')." >&2
    exit 1
fi
