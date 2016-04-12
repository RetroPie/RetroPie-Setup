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
rp_module_desc="RetroArch"
rp_module_menus="2+"

function depends_retroarch() {
    local depends=(libudev-dev libxkbcommon-dev libsdl2-dev)
    isPlatform "rpi" && depends+=(libraspberrypi-dev)
    isPlatform "mali" && depends+=(mali-fbdev)
    isPlatform "x86" && depends+=(nvidia-cg-toolkit)
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
    gitPullOrClone "$md_build/overlays" https://github.com/libretro/common-overlays.git
    isPlatform "rpi" && gitPullOrClone "$md_build/shader" https://github.com/RetroPie/common-shaders.git rpi
    isPlatform "x11" && gitPullOrClone "$md_build/shader" https://github.com/libretro/common-shaders.git
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
    mkdir -p "$md_inst/"{shader,assets,overlays}
    cp -v -a "$md_build/shader/"* "$md_inst/shader/"
    cp -v -a "$md_build/overlays/"* "$md_inst/overlays/"
    chown $user:$user -R "$md_inst/"{shader,assets,overlays}
    md_ret_files=(
        'retroarch.cfg'
    )
}

function configure_retroarch() {
    mkUserDir "$configdir/all/retroarch-joypads"

    local config="$configdir/all/retroarch.cfg"
    # if the user has an existing config we will not overwrite it, but instead copy the
    # default configuration to retroarch.cfg.rp-dist so any new options can be manually
    # copied across as needed without destroying users changes
    if [[ -f "$configdir/all/retroarch.cfg" ]]; then
        config="$configdir/all/retroarch.cfg.rp-dist"
        cp -v "$md_inst/retroarch.cfg" "$config"
    else
        cp -v "$md_inst/retroarch.cfg" "$config"
    fi

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

    chown $user:$user "$config"
}
