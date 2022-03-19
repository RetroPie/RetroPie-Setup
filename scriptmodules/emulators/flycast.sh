#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="flycast"
rp_module_desc="Multi-platform Sega Dreamcast, Naomi and Atomiswave emulator derived from Reicast"
rp_module_help="Dreamcast ROM Extensions: .cdi .gdi .chd .m3u, Naomi/Atomiswave ROM Extension: .zip\n\nCopy your Dreamcast/Naomi roms to $romdir/dreamcast\n\nCopy the required Dreamcast BIOS file dc_boot.bin to $biosdir/dc\n\nCopy the required Naomi/Atomiswave BIOS files naomi.zip and awbios.zip to $biosdir/dc"
rp_module_licence="GPL2 https://raw.githubusercontent.com/flyinghead/flycast/master/LICENSE"
rp_module_repo="git https://github.com/flyinghead/flycast.git master"
rp_module_section="opt"
rp_module_flags="!armv6 !videocore !:\$__gcc_version:-lt:9"

function depends_flycast() {
    local depends=(cmake libao-dev libasound2-dev libgles-dev libgl-dev libsdl2-dev libzip-dev libminiupnpc-dev liblua5.3-dev)
    isPlatform "x11" && depends+=(libpulse-dev)
    getDepends "${depends[@]}"
}

function sources_flycast() {
    gitPullOrClone
}

function build_flycast() {
    local params=("-DCMAKE_BUILD_TYPE=Release" "-DUSE_HOST_LIBZIP=ON" "-DUSE_HOST_SDL=ON" "-DUSE_ALSA=ON" "-DUSE_BREAKPAD=OFF")
    if isPlatform "x11"; then
        params+=("-DUSE_PULSEAUDIO=ON")
    else
        params+=("-DUSE_PULSEAUDIO=OFF")
    fi

    if isPlatform "gles3"; then
        params+=("-DUSE_GLES=ON")
    else if isPlatform "gles"; then
            params+=("-DUSE_GLES2=ON")
        fi
    fi
    ! isPlatform "vulkan" && params+=("-DUSE_VULKAN=Off")

    rm -fr build
    mkdir -p build && cd build
    cmake "${params[@]}" ..
    make
    md_ret_require="$md_build/build/flycast"
}

function install_flycast() {
    md_ret_files=(
        'build/flycast'
        'LICENSE'
        'README.md'
    )
}

function configure_flycast() {
    local emu_params=("--config window:height=%YRES%" "--config window:width=%XRES%" "--config window:fullscreen=yes")
    local sys

    for sys in "arcade" "dreamcast"; do
        addSystem "$sys"
        addEmulator 0 "$md_id" "$sys" "$md_inst/flycast ${emu_params[*]} %ROM%"
        [[ "$md_mode" == "install" ]] && mkRomDir "$sys"
    done

    [[ "$md_mode" == "remove" ]] && return

    mkUserDir "$biosdir/dc"
    # Emulator configuration folder (default: $XDG_CONFIG_DIRS/flycast)
    moveConfigDir "$home/.config/flycast" "$md_conf_root/dreamcast"
    # Emulator data folder (default: $XDG_DATA_DIRS/flycast)
    moveConfigDir "$home/.local/share/flycast" "$biosdir/dc"

    # generate a minimal configuration on install
    local temp_conf="$(mktemp)"
    _generate_conf_flycast "$temp_conf"
    copyDefaultConfig "$temp_conf" "$md_conf_root/dreamcast/emu.cfg"

    # add the SDL keyboard mapping on a first installation
    if [[ ! -f "$md_conf_root/dreamcast/mappings/SDL_Keyboard.cfg" ]]; then
        mkdir -p "$md_conf_root/dreamcast/mappings"
        _generate_keyboard_flycast
    fi
    chown -R "$__user":"$__group" "$md_conf_root/dreamcast"
}

# create a slightly modified default keyboard mapping, adding ESC to exit the emulator
function _generate_keyboard_flycast() {
    cat << EOF >> "$md_conf_root/dreamcast/mappings/SDL_Keyboard.cfg"
[digital]
bind0 = 4:btn_d
bind1 = 6:btn_b
bind10 = 27:btn_a
bind11 = 40:btn_start
bind12 = 41:btn_escape
bind13 = 43:btn_menu
bind14 = 44:btn_fforward
bind15 = 69:btn_screenshot
bind16 = 79:btn_dpad1_right
bind17 = 80:btn_dpad1_left
bind18 = 81:btn_dpad1_down
bind19 = 82:btn_dpad1_up
bind2 = 7:btn_y
bind3 = 9:btn_trigger_left
bind4 = 12:btn_analog_up
bind5 = 13:btn_analog_left
bind6 = 14:btn_analog_down
bind7 = 15:btn_analog_right
bind8 = 22:btn_x
bind9 = 25:btn_trigger_right

[emulator]
mapping_name = Keyboard
version = 3
EOF
}

# generate a minimal configuration ('emu.cfg') for Flycast
function _generate_conf_flycast() {
    [ -z "$1" ] && return
    local frame_skip="0"     # 0: no skipping, 1: Normal, 2: Maximum
    local enable_effects="yes" # visual effects toggle

    # enable frame skip on any ARM system
    if isPlatform "arm" || isPlatform "aarch64"; then
        frame_skip="1"
    fi
    # disable video enhancements on low-end platforms
    if isPlatform "armv7" || isPlatform "rpi3"; then
        enable_effects="no"
        frame_skip="2"
    fi

cat << EOF >> "$1"
[config]
BoxartDisplayMode = no
DiscordPresence = no
Dreamcast.ContentPath = $romdir/dreamcast
Dreamcast.BiosPath = $biosdir/dc
Dreamcast.SavePath = $romdir/dreamcast
Dreamcast.SavestatePath = $romdir/dreamcast
Dynarec.Enabled = yes
FetchBoxart = no
pvr.AutoSkipFrame = $frame_skip
rend.ThreadedRendering = yes
rend.DelayFrameSwapping = yes
rend.useMipMaps = $enable_effects
rend.Fog = $enable_effects
rend.ModifierVolumes = $enable_effects

[window]
fullscreen = yes
maximized = yes
EOF
}
