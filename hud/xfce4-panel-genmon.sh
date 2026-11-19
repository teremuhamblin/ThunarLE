#!/usr/bin/env bash
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/thunar-overwatch-${UID}/status.env"

STATUS="OFF"; EVENTS=0; ALERTS=0; LAST_EVENT="aucun"; UPDATED_AT="--:--:--"
[ -f "$STATE_FILE" ] && source "$STATE_FILE"

if [ "$STATUS" = "ACTIVE" ]; then
    if [ "${ALERTS:-0}" -gt 0 ]; then
        ICON="🟠"
    else
        ICON="🟩"
    fi
else
    ICON="⬛"
fi

echo "<txt>${ICON} OW:${STATUS} (${ALERTS})</txt>"
echo "<txtclick>bash ${BASE_DIR}/gui/overwatch-gui.sh</txtclick>"
echo "<tool>Thunar-xfce Overwatch v3.0&#10;Événements : ${EVENTS}&#10;Alertes : ${ALERTS}&#10;Dernier : ${LAST_EVENT} (${UPDATED_AT})</tool>"
