#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="moonlight"
rp_module_desc="Moonlight Embedded - an open source gamestream client for embedded systems"
rp_module_help="ROM Extensions: .ml\n\nCopy your moonlight launch configurations to $romdir/steam\n\nDon't forget to first pair with your remote host before using moonlight. You can use the configuration menu for pairing/unpairing to/from a remote machine."
rp_module_licence="GPL3 https://raw.githubusercontent.com/irtimmer/moonlight-embedded/master/LICENSE"
rp_module_repo="git https://github.com/irtimmer/moonlight-embedded.git master"
rp_module_section="exp"
rp_module_flags="!all arm"

function _scriptmodule_cfg_file_moonlight() {
    echo "$configdir/all/moonlight/scriptmodule.cfg"
}

function _global_cfg_file_moonlight() {
    echo "$configdir/all/moonlight/global.conf"
}

function _mangle_moonlight() {
    local -r type="$1"
    shift
    case "$type" in
        1)  # slugify, ref: https://gist.github.com/oneohthree/f528c7ae1e701ad990e6
            iconv -c -t ascii//TRANSLIT <<< "$@" |
                sed -r s/[^a-zA-Z0-9]+/-/g |
                sed -r s/^-+\|-+$//g |
                tr "[:upper:]" "[:lower:]"
            ;;
        2)  # windows-compatible, ref: https://stackoverflow.com/a/35352640
            iconv -c -t ascii//TRANSLIT <<< "$@" |
                sed -r s/[\<\>]+/\ /g |
                sed -r s/[\\/\|]+/-/g |
                sed -r s/[:\*\"]+//g
            ;;
        0|*)  # no mangling, but replace invalid "/" with "-"
            sed -r s/\\//-/g <<< "$@"
            ;;
    esac
}

function _mfmt_moonlight() {
    case "$1" in
        1)   echo "SLUGIFY" ;;
        2)   echo "WINDOWS" ;;
        0|*) echo "NONE   " ;;
    esac
}

function _bfmt_moonlight() {
    if [[ "$1" -eq 1 ]]; then echo "YES"; else echo "NO "; fi
}

function depends_moonlight() {
    # ref: https://github.com/irtimmer/moonlight-embedded/wiki/Compilation#debian-raspbian--osmc
    local depends=(
        libssl-dev libopus-dev libasound2-dev libudev-dev
        libavahi-client-dev libcurl4-openssl-dev libevdev-dev
        libexpat1-dev libpulse-dev libenet-dev uuid-dev cmake
    )

    # for remote host autodiscovery features
    depends+=(avahi-daemon libnss-mdns)

    # platform-specific dependencies
    isPlatform "rpi" && depends+=(libraspberrypi-dev)
    isPlatform "osmc" && depends+=(rbp-userland-dev-osmc)
    isPlatform "vero4k" && depends+=(vero3-userland-dev-osmc)

    # install selected dependencies
    getDepends "${depends[@]}"
}

function sources_moonlight() {
    gitPullOrClone
}

function build_moonlight() {
    # ref: https://github.com/irtimmer/moonlight-embedded/wiki/Compilation
    rm -rf build
    mkdir build
    cd build
    cmake ../ -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_INSTALL_RPATH="$md_inst/lib" \
        -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=TRUE
    make
}

function install_moonlight() {
    cd build
    make install
    strip "$md_inst/bin/moonlight"
}

