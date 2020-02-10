#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="ioquake3"
rp_module_desc="Quake 3 source port"
rp_module_licence="GPL2 https://github.com/ioquake/ioq3/blob/master/COPYING.txt"
rp_module_section="opt"
rp_module_flags="!mali !videocore"

function depends_ioquake3() {
    getDepends libsdl2-dev libgl1-mesa-dev
}

function sources_ioquake3() {
    gitPullOrClone "$md_build" https://github.com/ioquake/ioq3
}

function build_ioquake3() {
    make clean
    make
}

function _arch_ioquake3() {
    # exact parsing from Makefile
    echo "$(uname -m | sed -e 's/i.86/x86/' | sed -e 's/^arm.*/arm/')"
}

function install_ioquake3() {
    md_ret_files=(
        "build/release-linux-$(_arch_ioquake3)/ioq3ded.$(_arch_ioquake3)"
        "build/release-linux-$(_arch_ioquake3)/ioquake3.$(_arch_ioquake3)"
        "build/release-linux-$(_arch_ioquake3)/renderer_opengl1_$(_arch_ioquake3).so"
        "build/release-linux-$(_arch_ioquake3)/renderer_opengl2_$(_arch_ioquake3).so"
    )
}

function configure_ioquake3() {
    local launcher=("$md_inst/ioquake3.$(_arch_ioquake3)")
    isPlatform "mesa" && launcher+=("+set cl_renderer opengl1")
    isPlatform "kms" && launcher+=("+set r_mode -1" "+set r_customwidth %XRES%" "+set r_customheight %YRES%" "+set r_swapInterval 1")

    addPort "$md_id" "quake3" "Quake III Arena" "${launcher[*]}"

    mkRomDir "ports/quake3"

    moveConfigDir "$md_inst/baseq3" "$romdir/ports/quake3"
    moveConfigDir "$home/.q3a" "$md_conf_root/ioquake3"

    [[ "$md_mode" == "install" ]] && game_data_quake3
}
