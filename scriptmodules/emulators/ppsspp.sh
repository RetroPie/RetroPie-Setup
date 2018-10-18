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
rp_module_desc="PlayStation Portable emulator PPSSPP (ORA)"
rp_module_help="ROM Extensions: .iso .pbp .cso\n\nCopy your PlayStation Portable roms to $romdir/psp"
rp_module_licence="GPL2 https://raw.githubusercontent.com/hrydgard/ppsspp/master/LICENSE.TXT"
rp_module_section="opt"
rp_module_flags=""

function sources_ppsspp() {
    gitPullOrClone "$md_build/ppsspp" https://github.com/hrydgard/ppsspp.git
    
    # gl2ext.h fix
    if [[ -e /usr/include/GLES2/gl2ext.h.org ]]; then
        cp -p /usr/include/GLES2/gl2ext.h.org /usr/include/GLES2/gl2ext.h
    else
        cp -p /usr/include/GLES2/gl2ext.h /usr/include/GLES2/gl2ext.h.org
    fi
    sed -i -e 's:GL_APICALL void GL_APIENTRY glBufferStorageEXT://GL_APICALL void GL_APIENTRY glBufferStorageEXT:g' /usr/include/GLES2/gl2ext.h
    sed -i -e 's:GL_APICALL void GL_APIENTRY glCopyImageSubDataOES://GL_APICALL void GL_APIENTRY glCopyImageSubDataOES:g' /usr/include/GLES2/gl2ext.h
    sed -i -e 's:GL_APICALL void GL_APIENTRY glBindFragDataLocationIndexedEXT://GL_APICALL void GL_APIENTRY glBindFragDataLocationIndexedEXT:g' /usr/include/GLES2/gl2ext.h
    
    # CMakeLists.txt changes
    sed -i -e 's:set(ARM ON):set(ARM ON)\n    add_definitions(-mfloat-abi=hard -marm -mtune=cortex-a15.cortex-a7 -mcpu=cortex-a15 -mfpu=neon-vfpv4 -fomit-frame-pointer -ftree-vectorize -mvectorize-with-neon-quad -ffast-math -DARM_NEON):g' "$md_build/ppsspp/CMakeLists.txt"
    sed -i -e 's:set(VULKAN ON):set(VULKAN OFF):g' "$md_build/ppsspp/CMakeLists.txt"
	
    # linux_arm.sh changes   
    sed -i -e 's:cc=arm-linux-gnueabi-gcc:cc=gcc:g' "$md_build/ppsspp/ffmpeg/linux_arm.sh"
    sed -i '/   --cross-prefix=arm-linux-gnueabi- \\/d' "$md_build/ppsspp/ffmpeg/linux_arm.sh"
    sed -i -e 's:nm=arm-linux-gnueabi-nm:nm=nm:g' "$md_build/ppsspp/ffmpeg/linux_arm.sh"
    sed -i -e 's:-mfloat-abi=softfp -mfpu=neon -marm -march=armv7-a:-mfloat-abi=hard -mfpu=neon -marm -march=armv7-a:g' "$md_build/ppsspp/ffmpeg/linux_arm.sh"
    sed -i -e 's:build_ARMv6:#build_ARMv6:g' "$md_build/ppsspp/ffmpeg/linux_arm.sh"
    sed -i -e 's:function #build_ARMv6:function build_ARMv6:g' "$md_build/ppsspp/ffmpeg/linux_arm.sh"
    
    if hasPackage cmake 3.6 lt; then
        cd ..
        mkdir -p cmake
        downloadAndExtract "$__archive_url/cmake-3.6.2.tar.gz" "$md_build/cmake" 1
    fi
}

function build_cmake_ppsspp() {
    cd "$md_build/cmake"
    ./bootstrap
    make
}

function build_ppsspp() {
    local cmake="cmake"
    if hasPackage cmake 3.6 lt; then
        build_cmake_ppsspp
        cmake="$md_build/cmake/bin/cmake"
    fi

    # build ffmpeg
    source "$md_build/ppsspp/ffmpeg/linux_arm.sh"

    # build ppsspp
    cd "$md_build/ppsspp"
    rm -rf CMakeCache.txt CMakeFiles
    local params=()
    params+=(-DARMV7=ON -DARM=ON -DUSING_EGL=ON -DUSING_GLES2=ON -DUSING_FBDEV=ON -DUSING_X11_VULKAN=OFF -DUSING_QT_UI=OFF -DHEADLESS=OFF -DUNITTEST=OFF -DSIMULATOR=OFF -DUSE_WAYLAND_WSI=OFF -DUSE_FFMPEG=YES -DUSE_SYSTEM_FFMPEG=NO)
    "$cmake" "${params[@]}" .
    make clean
    make

    md_ret_require="$md_build/ppsspp/PPSSPPSDL"
}

function install_ppsspp() {
    md_ret_files=(
        'ppsspp/assets'
        'ppsspp/PPSSPPSDL'
    )
}

function install_bin_ppsspp() {
    downloadAndExtract "http://github.com/Retro-Arena/xu4-bins/raw/master/ppsspp.tar.gz" "$md_inst" 1
}

function configure_ppsspp() {
    mkRomDir "psp"

    mkUserDir "$home/.config"
    moveConfigDir "$home/.config/ppsspp" "$md_conf_root/psp"
    mkUserDir "$md_conf_root/psp/PSP"
    ln -snf "$romdir/psp" "$md_conf_root/psp/PSP/GAME"

    addEmulator 0 "$md_id" "psp" "$md_inst/PPSSPPSDL %ROM%"
    addSystem "psp"
	
    # gl2ext.h revert
    if [[ -e /usr/include/GLES2/gl2ext.h.org ]]; then
        cp -p /usr/include/GLES2/gl2ext.h.org /usr/include/GLES2/gl2ext.h
        rm /usr/include/GLES2/gl2ext.h.org
    fi
}