function configure_moonlight() {
    addEmulator 1 "$md_id" "steam" "$md_inst/moonlight.sh stream -config %ROM%"
    addSystem "steam" "Steam Game Streaming" ".ml"
    [[ "$md_mode" == "remove" ]] && return

    # ensure rom dir
    mkRomDir "steam"

    # create and symlink user configuration directory
    mkUserDir "$configdir/all/moonlight"
    moveConfigDir "$home/.config/moonlight" "$configdir/all/moonlight"

    # create a new global config file if not there already
    if [[ ! -f "$(_global_cfg_file_moonlight)" ]]; then
        cat > "$(_global_cfg_file_moonlight)" << "_EOF_"
# global config file for moonlight
quitappafter = true
_EOF_
        chown "$__user":"$__group" "$(_global_cfg_file_moonlight)"
    fi

    # create wrapper for moonlight with appropriate directories set
    # note: moonlight adds /moonlight to XDG_* variables
    cat > "$md_inst/moonlight.sh" << _EOF_
#!/usr/bin/env bash
export XDG_DATA_DIRS=$md_inst/share
export XDG_CONFIG_DIR=$configdir/all
export XDG_CACHE_DIR=$configdir/all
$md_inst/bin/moonlight "\$@"
_EOF_
    chmod +x "$md_inst/moonlight.sh"
}

function get_scriptmodule_cfg_moonlight() {
    local address
    local overwrite=0
    local wipe=0
    local mangle=0

    iniConfig " = " "" "$(_scriptmodule_cfg_file_moonlight)"
    iniGet "address" && address="$ini_value"
    iniGet "overwrite" && overwrite="$ini_value"
    iniGet "wipe" && wipe="$ini_value"
    iniGet "mangle" && mangle="$ini_value"

    echo "$address;$overwrite;$wipe;$mangle"
}

function set_scriptmodule_cfg_moonlight() {
    local -r address="$1"
    local -r overwrite="$2"
    local -r wipe="$3"
    local -r mangle="$4"

    [[ -z "$overwrite" || -z "$wipe" || -z "$mangle" ]] && return

    iniConfig " = " "" "$(_scriptmodule_cfg_file_moonlight)"
    if [[ -n "$address" ]]; then
        iniSet "address" "$address"
    else
        iniDel "address"
    fi
    iniSet "overwrite" "$overwrite"
    iniSet "wipe" "$wipe"
    iniSet "mangle" "$mangle"

    chown "$__user":"$__group" "$(_scriptmodule_cfg_file_moonlight)"
}

function get_resolution_moonlight() {
    local width=0
    local height=0
    local fps=0

    iniConfig " = " "" "$(_global_cfg_file_moonlight)"
    iniGet "width" && width="$ini_value"
    iniGet "height" && height="$ini_value"
    iniGet "fps" && fps="$ini_value"

    if [[ -n "$width" && -n "$height" && -n "$fps" ]]; then
        echo "$width;$height;$fps"
    else
        echo "0;0;0"
    fi
}

function get_host_moonlight() {
    local sops="true"
    local unsupported="false"

    iniConfig " = " "" "$(_global_cfg_file_moonlight)"
    iniGet "sops" && sops="$ini_value"
    iniGet "unsupported" && unsupported="$ini_value"

    if [[ -n "$sops" && -n "$unsupported" ]]; then
        echo "$sops;$unsupported"
    else
        echo "true;false"
    fi
}

function set_host_moonlight() {
    local -r sops="$1"
    local -r unsupported="$2"

    [[ -z "$sops" || -z "$unsupported" ]] && return

    iniConfig " = " "" "$(_global_cfg_file_moonlight)"
    iniSet "sops" "$sops"
    iniSet "unsupported" "$unsupported"

    chown "$__user":"$__group" "$(_global_cfg_file_moonlight)"
}


function set_resolution_moonlight() {
    local -r width="$1"
    local -r height="$2"
    local -r fps="$3"

    [[ -z "$width" || -z "$height" || -z "$fps" ]] && return

    iniConfig " = " "" "$(_global_cfg_file_moonlight)"
    if [[ "$width" -gt 0 && "$height" -gt 0 && "$fps" -gt 0 ]]; then
        iniSet "width" "$width"
        iniSet "height" "$height"
        iniSet "fps" "$fps"
    else
        iniDel "width"
        iniDel "height"
        iniDel "fps"
    fi

    chown "$__user":"$__group" "$(_global_cfg_file_moonlight)"
}

function get_bitrate_moonlight() {
    local bitrate=0

    iniConfig " = " "" "$(_global_cfg_file_moonlight)"
    iniGet "bitrate" && bitrate="$ini_value"

    if [[ -n "$bitrate" ]]; then
        echo "$bitrate"
    else
        echo "0"
    fi
}

