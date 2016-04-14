#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="mupen64plus"
rp_module_desc="N64 emulator MUPEN64Plus"
rp_module_menus="2+"
rp_module_flags="!mali"

function depends_mupen64plus() {
    local depends=(cmake libgl1-mesa-dev libsamplerate0-dev libspeexdsp-dev libsdl2-dev)
    [[ "$__default_gcc_version" == "4.7" ]] && depends+=(gcc-4.8 g++-4.8)
    isPlatform "x11" && depends+=(libglew-dev libglu1-mesa-dev libboost-filesystem-dev)
    getDepends "${depends[@]}"
}

function sources_mupen64plus() {
    local repos=(
        'mupen64plus core'
        'mupen64plus ui-console'
        'mupen64plus audio-sdl'
        'mupen64plus input-sdl'
        'mupen64plus rsp-hle'
    )
    if isPlatform "rpi"; then
        repos+=(
            'gizmo98 audio-omx'
            'ricrpi video-gles2rice pandora-backport'
            'ricrpi video-gles2n64'
        )
    else
        repos+=(
            'mupen64plus video-glide64mk2'
        )
    fi
    local repo
    local dir
    for repo in "${repos[@]}"; do
        repo=($repo)
        dir="$md_build/mupen64plus-${repo[1]}"
        gitPullOrClone "$dir" https://github.com/${repo[0]}/mupen64plus-${repo[1]} ${repo[2]}
    done
    gitPullOrClone "$md_build/GLideN64" https://github.com/gonetz/GLideN64.git
    # fix for static x86_64 libs found in repo which are not usefull if target is i686 
    isPlatform "x11" && sed -i "s/BCMHOST/UNIX/g" GLideN64/src/GLideNHQ/CMakeLists.txt
}

function build_mupen64plus() {
    rpSwap on 750

    local dir
    local params=()
    for dir in *; do
        if [[ -f "$dir/projects/unix/Makefile" ]]; then
            make -C "$dir/projects/unix" clean
            params=()
            isPlatform "rpi1" && params+=("VC=1" "VFP=1" "VFP_HARD=1")
            isPlatform "neon" && params+=("VC=1" "NEON=1")
            isPlatform "x11" && params+=("OSD=1")
            [[ "$dir" == "mupen64plus-ui-console" ]] && params+=("COREDIR=$md_inst/lib/" "PLUGINDIR=$md_inst/lib/mupen64plus/")
            make -C "$dir/projects/unix" all "${params[@]}" OPTFLAGS="$CFLAGS"
        fi
    done

    # build GLideN64
    $md_build/GLideN64/src/getRevision.sh
    pushd $md_build/GLideN64/projects/cmake
    # this plugin needs at least gcc-4.8
    if [[ "$__default_gcc_version" == "4.7" ]]; then
        cmake -DCMAKE_C_COMPILER=gcc-4.8 -DCMAKE_CXX_COMPILER=g++-4.8 -DMUPENPLUSAPI=On ../../src/
    else
        cmake -DMUPENPLUSAPI=On ../../src/
    fi
    make
    popd

    rpSwap off
    md_ret_require=(
        'mupen64plus-ui-console/projects/unix/mupen64plus'
        'mupen64plus-core/projects/unix/libmupen64plus.so.2.0.0'
        'mupen64plus-audio-sdl/projects/unix/mupen64plus-audio-sdl.so'
        'mupen64plus-input-sdl/projects/unix/mupen64plus-input-sdl.so'
        'mupen64plus-rsp-hle/projects/unix/mupen64plus-rsp-hle.so'
        'GLideN64/projects/cmake/plugin/release/mupen64plus-video-GLideN64.so'
    )
    if isPlatform "rpi"; then
        md_ret_require+=(
            'mupen64plus-video-gles2rice/projects/unix/mupen64plus-video-rice.so'
            'mupen64plus-video-gles2n64/projects/unix/mupen64plus-video-n64.so'
            'mupen64plus-audio-omx/projects/unix/mupen64plus-audio-omx.so'
        )
    else
        md_ret_require+=(
            'mupen64plus-video-glide64mk2/projects/unix/mupen64plus-video-glide64mk2.so'
        )
    fi
}

function install_mupen64plus() {
    for source in *; do
        if [[ -f "$source/projects/unix/Makefile" ]]; then
            # optflags is needed due to the fact the core seems to rebuild 2 files and relink during install stage most likely due to a buggy makefile
            local params=()
            isPlatform "rpi" && params+=("VC=1")
            make -C "$source/projects/unix" PREFIX="$md_inst" OPTFLAGS="$CFLAGS" "${params[@]}" install
        fi
    done
    cp "$md_build/GLideN64/ini/GLideN64.custom.ini" "$md_inst/share/mupen64plus/"
    cp "$md_build/GLideN64/projects/cmake/plugin/release/mupen64plus-video-GLideN64.so" "$md_inst/lib/mupen64plus/"
}

function configure_mupen64plus() {
    mkRomDir "n64"

    # copy hotkey remapping start script
    cp "$scriptdir/scriptmodules/$md_type/$md_id/mupen64plus.sh" "$md_inst/bin/"
    chmod +x "$md_inst/bin/mupen64plus.sh"

    # to solve startup problems delete old config file
    rm -f "$md_conf_root/n64/mupen64plus.cfg"
    # remove default InputAutoConfig.ini. inputconfigscript writes a clean file
    rm -f "$md_inst/share/mupen64plus/InputAutoCfg.ini"
    mkUserDir "$md_conf_root/n64/"
    # Copy config files
    cp -v "$md_inst/share/mupen64plus/"{*.ini,font.ttf,*.conf} "$md_conf_root/n64/"
    su "$user" -c "$md_inst/bin/mupen64plus --md_conf_root $md_conf_root/n64 --datadir $md_conf_root/n64"

    iniConfig " = " '"' "$md_conf_root/n64/mupen64plus.cfg"
    iniSet "ScreenshotPath" "$romdir/n64"
    iniSet "SaveStatePath" "$romdir/n64"
    iniSet "SaveSRAMPath" "$romdir/n64"

    chown -R $user:$user "$md_conf_root/n64"

    delSystem "$md_id" "n64-mupen64plus"
    addSystem 0 "${md_id}-GLideN64" "n64" "$md_inst/bin/mupen64plus.sh mupen64plus-video-GLideN64 %ROM%"
    if isPlatform "rpi"; then
        addSystem 1 "${md_id}-gles2rice" "n64" "$md_inst/bin/mupen64plus.sh mupen64plus-video-rice %ROM%"
        addSystem 0 "${md_id}-gles2n64" "n64" "$md_inst/bin/mupen64plus.sh mupen64plus-video-n64 %ROM%"
    else
        addSystem 1 "${md_id}-glide64" "n64" "$md_inst/bin/mupen64plus.sh mupen64plus-video-glide64mk2 %ROM%"
    fi

    addAutoConf mupen64plus_audio 1
    addAutoConf mupen64plus_hotkeys 1
    addAutoConf mupen64plus_compatibility_check 1
}
