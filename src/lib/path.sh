#!/usr/bin/env bash
# ==============================================================================
# ThunarLE / Thunar-xfce — Résolution centralisée des chemins (src/lib/path.sh)
# Compatible : mode dépôt Git, archive portable & installation /opt/thunar-xfce
# ==============================================================================

# Évite le rechargement multiple sauf si THUNAR_PATH_RELOAD=1
if [ "${_THUNAR_PATH_SH_LOADED:-0}" = "1" ] && [ "${THUNAR_PATH_RELOAD:-0}" != "1" ]; then
    if [ "${BASH_SOURCE[0]:-}" != "${0:-}" ]; then
        return 0
    fi
fi

# Remonte l'arborescence depuis le script appelant jusqu'à trouver la racine du projet
_thunar_resolve_root() {
    local caller_file
    local current_dir

    if [ -n "${THUNAR_XFCE_ROOT:-}" ] && [ -d "${THUNAR_XFCE_ROOT}" ]; then
        (cd -P "${THUNAR_XFCE_ROOT}" && pwd)
        return 0
    fi

    caller_file="${BASH_SOURCE[1]:-${BASH_SOURCE[0]}}"
    current_dir="$(cd -P "$(dirname "$caller_file")" 2>/dev/null && pwd)"

    while [ -n "$current_dir" ] && [ "$current_dir" != "/" ]; do
        if [ -f "${current_dir}/VERSION.md" ] || [ -f "${current_dir}/thunar-xfce.sh" ]; then
            printf '%s\n' "$current_dir"
            return 0
        fi
        current_dir="$(dirname "$current_dir")"
    done

    # Fallback en mode paquet Debian installé
    for system_dir in "/opt/thunar-xfce" "/usr/local/share/thunar-xfce" "/usr/share/thunar-xfce"; do
        if [ -d "$system_dir" ]; then
            printf '%s\n' "$system_dir"
            return 0
        fi
    done

    return 1
}

# Choisit le nouveau chemin (src/...) s'il existe, sinon fallback sur l'ancien (transition douce)
_thunar_pick_dir() {
    local preferred="$1"
    local legacy="$2"

    if [ -d "$preferred" ]; then
        printf '%s\n' "$preferred"
    elif [ -d "$legacy" ]; then
        printf '%s\n' "$legacy"
    else
        printf '%s\n' "$preferred"
    fi
}

# ── Racine du projet ──────────────────────────────────────────────────────────
if ! THUNAR_XFCE_ROOT="$(_thunar_resolve_root)"; then
    echo "❌ [path.sh] Impossible de localiser la racine de ThunarLE." >&2
    if [ "${BASH_SOURCE[0]:-}" != "${0:-}" ]; then
        return 1
    fi
    exit 1
fi
export THUNAR_XFCE_ROOT

# ── Arborescence src/ (regroupée par compatibilité) ───────────────────────────
export THUNAR_SRC_DIR="${THUNAR_XFCE_ROOT}/src"
export THUNAR_LIB_DIR="${THUNAR_SRC_DIR}/lib"

# 1. Couche Thunar (actions, plugins, extension)
THUNAR_ACTIONS_DIR="$(_thunar_pick_dir "${THUNAR_SRC_DIR}/thunar/actions" "${THUNAR_XFCE_ROOT}/actions")"
THUNAR_PLUGINS_DIR="$(_thunar_pick_dir "${THUNAR_SRC_DIR}/thunar/plugins" "${THUNAR_XFCE_ROOT}/plugins")"
THUNAR_EXTENSION_DIR="$(_thunar_pick_dir "${THUNAR_SRC_DIR}/thunar/extension" "${THUNAR_XFCE_ROOT}/extension")"
export THUNAR_ACTIONS_DIR
export THUNAR_ACTION_SCRIPTS_DIR="${THUNAR_ACTIONS_DIR}/scripts"
export THUNAR_PLUGINS_DIR
export THUNAR_CUSTOM_PLUGINS_DIR="${THUNAR_PLUGINS_DIR}/custom"
export THUNAR_EXTENSION_DIR

# 2. Couche UI (TUI, GUI, HUD)
THUNAR_TUI_DIR="$(_thunar_pick_dir "${THUNAR_SRC_DIR}/ui/tui" "${THUNAR_XFCE_ROOT}/tui")"
THUNAR_GUI_DIR="$(_thunar_pick_dir "${THUNAR_SRC_DIR}/ui/gui" "${THUNAR_XFCE_ROOT}/gui")"
THUNAR_HUD_DIR="$(_thunar_pick_dir "${THUNAR_SRC_DIR}/ui/hud" "${THUNAR_XFCE_ROOT}/hud")"
export THUNAR_TUI_DIR
export THUNAR_GUI_DIR
export THUNAR_HUD_DIR

# 3. Couche OpSec (security, sandbox)
THUNAR_SECURITY_DIR="$(_thunar_pick_dir "${THUNAR_SRC_DIR}/opsec/security" "${THUNAR_XFCE_ROOT}/security")"
THUNAR_SANDBOX_DIR="$(_thunar_pick_dir "${THUNAR_SRC_DIR}/opsec/sandbox" "${THUNAR_XFCE_ROOT}/sandbox")"
export THUNAR_SECURITY_DIR
export THUNAR_SANDBOX_DIR

