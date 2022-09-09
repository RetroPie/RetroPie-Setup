#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="openmsx"
rp_module_desc="MSX emulator OpenMSX"
rp_module_help="ROM Extensions: .cas .rom .mx1 .mx2 .col .dsk .zip\n\nCopy your MSX/MSX2 games to $romdir/msx\nCopy the BIOS files to $biosdir/openmsx"
rp_module_licence="GPL2 https://raw.githubusercontent.com/openMSX/openMSX/master/doc/GPL.txt"
rp_module_repo="git https://github.com/openMSX/openMSX.git RELEASE_17_0 :_get_commit_openmsx"
rp_module_section="opt"
rp_module_flags=""

function _get_commit_openmsx() {
    local commit
    # latest code requires at least GCC 8.3 (Debian Buster) for full C++17 support
    compareVersions $__gcc_version lt 8 && commit="c8d90e70"
    # for GCC before 7, build from an earlier commit, before C++17 support was added
    compareVersions $__gcc_version lt 7 && commit="5ee25b62"
    echo "$commit"
}

function depends_openmsx() {
    local depends=(libsdl2-dev libsdl2-ttf-dev libao-dev libogg-dev libtheora-dev libxml2-dev libvorbis-dev tcl-dev libasound2-dev libfreetype6-dev)
    isPlatform "x11" && depends+=(libglew-dev)

    getDepends "${depends[@]}"
}

function sources_openmsx() {
    gitPullOrClone
    sed -i "s|INSTALL_BASE:=/opt/openMSX|INSTALL_BASE:=$md_inst|" build/custom.mk
    sed -i "s|SYMLINK_FOR_BINARY:=true|SYMLINK_FOR_BINARY:=false|" build/custom.mk
}

function build_openmsx() {
    rpSwap on 2000
    ./configure
    make clean
    make
    rpSwap off
    md_ret_require="$md_build/derived/openmsx"
}

function install_openmsx() {
    make install
    mkdir -p "$md_inst/share/systemroms/"
    downloadAndExtract "$__archive_url/openmsxroms.tar.gz" "$md_inst/share/systemroms/"
}

function configure_openmsx() {
    mkRomDir "msx"

    addEmulator 0 "$md_id" "msx" "$md_inst/bin/openmsx %ROM%"
    addEmulator 0 "$md_id-msx2" "msx" "$md_inst/bin/openmsx -machine 'Boosted_MSX2_EN' %ROM%"
    addEmulator 0 "$md_id-msx2-plus" "msx" "$md_inst/bin/openmsx -machine 'Boosted_MSX2+_JP' %ROM%"
    addEmulator 0 "$md_id-msx-turbor" "msx" "$md_inst/bin/openmsx -machine 'Panasonic_FS-A1GT' %ROM%"
    addSystem "msx"

    [[ $md_mode == "remove" ]] && return

    # Add a minimal configuration
    local config="$(mktemp)"
    echo "$(_default_settings_openmsx)" > "$config"

    mkUserDir "$home/.openMSX/share/scripts"
    mkUserDir "$home/.openMSX/share/systemroms"
    moveConfigDir "$home/.openMSX" "$configdir/msx/openmsx"
    moveConfigDir "$configdir/msx/openmsx/share/systemroms" "$home/RetroPie/BIOS/openmsx"

    copyDefaultConfig "$config" "$home/.openMSX/share/settings.xml"
    rm "$config"

    # Add an autostart script, used for joypad configuration
    cp "$md_data/retropie-init.tcl" "$home/.openMSX/share/scripts"
    chown -R "$user:" "$home/.openMSX/share/scripts"
}

function _default_settings_openmsx() {
    local header
    local body
    local conf_reverse

    read -r -d '' header <<_EOF_
<!DOCTYPE settings SYSTEM 'settings.dtd'>
<settings>
  <settings>
    <setting id="default_machine">C-BIOS_MSX</setting>
    <setting id="osd_disk_path">$romdir/msx</setting>
    <setting id="osd_rom_path">$romdir/msx</setting>
    <setting id="osd_tape_path">$romdir/msx</setting>
    <setting id="osd_hdd_path">$romdir/msx</setting>
    <setting id="fullscreen">true</setting>
    <setting id="save_settings_on_exit">false</setting>
_EOF_

    if isPlatform "armv6" ; then
       IFS= read -r -d '' body <<_EOF_
    <setting id="scale_factor">1</setting>
    <setting id="horizontal_stretch">320</setting>
    <setting id="resampler">fast</setting>
    <setting id="scanline">0</setting>
    <setting id="maxframeskip">5</setting>
_EOF_
    fi

    ! isPlatform "x86" && conf_reverse="    <setting id=\"auto_enable_reverse\">off</setting\n"
    echo -e "${header}${body}${conf_reverse}  </settings>\n</settings>"
}
