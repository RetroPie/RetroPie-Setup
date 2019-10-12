#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="pcsx2"
rp_module_desc="PS2 emulator PCSX2"
rp_module_help="ROM Extensions: .bin .iso .img .mdf .z .z2 .bz2 .cso .ima .gz\n\nCopy your PS2 roms to $romdir/ps2"
rp_module_licence="GPL3 https://raw.githubusercontent.com/PCSX2/pcsx2/master/COPYING.GPLv3"
rp_module_section="exp"
rp_module_flags="!arm"

function depends_pcsx2() {
    if isPlatform "64bit"; then
        local depends=(gcc cmake gcc-multilib g++ g++-multilib libc6:i386 libncurses5:i386 libstdc++6:i386 libgcc-6-dev:i386 libaio-dev:i386 libbz2-dev:i386 libcggl:i386 libegl1-mesa-dev:i386 libglew-dev:i386 libgles2-mesa-dev libgtk2.0-dev:i386 libjpeg-dev:i386 libsdl1.2-dev:i386 libsoundtouch-dev:i386 libwxgtk3.0-dev:i386 nvidia-cg-toolkit portaudio19-dev:i386 zlib1g-dev:i386 libsdl2-dev:i386 libjack-jackd2-dev:i386 libportaudiocpp0:i386 portaudio19-dev:i386 liblzma-dev:i386 libpcap-dev:i386 libxml2-dev:i386)
        getDepends "${depends[@]}"

        iniConfig " = " '"' "$configdir/all/retropie.cfg"
        iniGet "own_sdl2"
        if [[ "$ini_value" != "0" ]]; then
            if dialog --yesno "PCSX2 cannot be installed on a 64bit system with the RetroPie custom version of SDL2 installed due to version conflicts with the multiarch i386 version of SDL2.\n\nDo you want to downgrade to your OS version of SDL2 and continue to install PCSX2?" 22 76 2>&1 >/dev/tty; then
                chown $user:$user "$configdir/all/retropie.cfg"
                if rp_callModule sdl2 revert; then
                    iniSet "own_sdl2" "0"
                else
                    md_ret_errors+=("Failed to install $md_desc")
                fi
            else
                md_ret_errors+=("$md_desc install aborted.")
            fi
        fi
    fi
}

function sources_pcsx2() {
    local branch="master"
    gitPullOrClone "$md_build" https://github.com/PCSX2/pcsx2.git "$branch"
}

function build_pcsx2() {
    bash -x build.sh
    rm bin/portable.ini
}

function install_pcsx2() {
    md_ret_files=(
        'bin'
    )
}

function configure_pcsx2() {
    mkRomDir "ps2"
    mkUserDir "$biosdir/ps2"
    moveConfigDir "$home/PCSX2" "$md_conf_root/ps2"
    mkUserDir "$md_conf_root/ps2/bios"
    local bios
    BIOSs=`cat "$md_data/bioslist"`
    for bios in $BIOSs; do
        ln -sf "$biosdir/ps2/$bios" "$md_conf_root/ps2/bios/$bios"
    done
    addEmulator 0 "$md_id-nogui" "ps2" "$md_inst/bin/PCSX2 %ROM% --fullscreen --nogui"
    addEmulator 1 "$md_id" "ps2" "$md_inst/bin/PCSX2 %ROM% --windowed"

    addSystem "ps2"
}
