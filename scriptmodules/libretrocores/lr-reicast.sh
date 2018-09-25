#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-reicast"
rp_module_desc="Dreamcast emu - Reicast port for libretro"
rp_module_help="Dreamcast ROM Extensions: .cdi .gdi\n\nCopy your Dreamcast roms to $romdir/dreamcast\n\nCopy the required BIOS files dc_boot.bin and dc_flash.bin to $biosdir/dc\n\nNaomi ROM Extensions: .lst and .bin pairs\n\nCopy your Naomi roms to $romdir/naomi\n\nCopy the required BIOS files naomi_boot_jp.bin and naomi_boot_us.bin to $biosdir/dc"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/reicast-emulator/master/LICENSE"
rp_module_section="opt"

function sources_lr-reicast() {
    gitPullOrClone "$md_build" https://github.com/libretro/reicast-emulator.git
}

function build_lr-reicast() {
    make clean
    platform=odroid BOARD="ODROID-XU3" ARCH=arm make
    md_ret_require="$md_build/reicast_libretro.so"
}

function install_lr-reicast() {
    md_ret_files=(
        'reicast_libretro.so'
    )
}

function install_bin_lr-reicast() {
    downloadAndExtract "http://github.com/Retro-Arena/xu4-bins/raw/master/lr-reicast.tar.gz" "$md_inst" 1
}

function configure_lr-reicast() {    
    # bios
    mkUserDir "$biosdir/dc"
    ln -sf "$biosdir/dc/naomi_boot_jp.bin" "$biosdir/dc/naomi_boot.bin"
          
    # add naomi to showcase theme
    if [[ ! -f /etc/emulationstation/themes/showcase/naomi/theme.xml ]]; then
        cp -R /etc/emulationstation/themes/showcase/arcade/. /etc/emulationstation/themes/showcase/naomi/
        wget -O /etc/emulationstation/themes/showcase/naomi/_inc/system.png https://image.ibb.co/kDMSAK/showcase_naomi_system.png
        wget -O /etc/emulationstation/themes/showcase/naomi/_inc/background.png https://image.ibb.co/gLBije/showcase_naomi_background.png
    fi
    
    # add atomiswave to showcase theme
    if [[ ! -f /etc/emulationstation/themes/showcase/atomiswave/theme.xml ]]; then
        cp -R /etc/emulationstation/themes/showcase/arcade/. /etc/emulationstation/themes/showcase/atomiswave/
        wget -O /etc/emulationstation/themes/showcase/atomiswave/_inc/system.png https://image.ibb.co/f5fCKe/system.png
        wget -O /etc/emulationstation/themes/showcase/atomiswave/_inc/background.png https://image.ibb.co/kgftsz/background.png
    fi
    
    local system
    for system in dreamcast naomi atomiswave; do
        mkRomDir "$system"
        ensureSystemretroconfig "$system"
        iniConfig " = " "" "$configdir/$system/retroarch.cfg"
        iniSet "video_shared_context" "true"
        addEmulator 1 "$md_id" "$system" "$md_inst/lr-reicast_libretro.so"
        addSystem "$system"
    done

    # set core options
    setRetroArchCoreOption "${dir_name}reicast_audio_buffer_size" "2048"
    setRetroArchCoreOption "${dir_name}reicast_broadcast" "default"
    setRetroArchCoreOption "${dir_name}reicast_enable_dsp" "disabled"
    setRetroArchCoreOption "${dir_name}reicast_enable_rtt" "disabled"    
    setRetroArchCoreOption "${dir_name}reicast_threaded_rendering" "enabled"
}
