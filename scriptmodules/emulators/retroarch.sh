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
    getDepends libudev-dev libxkbcommon-dev libsdl2-dev libraspberrypi-dev
    [[ "$__raspbian_ver" -ge "8" ]] && getDepends libusb-1.0-0-dev

    cat > "/etc/udev/rules.d/99-evdev.rules" << _EOF_
KERNEL=="event*", NAME="input/%k", MODE="666"
_EOF_
    sudo chmod 666 /dev/input/event*
}

function sources_retroarch() {
    gitPullOrClone "$md_build" https://github.com/libretro/RetroArch.git
    gitPullOrClone "$md_build/overlays" https://github.com/libretro/common-overlays.git
    gitPullOrClone "$md_build/shader" https://github.com/RetroPie/common-shaders.git
    # disable the search dialog
    sed -i 's|menu_input_ctl(MENU_INPUT_CTL_SEARCH_START|//menu_input_ctl(MENU_INPUT_CTL_SEARCH_START|g' menu/menu_entry.c
}

function build_retroarch() {
    local params=(--disable-x11 --enable-dispmanx --disable-oss --disable-pulse --disable-al --disable-jack --enable-sdl2 --enable-floathard)
    isPlatform "rpi2" && params+=(--enable-neon)
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
    iniConfig " = " "" "$config"
    iniSet "system_directory" "$biosdir"
    iniSet "config_save_on_exit" "false"
    iniSet "video_aspect_ratio_auto" "true"
    iniSet "video_smooth" "true"
    iniSet "video_threaded" "true"
    iniSet "video_font_size" "12"
    iniSet "core_options_path" "$configdir/all/retroarch-core-options.cfg"
    iniSet "assets_directory" "$md_inst/assets"
    iniSet "overlay_directory" "$md_inst/overlays"

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
    iniSet "input_joypad_driver" "sdl2"

    chown $user:$user "$config"
}
