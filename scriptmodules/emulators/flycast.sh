#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="flycast"
rp_module_desc="Multiplatform Sega Dreamcast, Naomi, Naomi 2 and Atomiswave emulator"
rp_module_help="Dreamcast ROM Extensions: .cdi .gdi .chd, Naomi/Atomiswave ROM Extension: .zip\n\nCopy your Dreamcast/Naomi roms to $romdir/dreamcast\n\nCopy the required Dreamcast BIOS files dc_boot.bin and dc_flash.bin to $biosdir/dc\n\nCopy the required Naomi/Atomiswave BIOS files naomi.zip/naomigd.zip and awbios.zip to $biosdir/dc"
rp_module_licence="GPL2 https://raw.githubusercontent.com/flyinghead/flycast/master/LICENSE"
rp_module_repo="git https://github.com/flyinghead/flycast.git master"
rp_module_section="opt"
rp_module_flags="!armv6 !videocore !:\$__gcc_version:-lt:9"

function depends_flycast() {
    local depends=(zlib1g-dev libgl-dev cmake)
    getDepends "${depends[@]}"
}

function sources_flycast() {
    gitPullOrClone
}

function build_flycast() {
    local params=("-DWITH_SYSTEM_ZLIB=ON -DCMAKE_BUILD_TYPE=Release")

    if isPlatform "gles3"; then
            params+=("-DUSE_GLES=ON")
    elif isPlatform "gles2"; then
            params+=("-DUSE_GLES2=ON")
    fi
    isPlatform "vulkan" && params+=("-DUSE_VULKAN=ON") || params+=("-DUSE_VULKAN=OFF")

    rm -fr build && mkdir build
    cd build
    cmake "${params[@]}" ..
    make

    md_ret_require="$md_build/build/flycast"
}

function install_flycast() {
    md_ret_files=(
        'build/flycast'
        'LICENSE'
    )
}

function configure_flycast() {
    local sys
    local def
    for sys in "arcade" "dreamcast"; do
        def=0
        isPlatform "kms" && [[ "$sys" == "dreamcast" ]] && def=1
        addEmulator $def "$md_id" "$sys" "$md_inst/flycast --config window:fullscreen=yes %ROM%"
        addSystem "$sys"
    done

    [[ "$md_mode" == "remove" ]] && return

    for sys in "arcade" "dreamcast"; do
        mkRomDir "$sys"
        defaultRAConfig "$sys"
    done
    
    # Map flycast's Bios path to match Reicast
    moveConfigDir "$home/.local/share/flycast" "$biosdir/dc"
    mkUserDir "$biosdir/dc"
    
    chown -R $user:$user "$biosdir/dc"
    
    moveConfigDir "$home/.config/flycast" "$md_conf_root/dreamcast/flycast"
    mkUserDir "$md_conf_root/dreamcast/flycast"

    chown -R $user:$user "$md_conf_root/dreamcast/flycast"
}
