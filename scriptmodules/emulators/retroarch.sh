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
    isPlatform "x11" && depends+=(libpulse-dev)
    [[ "$__raspbian_ver" -ge "8" ]] && depends+=(libusb-1.0-0-dev)

    getDepends "${depends[@]}"

    if [[ ! -f /etc/udev/rules.d/99-input.rules ]]; then
        echo 'SUBSYSTEM=="input", GROUP="input", MODE="0660"' > /etc/udev/rules.d/99-input.rules
    fi

    # remove old 99-evdev.rules
    rm -f /etc/udev/rules.d/99-evdev.rules
}

function sources_retroarch() {
    gitPullOrClone "$md_build" https://github.com/libretro/RetroArch.git
    # disable the search dialog
    sed -i 's|menu_input_ctl(MENU_INPUT_CTL_SEARCH_START|//menu_input_ctl(MENU_INPUT_CTL_SEARCH_START|g' menu/menu_entry.c
    if isPlatform "mali"; then
        sed -i 's|struct mali_native_window native_window|fbdev_window native_window|' gfx/drivers_context/mali_fbdev_ctx.c
    fi
    patch -p1 <"$scriptdir/scriptmodules/emulators/$md_id/01_hotkey_hack.diff"
}

function build_retroarch() {
    local params=(--enable-sdl2)
    ! isPlatform "x11" && params+=(--disable-x11 --enable-gles --disable-ffmpeg --disable-sdl --enable-sdl2 --disable-oss --disable-pulse --disable-al --disable-jack)
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
        local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option" 22 76 16)
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "$choice" ]] && break
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
    done
}