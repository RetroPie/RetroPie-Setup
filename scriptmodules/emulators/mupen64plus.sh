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
rp_module_help="ROM Extensions: .z64 .n64 .v64\n\nCopy your N64 roms to $romdir/n64"
rp_module_section="main"
rp_module_flags="!mali"

function depends_mupen64plus() {
    local depends=(cmake libgl1-mesa-dev libsamplerate0-dev libspeexdsp-dev libsdl2-dev)
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
            'gizmo98 video-videocore'
        )
    else
        repos+=(
            'mupen64plus video-glide64mk2'
            'mupen64plus rsp-cxd4'
            'mupen64plus rsp-z64'
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
            isPlatform "x86" && params+=("SSE=SSSE3")
            [[ "$dir" == "mupen64plus-ui-console" ]] && params+=("COREDIR=$md_inst/lib/" "PLUGINDIR=$md_inst/lib/mupen64plus/")
            make -C "$dir/projects/unix" all "${params[@]}" OPTFLAGS="$CFLAGS -flto"
        fi
    done

    # build GLideN64
    $md_build/GLideN64/src/getRevision.sh
    pushd $md_build/GLideN64/projects/cmake
    params=("-DMUPENPLUSAPI=On" "-DVEC4_OPT=On")
    isPlatform "neon" && params+=("-DNEON_OPT=On")
    isPlatform "rpi3" && params+=("-DCRC_ARMV8=On")
    cmake "${params[@]}" ../../src/
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
            'mupen64plus-video-videocore/projects/unix/mupen64plus-video-videocore.so'
        )
    else
        md_ret_require+=(
            'mupen64plus-video-glide64mk2/projects/unix/mupen64plus-video-glide64mk2.so'
            'mupen64plus-rsp-z64/projects/unix/mupen64plus-rsp-z64.so'
        )
        if isPlatform "x86"; then
            md_ret_require+=('mupen64plus-rsp-cxd4/projects/unix/mupen64plus-rsp-cxd4-ssse3.so')
        else
            md_ret_require+=('mupen64plus-rsp-cxd4/projects/unix/mupen64plus-rsp-cxd4.so')
        fi
    fi
}

function install_mupen64plus() {
    for source in *; do
        if [[ -f "$source/projects/unix/Makefile" ]]; then
            # optflags is needed due to the fact the core seems to rebuild 2 files and relink during install stage most likely due to a buggy makefile
            local params=()
            isPlatform "rpi" && params+=("VC=1")
            isPlatform "x86" && params+=("SSE=SSSE3")
            make -C "$source/projects/unix" PREFIX="$md_inst" OPTFLAGS="$CFLAGS" "${params[@]}" install
        fi
    done
    cp "$md_build/GLideN64/ini/GLideN64.custom.ini" "$md_inst/share/mupen64plus/"
    cp "$md_build/GLideN64/projects/cmake/plugin/release/mupen64plus-video-GLideN64.so" "$md_inst/lib/mupen64plus/"
    # remove default InputAutoConfig.ini. inputconfigscript writes a clean file
    rm -f "$md_inst/share/mupen64plus/InputAutoCfg.ini"
}