# 4. Couche Engine (daemon, ai, sync)
THUNAR_DAEMON_DIR="$(_thunar_pick_dir "${THUNAR_SRC_DIR}/engine/daemon" "${THUNAR_XFCE_ROOT}/daemon")"
THUNAR_AI_DIR="$(_thunar_pick_dir "${THUNAR_SRC_DIR}/engine/ai" "${THUNAR_XFCE_ROOT}/ai")"
THUNAR_SYNC_DIR="$(_thunar_pick_dir "${THUNAR_SRC_DIR}/engine/sync" "${THUNAR_XFCE_ROOT}/sync")"
export THUNAR_DAEMON_DIR
export THUNAR_AI_DIR
export THUNAR_SYNC_DIR

# ── Configuration, Runtime, Packaging & Docs ──────────────────────────────────
export THUNAR_CONFIG_DIR="${THUNAR_XFCE_ROOT}/config"
export THUNAR_VAR_DIR="${THUNAR_XFCE_ROOT}/var"

THUNAR_LOGS_DIR="$(_thunar_pick_dir "${THUNAR_VAR_DIR}/logs" "${THUNAR_XFCE_ROOT}/logs")"
export THUNAR_LOGS_DIR
export THUNAR_LOG_FILE="${THUNAR_LOGS_DIR}/thunar-xfce.log"
export THUNAR_DAEMON_LOG_FILE="${THUNAR_LOGS_DIR}/overwatch-daemon.log"
export THUNAR_CERTS_DIR="${THUNAR_LOGS_DIR}/certs"

THUNAR_DEBIAN_DIR="$(_thunar_pick_dir "${THUNAR_XFCE_ROOT}/packaging/debian" "${THUNAR_XFCE_ROOT}/debian")"
export THUNAR_PACKAGING_DIR="${THUNAR_XFCE_ROOT}/packaging"
export THUNAR_DEBIAN_DIR
export THUNAR_DOCS_DIR="${THUNAR_XFCE_ROOT}/docs"
export THUNAR_TESTS_DIR="${THUNAR_XFCE_ROOT}/tests"

# ── Chemins utilisateur XDG (runtime / quarantaine / état Overwatch) ──────────
export THUNAR_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/thunar-xfce"
export THUNAR_QUARANTINE_DIR="${THUNAR_DATA_HOME}/quarantine"
export THUNAR_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}/thunar-overwatch-${UID}"
export THUNAR_STATE_FILE="${THUNAR_RUNTIME_DIR}/status.env"

# ── Fonctions utilitaires exposées aux scripts ────────────────────────────────

# Crée les répertoires runtime nécessaires (logs, certs, quarantaine, socket/état)
thunar_init_runtime_dirs() {
    mkdir -p \
        "${THUNAR_LOGS_DIR}" \
        "${THUNAR_CERTS_DIR}" \
        "${THUNAR_QUARANTINE_DIR}" \
        "${THUNAR_RUNTIME_DIR}"
}

# Charge un fichier de config s'il existe (ex: thunar_load_conf "overwatch.conf")
thunar_load_conf() {
    local conf_name="$1"
    local conf_path="${THUNAR_CONFIG_DIR}/${conf_name}"
    if [ -f "$conf_path" ]; then
        # shellcheck disable=SC1090
        source "$conf_path"
        return 0
    fi
    return 1
}

# Affiche la cartographie complète des chemins (utile pour debug / SystemCheck)
thunar_print_paths() {
    cat << EOF
=== ThunarLE Paths Diagnostic ===
ROOT        : ${THUNAR_XFCE_ROOT}
CONFIG      : ${THUNAR_CONFIG_DIR}
LOGS        : ${THUNAR_LOGS_DIR}
CERTS       : ${THUNAR_CERTS_DIR}
ACTIONS     : ${THUNAR_ACTIONS_DIR}
PLUGINS     : ${THUNAR_PLUGINS_DIR}
EXTENSION   : ${THUNAR_EXTENSION_DIR}
TUI         : ${THUNAR_TUI_DIR}
GUI         : ${THUNAR_GUI_DIR}
HUD         : ${THUNAR_HUD_DIR}
SECURITY    : ${THUNAR_SECURITY_DIR}
SANDBOX     : ${THUNAR_SANDBOX_DIR}
DAEMON      : ${THUNAR_DAEMON_DIR}
AI          : ${THUNAR_AI_DIR}
SYNC        : ${THUNAR_SYNC_DIR}
DEBIAN      : ${THUNAR_DEBIAN_DIR}
RUNTIME     : ${THUNAR_RUNTIME_DIR}
STATE_FILE  : ${THUNAR_STATE_FILE}
EOF
}

export _THUNAR_PATH_SH_LOADED=1

# Si exécuté directement (et non sourcé), affiche le diagnostic des chemins
if [ "${BASH_SOURCE[0]:-}" = "${0:-}" ]; then
    thunar_print_paths
fi
