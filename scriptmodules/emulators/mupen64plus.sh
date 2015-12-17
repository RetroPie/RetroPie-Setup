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
rp_module_flags="!odroid"

function depends_mupen64plus() {
    getDepends cmake libgl1-mesa-dev libsamplerate0-dev libspeexdsp-dev libsdl2-dev
    [[ "$__default_gcc_version" == "4.7" ]] && getDepends gcc-4.8 g++-4.8
}

function sources_mupen64plus() {
    local repos=(
        #'ricrpi core ric_dev'
        'mupen64plus core'
        'mupen64plus ui-console'
        'gizmo98 audio-omx'
        'mupen64plus audio-sdl'
        'mupen64plus input-sdl'
        #'ricrpi rsp-hle'
        'mupen64plus rsp-hle'
        'ricrpi video-gles2rice pandora-backport'
        #'RetroPie video-rice rpi'
        'ricrpi video-gles2n64'
    )
    local repo
    local dir
    for repo in "${repos[@]}"; do
        repo=($repo)
        dir="$md_build/mupen64plus-${repo[1]}"
        gitPullOrClone "$dir" https://github.com/${repo[0]}/mupen64plus-${repo[1]} ${repo[2]}
    done
    gitPullOrClone "$md_build/GLideN64" https://github.com/gonetz/GLideN64.git
}

function build_mupen64plus() {
    rpSwap on 750

    local dir
    local params
    for dir in *; do
        if [[ -f "$dir/projects/unix/Makefile" ]]; then
            make -C "$dir/projects/unix" clean
            params=()
            [[ "$dir" == "mupen64plus-ui-console" ]] && params+=("COREDIR=$md_inst/lib/" "PLUGINDIR=$md_inst/lib/mupen64plus/")
            [[ "$dir" == "mupen64plus-video-gles2rice" ]] && params+=("VC=1")
            [[ "$dir" == "mupen64plus-video-rice" ]] && params+=("VC=1")
            [[ "$dir" == "mupen64plus-audio-omx" ]] && params+=("VC=1")
            if isPlatform "rpi2"; then
                [[ "$dir" == "mupen64plus-core" ]] && params+=("VC=1" "NEON=1")
                [[ "$dir" == "mupen64plus-video-gles2n64" ]] && params+=("VC=1" "NEON=1")
            else
                [[ "$dir" == "mupen64plus-core" ]] && params+=("VC=1" "VFP_HARD=1")
                [[ "$dir" == "mupen64plus-video-gles2n64" ]] && params+=("VC=1" "VFP=1")
            fi
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
        'mupen64plus-audio-omx/projects/unix/mupen64plus-audio-omx.so'
        'mupen64plus-video-gles2n64/projects/unix/mupen64plus-video-n64.so'
        'mupen64plus-rsp-hle/projects/unix/mupen64plus-rsp-hle.so'
        'mupen64plus-video-gles2rice/projects/unix/mupen64plus-video-rice.so'
        'GLideN64/projects/cmake/plugin/release/mupen64plus-video-GLideN64.so'
    )
}

function install_mupen64plus() {
    for source in *; do
        if [[ -f "$source/projects/unix/Makefile" ]]; then
            # optflags is needed due to the fact the core seems to rebuild 2 files and relink during install stage most likely due to a buggy makefile
            make -C "$source/projects/unix" PREFIX="$md_inst" OPTFLAGS="$CFLAGS" VC=1 install
        fi
    done
    cp "$md_build/GLideN64/ini/GLideN64.custom.ini" "$md_inst/share/mupen64plus/"
    cp "$md_build/GLideN64/projects/cmake/plugin/release/mupen64plus-video-GLideN64.so" "$md_inst/lib/mupen64plus/"
}

function configure_mupen64plus() {
    # copy hotkey remapping start script
    cp "$scriptdir/scriptmodules/$md_type/$md_id/mupen64plus.sh" "$md_inst/bin/"
    chmod +x "$md_inst/bin/mupen64plus.sh"
    
    # to solve startup problems delete old config file
    rm -f "$configdir/n64/mupen64plus.cfg"
    # remove default InputAutoConfig.ini. inputconfigscript writes a clean file
    rm -f "$md_inst/share/mupen64plus/InputAutoCfg.ini"
    mkUserDir "$configdir/n64/"
    # Copy config files
    cp -v "$md_inst/share/mupen64plus/"{*.ini,font.ttf,*.conf} "$configdir/n64/"
    chown -R $user:$user "$configdir/n64"
    su "$user" -c "$md_inst/bin/mupen64plus --configdir $configdir/n64 --datadir $configdir/n64"
    
    iniConfig " = " '"' "$configdir/n64/mupen64plus.cfg"
    iniSet "AudioPlugin" "mupen64plus-audio-omx.so"
    iniSet "ScreenshotPath" "$romdir/n64"
    iniSet "SaveStatePath" "$romdir/n64"
    iniSet "SaveSRAMPath" "$romdir/n64"
    
    mkRomDir "n64"

    delSystem "$md_id" "n64-mupen64plus"
    addSystem 0 "${md_id}-gles2n64" "n64" "$md_inst/bin/mupen64plus.sh mupen64plus-video-n64 %ROM%"
    addSystem 1 "${md_id}-gles2rice" "n64" "$md_inst/bin/mupen64plus.sh mupen64plus-video-rice %ROM%"
    addSystem 0 "${md_id}-GLideN64" "n64" "$md_inst/bin/mupen64plus.sh mupen64plus-video-GLideN64 %ROM%"

    addAutoConf mupen64plus_audio 1
    addAutoConf mupen64plus_hotkeys 1
    addAutoConf mupen64plus_compatibility_check 1
}
