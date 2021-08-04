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
rp_module_desc="Amiga emulator with JIT support (forked from uae4arm)"
rp_module_help="ROM Extension: .adf .ipf .zip\n\nCopy your Amiga games to $romdir/amiga\n\nCopy the required BIOS files\nkick13.rom\nkick20.rom\nkick31.rom\nto $biosdir"
rp_module_licence="GPL3 https://raw.githubusercontent.com/midwan/amiberry/master/COPYING"
rp_module_repo="git https://github.com/midwan/amiberry v3.3"
rp_module_section="opt"
rp_module_flags="!all arm"

function _get_platform_amiberry() {
    local platform="$__platform-sdl2"
    if isPlatform "dispmanx"; then
        platform="$__platform"
    elif isPlatform "odroid-xu"; then
        platform="xu4"
    elif isPlatform "odroid-c1"; then
        platform="c1"
    elif isPlatform "tinker"; then
        platform="tinker"
    elif isPlatform "vero4k"; then
        platform="vero4k"
    fi
    echo "$platform"
}

function depends_amiberry() {
    local depends=(autoconf libpng-dev libmpeg2-4-dev zlib1g-dev libmpg123-dev libflac-dev libxml2-dev libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev)

    isPlatform "dispmanx" && depends+=(libraspberrypi-dev)
    isPlatform "vero4k" && depends+=(vero3-userland-dev-osmc)

    getDepends "${depends[@]}"
}

function sources_amiberry() {
    gitPullOrClone
    # use our default optimisation level
    sed -i "s/-Ofast//" "$md_build/Makefile"
}

function build_amiberry() {
    local platform=$(_get_platform_amiberry)
    cd external/capsimg
    ./bootstrap.fs
    ./configure.fs
    make -f Makefile.fs clean
    make -f Makefile.fs
    cd "$md_build"
    make clean
    make PLATFORM="$platform"
    md_ret_require="$md_build/amiberry"
}

function install_amiberry() {
    md_ret_files=(
        'amiberry'
        'data'
        'external/capsimg/capsimg.so'
    )

    cp -R "$md_build/whdboot" "$md_inst/whdboot-dist"
}

function configure_amiberry() {
    configure_uae4arm

    [[ "$md_mode" == "remove" ]] && return

    # symlink the retroarch config / autoconfigs for amiberry to use
    ln -sf "$configdir/all/retroarch/autoconfig" "$md_inst/controllers"
    ln -sf "$configdir/all/retroarch.cfg" "$md_inst/conf/retroarch.cfg"

    local config_dir="$md_conf_root/amiga/$md_id"

    # create whdboot config area
    moveConfigDir "$md_inst/whdboot" "$config_dir/whdboot"

    # copy game-data, save-data folders, boot-data.zip and WHDLoad
    cp -R "$md_inst/whdboot-dist/"{game-data,save-data,boot-data.zip,WHDLoad} "$config_dir/whdboot/"

    chown -R $user:$user "$config_dir/whdboot"
}
