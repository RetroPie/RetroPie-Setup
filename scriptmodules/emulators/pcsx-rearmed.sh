#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="pcsx-rearmed"
rp_module_desc="Playstation emulator - PCSX (arm optimised)"
rp_module_help="ROM Extensions: .bin .cue .cbn .img .iso .m3u .mdf .pbp .toc .z .znx\n\nCopy your PSX roms to $romdir/psx\n\nCopy the required BIOS file SCPH1001.BIN to $biosdir"
rp_module_section="opt"
rp_module_flags="dispmanx !x86 !mali"

function depends_pcsx-rearmed() {
    getDepends libsdl1.2-dev libasound2-dev libpng12-dev libx11-dev
}

function sources_pcsx-rearmed() {
    gitPullOrClone "$md_build" https://github.com/notaz/pcsx_rearmed.git
    runCmd git submodule update --init
}

function build_pcsx-rearmed() {
    if isPlatform "neon"; then
        ./configure --sound-drivers=alsa --enable-neon
    else
        ./configure --sound-drivers=alsa
    fi
    make clean
    make
    md_ret_require="$md_build/pcsx"
}

function install_pcsx-rearmed() {
    md_ret_files=(
        'AUTHORS'
        'COPYING'
        'ChangeLog'
        'ChangeLog.df'
        'NEWS'
        'README.md'
        'readme.txt'
        'pcsx'
    )
    mkdir "$md_inst/plugins"
    cp "$md_build/plugins/spunull/spunull.so" "$md_inst/plugins/spunull.so"
    cp "$md_build/plugins/gpu_unai/gpu_unai.so" "$md_inst/plugins/gpu_unai.so"
    cp "$md_build/plugins/gpu-gles/gpu_gles.so" "$md_inst/plugins/gpu_gles.so"
    cp "$md_build/plugins/dfxvideo/gpu_peops.so" "$md_inst/plugins/gpu_peops.so"
}

function configure_pcsx-rearmed() {
    mkRomDir "psx"
    mkUserDir "$md_conf_root/psx"
    mkdir -p "$md_inst/bios"

    # symlink the rom so so it can be installed with the other bios files
    ln -sf "$biosdir/scph1001.bin" "$md_inst/bios/scph1001.bin"

    setDispmanx "$md_id" 1

    addSystem 0 "$md_id" "psx" "$md_inst/pcsx -cfg $md_conf_root/psx/pcsx.cfg -cdfile %ROM%"
}
