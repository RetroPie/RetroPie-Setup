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
rp_module_section="exp"

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

function configure_lr-reicast() {
    mkRomDir "dreamcast"
    mkRomDir "naomi"
    ensureSystemretroconfig "dreamcast"
    ensureSystemretroconfig "naomi"

    mkUserDir "$biosdir/dc"
     
    # symlink to JP bios by default
    ln -sf "$biosdir/dc/naomi_boot_jp.bin" "$biosdir/dc/naomi_boot.bin"
    
    # symlink update to dc folder
    ln -sf "$biosdir/dc/dc_boot.bin" "$md_conf_root/dreamcast/data/dc_boot.bin"
    ln -sf "$biosdir/dc/dc_flash.bin" "$md_conf_root/dreamcast/data/dc_flash.bin"
    
    # add naomi as a copy of arcade for carbon theme
    if [[ ! -f /etc/emulationstation/themes/carbon/naomi/theme.xml ]];
    then
        cp -R /etc/emulationstation/themes/carbon/arcade/. /etc/emulationstation/themes/carbon/naomi/
    fi
    
    # add naomi as a copy of arcade for showcase theme
    if [[ ! -f /etc/emulationstation/themes/showcase/naomi/theme.xml ]];
    then
        cp -R /etc/emulationstation/themes/showcase/arcade/. /etc/emulationstation/themes/showcase/naomi/
    fi
    
    # multibios hack
    if [[ ! -f /opt/retropie/supplementary/runcommand/runcommand_naomi.sh ]];
    then
        cp /opt/retropie/supplementary/runcommand/runcommand.sh /opt/retropie/supplementary/runcommand/runcommand_naomi.sh
        sed -i -e 's:function show_launch() {:function show_launch() {\n    if [[ "$ROM_BN" =~ ^("Capcom vs. SNK 2 - Mark of the Millennium 2001"|"Marvel vs. Capcom 2 - The New Age of Heroes"|"Project Justice")$ ]];\n    then\n        ln -sf /home/pigaming/RetroPie/BIOS/dc/naomi_boot_us.bin /home/pigaming/RetroPie/BIOS/dc/naomi_boot.bin\n    else\n        ln -sf /home/pigaming/RetroPie/BIOS/dc/naomi_boot_jp.bin /home/pigaming/RetroPie/BIOS/dc/naomi_boot.bin\n    fi\n:g' /opt/retropie/supplementary/runcommand/runcommand_naomi.sh
    fi
       
    # system-specific
    iniConfig " = " "" "$configdir/dreamcast/retroarch.cfg"
    iniSet "video_shared_context" "true"

    iniConfig " = " "" "$configdir/naomi/retroarch.cfg"
    iniSet "video_shared_context" "true"

    addEmulator 0 "$md_id" "dreamcast" "$md_inst/reicast_libretro.so"
    addEmulator 1 "$md_id" "naomi" "$md_inst/reicast_libretro.so"

    addSystem "dreamcast"
    addSystem "naomi"
    
    # use custom runcommand for naomi
    sed -i -e 's/runcommand.sh 0 _SYS_ naomi/runcommand_naomi.sh 0 _SYS_ naomi/g' /etc/emulationstation/es_systems.cfg
    
    # set core options
    setRetroArchCoreOption "${dir_name}reicast_audio_buffer_size" "2048"
    setRetroArchCoreOption "${dir_name}reicast_reicast_broadcast" "default"
    setRetroArchCoreOption "${dir_name}reicast_enable_dsp" "disabled"
    setRetroArchCoreOption "${dir_name}reicast_threaded_rendering" "disabled"
}