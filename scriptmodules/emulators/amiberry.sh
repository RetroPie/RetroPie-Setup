#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="amiberry"
rp_module_desc="Amiga emulator with JIT support"
rp_module_help="ROM Extension: .adf .adz .dms .uae\n\nCopy your Amiga games to $romdir/amiga\n\nCopy the required BIOS files\nkick13.rom\nkick20.rom\nkick31.rom\nto $biosdir"
rp_module_licence="GPL2"
rp_module_section="exp"
rp_module_flags="!x86 !mali"

function depends_amiberry() {
    getDepends libsdl1.2-dev libguichan-dev libsdl-ttf2.0-dev libsdl-gfx1.2-dev libxml2-dev libflac-dev libmpg123-dev
}

function sources_amiberry() {
    gitPullOrClone "$md_build" https://github.com/midwan/amiberry/
}

function build_amiberry() {
    make clean
    if isPlatform "rpi1"; then
        CXXFLAGS="" make PLATFORM=rpi1
    elif isPlatform "rpi3"; then
        CXXFLAGS="" make PLATFORM=rpi3
    else
        CXXFLAGS="" make PLATFORM=rpi2
    fi
    md_ret_require="$md_build/amiberry"
}

function install_amiberry() {
    md_ret_files=(
        'data'
        'amiberry'
    )
}

function configure_amiberry() {
    mkRomDir "amiga"

    mkUserDir "$md_conf_root/amiga"
    mkUserDir "$md_conf_root/amiga/$md_id"

    # move config / save folders to $md_conf_root/amiga/$md_id
    local dir
    for dir in conf savestates screenshots; do
        moveConfigDir "$md_inst/$dir" "$md_conf_root/amiga/$md_id/$dir"
    done

    # and kickstart dir (removing old symlinks first)
    if [[ ! -h "$md_inst/kickstarts" ]]; then
        rm -f "$md_inst/kickstarts/"{kick12.rom,kick13.rom,kick20.rom,kick31.rom}
    fi
    moveConfigDir "$md_inst/kickstarts" "$biosdir"

    local conf="$(mktemp)"
    iniConfig "=" "" "$conf"
    iniSet "config_description" "RetroPie A500, 68000, OCS, 512KB Chip + 512KB Slow Fast"
    iniSet "chipmem_size" "1"
    iniSet "bogomem_size" "2"
    iniSet "chipset" "ocs"
    iniSet "cachesize" "0"
    iniSet "kickstart_rom_file" "\$(FILE_PATH)/kick13.rom"
    copyDefaultConfig "$conf" "$md_conf_root/amiga/$md_id/conf/rp-a500.uae"
    rm "$conf"

    conf="$(mktemp)"
    iniConfig "=" "" "$conf"
    iniSet "config_description" "RetroPie A1200, 68EC020, AGA, 2MB Chip"
    iniSet "chipmem_size" "4"
    iniSet "finegrain_cpu_speed" "1024"
    iniSet "cpu_type" "68ec020"
    iniSet "cpu_model" "68020"
    iniSet "chipset" "aga"
    iniSet "cachesize" "0"
    iniSet "kickstart_rom_file" "\$(FILE_PATH)/kick31.rom"
    copyDefaultConfig "$conf" "$md_conf_root/amiga/$md_id/conf/rp-a1200.uae"
    rm "$conf"

    cp -v "$md_data/amiberry.sh" "$md_inst/"
    cat > "$romdir/amiga/+Start amiberry.sh" << _EOF_
#!/bin/bash
"$md_inst/amiberry.sh"
_EOF_
    chmod +x "$md_data/amiberry.sh"
    chmod a+x "$romdir/amiga/+Start amiberry.sh"
    chown $user:$user "$romdir/amiga/+Start amiberry.sh"

    addEmulator 1 "$md_id" "amiga" "$md_inst/amiberry.sh auto %ROM%"
    addEmulator 1 "$md_id-a500" "amiga" "$md_inst/amiberry.sh rp-a500.uae %ROM%"
    addEmulator 1 "$md_id-a1200" "amiga" "$md_inst/amiberry.sh rp-a1200.uae %ROM%"
    addSystem "amiga"
}
