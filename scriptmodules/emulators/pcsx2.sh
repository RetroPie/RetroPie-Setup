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

function install_bin_pcsx2() {
    aptInstall pcsx2
}

function remove_pcsx2() {
    aptRemove pcsx2
}

function configure_pcsx2() {
    mkRomDir "ps2"

    addEmulator 0 "$md_id-nogui" "ps2" "PCSX2 %ROM% --fullscreen --nogui"
    addEmulator 1 "$md_id" "ps2" "PCSX2 %ROM% --windowed"
    addSystem "ps2"
}