function configure_mupen64plus() {
    if isPlatform "rpi"; then
        local res
        for res in "320x240" "640x480"; do
            local def=0
            local name=""
            [[ "$res" == "320x240" ]] && def=1
            [[ "$res" == "640x480" ]] && name="-highres"
            addSystem $def "${md_id}-GLideN64$name" "n64" "$md_inst/bin/mupen64plus.sh mupen64plus-video-GLideN64 %ROM% $res"
            addSystem 0 "${md_id}-gles2rice$name" "n64" "$md_inst/bin/mupen64plus.sh mupen64plus-video-rice %ROM% $res"
        done
        addSystem 0 "${md_id}-gles2n64" "n64" "$md_inst/bin/mupen64plus.sh mupen64plus-video-n64 %ROM%"
        addSystem 0 "${md_id}-videocore" "n64" "$md_inst/bin/mupen64plus.sh mupen64plus-video-videocore %ROM%"
    else
        addSystem 0 "${md_id}-GLideN64" "n64" "$md_inst/bin/mupen64plus.sh mupen64plus-video-GLideN64 %ROM%"
        addSystem 0 "${md_id}-GLideN64-GL3-3" "n64" "MESA_GL_VERSION_OVERRIDE=3.3COMPAT $md_inst/bin/mupen64plus.sh mupen64plus-video-GLideN64 %ROM%"
        addSystem 1 "${md_id}-glide64" "n64" "$md_inst/bin/mupen64plus.sh mupen64plus-video-glide64mk2 %ROM%"
        if isPlatform "x86"; then
            addSystem 0 "${md_id}-GLideN64-LLE" "n64" "$md_inst/bin/mupen64plus.sh mupen64plus-video-GLideN64 %ROM% 640x480 mupen64plus-rsp-cxd4-ssse3"
            addSystem 0 "${md_id}-GLideN64-LLE-GL3-3" "n64" "MESA_GL_VERSION_OVERRIDE=3.3COMPAT $md_inst/bin/mupen64plus.sh mupen64plus-video-GLideN64 %ROM% 640x480 mupen64plus-rsp-cxd4-ssse3"
        fi
    fi

    mkRomDir "n64"

    [[ "$md_mode" == "remove" ]] && return

    # copy hotkey remapping start script
    cp "$scriptdir/scriptmodules/$md_type/$md_id/mupen64plus.sh" "$md_inst/bin/"
    chmod +x "$md_inst/bin/mupen64plus.sh"

    mkUserDir "$md_conf_root/n64/"

    # Copy config files
    cp -v "$md_inst/share/mupen64plus/"{*.ini,font.ttf} "$md_conf_root/n64/"
    isPlatform "rpi" && cp -v "$md_inst/share/mupen64plus/"*.conf "$md_conf_root/n64/"

    local config="$md_conf_root/n64/mupen64plus.cfg"
    local cmd="$md_inst/bin/mupen64plus --configdir $md_conf_root/n64 --datadir $md_conf_root/n64"

    # if the user has an existing mupen64plus config we back it up, generate a new configuration
    # copy that to rp-dist and put the original config back again. We then make any ini changes
    # on the rp-dist file. This preserves any user configs from modification and allows us to have
    # a default config for reference
    if [[ -f "$config" ]]; then
        mv "$config" "$config.user"
        su "$user" -c "$cmd"
        mv "$config" "$config.rp-dist"
        mv "$config.user" "$config"
        config+=".rp-dist"
    else
        su "$user" -c "$cmd"
    fi

    # RPI GLideN64 settings
    if isPlatform "rpi"; then
        iniConfig " = " "" "$config"
        # Create GlideN64 section in .cfg
        if ! grep -q "\[Video-GLideN64\]" "$config"; then
            echo "[Video-GLideN64]" >> "$config"
        fi
        # Settings version. Don't touch it.
        iniSet "configVersion" "14"
        # Bilinear filtering mode (0=N64 3point, 1=standard)
        iniSet "bilinearMode" "1"
        # Size of texture cache in megabytes. Good value is VRAM*3/4
        iniSet "CacheSize" "192"
        # Disable FB emulation until visual issues are sorted out
        iniSet "EnableFBEmulation" "False"
        # Use native res
        iniSet "UseNativeResolutionFactor" "1"

        # Disable gles2n64 autores feature and use dispmanx upscaling
        iniConfig " = " "" "$md_conf_root/n64/gles2n64.conf"
        iniSet "auto resolution" "0"

        addAutoConf mupen64plus_audio 1
        addAutoConf mupen64plus_compatibility_check 1
    else
        addAutoConf mupen64plus_audio 0
        addAutoConf mupen64plus_compatibility_check 0
    fi

    addAutoConf mupen64plus_hotkeys 1

    chown -R $user:$user "$md_conf_root/n64"
}
