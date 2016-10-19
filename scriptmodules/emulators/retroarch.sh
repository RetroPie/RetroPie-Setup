#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="retroarch"
rp_module_desc="RetroArch - frontend to the libretro emulator cores - required by all lr-* emulators"
rp_module_section="core"

function depends_retroarch() {
    local depends=(libudev-dev libxkbcommon-dev libsdl2-dev)
    isPlatform "rpi" && depends+=(libraspberrypi-dev)
    isPlatform "mali" && depends+=(mali-fbdev)
    isPlatform "x86" && depends+=(nvidia-cg-toolkit)
    isPlatform "x11" && depends+=(libpulse-dev libavcodec-dev libavformat-dev libavdevice-dev)
    compareVersions "$__os_release" ge 8  && depends+=(libusb-1.0-0-dev)

    getDepends "${depends[@]}"

    addUdevInputRules
}

function sources_retroarch() {
    gitPullOrClone "$md_build" https://github.com/libretro/RetroArch.git
    if isPlatform "mali"; then
        sed -i 's|struct mali_native_window native_window|fbdev_window native_window|' gfx/drivers_context/mali_fbdev_ctx.c
    fi
    applyPatch "$md_data/01_hotkey_hack.diff"
}

function build_retroarch() {
    local params=(--enable-sdl2)
    ! isPlatform "x11" && params+=(--disable-x11 --enable-opengles --disable-ffmpeg --disable-sdl --enable-sdl2 --disable-oss --disable-pulse --disable-al --disable-jack)
    isPlatform "rpi" && params+=(--enable-dispmanx)
    isPlatform "mali" && params+=(--enable-mali_fbdev)
    isPlatform "arm" && params+=(--enable-floathard)
    isPlatform "neon" && params+=(--enable-neon)
    ./configure --prefix="$md_inst" "${params[@]}"
    make clean
    make
    md_ret_require="$md_build/retroarch"
}

function install_retroarch() {
    make install
    md_ret_files=(
        'retroarch.cfg'
    )
}

function update_shaders_retroarch() {
    local branch=""
    isPlatform "rpi" && branch="rpi"
    # remove if not git repository for fresh checkout
    [[ ! -d "$md_inst/shader/.git" ]] && rm -rf "$md_inst/shader"
    gitPullOrClone "$md_inst/shader" https://github.com/RetroPie/common-shaders.git "$branch"
}

function update_overlays_retroarch() {
    # remove if not a git repository for fresh checkout
    [[ ! -d "$md_inst/overlays/.git" ]] && rm -rf "$md_inst/overlays"
    gitPullOrClone "$md_inst/overlays" https://github.com/libretro/common-overlays.git
}

function remove_shaders_retroarch() {
    rm -rf "$md_inst/shader"
}

function remove_overlays_retroarch() {
    rm -rf "$md_inst/overlays"
}

function configure_retroarch() {
    [[ "$md_mode" == "remove" ]] && return

    mkUserDir "$configdir/all/retroarch-joypads"

    mkUserDir "$md_inst/assets"

    # install shaders by default
    update_shaders_retroarch

    local config="$(mktemp)"

    cp "$md_inst/retroarch.cfg" "$config"

    # configure default options
    iniConfig " = " '"' "$config"
    iniSet "cache_directory" "/tmp/retroarch"
    iniSet "system_directory" "$biosdir"
    iniSet "config_save_on_exit" "false"
    iniSet "video_aspect_ratio_auto" "true"
    iniSet "video_smooth" "false"
    iniSet "video_threaded" "true"
    iniSet "video_font_size" "12"
    iniSet "core_options_path" "$configdir/all/retroarch-core-options.cfg"
    iniSet "assets_directory" "$md_inst/assets"
    iniSet "overlay_directory" "$md_inst/overlays"
    iniSet "menu_driver" "rgui"
    isPlatform "x11" && iniSet "video_fullscreen" "true"

    # set default render resolution to 640x480 for rpi1
    if isPlatform "rpi1"; then
        iniSet "video_fullscreen_x" "640"
        iniSet "video_fullscreen_y" "480"
    fi

    # enable hotkey ("select" button)
    iniSet "input_enable_hotkey" "nul"
    iniSet "input_exit_emulator" "escape"

    # enable and configure rewind feature
    iniSet "rewind_enable" "false"
    iniSet "rewind_buffer_size" "10"
    iniSet "rewind_granularity" "2"
    iniSet "input_rewind" "r"

    # enable gpu screenshots
    iniSet "video_gpu_screenshot" "true"

    # enable and configure shaders
    iniSet "input_shader_next" "m"
    iniSet "input_shader_prev" "n"
    iniSet "video_shader_dir" "$md_inst/shader/"

    # configure keyboard mappings
    iniSet "input_player1_a" "x"
    iniSet "input_player1_b" "z"
    iniSet "input_player1_y" "a"
    iniSet "input_player1_x" "s"
    iniSet "input_player1_start" "enter"
    iniSet "input_player1_select" "rshift"
    iniSet "input_player1_l" "q"
    iniSet "input_player1_r" "w"
    iniSet "input_player1_left" "left"
    iniSet "input_player1_right" "right"
    iniSet "input_player1_up" "up"
    iniSet "input_player1_down" "down"

    # input settings
    iniSet "input_autodetect_enable" "true"
    iniSet "joypad_autoconfig_dir" "$configdir/all/retroarch-joypads/"
    iniSet "auto_remaps_enable" "true"
    iniSet "input_joypad_driver" "udev"

    copyDefaultConfig "$config" "$configdir/all/retroarch.cfg"
    rm "$config"

    # remapping hack for old 8bitdo firmware
    addAutoConf "8bitdo_hack" 1
}

