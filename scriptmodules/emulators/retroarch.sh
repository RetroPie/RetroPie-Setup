rp_module_id="retroarch"
rp_module_desc="RetroArch"
rp_module_menus="2+"

function depends_retroarch() {
    rps_checkNeededPackages libudev-dev libxkbcommon-dev
    cat > "/etc/udev/rules.d/99-evdev.rules" << _EOF_
KERNEL=="event*", NAME="input/%k", MODE="666"
_EOF_
    sudo chmod 666 /dev/input/event*
}

function sources_retroarch() {
    gitPullOrClone "$rootdir/emulators/RetroArch" git://github.com/libretro/RetroArch.git
}

function build_retroarch() {
    pushd "$rootdir/emulators/RetroArch"
    ./configure --prefix="$rootdir/emulators/RetroArch/installdir" --disable-x11 --disable-oss --disable-pulse --enable-floathard
    make clean
    make
    popd
}

function install_retroarch() {
    pushd "$rootdir/emulators/RetroArch"
    make install
    popd
    if [[ ! -f "$rootdir/emulators/RetroArch/installdir/bin/retroarch" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile and install RetroArch."
    fi
}

function ensureSystemretroconfig {
    if [[ ! -d "$rootdir/configs/$1/" ]]; then
        mkdir -p "$rootdir/configs/$1/"
        echo -e "# All settings made here will override the global settings for the current emulator core\n" >> $rootdir/configs/$1/retroarch.cfg
    fi
}

function configure_retroarch() {
    cp $scriptdir/supplementary/retroarch-zip "$rootdir/emulators/RetroArch/installdir/bin/"

    if [[ ! -d "$rootdir/configs/all/" ]]; then
        mkdir -p "$rootdir/configs/all/"
    fi
    cp $scriptdir/supplementary/retroarch-core-options.cfg "$rootdir/configs/all/"
    chown $user:$user "$rootdir/configs/all/retroarch-core-options.cfg"

    if [[ -f "$rootdir/configs/all/retroarch.cfg" ]]; then
        cp "$rootdir/configs/all/retroarch.cfg" "$rootdir/configs/all/retroarch.cfg.bak"
    fi
    cp $rootdir/emulators/RetroArch/retroarch.cfg "$rootdir/configs/all/"
    chown $user:$user "$rootdir/configs/all/retroarch.cfg"
    mkdir -p "$rootdir/configs/all/"

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
    ensureSystemretroconfig "msx"
    ensureSystemretroconfig "lynx"
    ensureSystemretroconfig "quake"

    mkdir -p "$romdir/../BIOS/"
    ensureKeyValue "system_directory" "$romdir/../BIOS" "$rootdir/configs/all/retroarch.cfg"
    ensureKeyValue "config_save_on_exit" "false" "$rootdir/configs/all/retroarch.cfg"
    ensureKeyValue "video_aspect_ratio" "1.33" "$rootdir/configs/all/retroarch.cfg"
    ensureKeyValue "video_smooth" "false" "$rootdir/configs/all/retroarch.cfg"
    ensureKeyValue "video_threaded" "true" "$rootdir/configs/all/retroarch.cfg"
    ensureKeyValue "core_options_path" "$rootdir/configs/all/retroarch-core-options.cfg" "$rootdir/configs/all/retroarch.cfg"

    # enable hotkey ("select" button)
    ensureKeyValue "input_enable_hotkey" "nul" "$rootdir/configs/all/retroarch.cfg"
    ensureKeyValue "input_exit_emulator" "escape" "$rootdir/configs/all/retroarch.cfg"

    # enable and configure rewind feature
    ensureKeyValue "rewind_enable" "false" "$rootdir/configs/all/retroarch.cfg"
    ensureKeyValue "rewind_buffer_size" "10" "$rootdir/configs/all/retroarch.cfg"
    ensureKeyValue "rewind_granularity" "2" "$rootdir/configs/all/retroarch.cfg"
    ensureKeyValue "input_rewind" "r" "$rootdir/configs/all/retroarch.cfg"

    # enable gpu screenshots
    ensureKeyValue "video_gpu_screenshot" "true" "$rootdir/configs/all/retroarch.cfg"

    # enable and configure shaders
    if [[ ! -d "$rootdir/emulators/RetroArch/shader" ]]; then
        mkdir -p "$rootdir/emulators/RetroArch/shader"
    fi
    cp -r $scriptdir/supplementary/RetroArchShader/* $rootdir/emulators/RetroArch/shader/
    for f in `ls "$rootdir/emulators/RetroArch/shader/*.glslp"`;
    do
        sed -i "s|/home/pi/RetroPie|$rootdir|g" $f
    done

    ensureKeyValue "input_shader_next" "m" "$rootdir/configs/all/retroarch.cfg"
    ensureKeyValue "input_shader_prev" "n" "$rootdir/configs/all/retroarch.cfg"
    ensureKeyValue "video_shader_dir" "$rootdir/emulators/RetroArch/shader/" "$rootdir/configs/all/retroarch.cfg"

    # system-specific shaders, SNES
    ensureKeyValue "video_shader" "\"$rootdir/emulators/RetroArch/shader/snes_phosphor.glslp\"" "$rootdir/configs/snes/retroarch.cfg"
    ensureKeyValue "video_shader_enable" "false" "$rootdir/configs/snes/retroarch.cfg"
    ensureKeyValue "video_smooth" "false" "$rootdir/configs/snes/retroarch.cfg"

    # system-specific shaders, NES
    ensureKeyValue "video_shader" "\"$rootdir/emulators/RetroArch/shader/phosphor.glslp\"" "$rootdir/configs/nes/retroarch.cfg"
    ensureKeyValue "video_shader_enable" "false" "$rootdir/configs/nes/retroarch.cfg"
    ensureKeyValue "video_smooth" "false" "$rootdir/configs/nes/retroarch.cfg"

    # system-specific shaders, Megadrive
    ensureKeyValue "video_shader" "\"$rootdir/emulators/RetroArch/shader/phosphor.glslp\"" "$rootdir/configs/megadrive/retroarch.cfg"
    ensureKeyValue "video_shader_enable" "false" "$rootdir/configs/megadrive/retroarch.cfg"
    ensureKeyValue "video_smooth" "false" "$rootdir/configs/megadrive/retroarch.cfg"

    # system-specific shaders, Mastersystem
    ensureKeyValue "video_shader" "\"$rootdir/emulators/RetroArch/shader/phosphor.glslp\"" "$rootdir/configs/mastersystem/retroarch.cfg"
    ensureKeyValue "video_shader_enable" "false" "$rootdir/configs/mastersystem/retroarch.cfg"
    ensureKeyValue "video_smooth" "false" "$rootdir/configs/mastersystem/retroarch.cfg"

    # system-specific shaders, Gameboy
    ensureKeyValue "video_shader" "\"$rootdir/emulators/RetroArch/shader/hq4x.glslp\"" "$rootdir/configs/gb/retroarch.cfg"
    ensureKeyValue "video_shader_enable" "false" "$rootdir/configs/gb/retroarch.cfg"

    # system-specific shaders, Gameboy Color
    ensureKeyValue "video_shader" "\"$rootdir/emulators/RetroArch/shader/hq4x.glslp\"" "$rootdir/configs/gbc/retroarch.cfg"
    ensureKeyValue "video_shader_enable" "false" "$rootdir/configs/gbc/retroarch.cfg"

    # system-specific, PSX
    ensureKeyValue "rewind_enable" "false" "$rootdir/configs/psx/retroarch.cfg"

    # configure keyboard mappings
    ensureKeyValue "input_player1_a" "x" "$rootdir/configs/all/retroarch.cfg"
    ensureKeyValue "input_player1_b" "z" "$rootdir/configs/all/retroarch.cfg"
    ensureKeyValue "input_player1_y" "a" "$rootdir/configs/all/retroarch.cfg"
    ensureKeyValue "input_player1_x" "s" "$rootdir/configs/all/retroarch.cfg"
    ensureKeyValue "input_player1_start" "enter" "$rootdir/configs/all/retroarch.cfg"
    ensureKeyValue "input_player1_select" "rshift" "$rootdir/configs/all/retroarch.cfg"
    ensureKeyValue "input_player1_l" "q" "$rootdir/configs/all/retroarch.cfg"
    ensureKeyValue "input_player1_r" "w" "$rootdir/configs/all/retroarch.cfg"
    ensureKeyValue "input_player1_left" "left" "$rootdir/configs/all/retroarch.cfg"
    ensureKeyValue "input_player1_right" "right" "$rootdir/configs/all/retroarch.cfg"
    ensureKeyValue "input_player1_up" "up" "$rootdir/configs/all/retroarch.cfg"
    ensureKeyValue "input_player1_down" "down" "$rootdir/configs/all/retroarch.cfg"

    # input settings
    ensureKeyValue "input_autodetect_enable" "true" "$rootdir/configs/all/retroarch.cfg"
    ensureKeyValue "joypad_autoconfig_dir" "$rootdir/emulators/RetroArch/configs/" "$rootdir/configs/all/retroarch.cfg"

    chown $user:$user -R "$rootdir/emulators/RetroArch/shader/"
    chown $user:$user -R "$rootdir/configs/"
}
