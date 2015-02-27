rp_module_id="retroarch"
rp_module_desc="RetroArch"
rp_module_menus="2+"

function depends_retroarch() {
    getDepends libudev-dev libxkbcommon-dev libsdl2-dev

    cat > "/etc/udev/rules.d/99-evdev.rules" << _EOF_
KERNEL=="event*", NAME="input/%k", MODE="666"
_EOF_
    sudo chmod 666 /dev/input/event*
}

function sources_retroarch() {
    gitPullOrClone "$md_build" git://github.com/libretro/RetroArch.git
    gitPullOrClone "$md_build/overlays" git://github.com/libretro/common-overlays.git
    gitPullOrClone "$md_build/assets" git://github.com/libretro/retroarch-assets.git
}

function build_retroarch() {
    local params=(--disable-x11 --disable-oss --disable-pulse --enable-floathard)
    isPlatform "rpi2" && params+=(--enable-neon)
    ./configure --prefix="$md_inst" ${params[@]}
    make clean
    make
    md_ret_require="$md_build/retroarch"
}

function install_retroarch() {
    make install
    mkdir -p "$md_inst/shader"
    mkdir -p "$md_inst/assets"
    mkdir -p "$md_inst/overlays"
    cp "$scriptdir/supplementary/RetroArchShader/"* "$md_inst/shader/"
    cp -a "$md_build/overlays/"* "$md_inst/overlays/"
    cp -a "$md_build/assets/"* "$md_inst/assets/"
    chown $user:$user -R "$md_inst/shader"
    chown $user:$user -R "$md_inst/assets"
    chown $user:$user -R "$md_inst/overlays"
    md_ret_files=(
        'retroarch.cfg'
        'tools/retroarch-joyconfig'
    )
    md_ret_require="$md_inst/bin/retroarch"
}

function configure_retroarch() {
    if [[ ! -d "$configdir/all/" ]]; then
        mkdir -p "$configdir/all/"
    fi
    cp $scriptdir/supplementary/retroarch-core-options.cfg "$configdir/all/"

    if [[ -f "$configdir/all/retroarch.cfg" ]]; then
        cp "$configdir/all/retroarch.cfg" "$configdir/all/retroarch.cfg.bak"
    fi

    mkdir -p "$configdir/all/"
    cp "$md_inst/retroarch.cfg" "$configdir/all/"

    iniConfig " = " "" "$configdir/all/retroarch.cfg"
    iniSet "system_directory" "$biosdir"
    iniSet "config_save_on_exit" "false"
    iniSet "video_aspect_ratio_auto" "true"
    iniSet "video_smooth" "false"
    iniSet "video_threaded" "true"
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
    iniSet "joypad_autoconfig_dir" "$md_inst/configs/"

    chown $user:$user -R "$configdir"
}
