#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="daphne"
rp_module_desc="Daphne - Laserdisc Emulator"
rp_module_help="ROM Extension: .daphne\n\nCopy your Daphne roms to $romdir/daphne"
rp_module_licence="GPL2 https://raw.githubusercontent.com/RetroPie/daphne-emu/master/COPYING"
rp_module_repo="git https://github.com/RetroPie/daphne-emu.git retropie"
rp_module_section="opt"
rp_module_flags="sdl1 !x86 !mali"

function depends_daphne() {
    getDepends libsdl1.2-dev libvorbis-dev libglew-dev zlib1g-dev
}

function sources_daphne() {
    gitPullOrClone
}

function build_daphne() {
    local params=()
    isPlatform "aarch64" && params=(--build=arm)
    cd src/vldp2
    ./configure "${params[@]}"
    make -f Makefile.rp
    cd ..
    ln -sf Makefile.vars.rp Makefile.vars
    make STATIC_VLDP=1
    md_ret_require="$md_build/daphne.bin"
}

function install_daphne() {
    md_ret_files=(
        'sound'
        'pics'
        'daphne.bin'
        'COPYING'
    )
}

function configure_daphne() {
    mkRomDir "daphne"
    mkRomDir "daphne/roms"

    addEmulator 1 "$md_id" "daphne" "$md_inst/daphne.sh %ROM%"
    addSystem "daphne"

    [[ "$md_mode" == "remove" ]] && return

    mkUserDir "$md_conf_root/daphne"

    isPlatform "dispmanx" && setBackend "$md_id" "dispmanx"

    if [[ ! -f "$md_conf_root/daphne/dapinput.ini" ]]; then
        cp -v "$md_data/dapinput.ini" "$md_conf_root/daphne/dapinput.ini"
    fi
    ln -snf "$romdir/daphne/roms" "$md_inst/roms"
    ln -sf "$md_conf_root/$md_id/dapinput.ini" "$md_inst/dapinput.ini"

    cat >"$md_inst/daphne.sh" <<_EOF_
#!/bin/bash
dir="\$1"
name="\${dir##*/}"
name="\${name%.*}"

if [[ -f "\$dir/\$name.commands" ]]; then
    params=\$(<"\$dir/\$name.commands")
fi

"$md_inst/daphne.bin" "\$name" vldp -nohwaccel -framefile "\$dir/\$name.txt" -homedir "$md_inst" -fullscreen \$params
_EOF_
    chmod +x "$md_inst/daphne.sh"

    chown -R $user:$user "$md_inst"
    chown -R $user:$user "$md_conf_root/daphne/dapinput.ini"

}
