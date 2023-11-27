#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="ppsspp"
rp_module_desc="PlayStation Portable emulator PPSSPP"
rp_module_help="ROM Extensions: .iso .pbp .cso\n\nCopy your PlayStation Portable roms to $romdir/psp"
rp_module_licence="GPL2 https://raw.githubusercontent.com/hrydgard/ppsspp/master/LICENSE.TXT"
rp_module_repo="git https://github.com/hrydgard/ppsspp.git :_get_release_ppsspp"
rp_module_section="opt"
rp_module_flags=""

function _get_release_ppsspp() {
    local tagged_version="v1.16.6"
    #  the V3D Mesa driver before 21.x has issues with v1.14 and later
    if [[ "$__os_debian_ver" -lt 11 ]] && isPlatform "kms" && isPlatform "rpi"; then
        tagged_version="v1.13.2"
    fi
    echo $tagged_version
}

function depends_ppsspp() {
    local depends=(cmake libsdl2-dev libsnappy-dev libzip-dev zlib1g-dev)
    isPlatform "videocore" && depends+=(libraspberrypi-dev)
    isPlatform "mesa" && depends+=(libgles2-mesa-dev)
    isPlatform "vero4k" && depends+=(vero3-userland-dev-osmc)
    getDepends "${depends[@]}"
}

function sources_ppsspp() {
    gitPullOrClone "$md_build/ppsspp"
    cd "ppsspp"

    # remove the lines that trigger the ffmpeg build script functions - we will just use the variables from it
    sed -i "/^build_ARMv6$/,$ d" ffmpeg/linux_arm.sh

    # remove -U__GCC_HAVE_SYNC_COMPARE_AND_SWAP_2 as we handle this ourselves if armv7 on Raspbian
    sed -i "/^  -U__GCC_HAVE_SYNC_COMPARE_AND_SWAP_2/d" cmake/Toolchains/raspberry.armv7.cmake
    # set ARCH_FLAGS to our own CXXFLAGS (which includes GCC_HAVE_SYNC_COMPARE_AND_SWAP_2 if needed)
    sed -i "s/^set(ARCH_FLAGS.*/set(ARCH_FLAGS \"$CXXFLAGS\")/" cmake/Toolchains/raspberry.armv7.cmake

    # remove file(READ "/sys/firmware/devicetree/base/compatible" PPSSPP_PI_MODEL)
    # as it fails when building in a chroot
    sed -i "/^file(READ .*/d" cmake/Toolchains/raspberry.armv7.cmake

    # ensure Pi vendor libraries are available for linking of shared library
    sed -n -i "p; s/^set(CMAKE_EXE_LINKER_FLAGS/set(CMAKE_SHARED_LINKER_FLAGS/p" cmake/Toolchains/raspberry.armv?.cmake

    # fix missing defines on opengles2 on v1.16.6
    if [[ "$md_id" == "ppsspp" && "$(_get_release_ppsspp)" == "v1.16.6" ]]; then
        applyPatch "$md_data/gles2_fix.diff"
    fi

    # fix missing exported symbol for libretro on v1.13.2
    if [[ "$md_id" == "lr-ppsspp" && "$(_get_release_ppsspp)" == "v1.13.2" ]]; then
        applyPatch "$md_data/v13-libretro_fix.diff"
    fi

    if hasPackage cmake 3.6 lt; then
        cd ..
        mkdir -p cmake
        downloadAndExtract "$__archive_url/cmake-3.6.2.tar.gz" "$md_build/cmake" --strip-components 1
    fi
}

function build_ffmpeg_ppsspp() {
    cd "$1"
    local arch
    if isPlatform "arm"; then
        if isPlatform "armv6"; then
            arch="arm"
        else
            arch="armv7"
        fi
    elif isPlatform "x86"; then
        if isPlatform "x86_64"; then
            arch="x86_64";
        else
            arch="x86";
        fi
    elif isPlatform "aarch64"; then
        arch="aarch64"
    fi
    isPlatform "vero4k" && local extra_params='--arch=arm'

    local MODULES
    local VIDEO_DECODERS
    local AUDIO_DECODERS
    local VIDEO_ENCODERS
    local AUDIO_ENCODERS
    local DEMUXERS
    local MUXERS
    local PARSERS
    local GENERAL
    local OPTS # used by older lr-ppsspp fork
    # get the ffmpeg configure variables from the ppsspp ffmpeg distributed script
    source linux_arm.sh
    # linux_arm.sh has set -e which we need to switch off
    set +e
    ./configure $extra_params \
        --prefix="./linux/$arch" \
        --extra-cflags="-fasm -Wno-psabi -fno-short-enums -fno-strict-aliasing -finline-limit=300" \
        --disable-shared \
        --enable-static \
        --enable-zlib \
        --enable-pic \
        --disable-everything \
        ${MODULES} \
        ${VIDEO_DECODERS} \
        ${AUDIO_DECODERS} \
        ${VIDEO_ENCODERS} \
        ${AUDIO_ENCODERS} \
        ${DEMUXERS} \
        ${MUXERS} \
        ${PARSERS}
    make clean
    make install
}

