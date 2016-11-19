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
rp_module_help="ROM Extension: .adf .ipf .dms .adz .zip\n\nCopy your Amiga games to $romdir/amiga\n\nCopy the required kickstart file kick13.bin to $biosdir"
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
    aptInstall fs-uae
}

function remove_fs-uae() {
    aptRemove fs-uae
}

function configure_fs-uae() {
    mkRomDir "amiga"

    mkUserDir "$md_conf_root/amiga"
    mkUserDir "$md_conf_root/amiga/$md_id"
    
    # copy configuring start script
    mkdir "$md_inst/bin/"
    cp "$scriptdir/scriptmodules/$md_type/$md_id/fs-uae.sh" "$md_inst/bin/"
    chmod +x "$md_inst/bin/fs-uae.sh"

    # copy default config file
    cp -v "$scriptdir/scriptmodules/$md_type/$md_id/default_cfg.fs-uae" "$md_conf_root/amiga"
    
    mkUserDir "$home/.config"
    mkUserDir "$md_conf_root/amiga"
    moveConfigDir "$home/.config/fs-uae" "$md_conf_root/amiga/fs-uae"

    addSystem 1 "$md_id" "amiga" "bash $md_inst/bin/fs-uae.sh %ROM%" Amiga ".adf .ipf .dms .adz .zip"
}
