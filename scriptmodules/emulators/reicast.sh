#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="reicast"
rp_module_desc="Dreamcast emulator Reicast"
rp_module_menus="4+"
rp_module_flags="!rpi1"

function depends_reicast() {
    getDepends libsdl1.2-dev python-dev python-pip alsa-oss
    pip install evdev
}

function sources_reicast() {
    gitPullOrClone "$md_build" https://github.com/reicast/reicast-emulator.git
    # tune flags
    sed -i 's/-mtune=cortex-a9//g' shell/linux/Makefile
    sed -i 's/-mfpu=neon/-mfpu=neon-vfpv4/g' shell/linux/Makefile
    sed -i 's/-mfloat-abi=softfp/-mfloat-abi=hard/g' shell/linux/Makefile
    # don't use precompiled stuff. use system libs
    sed -i 's|-L../linux-deps/lib||g' shell/linux/Makefile
    sed -i 's|-I../linux-deps/include||g' shell/linux/Makefile
    # fix reicast-joyconfig script
    sed -i 's|"dreamcast", "btn_escape"|"emulator", "btn_escape"|g' shell/linux/tools/reicast-joyconfig.py
}

function build_reicast() {
    cd "$md_build/shell/linux"
    make clean
    make platform=rpi2
    md_ret_require="$md_build/shell/linux/reicast.elf"
}

function install_reicast() {
    cd "$md_build/shell/linux"
    make PREFIX="$md_inst" install
    md_ret_files=(
        'LICENSE'
        'README.md'
    )
}

function configure_reicast() {
    # copy hotkey remapping start script
    cp "$scriptdir/scriptmodules/$md_type/$md_id/reicast.sh" "$md_inst/bin/"

    mkRomDir "dreamcast"

    # Create home VMU, cfg, and data folders. Copy dc_boot.bin and dc_flash.bin to the ~/.reicast/data/ folder.
    mkUserDir "$home/.reicast"
    mkUserDir "$home/.reicast/data"
    mkUserDir "$home/.reicast/mappings"

    ln -sf "$biosdir/dc_boot.bin" "$home/.reicast/data/"
    ln -sf "$biosdir/dc_flash.bin" "$home/.reicast/data/"
    # add links to retropie config dir
    ln -s "$home/.reicast/mappings" "$configdir/dreamcast/"
    ln -sf "$home/.reicast/emu.cfg" "$configdir/dreamcast/"
    # copy default mappings
    cp "$md_inst/share/reicast/mappings/"*.cfg "$home/.reicast/mappings/"

    # Link to file that does not exist as this results in the Dreamcast System Manager launching (as if one turned on the Dreamcast without a disc inserted)
    # This is required to fix broken / corrupted VMU files.
    ln -sf fileThatDoesNotExist "$home/RetroPie/roms/dreamcast/systemManager.cdi"

    # add system
    addSystem 1 "$md_id" "dreamcast" "$md_inst/bin/reicast.sh OSS %ROM%"

    __INFMSGS+=("You need to copy the Dreamcast BIOS files (dc_boot.bin and dc_flash.bin) to the folder $biosdir to boot the Dreamcast emulator.")
}
