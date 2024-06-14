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
rp_module_help="ROM Extension: .adf .chd .ipf .lha .zip\n\nCopy your Amiga games to $romdir/amiga\n\nCopy the required BIOS files\nkick13.rom\nkick20.rom\nkick31.rom\nto $biosdir/amiga"
rp_module_licence="GPL3 https://raw.githubusercontent.com/BlitterStudio/amiberry/master/LICENSE"
rp_module_repo="git https://github.com/BlitterStudio/amiberry :_get_branch_amiberry"
rp_module_section="opt"
rp_module_flags="!all arm rpi3 rpi4 rpi5"

function _update_hook_amiberry() {
    local rom
    mkUserDir "$biosdir/amiga"
    for rom in kick13.rom kick20.rom kick31.rom; do
        # if we have a kickstart rom in $biosdir, move it to $biosdir/amiga and symlink the old location
        if [[ -f "$biosdir/$rom" && ! -h "$biosdir/$rom" ]]; then
            moveConfigFile "$biosdir/$rom" "$biosdir/amiga/$rom"
        fi
    done
}

function _get_branch_amiberry() {
    if isPlatform "dispmanx"; then
        echo "v5.7.1"
    else
        echo "v5.7.2"
    fi
}

function _get_platform_amiberry() {
    local platform="$__platform-sdl2"
    if isPlatform "aarch64" && isPlatform "rpi"; then
        platform="$__platform-64-sdl2"
    elif isPlatform "dispmanx"; then
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
    local depends=(cmake autoconf libpng-dev libmpeg2-4-dev zlib1g-dev libmpg123-dev libflac-dev libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev libserialport-dev wget libportmidi-dev)

    isPlatform "dispmanx" && depends+=(libraspberrypi-dev)
    isPlatform "vero4k" && depends+=(vero3-userland-dev-osmc)

    getDepends "${depends[@]}"
}

function sources_amiberry() {
    gitPullOrClone
    applyPatch "$md_data/01_preserve_env.diff"
    # Dispmanx is locked on v5.7.1, apply some critical fixes on top of it
    if isPlatform "dispmanx"; then
        applyPatch "$md_data/02_fix_uae_config_load.diff"
        applyPatch "$md_data/03_fix_crash_saving.diff"
    fi
    # use our default optimisation level
    sed -i "/CFLAGS += -O3/d" "$md_build/Makefile"
}

function build_amiberry() {
    local platform=$(_get_platform_amiberry)
    cd external/capsimg
    ./bootstrap
    ./configure
    make clean
    make
    cd "$md_build"
    make clean
    make PLATFORM="$platform" CPUFLAGS="$__cpu_flags"
    md_ret_require="$md_build/amiberry"
}

function install_amiberry() {
    md_ret_files=(
        'abr'
        'amiberry'
        'data'
        'external/capsimg/capsimg.so'
        'kickstarts'
    )

    cp -R "$md_build/whdboot" "$md_inst/whdboot-dist"
}

function configure_amiberry() {
    addEmulator 1 "amiberry" "amiga" "$md_inst/amiberry.sh %ROM%"
    addEmulator 0 "amiberry-a500" "amiga" "$md_inst/amiberry.sh %ROM% --model A500"
    addEmulator 0 "amiberry-a500plus" "amiga" "$md_inst/amiberry.sh %ROM% --model A500P"
    addEmulator 0 "amiberry-a1200" "amiga" "$md_inst/amiberry.sh %ROM% --model A1200"
    addEmulator 0 "amiberry-a4000" "amiga" "$md_inst/amiberry.sh %ROM% --model A4000"
    addEmulator 0 "amiberry-cdtv" "amiga" "$md_inst/amiberry.sh %ROM% --model CDTV"
    addEmulator 0 "amiberry-cd32" "amiga" "$md_inst/amiberry.sh %ROM% --model CD32"
    addSystem "amiga"

    [[ "$md_mode" == "remove" ]] && return

    mkRomDir "amiga"

    mkUserDir "$md_conf_root/amiga"
    mkUserDir "$md_conf_root/amiga/amiberry"

    # move config / save folders to $md_conf_root/amiga/amiberry
    local dir
    for dir in conf nvram savestates screenshots; do
        moveConfigDir "$md_inst/$dir" "$md_conf_root/amiga/amiberry/$dir"
    done

    # check for cd32.nvr and move it to $md_conf_root/amiga/amiberry/nvram
    if [[ -f "$md_conf_root/amiga/amiberry/cd32.nvr" ]]; then
        mv "$md_conf_root/amiga/amiberry/cd32.nvr" "$md_conf_root/amiga/amiberry/nvram/"
    fi

    moveConfigDir "$md_inst/kickstarts" "$biosdir/amiga"
    chown -R $user:$user "$biosdir/amiga"

    # symlink the retroarch config / autoconfigs for amiberry to use
    ln -sf "$configdir/all/retroarch/autoconfig" "$md_inst/controllers"
    ln -sf "$configdir/all/retroarch.cfg" "$md_inst/conf/retroarch.cfg"

    local config_dir="$md_conf_root/amiga/amiberry"

    # create whdboot config area
    moveConfigDir "$md_inst/whdboot" "$config_dir/whdboot"

    # copy game-data, save-data folders, boot-data.zip and WHDLoad
    cp -R "$md_inst/whdboot-dist/"{game-data,save-data,boot-data.zip,WHDLoad} "$config_dir/whdboot/"

    chown -R $user:$user "$config_dir/whdboot"

    # copy shared uae4arm/amiberry launch script while setting is_amiberry=1
    sed "s/is_amiberry=0/is_amiberry=1/" "$md_data/../uae4arm/uae4arm.sh" >"$md_inst/amiberry.sh"
    chmod a+x "$md_inst/amiberry.sh"

    local script="+Start Amiberry.sh"
    cat > "$romdir/amiga/$script" << _EOF_
#!/bin/bash
"$md_inst/amiberry.sh"
_EOF_
    chmod a+x "$romdir/amiga/$script"
    chown $user:$user "$romdir/amiga/$script"
}
