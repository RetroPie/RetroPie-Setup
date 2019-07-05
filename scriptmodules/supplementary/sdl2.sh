#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="sdl2"
rp_module_desc="SDL (Simple DirectMedia Layer) v2.x"
rp_module_licence="ZLIB https://hg.libsdl.org/SDL/raw-file/f426dbef4aa0/COPYING.txt"
rp_module_section=""
rp_module_flags=""

function get_ver_sdl2() {
    echo "2.0.9+dfsg1-1+rpt1"
}

function get_pkg_ver_sdl2() {
    local our_ver="1"
    local ver="$(get_ver_sdl2)+"
    isPlatform "videocore" && ver+="videocore"
    isPlatform "mesa" && ver+="mesa"
    isPlatform "mali" && ver+="mali"
    isPlatform "vero4k" && ver+="mali"
    echo "${ver}rpi${our_ver}"
}

function get_arch_sdl2() {
    echo "$(dpkg --print-architecture)"
}

function depends_sdl2() {
    # Dependencies from the debian package control + additional dependencies for the pi (some are excluded like dpkg-dev as they are
    # already covered by the build-essential package retropie relies on.
    local depends=(
        debhelper devscripts dh-autoreconf doxygen fcitx-libs-dev libasound2-dev libdbus-1-dev libegl1-mesa-dev libgles2-mesa-dev
        libglu1-mesa-dev libibus-1.0-dev libpulse-dev libsamplerate0-dev libsndio-dev libudev-dev libvulkan-dev libwayland-dev
        libxkbcommon-dev libxv-dev wayland-protocols
    )
    # these were removed by a PR for vero4k support (cannot test). Needed though at least for for RPI and X11
    ! isPlatform "vero4k" && depends+=(libx11-dev libxcursor-dev libxext-dev libxi-dev libxinerama-dev libxrandr-dev libxss-dev libxt-dev libxxf86vm-dev libgl1-mesa-dev)
    isPlatform "videocore" && depends+=(libraspberrypi-dev)
    isPlatform "mesa" && depends+=(libegl1-mesa-dev libgles2-mesa-dev)
    isPlatform "mali" && depends+=(mali-fbdev)
    isPlatform "kms" && depends+=(libdrm-dev libgbm-dev)
    isPlatform "x11" && depends+=(libpulse-dev libegl1-mesa-dev libgles2-mesa-dev libglu1-mesa-dev)
    isPlatform "vero4k" && depends+=(vero3-userland-dev-osmc)
    getDepends "${depends[@]}"
}

function sources_sdl2() {
    local branch="retropie-2.0.9+dfsg1-1"
    local ver="$(get_ver_sdl2)"
    local pkg_ver="$(get_pkg_ver_sdl2)"

    gitPullOrClone "$md_build/$pkg_ver" https://github.com/psyke83/libsdl2 "$branch"
    cd "$pkg_ver"
    DEBEMAIL="Jools Wills <buzz@exotica.org.uk>" dch -v "$pkg_ver" "SDL $ver configured for the $__platform"
}

function build_sdl2() {
    local conf_flags=()

    cd "$(get_pkg_ver_sdl2)"

    if isPlatform "vero4k"; then
        # remove harmful (mesa) and un-needed (X11) dependancies from debian package control
        sed -i '/^\s*lib.*x\|mesa/ d' ./debian/control
        # disable vulkan and X11 video support
        conf_flags+=("--disable-video-x11")
    elif ! isPlatform "arm"; then
         # disable Raspbian ARM optimizations
         sed -i -e '/-ARM-/d' -e '/-SDL_blit/d' ./debian/patches/series
    fi
    ! isPlatform "x11" && conf_flags+=("--disable-video-vulkan")
    ! isPlatform "videocore" && conf_flags+=("--disable-video-rpi")
    ! isPlatform "mali" && conf_flags+=("--disable-video-mali")
    isPlatform "kms" && conf_flags+=("--enable-video-kmsdrm")
    sed -i 's/confflags =/confflags = '"${conf_flags[*]}"' \\\n/' ./debian/rules

    # disable docs packaging to speed up building
    rm -rf debian/libsdl2-doc.*
    sed -i -e 's/doxygen docs\/doxyfile/install \-Dv \/dev\/null output\/jquery.js/' \
      -e 's/dh_installexamples \-i.*/\/bin\/true/' ./debian/rules

    # enable debhelper <11 compatibility
    if hasPackage "debhelper" 11 "lt"; then
        sed -i 's/debhelper (.*/debhelper,/' ./debian/control
        echo "9" >"debian/compat"
    fi

    dpkg-buildpackage -b
    md_ret_require="$md_build/libsdl2-dev_$(get_pkg_ver_sdl2)_$(get_arch_sdl2).deb"
    local dest="$__tmpdir/archives/$__os_codename/$__platform"
    mkdir -p "$dest"
    cp ../*.deb "$dest/"
}

function remove_old_sdl2() {
    # remove our old libsdl2 packages
    hasPackage libsdl2 && dpkg --remove libsdl2 libsdl2-dev
}

function install_sdl2() {
    remove_old_sdl2
    # if the packages don't install completely due to missing dependencies the apt-get -y -f install will correct it
    if ! dpkg -i libsdl2-2.0-0_$(get_pkg_ver_sdl2)_$(get_arch_sdl2).deb libsdl2-dev_$(get_pkg_ver_sdl2)_$(get_arch_sdl2).deb; then
        apt-get -y -f install
    fi
    echo "libsdl2-dev hold" | dpkg --set-selections
}

function install_bin_sdl2() {
    if ! isPlatform "rpi"; then
        md_ret_errors+=("$md_id is only available as a binary package for platform rpi")
        return 1
    fi
    wget -c "$__binary_url/libsdl2-dev_$(get_pkg_ver_sdl2)_armhf.deb"
    wget -c "$__binary_url/libsdl2-2.0-0_$(get_pkg_ver_sdl2)_armhf.deb"
    install_sdl2
    rm ./*.deb
}

function revert_sdl2() {
    aptUpdate
    local packaged="$(apt-cache madison libsdl2-dev | cut -d" " -f3 | head -n1)"
    if ! aptInstall --allow-downgrades --allow-change-held-packages libsdl2-2.0-0="$packaged" libsdl2-dev="$packaged"; then
        md_ret_errors+=("Failed to revert to OS packaged sdl2 versions")
    fi
}

function remove_sdl2() {
    apt-get remove -y --allow-change-held-packages libsdl2-dev libsdl2-2.0-0
    apt-get autoremove -y
}
