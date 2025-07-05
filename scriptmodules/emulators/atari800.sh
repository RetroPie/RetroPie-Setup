#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="atari800"
rp_module_desc="Atari 8-bit/800/5200 emulator"
rp_module_help="ROM Extensions: .a52 .bas .bin .car .xex .atr .xfd .dcm .atr.gz .xfd.gz\n\nCopy your Atari800 games to $romdir/atari800\n\nCopy your Atari 5200 roms to $romdir/atari5200 You need to copy the Atari 800/5200 BIOS files (5200.ROM, ATARIBAS.ROM, ATARIOSB.ROM and ATARIXL.ROM) to the folder $biosdir and then on first launch configure it to scan that folder for roms (F1 -> Emulator Configuration -> System Rom Settings)"
rp_module_licence="GPL2 https://raw.githubusercontent.com/atari800/atari800/master/COPYING"
rp_module_repo="git https://github.com/atari800/atari800.git ATARI800_5_2_0"
rp_module_section="opt"
rp_module_flags="sdl1"

function depends_atari800() {
    local depends=(libsdl1.2-dev autoconf automake zlib1g-dev libpng-dev)
    isPlatform "dispmanx" && depends+=(libraspberrypi-dev)
    getDepends "${depends[@]}"
}

function sources_atari800() {
    gitPullOrClone
    if isPlatform "rpi"; then
        applyPatch "$md_data/01_rpi_fixes.diff"
    fi
}

function build_atari800() {
    local params=()
    ./autogen.sh
    isPlatform "dispmanx" && params+=(--target=rpi)
    ./configure --prefix="$md_inst" ${params[@]}
    make clean
    make
    md_ret_require="$md_build/src/atari800"
}

function install_atari800() {
    cd src
    make install
}

function _add_emulators_atari800() {
    local params=()
    local backend="$(getBackend "$md_id")"
    case "$backend" in
        x11*)
            # use fullscreen on x11
            params+=("-fullscreen")
            # enable hw acceleration by default if supported
            if isPlatform "gl" || isPlatform "gles"; then
                params+=("-video-accel")
            fi
            ;;
        default|x11*)
            # if backend is set to sdl1 default and we are on kms, we need to set fullscreen
            # and add width/height params to be filled out by runcommand or else it won't fill the screen
            isPlatform "kms" && params+=("-fullscreen" "-fs-width %XRES%" "-fs-height %YRES%")
            ;;
    esac

    local cmd="$md_inst/atari800.sh %ROM% ${params[*]}"
    addEmulator 1 "$md_id" "atari800" "$cmd"
    addEmulator 1 "$md_id-800" "atari800" "$cmd -atari"
    addEmulator 1 "$md_id-800xl" "atari800" "$cmd -xl"
    addEmulator 1 "$md_id-130xe" "atari800" "$cmd -xe"
    addEmulator 1 "$md_id-5200" "atari5200" "$cmd -5200"
}

function configure_atari800() {
    mkRomDir "atari800"
    mkRomDir "atari5200"

    if [[ "$md_mode" == "install" ]]; then
        mkUserDir "$md_conf_root/atari800"

        # move old config if exists to new location
        if [[ -f "$md_conf_root/atari800.cfg" ]]; then
            mv "$md_conf_root/atari800.cfg" "$md_conf_root/atari800/atari800.cfg"
        fi
        moveConfigFile "$home/.atari800.cfg" "$md_conf_root/atari800/atari800.cfg"

        # copy launch script (used for unpacking archives)
        sed "s#EMULATOR#/bin/$md_id#" "$scriptdir/scriptmodules/$md_type/atari800/atari800.sh" >"$md_inst/$md_id.sh"
        chmod a+x "$md_inst/$md_id.sh"
    fi

    local params=()
    # if we are on fkms, use the sdl1 dispmanx backend by default for good performance without using X11/opengl
    isPlatform kms && isPlatform "dispmanx" && _backend_set_atari800 "dispmanx"

    # when no dispmanx is available, but still on KMS, use 'sdl12-compat' and go through SDL2
    isPlatform "kms" && ! isPlatform "dispmanx" _&& _backend_set_atari800 "sdl12-compat"

    # this is split out so we can call it via _backend_set_atari800
    _add_emulators_atari800
    addSystem "atari800"
    addSystem "atari5200"

}

function _backend_set_atari800() {
    local mode="$1"
    local force="$2"
    setBackend "$md_id" "$mode" "$force"
    setBackend "$md_id-800" "$mode" "$force"
    setBackend "$md_id-800xl" "$mode" "$force"
    setBackend "$md_id-130xe" "$mode" "$force"
    setBackend "$md_id-5200" "$mode" "$force"
    # call _add_emulators_atari800 again (unless called from configure_atari800) as the emulator.cfg
    # entries differ depending on backend
    [[ "${FUNCNAME[1]}" != "configure_atari800" ]] && _add_emulators_atari800
}
