#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="drastic"
rp_module_desc="NDS emu - DraStic"
rp_module_help="ROM Extensions: .nds .zip\n\nCopy your Nintendo DS roms to $romdir/nds"
rp_module_licence="PROP"
rp_module_section="exp"
rp_module_flags="!all arm !armv6 !mali"

function depends_drastic() {
    local depends=(libasound2-dev libsdl2-dev zlib1g-dev)
    if isPlatform "kms" && ! isPlatform "x11"; then
        depends+=(matchbox-window-manager xorg xserver-xorg-input-all)
    fi

    getDepends ${depends[@]}
}

function __binary_url_drastic() {
   echo "$__archive_url/drastic-2.5.0.4.tar.gz"
}

function install_bin_drastic() {
    downloadAndExtract "$(__binary_url_drastic)" "$md_inst" --strip-components 1
}

function configure_drastic() {
    mkRomDir "nds"

    # wrong permissions on game_database.xml
    chmod 644 "$md_inst/game_database.xml"

    mkUserDir "$md_conf_root/nds/drastic"
    mkUserDir "$md_conf_root/nds/drastic/system"

    local file
    for file in game_database.xml system/drastic_bios_arm7.bin system/drastic_bios_arm9.bin usrcheat.dat drastic_logo_0.raw drastic_logo_1.raw; do
        ln -sfv "$md_inst/$file" "$md_conf_root/nds/drastic/$file"
    done

    if [[ "$md_mode" == "install" ]]; then
        cat > "$md_inst/drastic.sh" << _EOF_
#!/bin/bash
# Don't start a window manager on x11 platforms
if [[ -n \$DISPLAY && "\$2" == "kms" ]]; then
    matchbox-window-manager -use_cursor no &
    sleep 0.5
fi
pushd "$md_conf_root/nds/drastic"
$md_inst/drastic "\$1"
popd
_EOF_
        chmod +x "$md_inst/drastic.sh"
    fi

    # Launch DraStic in an x11 session for KMS platforms
    if isPlatform "kms" && ! isPlatform "x11"; then
        addEmulator 1 "$md_id" "nds" "XINIT:$md_inst/drastic.sh %ROM% kms"
    else
        addEmulator 1 "$md_id" "nds" "$md_inst/drastic.sh %ROM%"
    fi

    addSystem "nds"
}
