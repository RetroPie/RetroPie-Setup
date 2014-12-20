rp_module_id="retroarch"
rp_module_desc="RetroArch"
rp_module_menus="2+"

function depends_retroarch() {
    checkNeededPackages libudev-dev libxkbcommon-dev
    cat > "/etc/udev/rules.d/99-evdev.rules" << _EOF_
KERNEL=="event*", NAME="input/%k", MODE="666"
_EOF_
    sudo chmod 666 /dev/input/event*
}

function sources_retroarch() {
    gitPullOrClone "$md_build" git://github.com/libretro/RetroArch.git
}

function build_retroarch() {
    ./configure --prefix="$md_inst" --disable-x11 --disable-oss --disable-pulse --enable-floathard
    make clean
    make
    md_ret_require="$md_build/retroarch"
}

function install_retroarch() {
    make install
    mkdir -p "$md_inst/shader"
    cp "$scriptdir/supplementary/RetroArchShader/"* "$md_inst/shader/"
    md_ret_files=(
        'retroarch.cfg'
        'tools/retroarch-joyconfig'
    )
    md_ret_require="$md_inst/bin/retroarch"
}

function ensureSystemretroconfig {
    if [[ ! -d "$configdir/$1/" ]]; then
        mkdir -p "$configdir/$1/"
        echo -e "# All settings made here will override the global settings for the current emulator core\n" >> $configdir/$1/retroarch.cfg
    fi
}

