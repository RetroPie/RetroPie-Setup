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
rp_module_help="ROM Extensions: .cdi .gdi\n\nCopy your Dreamcast roms to $romdir/dreamcast\n\nCopy the required BIOS files dc_boot.bin and dc_flash.bin to $biosdir/dc"
rp_module_licence="GPL2 https://raw.githubusercontent.com/reicast/reicast-emulator/master/LICENSE"
rp_module_section="opt"
rp_module_flags="!armv6 "

function depends_reicast() {
    local depends=(libsdl2-dev python-dev python-pip alsa-oss python-setuptools libevdev-dev)
    isPlatform "vero4k" && depends+=(vero3-userland-dev-osmc)
    getDepends "${depends[@]}"
    pip install evdev
}

function sources_reicast() {
    if isPlatform "x11"; then
        gitPullOrClone "$md_build" https://github.com/reicast/reicast-emulator.git
    elif isPlatform "vero4k"; then
        gitPullOrClone "$md_build" https://github.com/reicast/reicast-emulator.git
    else
        gitPullOrClone "$md_build" https://github.com/reicast/reicast-emulator.git
    fi
    sed -i "s/CXXFLAGS += -fno-rtti -fpermissive -fno-operator-names/CXXFLAGS += -fno-rtti -fpermissive -fno-operator-names -D_GLIBCXX_USE_CXX11_ABI=0/g" shell/linux/Makefile
}

function build_reicast() {
    cd shell/linux
    if isPlatform "rpi"; then
        make platform=rpi2 clean
        make platform=rpi2
    elif isPlatform "tinker"; then
        make USE_GLES=1 USE_SDL=1 clean
        make USE_GLES=1 USE_SDL=1
    else
        make clean
        make
    fi
    md_ret_require="$md_build/shell/linux/reicast.elf"
}

function install_reicast() {
    cd shell/linux
    if isPlatform "rpi"; then
        make platform=rpi2 PREFIX="$md_inst" install
    elif isPlatform "tinker"; then
        make USE_GLES=1 USE_SDL=1 PREFIX="$md_inst" install
    else
        make PREFIX="$md_inst" install
    fi
    md_ret_files=(
        'LICENSE'
        'README.md'
    )
}

function configure_reicast() {
    # copy hotkey remapping start script
    cp "$md_data/reicast.sh" "$md_inst/bin/"
    chmod +x "$md_inst/bin/reicast.sh"

    mkRomDir "dreamcast"

    # move any old configs to the new location
    moveConfigDir "$home/.reicast" "$md_conf_root/dreamcast/"

    # Create home VMU, cfg, and data folders. Copy dc_boot.bin and dc_flash.bin to the ~/.reicast/data/ folder.
    mkdir -p "$md_conf_root/dreamcast/"{data,mappings}

    # symlink bios
    mkUserDir "$biosdir/dc"
    ln -sf "$biosdir/dc/"{dc_boot.bin,dc_flash.bin} "$md_conf_root/dreamcast/data"

    # copy default mappings
    cp "$md_inst/share/reicast/mappings/"*.cfg "$md_conf_root/dreamcast/mappings/"

    chown -R $user:$user "$md_conf_root/dreamcast"

    cat > "$romdir/dreamcast/+Start Reicast.sh" << _EOF_
#!/bin/bash
$md_inst/bin/reicast.sh
_EOF_
    chmod a+x "$romdir/dreamcast/+Start Reicast.sh"
    chown $user:$user "$romdir/dreamcast/+Start Reicast.sh"

    # remove old systemManager.cdi symlink
    rm -f "$romdir/dreamcast/systemManager.cdi"

    # add system
    # possible audio backends: alsa, oss, omx
    if isPlatform "rpi"; then
        addEmulator 1 "${md_id}-audio-omx" "dreamcast" "CON:$md_inst/bin/reicast.sh omx %ROM%"
        addEmulator 0 "${md_id}-audio-oss" "dreamcast" "CON:$md_inst/bin/reicast.sh oss %ROM%"
    elif isPlatform "vero4k"; then
        addEmulator 1 "$md_id" "dreamcast" "CON:$md_inst/bin/reicast.sh alsa %ROM%"
    else
        addEmulator 1 "$md_id" "dreamcast" "CON:$md_inst/bin/reicast.sh oss %ROM%"
    fi
    addSystem "dreamcast"

    addAutoConf reicast_input 1
}

function input_reicast() {
    local temp_file="$(mktemp)"
    cd "$md_inst/bin"
    ./reicast-joyconfig -f "$temp_file" >/dev/tty
    iniConfig " = " "" "$temp_file"
    iniGet "mapping_name"
    local mapping_file="$configdir/dreamcast/mappings/controller_${ini_value// /}.cfg"
    mv "$temp_file" "$mapping_file"
    chown $user:$user "$mapping_file"
}

function gui_reicast() {
    while true; do
        local options=(
            1 "Configure input devices for Reicast"
        )
        local cmd=(dialog --backtitle "$__backtitle" --menu "Choose an option" 22 76 16)
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        [[ -z "$choice" ]] && break
        case "$choice" in
            1)
                clear
                input_reicast
                ;;
        esac
    done
}