function set_bitrate_moonlight() {
    local -r bitrate="$1"

    [[ -z "$bitrate" ]] && return

    iniConfig " = " "" "$(_global_cfg_file_moonlight)"
    if [[ "$bitrate" -gt 0 ]]; then
        iniSet "bitrate" "$bitrate"
    else
        iniDel "bitrate"
    fi

    chown "$__user":"$__group" "$(_global_cfg_file_moonlight)"
}

function exec_moonlight() {
    trap "trap INT; echo; return" INT
    sudo -u "$__user" "$md_inst/moonlight.sh" "$@"
    trap INT
}

function pair_moonlight() {
    exec_moonlight pair "$@"
}

function unpair_moonlight() {
    exec_moonlight unpair "$@"
}

function list_moonlight() {
    exec_moonlight list "$@"
}

function clear_pairing_moonlight() {
    rm -rf "$configdir/all/moonlight"/{client*,key*,uniqueid.dat}
}

function gen_configs_moonlight() {
    local apps=()
    local app
    local fname
    local config

    # read scriptmodule config
    IFS=";" read -r -a config < <(get_scriptmodule_cfg_moonlight)

    # wipe existing configuration files?
    if [[ "${config[2]}" -eq 1 ]]; then
        printMsgs "console" "Wiping existing config files ..."
        rm -f "$romdir/steam/"*.ml
    fi

    # iterate over all apps in remote host
    mapfile -t apps < <(list_moonlight ${config[0]:+"${config[0]}"} | sed -nE 's/^[0-9]+\. //gp')
    for app in "${apps[@]}"; do
        if [[ "$app" == "." || "$app" == ".." ]]; then
            printMsgs "console" "warning: app name '$app' is not valid"
            continue
        fi
        fname="$(_mangle_moonlight "${config[3]}" "$app")"  # app filename mangle
        [[ "${config[1]}" -eq 0 && -f "$romdir/steam/$fname.ml" ]] && continue  # overwrite?

        # generate config file with defaults
        printMsgs "console" "Generating config file for '$app' ..."
        iniConfig " = " "" "$romdir/steam/$fname.ml"
        iniSet "config" "$(_global_cfg_file_moonlight)"
        [[ -n "${config[0]}" ]] && iniSet "address" "${config[0]}"
        iniSet "app" "$app"
        chown "$__user":"$__group" "$romdir/steam/$fname.ml" 2>/dev/null
    done
}

function apps_gui_moonlight() {
    local options=()
    local default
    local cmd
    local choice
    local config

    # read scriptmodule config
    IFS=";" read -r -a config < <(get_scriptmodule_cfg_moonlight)

    # start the menu gui
    default="O"
    while true; do
        # create menu options
        options=(
            O "Overwrite existing config files: $(_bfmt_moonlight ${config[1]})" "Overwrite existing files in '$romdir/steam'?"
            W "Wipe existing config files: $(_bfmt_moonlight ${config[2]})" "Delete all files in '$romdir/steam'?"
            S "Config filename mangling: $(_mfmt_moonlight ${config[3]})" "Use original app names, slugified names or Windows-compatible names?"
            G "Generate config files" "Start remote apps config files generation"
        )

        # show main menu
        cmd=(dialog --backtitle "$__backtitle" --default-item "$default" --item-help --menu "Remote Apps" 13 60 16)
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        default="$choice"
        case "$choice" in
            O)
                config[1]=$((1 - config[1]))
                set_scriptmodule_cfg_moonlight "${config[@]}"
                ;;
            W)
                config[2]=$((1 - config[2]))
                set_scriptmodule_cfg_moonlight "${config[@]}"
                ;;
            S)
                config[3]=$((config[3] + 1))
                [[ "${config[3]}" -gt 2 ]] && config[3]=0
                set_scriptmodule_cfg_moonlight "${config[@]}"
                ;;
            G)
                gen_configs_moonlight
                read -p "Press ENTER to continue... "
                ;;
            *)
                break
                ;;
        esac
    done
}

