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
rp_module_help="ROM Extensions: .bin .iso .img .mdf .z .z2 .bz2 .cso .chd .ima .gz\n\nCopy your PS2 roms to $romdir/ps2\n\nCopy the required BIOS file to $biosdir"
rp_module_licence="GPL3 https://raw.githubusercontent.com/PCSX2/pcsx2/master/COPYING.GPLv3"
rp_module_section="exp"
rp_module_flags="!all x86"

function _64bit_available_pcsx2() {
    # detect if a 64bit version for pcsx2 is available in the Ubuntu PPA
    if [[ -n "${__os_ubuntu_ver}" ]] && compareVersions "${__os_ubuntu_ver}" ge 21.04; then
        return 0
    fi

    return 1
}
function depends_pcsx2() {
    if isPlatform "64bit" && ! _64bit_available_pcsx2 ; then
        iniConfig " = " '"' "$configdir/all/retropie.cfg"
        iniGet "own_sdl2"
        if [[ "$ini_value" != "0" ]]; then
            if dialog --yesno "PCSX2 cannot be installed on a 64bit system with the RetroPie custom version of SDL2 installed due to version conflicts with the multiarch i386 version of SDL2.\n\nDo you want to downgrade to your OS version of SDL2 and continue to install PCSX2?" 22 76 2>&1 >/dev/tty; then
                chown "$__user":"$__group" "$configdir/all/retropie.cfg"
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

    if [[ "$md_mode" == "install" ]]; then
        # On Ubuntu, add the PCSX2 PPA to get the latest version
        [[ -n "${__os_ubuntu_ver}" ]] && add-apt-repository -y ppa:pcsx2-team/pcsx2-daily
        if ! _64bit_available_pcsx2 ; then
            dpkg --add-architecture i386
        fi
    else
        rm -f /etc/apt/sources.list.d/pcsx2-team-ubuntu-pcsx2-daily-*.list
        apt-key del "D7B4 49CF E17E 659E 5A12  EE8E DD6E EEA2 BD74 7717" >/dev/null
    fi
}

function install_bin_pcsx2() {
    local version
    [[ -n "${__os_ubuntu_ver}" ]] && version="-unstable"

    aptInstall "pcsx2$version"
}

function remove_pcsx2() {
    local version
    [[ -n "${__os_ubuntu_ver}" ]] && version="-unstable"

    aptRemove "pcsx2$version"
    rp_callModule pcsx2 depends remove
}

function configure_pcsx2() {
    mkRomDir "ps2"

    # detect if the new (QT) UI is installed and add the fullscreen/windowed commands
    if [[ -f /usr/bin/pcsx2-qt ]]; then
        addEmulator 0 "$md_id" "ps2" "pcsx2-qt -nofullscreen %ROM%"
        addEmulator 1 "$md_id-nogui" "ps2" "pcsx2-qt -fullscreen -nogui %ROM%"
    else
        local emu_path="/usr/games/PCSX2"
        [[ -f "/usr/games/pcsx2" ]] && emu_path="/usr/games/pcsx2"
        addEmulator 0 "$md_id" "ps2" "$emu_path --windowed %ROM%"
        addEmulator 1 "$md_id-nogui" "ps2" "$emu_path --fullscreen --nogui %ROM%"
    fi

    addSystem "ps2"
}
