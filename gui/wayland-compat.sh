#!/usr/bin/env bash

detect_session_type() {
    if [ -n "${WAYLAND_DISPLAY:-}" ] || [ "${XDG_SESSION_TYPE:-}" = "wayland" ]; then
        echo "wayland"
    else
        echo "x11"
    fi
}

copy_to_clipboard() {
    local content="$1"
    if [ "$(detect_session_type)" = "wayland" ] && command -v wl-copy >/dev/null 2>&1; then
        printf '%s' "$content" | wl-copy
    elif command -v xclip >/dev/null 2>&1; then
        printf '%s' "$content" | xclip -selection clipboard
    elif command -v xsel >/dev/null 2>&1; then
        printf '%s' "$content" | xsel --clipboard --input
    else
        return 1
    fi
}

pick_dialog_backend() {
    if command -v yad >/dev/null 2>&1; then
        echo "yad"
    elif command -v zenity >/dev/null 2>&1; then
        echo "zenity"
    else
        echo "cli"
    fi
}
