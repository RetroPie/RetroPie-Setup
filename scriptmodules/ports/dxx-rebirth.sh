#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="dxx-rebirth"
rp_module_desc="DXX-Rebirth (Descent & Descent 2) source port"
rp_module_licence="NONCOM https://raw.githubusercontent.com/dxx-rebirth/dxx-rebirth/master/COPYING.txt"
rp_module_repo="git https://github.com/dxx-rebirth/dxx-rebirth master :_get_commit_dxx-rebirth"
rp_module_section="opt"
rp_module_flags="!mali"

function _get_commit_dxx-rebirth() {
    local commit=""
    # last version to build on gcc 10
    [[ "$__gcc_version" -le 10 ]] && commit="ec41384d"
    # last version to build on Debian Buster due to pkg-config issue with physfs
    # newer versions also have incompatible scons changes
    [[ "$__os_debian_ver" -le 10 ]] && commit="15bd145d"
    # latest code requires gcc 7+
    [[ "$__gcc_version" -lt 7 ]] && commit="a1b3a86c"
    echo "$commit"
}

function depends_dxx-rebirth() {
    local depends=(libpng-dev libphysfs-dev scons)
    if isPlatform "videocore"; then
        depends+=(libraspberrypi-dev libsdl1.2-dev libsdl-mixer1.2-dev libsdl-image1.2-dev)
    else
        depends+=(libgl1-mesa-dev libglu1-mesa-dev libsdl2-dev libsdl2-mixer-dev libsdl2-image-dev)
    fi

    getDepends "${depends[@]}"
}

function sources_dxx-rebirth() {
    gitPullOrClone
}

function _get_build_path_dxx-rebirth() {
    # later versions use a build subfolder
    [[ -d "$md_build/build" ]] && echo "build"
}

function build_dxx-rebirth() {
    local params=()
    isPlatform "arm" && params+=("words_need_alignment=1")
    if isPlatform "videocore"; then
        params+=("raspberrypi=1")
    elif isPlatform "mesa"; then
        # GLES is limited to ES 1 and blocks SDL2; GL works at fullspeed on Pi 3.
        params+=("raspberrypi=mesa" "opengl=1" "opengles=0" "sdl2=1")
    else
        params+=("opengl=1" "opengles=0" "sdl2=1")
    fi

    scons -c
    scons "${params[@]}" -j$__jobs

    local build_path="$md_build/$(_get_build_path_dxx-rebirth)"
    md_ret_require=(
        "$build_path/d1x-rebirth/d1x-rebirth"
        "$build_path/d2x-rebirth/d2x-rebirth"
    )
}

function install_dxx-rebirth() {
    # Rename generic files
    mv -f "$md_build/d1x-rebirth/INSTALL.txt" "$md_build/d1x-rebirth/D1X-INSTALL.txt"
    mv -f "$md_build/d1x-rebirth/RELEASE-NOTES.txt" "$md_build/d1x-rebirth/D1X-RELEASE-NOTES.txt"
    mv -f "$md_build/d2x-rebirth/INSTALL.txt" "$md_build/d2x-rebirth/D2X-INSTALL.txt"
    mv -f "$md_build/d2x-rebirth/RELEASE-NOTES.txt" "$md_build/d2x-rebirth/D2X-RELEASE-NOTES.txt"

    local build_path="$(_get_build_path_dxx-rebirth)"

    md_ret_files=(
        'COPYING.txt'
        'GPL-3.txt'
        'd1x-rebirth/README.RPi'
        "$build_path/d1x-rebirth/d1x-rebirth"
        'd1x-rebirth/d1x.ini'
        'd1x-rebirth/D1X-INSTALL.txt'
        'd1x-rebirth/D1X-RELEASE-NOTES.txt'
        "$build_path/d2x-rebirth/d2x-rebirth"
        'd2x-rebirth/d2x.ini'
        'd2x-rebirth/D2X-INSTALL.txt'
        'd2x-rebirth/D2X-RELEASE-NOTES.txt'
    )
}

function game_data_dxx-rebirth() {
    local base_url="$__archive_url/descent"
    local D1X_SHARE_URL="$base_url/descent-pc-shareware.zip"
    local D2X_SHARE_URL="$base_url/descent2-pc-demo.zip"
    local D1X_HIGH_TEXTURE_URL="$base_url/d1xr-hires.dxa"
    local D1X_OGG_URL="$base_url/d1xr-sc55-music.dxa"
    local D2X_OGG_URL="$base_url/d2xr-sc55-music.dxa"

    local dest_d1="$romdir/ports/descent1"
    local dest_d2="$romdir/ports/descent2"

    mkUserDir "$dest_d1"
    mkUserDir "$dest_d2"

    # Download / unpack / install Descent shareware files
    if [[ -z "$(find "$dest_d1" -maxdepth 1 -iname descent.hog)" ]]; then
        downloadAndExtract "$D1X_SHARE_URL" "$dest_d1"
    fi

    # High Res Texture Pack
    if [[ ! -f "$dest_d1/d1xr-hires.dxa" ]]; then
        download "$D1X_HIGH_TEXTURE_URL" "$dest_d1"
    fi

    # Ogg Sound Replacement (Roland Sound Canvas SC-55 MIDI)
    if [[ ! -f "$dest_d1/d1xr-sc55-music.dxa" ]]; then
        download "$D1X_OGG_URL" "$dest_d1"
    fi

    # Download / unpack / install Descent 2 shareware files
    if [[ -z "$(find "$dest_d2" -maxdepth 1 \( -iname D2DEMO.HOG -o -iname DESCENT2.HOG \))" ]]; then
        downloadAndExtract "$D2X_SHARE_URL" "$dest_d2"
    fi

    # Ogg Sound Replacement (Roland Sound Canvas SC-55 MIDI)
    if [[ ! -f "$dest_d2/d2xr-sc55-music.dxa" ]]; then
        download "$D2X_OGG_URL" "$dest_d2"
    fi

    chown -R $user:$user "$dest_d1" "$dest_d2"
}

function configure_dxx-rebirth() {
    local config
    local ver
    local name="Descent Rebirth"
    for ver in 1 2; do
        [[ "$ver" -eq 2 ]] && name="Descent 2 Rebirth"
        addPort "$md_id" "descent${ver}" "$name" "$md_inst/d${ver}x-rebirth -hogdir $romdir/ports/descent${ver}"

        # skip folder / config work on removal
        [[ "$md_mode" == "remove" ]] && continue

        mkRomDir "ports/descent${ver}"
        # copy any existing configs from ~/.d1x-rebirth and symlink the config folder to $md_conf_root/descent1/
        moveConfigDir "$home/.d${ver}x-rebirth" "$md_conf_root/descent${ver}/"
        if isPlatform "kms"; then
            config="$md_conf_root/descent${ver}/descent.cfg"
            iniConfig "=" '' "$config"
            iniSet "VSync" "1"
            chown $user:$user "$config"
        fi
    done

    [[ "$md_mode" == "install" ]] && game_data_dxx-rebirth
}
