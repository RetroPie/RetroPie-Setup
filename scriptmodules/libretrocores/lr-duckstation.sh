#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-duckstation"
rp_module_desc="PlayStation emulator - Duckstation for libretro"
rp_module_help="ROM Extensions: .exe .cue .bin .chd .psf .m3u .pbp\n\nCopy your PlayStation roms to $romdir/psx\n\nCopy compatble BIOS files to $biosdir"
rp_module_licence="PROP"
rp_module_section="exp"
rp_module_flags="!all arm !armv6 aarch64 64bit"

function __binary_url_lr-duckstation() {
    local url="https://www.duckstation.org/libretro/duckstation_libretro_linux_"
    isPlatform "aarch64" && echo "${url}aarch64.zip"
    isPlatform "arm" && echo "${url}armv7.zip"
    isPlatform "x86" && isPlatform "64bit" && echo "${url}x64.zip"
}

function install_bin_lr-duckstation() {
    downloadAndExtract "$(__binary_url_lr-duckstation)" "$md_inst"
}

function configure_lr-duckstation() {
    mkRomDir "psx"
    ensureSystemretroconfig "psx"

    if isPlatform "gles" && ! isPlatform "gles3"; then
        # Hardware renderer not supported on GLES2 devices
        setRetroArchCoreOption "duckstation_GPU.Renderer" "Software"
    fi

    # Pi 4 has occasional slowdown with hardware rendering
    # e.g. Gran Turismo 2 (Arcade) race start
    isPlatform "rpi4" && setRetroArchCoreOption "duckstation_GPU.Renderer" "Software"

    # dynarec segfaults without redirecting stdin from </dev/null
    addEmulator 0 "$md_id" "psx" "$md_inst/duckstation_libretro.so </dev/null"
    addSystem "psx"
}