function host_gui_moonlight() {
    local options=()
    local default
    local cmd
    local choice
    local tuple

    # get current host options
    IFS=";" read -r -a tuple < <(get_host_moonlight)
    default="U"
    [[ "${tuple[0]}" == "false" && "${tuple[1]}" == "false" ]] && default="1"
    [[ "${tuple[0]}" == "true"  && "${tuple[1]}" == "true"  ]] && default="2"
    [[ "${tuple[0]}" == "false" && "${tuple[1]}" == "true"  ]] && default="3"

    # create menu options
    options=(
        U "Unset (use default)" "Do not force host compatibility settings"
        1 "No SOPS" "Don't allow GFE to modify game settings"
        2 "Allow unsupported" "Try streaming if GFE version or options are unsupported"
        3 "Open-source host compatibility" "Turn off SOPS and allow unsupported options (for Sunshine/Open-Stream GFE server)"
    )

    # show main menu
    cmd=(dialog --backtitle "$__backtitle" --default-item "$default" --item-help --menu "Host Compatibility Options" 16 45 16)
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    case "$choice" in
        U)
            set_host_moonlight "true" "false"
            ;;
        1)
            set_host_moonlight "false" "false"
            ;;
        2)
            set_host_moonlight "true" "true"
            ;;
        3)
            set_host_moonlight "false" "true"
            ;;
    esac
}

function resolution_gui_moonlight() {
    local options=()
    local default
    local cmd
    local choice
    local resolution

    # get current resolution
    IFS=";" read -r -a resolution < <(get_resolution_moonlight)
    if [[ "${resolution[0]}" -gt 0 && "${resolution[1]}" -gt 0 && "${resolution[2]}" -gt 0 ]]; then
        default="C"
        [[ "${resolution[0]}" == 1920 && "${resolution[1]}" == 1080 && "${resolution[2]}" == 60 ]] && default="1"
        [[ "${resolution[0]}" == 1920 && "${resolution[1]}" == 1080 && "${resolution[2]}" == 30 ]] && default="2"
        [[ "${resolution[0]}" == 1280 && "${resolution[1]}" == 720 && "${resolution[2]}" == 60 ]] && default="3"
        [[ "${resolution[0]}" == 1280 && "${resolution[1]}" == 720 && "${resolution[2]}" == 30 ]] && default="4"
        resolution="${resolution[0]} x ${resolution[1]} @ ${resolution[2]} fps"
    else
        default="U"
        resolution="(using default)"
    fi

    # create menu options
    options=(
        U "Unset (use default)" "Do not force a resolution setting"
        1 "1080p60" "Set resolution to 1920 x 1080 @ 60 fps"
        2 "1080p30" "Set resolution to 1920 x 1080 @ 30 fps"
        3 "720p60"  "Set resolution to 1280 x 720 @ 60 fps"
        4 "720p30"  "Set resolution to 1280 x 720 @ 30 fps"
        C "Custom"  "Set a custom resolution"
    )

    # show main menu
    cmd=(dialog --backtitle "$__backtitle" --default-item "$default" --item-help --menu "Global Resolution\nCurrent: $resolution" 16 45 16)
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    case "$choice" in
        U)
            set_resolution_moonlight "0" "0" "0"
            ;;
        1)
            set_resolution_moonlight "1920" "1080" "60"
            ;;
        2)
            set_resolution_moonlight "1920" "1080" "30"
            ;;
        3)
            set_resolution_moonlight "1280" "720" "60"
            ;;
        4)
            set_resolution_moonlight "1280" "720" "30"
            ;;
        C)
            cmd=(dialog --backtitle "$__backtitle" --inputbox "Please enter a custom resolution as WIDTH HEIGHT FPS (separated by spaces)" 10 50)
            choice=$("${cmd[@]}" 2>&1 >/dev/tty)
            if [[ $? -eq 0 ]]; then
                IFS=" " read -r -a choice <<< "$choice"
                set_resolution_moonlight "${choice[0]}" "${choice[1]}" "${choice[2]}"
            fi
            ;;
    esac
}

