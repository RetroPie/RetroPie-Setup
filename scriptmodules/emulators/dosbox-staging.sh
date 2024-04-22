#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="dosbox-staging"
rp_module_desc="modern DOS/x86 emulator focusing on ease of use"
rp_module_help="ROM Extensions: .bat .com .exe .sh .conf\n\nCopy your DOS games to $romdir/pc"
rp_module_licence="GPL2 https://raw.githubusercontent.com/dosbox-staging/dosbox-staging/master/COPYING"
rp_module_repo="git https://github.com/dosbox-staging/dosbox-staging.git :_get_branch_dosbox-staging"
rp_module_section="opt"
rp_module_flags="sdl2"

function _get_branch_dosbox-staging() {
    # use 0.80.1 for VideoCore devices, 0.81 and later require OpenGL
    if isPlatform "videocore"; then
        echo "v0.80.1"
        return
    fi
    download https://api.github.com/repos/dosbox-staging/dosbox-staging/releases/latest - | grep -m 1 tag_name | cut -d\" -f4
}

function depends_dosbox-staging() {
    local depends
    depends=(cmake libasound2-dev libglib2.0-dev libopusfile-dev libpng-dev libsdl2-dev libsdl2-net-dev libspeexdsp-dev meson ninja-build zlib1g-dev)
    [[ "$__os_debian_ver" -ge 11 ]] && depends+=(libslirp-dev libfluidsynth-dev)

    getDepends "${depends[@]}"
}

function sources_dosbox-staging() {
    gitPullOrClone
    # Check if we have at least meson>=0.57, otherwise install it locally for the build
    local meson_version="$(meson --version)"
    if compareVersions "$meson_version" lt 0.57; then
        downloadAndExtract "https://github.com/mesonbuild/meson/releases/download/0.61.5/meson-0.61.5.tar.gz" meson --strip-components 1
    fi
}

function build_dosbox-staging() {
    local params=(-Dprefix="$md_inst" -Ddatadir="resources" -Dtry_static_libs="iir,mt32emu")
    # use the build local Meson installation if found
    local meson_cmd="meson"
    [[ -f "$md_build/meson/meson.py" ]] && meson_cmd="python3 $md_build/meson/meson.py"

    # disable speexdsp simd support on armv6 devices
    isPlatform "armv6" && params+=(-Dspeexdsp:simd=false)

    $meson_cmd setup "${params[@]}" build
    $meson_cmd compile -j${__jobs} -C build

    md_ret_require=(
        "$md_build/build/dosbox"
    )
}

function install_dosbox-staging() {
    ninja -C build install
}

function configure_dosbox-staging() {
    configure_dosbox

    [[ "$md_id" == "remove" ]] && return

    local config_dir="$md_conf_root/pc"
    chown -R $user: "$config_dir"

    local staging_output="texturenb"
    if isPlatform "kms"; then
        staging_output="openglnb"
    fi

    local config_path=$(su "$user" -c "\"$md_inst/bin/dosbox\" -printconf")
    if [[ -f "$config_path" ]]; then
        iniConfig " = " "" "$config_path"
        if isPlatform "rpi"; then
            iniSet "fullscreen" "true"
            iniSet "fullresolution" "original"
            iniSet "vsync" "true"
            iniSet "output" "$staging_output"
            iniSet "core" "dynamic"
            iniSet "blocksize" "2048"
            iniSet "prebuffer" "50"
        fi
    fi
}
