#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="hypseus"
rp_module_desc="Hypseus Singe - Laserdisc Emulator"
rp_module_help="ROM Extension: .daphne\n\nCopy your Daphne roms to $romdir/daphne"
rp_module_licence="GPL3 https://raw.githubusercontent.com/DirtBagXon/hypseus-singe/master/LICENSE"
rp_module_repo="git https://github.com/DirtBagXon/hypseus-singe.git RetroPie"
rp_module_section="exp"
rp_module_flags="sdl2"

function depends_hypseus() {
    getDepends libvorbis-dev libogg-dev zlib1g-dev libzip-dev libmpeg2-4-dev libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev cmake
}

function sources_hypseus() {
    gitPullOrClone
}

function build_hypseus() {
    rm -rf build
    mkdir build
    cd build
    rpSwap on 1024
    cmake ../src
    make
    rpSwap off
    cp hypseus ../hypseus.bin
    md_ret_require="hypseus"
}

function install_hypseus() {
    md_ret_files=(
        'sound'
        'pics'
        'fonts'
        'hypseus.bin'
        'LICENSE'
    )
}

function configure_hypseus() {
    mkRomDir "daphne"
    mkRomDir "daphne/roms"

    addEmulator 0 "$md_id" "daphne" "$md_inst/hypseus.sh %ROM%"
    addSystem "daphne"

    [[ "$md_mode" == "remove" ]] && return

    mkUserDir "$md_conf_root/daphne"

    local dir
    for dir in ram logs screenshots bezels; do
        mkUserDir "$md_conf_root/daphne/$dir"
        ln -snf "$md_conf_root/daphne/$dir" "$md_inst/$dir"
    done

    copyDefaultConfig "$md_data/hypinput.ini" "$md_conf_root/daphne/hypinput.ini"

    ln -snf "$romdir/daphne/roms" "$md_inst/roms"
    ln -snf "$romdir/daphne/roms" "$md_inst/singe"

    ln -sf "$md_conf_root/daphne/hypinput.ini" "$md_inst/hypinput.ini"

    local common_args="-framefile \"\$dir/\$name.txt\" -homedir \"$md_inst\" -fullscreen \$params"
    # prevents SDL doing an internal software conversion since 2.0.16+
    isPlatform "arm" && common_args="-texturestream $common_args"

    cat >"$md_inst/hypseus.sh" <<_EOF_
#!/bin/bash
dir="\$1"
name="\${dir##*/}"
name="\${name%.*}"

if [[ -f "\$dir/\$name.commands" ]]; then
    params=\$(<"\$dir/\$name.commands")
fi

if [[ -f "\$dir/\$name.singe" ]]; then
    singerom="\$dir/\$name.singe"
elif [[ -f "\$dir/\$name.zip" ]]; then
    singerom="\$dir/\$name.zip"
fi

if [[ -n "\$singerom" ]]; then
    "$md_inst/hypseus.bin" singe vldp -retropath -manymouse -script "\$singerom" $common_args
else
    "$md_inst/hypseus.bin" "\$name" vldp $common_args
fi
_EOF_
    chmod +x "$md_inst/hypseus.sh"
}