function build_cmake_ppsspp() {
    cd "$md_build/cmake"
    ./bootstrap
    make
}

function build_ppsspp() {
    local ppsspp_binary="PPSSPPSDL"
    local cmake="cmake"
    if hasPackage cmake 3.6 lt; then
        build_cmake_ppsspp
        cmake="$md_build/cmake/bin/cmake"
    fi

    # build ffmpeg
    build_ffmpeg_ppsspp "$md_build/ppsspp/ffmpeg"

    # build ppsspp
    cd "$md_build/ppsspp"
    rm -rf CMakeCache.txt CMakeFiles
    local params=()
    if isPlatform "videocore"; then
        if isPlatform "armv6"; then
            params+=(-DCMAKE_TOOLCHAIN_FILE=cmake/Toolchains/raspberry.armv6.cmake -DFORCED_CPU=armv6 -DATOMIC_LIB=atomic)
        else
            params+=(-DCMAKE_TOOLCHAIN_FILE=cmake/Toolchains/raspberry.armv7.cmake)
        fi
    elif isPlatform "mesa"; then
        params+=(-DUSING_GLES2=ON -DUSING_EGL=OFF)
    elif isPlatform "mali"; then
        params+=(-DUSING_GLES2=ON -DUSING_FBDEV=ON)
        # remove -DGL_GLEXT_PROTOTYPES on odroid-xu/tinker to avoid errors due to header prototype differences
        params+=(-DCMAKE_C_FLAGS="${CFLAGS/-DGL_GLEXT_PROTOTYPES/}")
        params+=(-DCMAKE_CXX_FLAGS="${CXXFLAGS/-DGL_GLEXT_PROTOTYPES/}")
    elif isPlatform "tinker"; then
        params+=(-DCMAKE_TOOLCHAIN_FILE="$md_data/tinker.armv7.cmake")
    fi
    isPlatform "vero4k" && params+=(-DCMAKE_TOOLCHAIN_FILE="cmake/Toolchains/vero4k.armv8.cmake")
    if isPlatform "arm" && ! isPlatform "vulkan"; then
        params+=(-DARM_NO_VULKAN=ON)
    fi
    if [[ "$md_id" == "lr-ppsspp" ]]; then
        params+=(-DLIBRETRO=On)
        ppsspp_binary="lib/ppsspp_libretro.so"
    fi
    "$cmake" "${params[@]}" .
    make clean
    make

    md_ret_require="$md_build/ppsspp/$ppsspp_binary"
}

function install_ppsspp() {
    md_ret_files=(
        'ppsspp/assets'
        'ppsspp/PPSSPPSDL'
    )
}

function configure_ppsspp() {
    local extra_params=()
    if ! isPlatform "x11"; then
        extra_params+=(--fullscreen)
    fi

    mkRomDir "psp"
    if [[ "$md_mode" == "install" ]]; then
        moveConfigDir "$home/.config/ppsspp" "$md_conf_root/psp"
        mkUserDir "$md_conf_root/psp/PSP"
        ln -snf "$romdir/psp" "$md_conf_root/psp/PSP/GAME"
    fi

    addEmulator 0 "$md_id" "psp" "pushd $md_inst; $md_inst/PPSSPPSDL ${extra_params[*]} %ROM%; popd"
    addSystem "psp"

    # if we are removing the last remaining psp emu - remove the symlink
    if [[ "$md_mode" == "remove" ]]; then
        if [[ -h "$home/.config/ppsspp" && ! -f "$md_conf_root/psp/emulators.cfg" ]]; then
            rm -f "$home/.config/ppsspp"
        fi
    fi
}
