#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="reicast"
rp_module_desc="Dreamcast emulator Reicast"
rp_module_menus="4+"
rp_module_flags="!rpi1"

function depends_reicast() {
    getDepends alsa-oss
}

function sources_reicast() {
    gitPullOrClone "$md_build" https://github.com/gizmo98/reicast-emulator.git skmp/rapi2-audiofix
}

function build_reicast() {
    cd $md_build/shell/rapi2
    make clean
    make 
    md_ret_require="$md_build/shell/rapi2/reicast.elf"
}

function install_reicast() {
    md_ret_files=(
        'shell/rapi2/reicast.elf'
        'shell/rapi2/nosym-reicast.elf'
        'LICENSE'
        'README.md'
    )
}

function configure_reicast() {
    mkRomDir "dreamcast"

    # create bios dir. Copy dc_boot.bin and dc_flash.bin there.
    mkdir $md_inst/data

    cat > $md_inst/reicast.sh << _EOF_
#!/bin/bash
pushd $md_inst
sudo aoss ./reicast.elf -config config:image="\$1"
popd
_EOF_

    chmod +x "$md_inst/reicast.sh"
    
    # add system
    addSystem 1 "$md_id" "dreamcast" "$md_inst/reicast.sh %ROM%"
}
