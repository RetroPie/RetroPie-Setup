#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="reicast"
rp_module_desc="Dreamcast emulator Reicast"
rp_module_menus="4+"
rp_module_flags="!rpi1"

function depends_reicast() {
    getDepends alsa-oss
}

function sources_reicast() {
    gitPullOrClone "$md_build" https://github.com/free5ty1e/reicast-emulator.git free5ty1e/rpi2/retropie-reicast-updated
}

function build_reicast() {
    cd "$md_build/shell/rapi2"
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

    # Create home VMU, cfg, and data folders. Copy dc_boot.bin and dc_flash.bin to the ~/.reicast/data/ folder.
    mkUserDir "$home/.reicast"
    mkUserDir "$home/.reicast/data"

    ln -sf "$biosdir/dc_boot.bin" "$home/.reicast/data/"
    ln -sf "$biosdir/dc_flash.bin" "$home/.reicast/data/"

    cat > "$md_inst/reicast.sh" << _EOF_
#!/bin/bash
pushd "$md_inst"
echo Reading the entire Reicast emulator into memory to execute from there...
sudo mkdir tmpfs
#TODO: Find optimal smaller tmpfs size, I do not believe anywhere near this much is required.  I have only ever seen 54MB utilized during a game of Rush 2049.
sudo mount -o size=150M -t tmpfs none tmpfs/
sudo cp -v * tmpfs/
sudo chown -R $user:$user tmpfs
cd tmpfs
aoss ./reicast.elf -config config:homedir="$home" -config config:image="\$1"
cd ..
echo Freeing up memory...
sudo umount "$md_inst/tmpfs"
sudo rm -rf tmpfs
popd
_EOF_

    chmod +x "$md_inst/reicast.sh"

    # Link to file that does not exist as this results in the Dreamcast System Manager launching (as if one turned on the Dreamcast without a disc inserted)
    # This is required to fix broken / corrupted VMU files.
    ln -sf fileThatDoesNotExist "$home/RetroPie/roms/dreamcast/systemManager.cdi"

    # add system
    addSystem 1 "$md_id" "dreamcast" "$md_inst/reicast.sh %ROM%"

    __INFMSGS+=("You need to copy the Dreamcast BIOS files (dc_boot.bin and dc_flash.bin) to the folder $biosdir to boot the Dreamcast emulator.")
}
