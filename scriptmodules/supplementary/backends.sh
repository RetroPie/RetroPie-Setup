#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="backends"
rp_module_desc="Configure display/driver backends for emulators"
rp_module_section="config"
rp_module_flags="!mali !x11"

function _list_backends() {
    local id="$1"
    backends=()

    local flags="${__mod_info[$id/flags]}"
    local sdl
    if isPlatform "videocore" && hasFlag "$flags" "sdl1-videocore"; then
        sdl="sdl1"
    elif hasFlag "$flags" "sdl1" || hasFlag "$flags" "dispmanx"; then
        sdl="sdl1"
    elif hasFlag "$flags" "sdl2"; then
        sdl="sdl2"
    else
        return 1
    fi

    local default
    local sdl_name="${sdl^^}"
    if [[ "$sdl" == "sdl1" ]]; then
        backends["default"]="SDL1 Framebuffer driver"
        isPlatform "dispmanx" && backends["dispmanx"]="SDL1 DispmanX driver"
    elif [[ "$sdl" == "sdl2" ]]; then
        if isPlatform "videocore"; then
            default="SDL2 videocore driver"
        elif isPlatform "kms"; then
            default="SDL2 KMS driver"
        fi
        backends["default"]="$default"
    fi
    backends["x11"]="$sdl_name on Desktop"
    backends["x11-c"]="$sdl_name on Desktop + Cursor"
    return 0
}

function _get_current_backends() {
    local id="$1"
    iniConfig " = " '"' "$configdir/all/backends.cfg"
    iniGet "$id"
    if [[ -n "$ini_value" ]]; then
        # translate old value of 1 as dispmanx for backward compatibility
        [[ "$ini_value" == "1" ]] && ini_value="dispmanx"
     else
        ini_value="default"
     fi
     echo "$ini_value"
}

function _update_hook_backends() {
    local dispmanx_cfg="$configdir/all/dispmanx.cfg"
    local backends_cfg="$configdir/all/backends.cfg"
    if [[ -f "$dispmanx_cfg" ]]; then
        mv "$dispmanx_cfg" "$backends_cfg"
    fi
}

function gui_backends() {
    declare -A backends
    local id
    local backend
    local default
    local flags
    local valid
    while true; do
        local options=()
        for id in "${__mod_id[@]}"; do
            valid=0
            if rp_isInstalled "$id"; then
                if _list_backends "$id" >/dev/null; then
                    backend="$(_get_current_backends "$id")"
                    options+=("$id" "Using ${backends[$backend]} ($backend)")
                fi
            fi
        done
        local cmd=(dialog --backtitle "$__backtitle" --default-item "$default" --menu "Configure display/driver backends for emulators" 22 76 16)
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "$choice" ]] && break
        default="$choice"
        gui_configure_backends "$choice"
    done
}

function gui_configure_backends() {
    local id="$1"
    declare -A backends

    _list_backends "$id"

    while true; do
        local current="$(_get_current_backends "$id")"
        local options=()
        local selected
        local backend
        local flags
        for backend in $(echo "${!backends[@]}" | xargs -n1 | sort); do
            selected=""
            [[ "$current" == "$backend" ]] && selected="(Currently selected)"
            options+=("$backend" "${backends[$backend]} $selected")
        done
        local cmd=(dialog --default-item "$current" --backtitle "$__backtitle" --menu "Select backend for $id" 22 76 16)
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choice" ]]; then
            if [[ "$choice" == "x11" ]] && ( ! hasPackage "xorg" || ! hasPackage "matchbox-window-manager" ); then
                if dialog --defaultno --yesno "To use the X11/Xorg backend, some additional packages are needed (xorg / matchbox-window-manager) - do you want to continue?" 22 76 2>&1 >/dev/tty; then
                    aptInstall xorg matchbox-window-manager
                else
                    continue
                fi
            fi
            local func="_backend_set_$id"
            if fnExists "$func"; then
                rp_callModule "$id" _backend_set "$choice" 1
            else
                setBackend "$id" "$choice" 1
            fi
        fi
        break
    done
}



