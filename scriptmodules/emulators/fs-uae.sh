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
rp_module_help="ROM Extension: .adf  .adz .dms .ipf .zip\n\nCopy your Amiga games to $romdir/amiga\n\nCopy a required BIOS file (e.g. kick13.rom) to $biosdir"
rp_module_licence="GPL2 https://raw.githubusercontent.com/FrodeSolheim/fs-uae/master/COPYING"
rp_module_section="exp"
rp_module_flags="!all !arm x11"

function depends_fs-uae() {
    case "$__os_id" in
        Debian)
            local apt_file="/etc/apt/sources.list.d/fsuae-stable.list"
            if [[ "$md_mode" == "install" ]]; then
                local name
                case "$__os_debian_ver" in
                    9)
                        name="Debian_9.0"
                        ;;
                    10)
                        name="Debian_10"
                        ;;
                    *)
                        md_ret_errors+=("Sorry, fs-uae isn't currently available for Debian $__os_debian_ver")
                        return 1
                        ;;
                esac
                # add repository and key
                local repo="http://download.opensuse.org/repositories/home:/FrodeSolheim:/stable/$name"
                echo "deb $repo/ /" > "$apt_file"
                download "$repo/Release.key" - | apt-key add -
            else
                # remove repository and key
                rm -f "$apt_file"
                # remove key by email
                gpg --keyring /etc/apt/trusted.gpg --batch --yes --delete-keys "home:FrodeSolheim@build.opensuse.org" &>/dev/null
            fi
            aptUpdate
            ;;
        *)
            # check if we are running on an Ubuntu based OS.
            if [[ -n "$__os_ubuntu_ver" ]]; then
                if [[ "$md_mode" == "install" ]]; then
                    apt-add-repository -y ppa:fengestad/stable
                else
                    apt-add-repository -r -y ppa:fengestad/stable
                fi
                aptUpdate
            else
                md_ret_errors+=("Sorry, but $__os_id is not supported by fs-uae")
                return 1
            fi
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

    # copy configuring start script
    mkdir "$md_inst/bin"
    cp "$md_data/fs-uae.sh" "$md_inst/bin"
    chmod +x "$md_inst/bin/fs-uae.sh"

    mkUserDir "$md_conf_root/amiga"
    mkUserDir "$home/Documents/FS-UAE"
    mkUserDir "$home/Documents/FS-UAE/Configurations"
    moveConfigDir "$home/Documents/FS-UAE/Configurations" "$md_conf_root/amiga/fs-uae"

    # copy default config file
    local config="$(mktemp)"
    iniConfig " = " "" "$config"
    iniSet "fullscreen" "1"
    iniSet "keep_aspect" "1"
    iniSet "zoom" "full"
    iniSet "fsaa" "0"
    iniSet "scanlines" "0"
    iniSet "floppy_drive_speed" "100"
    copyDefaultConfig "$config" "$md_conf_root/amiga/fs-uae/Default.fs-uae"
    rm "$config"

    addEmulator 1 "$md_id" "amiga" "CON:bash $md_inst/bin/fs-uae.sh %ROM%"
    addSystem "amiga"
}
