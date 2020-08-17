#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="ti99sim-sdl1"
rp_module_desc="TI-99/SIM - Texas Instruments Home Computer Emulator (SDL1 version)"
rp_module_help="ROM Extension: .ctg\n\nCopy your TI-99 games to $romdir/ti99\n\nCopy the required BIOS file TI-994A.ctg (case sensitive) to $biosdir"
rp_module_licence="GPL2 http://www.mrousseau.org/programs/ti99sim/"
rp_module_section="exp"
rp_module_flags="dispmanx !mali"

function depends_ti99sim-sdl1() {
    getDepends libsdl1.2-dev libssl-dev libboost-regex-dev
}

function sources_ti99sim-sdl1() {
    downloadAndExtract "$__archive_url/ti99sim-0.15.0.src.tar.gz" "$md_build" --strip-components 1
}

function build_ti99sim-sdl1() {
    build_ti99sim
}

function install_ti99sim-sdl1() {
    install_ti99sim
}

function configure_ti99sim-sdl1() {
    mkRomDir "ti99"

    addEmulator 0 "$md_id" "ti99" "$md_inst/ti99sim.sh -f %ROM%"
    addSystem "ti99"

    [[ "$md_mode" == "remove" ]] && return

    setDispmanx "$md_id" 1

    moveConfigDir "$home/.ti99sim" "$md_conf_root/ti99/"
    ln -sf "$biosdir/TI-994A.ctg" "$md_inst/TI-994A.ctg"

    local file="$md_inst/ti99sim.sh"
    cat >"$file" << _EOF_
#!/bin/bash
pushd "$md_inst"
./ti99sim-sdl "\$@"
popd
_EOF_
    chmod +x "$file"
}
