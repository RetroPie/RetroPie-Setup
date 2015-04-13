#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="mupen64plus-testing"
rp_module_desc="N64 emulator MUPEN64Plus (Testing)"
rp_module_menus="4+"
rp_module_flags="!odroid"

function depends_mupen64plus-testing() {
    getDepends libsamplerate0-dev libspeexdsp-dev libsdl2-dev
}

function sources_mupen64plus-testing() {
    local repos=(
        #'ricrpi core ric_dev'
        'mupen64plus core'
        'mupen64plus ui-console'
        'ricrpi audio-omx'
        'mupen64plus audio-sdl'
        'mupen64plus input-sdl'
        'mupen64plus rsp-hle'
        #'ricrpi video-gles2rice'
        #'mupen64plus video-rice'
        'ricrpi video-gles2rice pandora-backport'
        #'Narann video-rice'
        #'Nebuleon video-gles2n64'
        'gizmo98 video-gles2n64 pandora-backport'
        #'gizmo98 video-gles2n64'
        'gizmo98 video-glide64mk2 rpi'
    )
    local repo
    for repo in "${repos[@]}"; do
        repo=($repo)
        gitPullOrClone "$md_build/mupen64plus-${repo[1]}" https://github.com/${repo[0]}/mupen64plus-${repo[1]} ${repo[2]}
    done
    gitPullOrClone "$md_build/mupen64plus-video-settings" https://github.com/gizmo98/mupen64plus-video-settings.git
}

function build_mupen64plus-testing() {
    rpSwap on 750

    local dir
    local params
    for dir in *; do
        if [[ -f "$dir/projects/unix/Makefile" ]]; then
            make -C "$dir/projects/unix" clean
            params=()
            [[ "$dir" == "mupen64plus-ui-console" ]] && params+=("COREDIR=$md_inst/lib/" "PLUGINDIR=$md_inst/lib/mupen64plus/")
            [[ "$dir" == "mupen64plus-video-rice" ]] && params+=("VC=1")
            [[ "$dir" == "mupen64plus-video-gles2rice" ]] && params+=("VC=1")
            [[ "$dir" == "mupen64plus-audio-omx" ]] && params+=("VC=1")
            [[ "$dir" == "mupen64plus-video-glide64mk2" ]] && params+=("VC=1")
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

    rpSwap off
}

function install_mupen64plus-testing() {
    for source in *; do
        if [[ -f "$source/projects/unix/Makefile" ]]; then
            # optflags is needed due to the fact the core seems to rebuild 2 files and relink during install stage most likely due to a buggy makefile
            make -C "$source/projects/unix" PREFIX="$md_inst" OPTFLAGS="$CFLAGS" VC=1 install
        fi
    done
    cp -v "$md_build/mupen64plus-video-settings/"{*.ini,*.conf} "$md_inst/share/mupen64plus/"
}

function configure_mupen64plus-testing() {
    # to solve startup problems delete old config file
    rm -f "$configdir/n64/mupen64plus.cfg"
    mkUserDir "$configdir/n64/"
    # Copy config files
    cp -v "$md_inst/share/mupen64plus/"{*.ini,font.ttf,*.conf} "$configdir/n64/"
    cat > "$configdir/n64/mupen64plus.cfg" << _EOF_
    [Video-Rice]
# Control when the screen will be updated (0=ROM default, 1=VI origin update, 2=VI origin change, 3=CI change, 4=first CI change, 5=first primitive draw, 6=before screen clear, 7=after screen drawn)
ScreenUpdateSetting = 7
# Frequency to write back the frame buffer (0=every frame, 1=every other frame, etc)
FrameBufferWriteBackControl = 1
# If this option is enabled, the plugin will skip every other frame
SkipFrame = False
# If this option is enabled, the plugin will only draw every other screen update
SkipScreenUpdate = False
# Force to use texture filtering or not (0=auto: n64 choose, 1=force no filtering, 2=force filtering)
ForceTextureFilter = 2
# Primary texture enhancement filter (0=None, 1=2X, 2=2XSAI, 3=HQ2X, 4=LQ2X, 5=HQ4X, 6=Sharpen, 7=Sharpen More, 8=External, 9=Mirrored)
TextureEnhancement = 6
# Secondary texture enhancement filter (0 = none, 1-4 = filtered)
TextureEnhancementControl = 0

[Video-Glide64mk2]
# Wrapper FBO
wrpFBO = False
_EOF_

    chown -R $user:$user "$configdir/n64"
    su "$user" -c "$md_inst/bin/mupen64plus --configdir $configdir/n64 --datadir $configdir/n64"

    iniConfig " = " '"' "$configdir/n64/mupen64plus.cfg"
    iniSet "AudioPlugin" "mupen64plus-audio-omx.so"
    iniSet "ScreenshotPath" "$romdir/n64"
    iniSet "SaveStatePath" "$romdir/n64"
    iniSet "SaveSRAMPath" "$romdir/n64"
    
    mkRomDir "n64"
    
    addSystem 0 "${md_id}-gles2n64-testing" "n64" "$md_inst/bin/mupen64plus --noosd --fullscreen --gfx mupen64plus-video-n64.so --configdir $configdir/n64 --datadir $configdir/n64 %ROM%"
    addSystem 0 "${md_id}-gles2rice-testing" "n64" "$md_inst/bin/mupen64plus --noosd --fullscreen --gfx mupen64plus-video-rice.so --configdir $configdir/n64 --datadir $configdir/n64 %ROM%"
    addSystem 0 "${md_id}-glide64mk2-testing" "n64" "$md_inst/bin/mupen64plus --noosd --fullscreen --gfx mupen64plus-video-glide64mk2.so --configdir $configdir/n64 --datadir $configdir/n64 %ROM%"
}
