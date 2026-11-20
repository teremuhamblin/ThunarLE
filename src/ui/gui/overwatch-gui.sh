#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${BASE_DIR}/gui/wayland-compat.sh"

BACKEND="$(pick_dialog_backend)"
SESSION="$(detect_session_type)"
STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/thunar-overwatch-${UID}/status.env"

STATUS="INACTIF"; EVENTS="0"; ALERTS="0"
[ -f "$STATE_FILE" ] && source "$STATE_FILE"

if [ "$BACKEND" = "cli" ]; then
    exec bash "${BASE_DIR}/tui/menu.sh"
fi

CHOICE=""
if [ "$BACKEND" = "yad" ]; then
    CHOICE=$(yad --title="🟩 Thunar-xfce v3.0 Overwatch [$SESSION]" \
        --width=540 --height=360 --list --radiolist \
        --text="<b>Poste de Commandement Overwatch</b>\nDaemon: <b>$STATUS</b> | Événements: <b>$EVENTS</b> | Alertes: <b>$ALERTS</b>" \
        --column="Sel" --column="ID" --column="Module" --column="Description" \
        TRUE  "SYSTEMCHECK" "🩺 SystemCheck" "Vérifier dépendances, session et intégrité" \
        FALSE "PLUGINS"     "🧩 Plugins SHA-256" "Auditer les manifestes v3.0" \
        FALSE "DAEMON"      "📡 Overwatch Daemon" "Démarrer / Arrêter la surveillance inotify" \
        FALSE "ENCRYPT"     "🔐 OpSec Crypt" "Chiffrer un fichier (age / GPG)" \
        FALSE "WIPE"        "🔥 OpSec Wipe" "Destruction sécurisée + certificat" \
        FALSE "TUI"         "🕶️ Mode TUI" "Ouvrir Ghost Recon dans le terminal" \
        --print-column=2 --separator="" || true)
else
    CHOICE=$(zenity --list --title="🟩 Thunar-xfce v3.0 [$SESSION]" \
        --text="Daemon: $STATUS | Événements: $EVENTS | Alertes: $ALERTS" \
        --column="ID" --column="Action" \
        "SYSTEMCHECK" "🩺 SystemCheck Mode" \
        "PLUGINS"     "🧩 Audit Plugins SHA-256" \
        "DAEMON"      "📡 Basculer Overwatch Daemon" \
        "ENCRYPT"     "🔐 Chiffrer un fichier (age/GPG)" \
        "WIPE"        "🔥 Wipe sécurisé + certificat" \
        "TUI"         "🕶️ Ouvrir TUI Ghost Recon" || true)
fi

case "${CHOICE%%|*}" in
    SYSTEMCHECK)
        OUT="$(bash "${BASE_DIR}/tui/SystemCheck.sh" 2>&1 || true)"
        zenity --info --title="SystemCheck" --text="$OUT" 2>/dev/null || echo "$OUT"
        ;;
    PLUGINS)
        REPORT=""
        for p in "${BASE_DIR}"/plugins/custom/*; do
            [ -d "$p" ] && REPORT+="$(bash "${BASE_DIR}/plugins/verify-plugin.sh" "$p" 2>&1 || true)"$'\n'
        done
        zenity --info --title="Audit Plugins v3.0" --text="${REPORT:-Aucun plugin trouvé}" 2>/dev/null || echo "$REPORT"
        ;;
    DAEMON)
        if systemctl --user is-active --quiet thunar-overwatch.service 2>/dev/null; then
            systemctl --user stop thunar-overwatch.service
        else
            systemctl --user start thunar-overwatch.service
        fi
        ;;
    ENCRYPT)
        FILE="$(zenity --file-selection --title="Choisir un fichier à chiffrer" 2>/dev/null || true)"
        [ -n "$FILE" ] && x-terminal-emulator -e bash "${BASE_DIR}/security/opsec-crypt.sh" encrypt "$FILE"
        ;;
    WIPE)
        FILE="$(zenity --file-selection --title="⚠️ Fichier à détruire définitivement" 2>/dev/null || true)"
        [ -n "$FILE" ] && bash "${BASE_DIR}/security/opsec-wipe.sh" "$FILE"
        ;;
    TUI)
        x-terminal-emulator -e bash "${BASE_DIR}/tui/menu.sh"
        ;;
esac