function keyboard_retroarch() {
    if [[ ! -f "$configdir/all/retroarch.cfg" ]]; then
        printMsgs "dialog" "No RetroArch configuration file found at $configdir/all/retroarch.cfg"
        return
    fi
    local input
    local options
    local i=1
    local key=()
    while read input; do
        local parts=($input)
        key+=("${parts[0]}")
        options+=("${parts[0]}" $i 2 "${parts[*]:2}" $i 26 16 0)
        ((i++))
    done < <(grep "^[[:space:]]*input_player[0-9]_[a-z]*" "$configdir/all/retroarch.cfg")
    local cmd=(dialog --backtitle "$__backtitle" --form "RetroArch keyboard configuration" 22 48 16)
    local choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choices" ]]; then
        local value
        local values
        readarray -t values <<<"$choices"
        iniConfig " = " "" "$configdir/all/retroarch.cfg"
        i=0
        for value in "${values[@]}"; do
            iniSet "${key[$i]}" "$value" >/dev/null
            ((i++))
        done
    fi
}

function hotkey_retroarch() {
    iniConfig " = " '"' "$configdir/all/retroarch.cfg"
    cmd=(dialog --backtitle "$__backtitle" --menu "Choose the desired hotkey behaviour." 22 76 16)
    options=(1 "Hotkeys enabled. (default)"
             2 "Press ALT to enable hotkeys."
             3 "Hotkeys disabled. Press ESCAPE to open RGUI.")
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choices" ]]; then
        case $choices in
            1)
                iniSet "input_enable_hotkey" "nul"
                iniSet "input_exit_emulator" "escape"
                iniSet "input_menu_toggle" "F1"
                ;;
            2)
                iniSet "input_enable_hotkey" "alt"
                iniSet "input_exit_emulator" "escape"
                iniSet "input_menu_toggle" "F1"
                ;;
            3)
                iniSet "input_enable_hotkey" "escape"
                iniSet "input_exit_emulator" "nul"
                iniSet "input_menu_toggle" "escape"
                ;;
        esac
    fi
}

function gui_retroarch() {
    while true; do
        local options=()
        local dir
        local name
        local i=1
        for name in shaders overlays; do
            dir="$name"
            [[ "$dir" == "shaders" ]] && dir="shader"
            if [[ -d "$md_inst/$dir/.git" ]]; then
                options+=("$i" "Manage $name (installed)")
            else
                options+=("$i" "Manage $name (not installed)")
            fi
            ((i++))
        done
        options+=(
            3 "Configure keyboard for use with RetroArch"
            4 "Configure keyboard hotkey behaviour for RetroArch"
        )
        local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option" 22 76 16)
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "$choice" ]] && break
        case "$choice" in
            1|2)
                [[ "$choice" -eq 1 ]] && dir="shaders"
                [[ "$choice" -eq 2 ]] && dir="overlays"
                options=(1 "Install/Update $dir" 2 "Uninstall $dir" )
                cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option for $dir" 12 40 06)
                choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

                case "$choice" in
                    1)
                        "update_${dir}_retroarch"
                        ;;
                    2)
                        "remove_${dir}_retroarch"
                        ;;
                    *)
                        continue
                        ;;

                esac
                ;;
            3)
                keyboard_retroarch
                ;;
            4)
                hotkey_retroarch
                ;;
        esac

    done
}