function configure_retroarch() {
    cp $scriptdir/supplementary/retroarch-zip "$md_inst"

    if [[ ! -d "$configdir/all/" ]]; then
        mkdir -p "$configdir/all/"
    fi
    cp $scriptdir/supplementary/retroarch-core-options.cfg "$configdir/all/"

    if [[ -f "$configdir/all/retroarch.cfg" ]]; then
        cp "$configdir/all/retroarch.cfg" "$configdir/all/retroarch.cfg.bak"
    fi

    mkdir -p "$configdir/all/"
    cp "$md_inst/retroarch.cfg" "$configdir/all/"

    ensureSystemretroconfig "atari2600"
    ensureSystemretroconfig "cavestory"
    ensureSystemretroconfig "doom"
    ensureSystemretroconfig "gb"
    ensureSystemretroconfig "gbc"
    ensureSystemretroconfig "gamegear"
    ensureSystemretroconfig "mame"
    ensureSystemretroconfig "mastersystem"
    ensureSystemretroconfig "megadrive"
    ensureSystemretroconfig "nes"
    ensureSystemretroconfig "pcengine"
    ensureSystemretroconfig "psx"
    ensureSystemretroconfig "snes"
    ensureSystemretroconfig "segacd"
    ensureSystemretroconfig "sega32x"
    ensureSystemretroconfig "fba"

    mkdir -p "$romdir/../BIOS/"
    chown $user:$user "$romdir/../BIOS/"
    ensureKeyValue "system_directory" "$romdir/../BIOS" "$configdir/all/retroarch.cfg"
    ensureKeyValue "config_save_on_exit" "false" "$configdir/all/retroarch.cfg"
    ensureKeyValue "video_aspect_ratio" "1.33" "$configdir/all/retroarch.cfg"
    ensureKeyValue "video_smooth" "false" "$configdir/all/retroarch.cfg"
    ensureKeyValue "video_threaded" "true" "$configdir/all/retroarch.cfg"
    ensureKeyValue "core_options_path" "$configdir/all/retroarch-core-options.cfg" "$configdir/all/retroarch.cfg"

    # enable hotkey ("select" button)
    ensureKeyValue "input_enable_hotkey" "nul" "$configdir/all/retroarch.cfg"
    ensureKeyValue "input_exit_emulator" "escape" "$configdir/all/retroarch.cfg"

    # enable and configure rewind feature
    ensureKeyValue "rewind_enable" "false" "$configdir/all/retroarch.cfg"
    ensureKeyValue "rewind_buffer_size" "10" "$configdir/all/retroarch.cfg"
    ensureKeyValue "rewind_granularity" "2" "$configdir/all/retroarch.cfg"
    ensureKeyValue "input_rewind" "r" "$configdir/all/retroarch.cfg"

    # enable gpu screenshots
    ensureKeyValue "video_gpu_screenshot" "true" "$configdir/all/retroarch.cfg"

    # enable and configure shaders
    mkdir -p "$md_inst/shader"

    ensureKeyValue "input_shader_next" "m" "$configdir/all/retroarch.cfg"
    ensureKeyValue "input_shader_prev" "n" "$configdir/all/retroarch.cfg"
    ensureKeyValue "video_shader_dir" "$md_inst/shader/" "$configdir/all/retroarch.cfg"

    # system-specific shaders, SNES
    ensureKeyValue "video_shader" "\"$md_inst/shader/snes_phosphor.glslp\"" "$configdir/snes/retroarch.cfg"
    ensureKeyValue "video_shader_enable" "false" "$configdir/snes/retroarch.cfg"
    ensureKeyValue "video_smooth" "false" "$configdir/snes/retroarch.cfg"

    # system-specific shaders, NES
    ensureKeyValue "video_shader" "\"$md_inst/shader/phosphor.glslp\"" "$configdir/nes/retroarch.cfg"
    ensureKeyValue "video_shader_enable" "false" "$configdir/nes/retroarch.cfg"
    ensureKeyValue "video_smooth" "false" "$configdir/nes/retroarch.cfg"

    # system-specific shaders, Megadrive
    ensureKeyValue "video_shader" "\"$md_inst/shader/phosphor.glslp\"" "$configdir/megadrive/retroarch.cfg"
    ensureKeyValue "video_shader_enable" "false" "$configdir/megadrive/retroarch.cfg"
    ensureKeyValue "video_smooth" "false" "$configdir/megadrive/retroarch.cfg"

    # system-specific shaders, Mastersystem
    ensureKeyValue "video_shader" "\"$md_inst/shader/phosphor.glslp\"" "$configdir/mastersystem/retroarch.cfg"
    ensureKeyValue "video_shader_enable" "false" "$configdir/mastersystem/retroarch.cfg"
    ensureKeyValue "video_smooth" "false" "$configdir/mastersystem/retroarch.cfg"

    # system-specific shaders, Gameboy
    ensureKeyValue "video_shader" "\"$md_inst/shader/hq4x.glslp\"" "$configdir/gb/retroarch.cfg"
    ensureKeyValue "video_shader_enable" "false" "$configdir/gb/retroarch.cfg"

    # system-specific shaders, Gameboy Color
    ensureKeyValue "video_shader" "\"$md_inst/shader/hq4x.glslp\"" "$configdir/gbc/retroarch.cfg"
    ensureKeyValue "video_shader_enable" "false" "$configdir/gbc/retroarch.cfg"

    # system-specific, PSX
    ensureKeyValue "rewind_enable" "false" "$configdir/psx/retroarch.cfg"

    # configure keyboard mappings
    ensureKeyValue "input_player1_a" "x" "$configdir/all/retroarch.cfg"
    ensureKeyValue "input_player1_b" "z" "$configdir/all/retroarch.cfg"
    ensureKeyValue "input_player1_y" "a" "$configdir/all/retroarch.cfg"
    ensureKeyValue "input_player1_x" "s" "$configdir/all/retroarch.cfg"
    ensureKeyValue "input_player1_start" "enter" "$configdir/all/retroarch.cfg"
    ensureKeyValue "input_player1_select" "rshift" "$configdir/all/retroarch.cfg"
    ensureKeyValue "input_player1_l" "q" "$configdir/all/retroarch.cfg"
    ensureKeyValue "input_player1_r" "w" "$configdir/all/retroarch.cfg"
    ensureKeyValue "input_player1_left" "left" "$configdir/all/retroarch.cfg"
    ensureKeyValue "input_player1_right" "right" "$configdir/all/retroarch.cfg"
    ensureKeyValue "input_player1_up" "up" "$configdir/all/retroarch.cfg"
    ensureKeyValue "input_player1_down" "down" "$configdir/all/retroarch.cfg"

    # input settings
    ensureKeyValue "input_autodetect_enable" "true" "$configdir/all/retroarch.cfg"
    ensureKeyValue "joypad_autoconfig_dir" "$md_inst/configs/" "$configdir/all/retroarch.cfg"

    chown $user:$user -R "$md_inst/shader/"
    chown $user:$user -R "$configdir/"
}