function bitrate_gui_moonlight() {
    local options=()
    local default
    local cmd
    local choice
    local bitrate

    # get current bitrate
    bitrate=$(get_bitrate_moonlight)
    if [[ "$bitrate" -gt 0 ]]; then
        default="C"
        [[ "$bitrate" == 20000 ]] && default="1"
        [[ "$bitrate" == 10000 ]] && default="2"
        [[ "$bitrate" == 5000 ]] && default="3"
        bitrate="$bitrate Kbps"
    else
        default="U"
        bitrate="(using default)"
    fi

    # create menu options
    options=(
        U "Unset (use default)" "Do not force a stream bitrate setting"
        1 "20000"  "Set stream bitrate to 20000 Kbps"
        2 "10000"  "Set stream bitrate to 10000 Kbps"
        3 "5000"   "Set stream bitrate to 5000 Kbps"
        C "Custom" "Set a custom stream bitrate"
    )

    # show main menu
    cmd=(dialog --backtitle "$__backtitle" --default-item "$default" --item-help --menu "Stream Bitrate\nCurrent: $bitrate" 16 45 16)
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    case "$choice" in
        U)
            set_bitrate_moonlight "0"
            ;;
        1)
            set_bitrate_moonlight "20000"
            ;;
        2)
            set_bitrate_moonlight "10000"
            ;;
        3)
            set_bitrate_moonlight "5000"
            ;;
        C)
            cmd=(dialog --backtitle "$__backtitle" --inputbox "Please enter a custom stream bitrate in Kbps" 10 50)
            choice=$("${cmd[@]}" 2>&1 >/dev/tty)
            [[ $? -eq 0 ]] && set_bitrate_moonlight "$choice"
            ;;
    esac
}

function gui_moonlight() {
    local options=()
    local default
    local cmd
    local choice
    local config

    # read scriptmodule config
    IFS=";" read -r -a config < <(get_scriptmodule_cfg_moonlight)

    # start the menu gui
    default="A"
    while true; do
        # create menu options, if no address show "autodiscover"
        options=(
            A "Set remote host address (${config[0]:-autodiscover})"
            P "Pair to remote host"
            U "Unpair from remote host"
            G "Configure remote apps"
            R "Configure global resolution"
            B "Configure global stream bitrate"
            H "Configure host compatibility"
            C "Clear all pairing data"
        )

        # show main menu
        cmd=(dialog --backtitle "$__backtitle" --default-item "$default" --menu "Choose an option" 16 60 16)
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        default="$choice"
        case "$choice" in
            A)
                cmd=(dialog --backtitle "$__backtitle" --inputbox "Please enter the address of the remote host (leave BLANK for autodiscovery of the remote host)" 10 65)
                choice=$("${cmd[@]}" 2>&1 >/dev/tty)
                if [[ $? -eq 0 ]]; then
                    config[0]="$choice"
                    set_scriptmodule_cfg_moonlight "${config[@]}"
                fi
                ;;
            P)
                pair_moonlight ${config[0]:+"${config[0]}"} </dev/tty >/dev/tty
                read -p "Press ENTER to continue... "
                ;;
            U)
                unpair_moonlight ${config[0]:+"${config[0]}"} </dev/tty >/dev/tty
                read -p "Press ENTER to continue... "
                ;;
            G)
                apps_gui_moonlight
                ;;
            R)
                resolution_gui_moonlight
                ;;
            B)
                bitrate_gui_moonlight
                ;;
            H)
                host_gui_moonlight
                ;;
            C)
                if dialog --defaultno --yesno "Are you sure you want to CLEAR ALL pairing data?" 8 40 2>&1 >/dev/tty; then
                    if clear_pairing_moonlight; then
                        printMsgs "dialog" "All pairing data cleared."
                    else
                        printMsgs "dialog" "Could not clear pairing data."
                    fi
                fi
                ;;
            *)
                break
                ;;
        esac
    done
}
