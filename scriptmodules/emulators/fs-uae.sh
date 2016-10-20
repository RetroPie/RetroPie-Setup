#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="fs-uae"
rp_module_desc="Amiga emulator - FS-UAE integrates the most accurate Amiga emulation code available from WinUAE"
rp_module_help="ROM Extension: .adf"
rp_module_section="exp"
rp_module_flags="!arm"

function depends_fs-uae() {
    case "$__os_id" in
        Ubuntu)
            if [[ "$md_mode" == "install" ]]; then
                apt-add-repository -y ppa:fengestad/stable
            else
                apt-add-repository -r -y ppa:fengestad/stable
            fi
            aptUpdate
            ;;
        Debian)
            if [[ "$md_mode" == "install" ]]; then
                echo "deb http://download.opensuse.org/repositories/home:/FrodeSolheim:/stable/Debian_8.0/ /" > /etc/apt/sources.list.d/fsuae-stable.list
            else
                rm -f /etc/apt/sources.list.d/fsuae-stable.list
            fi
            aptUpdate
            ;;
    esac
}

function install_bin_fs-uae() {
    aptInstall fs-uae fs-uae-launcher fs-uae-arcade
}

function remove_fs-uae() {
    aptRemove fs-uae fs-uae-launcher fs-uae-arcade
}

function configure_fs-uae() {
    mkRomDir "amiga"

    mkUserDir "$home/.config"
    mkUserDir "$md_conf_root/amiga"
    moveConfigDir "$home/.config/fs-uae" "$md_conf_root/amiga/fs-uae"

    cat > "$romdir/amiga/+Start FS-UAE.sh" << _EOF_
#!/bin/bash
fs-uae-launcher
_EOF_
    chmod a+x "$romdir/amiga/+Start FS-UAE.sh"
    chown $user:$user "$romdir/amiga/+Start FS-UAE.sh"

    addSystem 1 "$md_id" "amiga" "bash $romdir/amiga/+Start\ FS-UAE.sh" "Amiga" ".sh"
}
