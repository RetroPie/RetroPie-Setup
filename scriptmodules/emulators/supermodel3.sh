#!/usr/bin/env bash
 
# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="supermodel3"
rp_module_desc="Super Model 3 Emulator"
rp_module_help="ROM Addition: Copy your roms to $romdir/arcade"
rp_module_licence="GPL3 https://raw.githubusercontent.com/DirtBagXon/model3emu-code-sinden/main/Docs/LICENSE.txt"
rp_module_repo="git https://github.com/DirtBagXon/model3emu-code-sinden.git arm"
rp_module_section="exp"
rp_module_flags="sdl2"

function depends_supermodel3() {

    getDepends xinit libsdl2-dev libsdl2-net-dev libsdl2-net-2.0-0 x11-xserver-utils xserver-xorg

    aptRemove xserver-xorg-legacy

    if [[ "$__os_debian_ver" -eq 12 ]]; then
        getDepends gldriver-test
    fi
}

function sources_supermodel3() {
    gitPullOrClone
}

function build_supermodel3() {
    cp Makefiles/Makefile.UNIX Makefile
    make clean
    make NET_BOARD=1
    cp Docs/LICENSE.txt LICENSE
    cp bin/supermodel supermodel3
    md_ret_require="supermodel3"
}

function install_supermodel3() {
    md_ret_files=(
        'supermodel3'
        'Config'
        'LICENSE'
    )
}

function configure_supermodel3() {

    mkRomDir "arcade"
    
    addEmulator 0 "$md_id" "arcade" "XINIT:$md_inst/supermodel3.sh %ROM%"
    addSystem "arcade"

    [[ "$md_mode" == "remove" ]] && return

    mkUserDir "$md_conf_root/$md_id"
    mkUserDir "$md_conf_root/$md_id/Saves"
    mkUserDir "$md_conf_root/$md_id/NVRAM"

    ln -snf "$md_conf_root/$md_id/NVRAM" "$md_inst/NVRAM"
    ln -snf "$md_conf_root/$md_id/NVRAM" "$home/NVRAM"
    ln -snf "$md_conf_root/$md_id/Saves" "$md_inst/Saves"
    ln -snf "$md_conf_root/$md_id/Saves" "$home/Saves"
    ln -snf "$md_conf_root/$md_id" "$home/Config"
    ln -snf "$md_conf_root/$md_id" "$md_inst/LocalConfig"
    ln -snf "$md_conf_root/$md_id" "$home/LocalConfig"

    copyDefaultConfig "$md_inst/Config/Supermodel.ini" "$md_conf_root/$md_id/Supermodel.ini"
    copyDefaultConfig "$md_inst/Config/Games.xml" "$md_conf_root/$md_id/Games.xml"

    rm -rf "$md_inst/Config"
    chown -R $user:$user "$md_inst"
    chown -R $user:$user "$md_conf_root/$md_id"

    cat >"$md_inst/supermodel3.sh" <<_EOF_
#!/bin/bash

commands="\${1%.*}.commands"

if [[ -f "\$commands" ]]; then
	params=\$(<"\$commands" tr -d '\r' | tr '\n' ' ')
fi

$md_inst/supermodel3 \$params \$1
_EOF_
    chmod +x "$md_inst/supermodel3.sh"
}
