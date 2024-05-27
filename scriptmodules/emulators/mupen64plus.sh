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
rp_module_licence="GPL2 https://raw.githubusercontent.com/mupen64plus/mupen64plus-core/master/LICENSES"
rp_module_repo=":_pkg_info_mupen64plus"
rp_module_section="main"
rp_module_flags="sdl2 nodistcc"

function depends_mupen64plus() {
    local depends=(cmake libsamplerate0-dev libspeexdsp-dev libsdl2-dev libpng-dev libfreetype6-dev fonts-freefont-ttf libboost-filesystem-dev)
    isPlatform "videocore" && depends+=(libraspberrypi-dev)
    isPlatform "mesa" && depends+=(libgles2-mesa-dev)
    isPlatform "gl" && depends+=(libglew-dev libglu1-mesa-dev)
    isPlatform "x86" && depends+=(nasm)
    isPlatform "vero4k" && depends+=(vero3-userland-dev-osmc)
    # was a vero4k only line - I think it's not needed or can use a smaller subset of boost
    isPlatform "osmc" && depends+=(libboost-all-dev)
    getDepends "${depends[@]}"
}

function _get_repos_mupen64plus() {
    local repos=(
        'mupen64plus mupen64plus-core master'
        'mupen64plus mupen64plus-ui-console master'
        'mupen64plus mupen64plus-audio-sdl master'
        'mupen64plus mupen64plus-input-sdl master'
        'mupen64plus mupen64plus-rsp-hle master'
    )
    if isPlatform "videocore" && isPlatform "32bit"; then
        repos+=('gizmo98 mupen64plus-audio-omx master')
    fi
    if isPlatform "gles"; then
        ! isPlatform "rpi" && repos+=('mupen64plus mupen64plus-video-glide64mk2 master')
        if isPlatform "32bit"; then
            repos+=('ricrpi mupen64plus-video-gles2rice pandora-backport')
            repos+=('ricrpi mupen64plus-video-gles2n64 master')
        fi
    fi
    if isPlatform "gl"; then
        repos+=(
            'mupen64plus mupen64plus-video-glide64mk2 master'
            'mupen64plus mupen64plus-rsp-cxd4 master'
            'mupen64plus mupen64plus-rsp-z64 master'
        )
    fi

    local commit=""
    # GLideN64 now requires cmake 3.9 so use an older commit as a workaround for systems with older cmake (pre buster).
    # Test using "apt-cache madison" as this code could be called when cmake isn't yet installed but correct version
    # is available - eg via update check with builder module which removes dependencies after building.
    # Multiple versions may be available, so grab the versions via cut, sort by version, take the latest from the top
    # and pipe to xargs to strip whitespace
    local cmake_ver=$(apt-cache madison cmake | cut -d\| -f2 | sort --version-sort | head -1 | xargs)
    if compareVersions "$cmake_ver" lt 3.9; then
        commit="8a9d52b41b33d853445f0779dd2b9f5ec4ecdda8"
    fi
    # avoid a GLideN64 regression introduced in 1a0621d
    isPlatform "gles" && commit="5bbf55df"
    repos+=("gonetz GLideN64 master $commit")

    local repo
    for repo in "${repos[@]}"; do
        echo "$repo"
    done
}

function _pkg_info_mupen64plus() {
    local mode="$1"
    local repo
    case "$mode" in
        get)
            local hashes=()
            local hash
            local date
            local newest_date
            while read repo; do
                repo=($repo)
                date=$(git -C "$md_build/${repo[1]}" log -1 --format=%aI)
                hash="$(git -C "$md_build/${repo[1]}" log -1 --format=%H)"
                hashes+=("$hash")
                if rp_dateIsNewer "$newest_date" "$date"; then
                    newest_date="$date"
                fi
            done < <(_get_repos_mupen64plus)
            # store an md5sum of the various last commit hashes to be used to check for changes
            local hash="$(echo "${hashes[@]}" | md5sum | cut -d" " -f1)"
            echo "local pkg_repo_date=\"$newest_date\""
            echo "local pkg_repo_extra=\"$hash\""
            ;;
        newer)
            local hashes=()
            local hash
            while read repo; do
                repo=($repo)
                # if we have any repos set to a specific git hash (eg GLideN64 then we use that) otherwise check
                if [[ -n "${repo[3]}" ]]; then
                    hash="${repo[3]}"
                else
                    if ! hash="$(rp_getRemoteRepoHash git https://github.com/${repo[0]}/${repo[1]} ${repo[2]})"; then
                        __ERRMSGS+=("$hash")
                        return 3
                    fi
                fi
                hashes+=("$hash")
            done < <(_get_repos_mupen64plus)
            # store an md5sum of the various last commit hashes to be used to check for changes
            local hash="$(echo "${hashes[@]}" | md5sum | cut -d" " -f1)"
            if [[ "$hash" != "$pkg_repo_extra" ]]; then
                return 0
            fi
            return 1
            ;;
        check)
            local ret=0
            while read repo; do
                repo=($repo)
                out=$(rp_getRemoteRepoHash git https://github.com/${repo[0]}/${repo[1]} ${repo[2]})
                if [[ -z "$out" ]]; then
                    printMsgs "console" "$id repository failed - https://github.com/${repo[0]}/${repo[1]} ${repo[2]}"
                    ret=1
                fi
            done < <(_get_repos_mupen64plus)
            return "$ret"
            ;;
    esac
}

function sources_mupen64plus() {
    local commit
    local repo
    while read repo; do
        repo=($repo)
        gitPullOrClone "$md_build/${repo[1]}" https://github.com/${repo[0]}/${repo[1]} ${repo[2]} ${repo[3]}
    done < <(_get_repos_mupen64plus)

    if isPlatform "videocore"; then
        # workaround for shader cache crash issue on Raspbian stretch. See: https://github.com/gonetz/GLideN64/issues/1665
        applyPatch "$md_data/0001-GLideN64-use-emplace.patch"
    fi

    local config_version=$(grep -oP '(?<=CONFIG_VERSION_CURRENT ).+?(?=U)' GLideN64/src/Config.h)
    echo "$config_version" > "$md_build/GLideN64_config_version.ini"
}

function build_mupen64plus() {
    rpSwap on 750

    local dir
    local params=()
    for dir in *; do
        if [[ -f "$dir/projects/unix/Makefile" ]]; then
            params=()
            isPlatform "rpi1" && params+=("VFP=1" "VFP_HARD=1")
            isPlatform "videocore" || [[ "$dir" == "mupen64plus-audio-omx" ]] && params+=("VC=1")
            if isPlatform "mesa" || isPlatform "mali"; then
                params+=("USE_GLES=1")
            fi
            isPlatform "neon" && params+=("NEON=1")
            isPlatform "x11" && params+=("OSD=1" "PIE=1")
            isPlatform "x86" && params+=("SSE=SSE2")
            isPlatform "armv6" && params+=("HOST_CPU=armv6")
            isPlatform "armv7" && params+=("HOST_CPU=armv7")
            isPlatform "armv8" && params+=("HOST_CPU=armv8")
            isPlatform "aarch64" && params+=("HOST_CPU=aarch64")
            # we don't ship a Vulkan enabled front-end, so disable Vulkan in the core project
            params+=("VULKAN=0")

            [[ "$dir" == "mupen64plus-ui-console" ]] && params+=("COREDIR=$md_inst/lib/" "PLUGINDIR=$md_inst/lib/mupen64plus/")
            make -C "$dir/projects/unix" "${params[@]}" clean
            make -C "$dir/projects/unix" all "${params[@]}" OPTFLAGS="$CFLAGS -O3 -flto"
        fi
    done

    # build GLideN64
    "$md_build/GLideN64/src/getRevision.sh"
    pushd "$md_build/GLideN64/projects/cmake"

    params=("-DMUPENPLUSAPI=On" "-DVEC4_OPT=On" "-DUSE_SYSTEM_LIBS=On")
    isPlatform "neon" && params+=("-DNEON_OPT=On")
    isPlatform "mesa" && params+=("-DMESA=On" "-DEGL=On")
    isPlatform "vero4k" && params+=("-DVERO4K=On")
    isPlatform "armv8" && params+=("-DCRC_ARMV8=On")
    isPlatform "mali" && params+=("-DVERO4K=On" "-DCRC_OPT=On" "-DEGL=On")
    isPlatform "x86" && params+=("-DCRC_OPT=On")

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
        'GLideN64/projects/cmake/plugin/Release/mupen64plus-video-GLideN64.so'
    )

    if isPlatform "videocore" && ! isPlatform " 64bit"; then
        md_ret_require+=('mupen64plus-audio-omx/projects/unix/mupen64plus-audio-omx.so')
    fi

    if isPlatform "gles"; then
        ! isPlatform "rpi" && md_ret_require+=('mupen64plus-video-glide64mk2/projects/unix/mupen64plus-video-glide64mk2.so')
        if isPlatform "32bit"; then
            md_ret_require+=('mupen64plus-video-gles2rice/projects/unix/mupen64plus-video-rice.so')
            md_ret_require+=('mupen64plus-video-gles2n64/projects/unix/mupen64plus-video-n64.so')
        fi
    fi
    if isPlatform "gl"; then
        md_ret_require+=(
            'mupen64plus-video-glide64mk2/projects/unix/mupen64plus-video-glide64mk2.so'
            'mupen64plus-rsp-z64/projects/unix/mupen64plus-rsp-z64.so'
        )
        if isPlatform "x86"; then
            md_ret_require+=('mupen64plus-rsp-cxd4/projects/unix/mupen64plus-rsp-cxd4-sse2.so')
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
            isPlatform "videocore" || [[ "$dir" == "mupen64plus-audio-omx" ]] && params+=("VC=1")
            if isPlatform "mesa" || isPlatform "mali"; then
                params+=("USE_GLES=1")
            fi
            isPlatform "neon" && params+=("NEON=1")
            isPlatform "x11" && params+=("OSD=1" "PIE=1")
            isPlatform "x86" && params+=("SSE=SSE2")
            isPlatform "armv6" && params+=("HOST_CPU=armv6")
            isPlatform "armv7" && params+=("HOST_CPU=armv7")
            isPlatform "aarch64" && params+=("HOST_CPU=aarch64")
            isPlatform "x86" && params+=("SSE=SSE2")
            # disable VULKAN for the core project
            params+=("VULKAN=0")
            make -C "$source/projects/unix" PREFIX="$md_inst" OPTFLAGS="$CFLAGS -O3 -flto" "${params[@]}" install
        fi
    done
    cp "$md_build/GLideN64/ini/GLideN64.custom.ini" "$md_inst/share/mupen64plus/"
    cp "$md_build/GLideN64/projects/cmake/plugin/Release/mupen64plus-video-GLideN64.so" "$md_inst/lib/mupen64plus/"
    cp "$md_build/GLideN64_config_version.ini" "$md_inst/share/mupen64plus/"
    # remove default InputAutoConfig.ini. inputconfigscript writes a clean file
    rm -f "$md_inst/share/mupen64plus/InputAutoCfg.ini"
}

function configure_mupen64plus() {
    local res
    local resolutions=("320x240" "640x480")
    isPlatform "kms" && res="%XRES%x%YRES%"

    if isPlatform "rpi"; then
        # kms needs to run at full screen as it doesn't benefit from our SDL scaling hint
        if isPlatform "mesa"; then
            addEmulator 0 "${md_id}-GLideN64" "n64" "$md_inst/bin/mupen64plus.sh mupen64plus-video-GLideN64 %ROM% $res 0 --set Video-GLideN64[UseNativeResolutionFactor]\=1"
            addEmulator 0 "${md_id}-GLideN64-highres" "n64" "$md_inst/bin/mupen64plus.sh mupen64plus-video-GLideN64 %ROM% $res 0 --set Video-GLideN64[UseNativeResolutionFactor]\=2"
            addEmulator 0 "${md_id}-gles2n64" "n64" "$md_inst/bin/mupen64plus.sh mupen64plus-video-n64 %ROM%"
            if isPlatform "32bit"; then
                addEmulator 0 "${md_id}-gles2rice" "n64" "$md_inst/bin/mupen64plus.sh mupen64plus-video-rice %ROM% $res"
            fi
        else
            for res in "${resolutions[@]}"; do
                local name=""
                local nativeResFactor=1
                if [[ "$res" == "640x480" ]]; then
                    name="-highres"
                    nativeResFactor=2
                fi
                addEmulator 0 "${md_id}-GLideN64$name" "n64" "$md_inst/bin/mupen64plus.sh mupen64plus-video-GLideN64 %ROM% $res 0 --set Video-GLideN64[UseNativeResolutionFactor]\=$nativeResFactor"
                addEmulator 0 "${md_id}-gles2rice$name" "n64" "$md_inst/bin/mupen64plus.sh mupen64plus-video-rice %ROM% $res"
            done
            addEmulator 1 "${md_id}-auto" "n64" "$md_inst/bin/mupen64plus.sh AUTO %ROM%"
        fi
        addEmulator 0 "${md_id}-gles2n64" "n64" "$md_inst/bin/mupen64plus.sh mupen64plus-video-n64 %ROM%"
    elif isPlatform "mali"; then
        addEmulator 1 "${md_id}-gles2n64" "n64" "$md_inst/bin/mupen64plus.sh mupen64plus-video-n64 %ROM%"
        addEmulator 0 "${md_id}-GLideN64" "n64" "$md_inst/bin/mupen64plus.sh mupen64plus-video-GLideN64 %ROM%"
        addEmulator 0 "${md_id}-glide64" "n64" "$md_inst/bin/mupen64plus.sh mupen64plus-video-glide64mk2 %ROM%"
        addEmulator 0 "${md_id}-gles2rice" "n64" "$md_inst/bin/mupen64plus.sh mupen64plus-video-rice %ROM%"
        addEmulator 0 "${md_id}-auto" "n64" "$md_inst/bin/mupen64plus.sh AUTO %ROM%"
    else
        addEmulator 0 "${md_id}-GLideN64" "n64" "$md_inst/bin/mupen64plus.sh mupen64plus-video-GLideN64 %ROM% $res"
        addEmulator 1 "${md_id}-glide64" "n64" "$md_inst/bin/mupen64plus.sh mupen64plus-video-glide64mk2 %ROM% $res"
        if isPlatform "x86"; then
            ! isPlatform "kms" && res="640x480"
            addEmulator 0 "${md_id}-GLideN64-LLE" "n64" "$md_inst/bin/mupen64plus.sh mupen64plus-video-GLideN64 %ROM% $res mupen64plus-rsp-cxd4-sse2"
        fi
    fi
    addSystem "n64"

    mkRomDir "n64"
    moveConfigDir "$home/.local/share/mupen64plus" "$md_conf_root/n64/mupen64plus"

    [[ "$md_mode" == "remove" ]] && return

    # copy hotkey remapping start script
    cp "$md_data/mupen64plus.sh" "$md_inst/bin/"
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

    # RPI main/GLideN64 settings
    if isPlatform "rpi"; then
        iniConfig " = " "" "$config"
        # VSync is mandatory for good performance on KMS
        if isPlatform "kms"; then
            if ! grep -q "\[Video-General\]" "$config"; then
                echo "[Video-General]" >> "$config"
            fi
            iniSet "VerticalSync" "True"
        fi
        # Create GlideN64 section in .cfg
        if ! grep -q "\[Video-GLideN64\]" "$config"; then
            echo "[Video-GLideN64]" >> "$config"
        fi
        # Settings version. Don't touch it.
        iniSet "configVersion" "29"
        # Bilinear filtering mode (0=N64 3point, 1=standard)
        iniSet "bilinearMode" "1"
        iniSet "EnableFBEmulation" "True"
        # Use native res
        iniSet "UseNativeResolutionFactor" "1"
        # Enable legacy blending
        iniSet "EnableLegacyBlending" "True"
        # Enable Threaded GL calls
        iniSet "ThreadedVideo" "True"
        # Swap frame buffers On buffer update (most performant)
        iniSet "BufferSwapMode" "2"
        # Disable hybrid upscaling filter (needs better GPU)
        iniSet "EnableHybridFilter" "False"
        # Use fast but less accurate shaders. Can help with low-end GPUs.
        iniSet "EnableInaccurateTextureCoordinates" "True"

        if isPlatform "videocore"; then
            # Disable gles2n64 autores feature and use dispmanx upscaling
            iniConfig "=" "" "$md_conf_root/n64/gles2n64.conf"
            iniSet "auto resolution" "0"

            setAutoConf mupen64plus_audio 1
            setAutoConf mupen64plus_compatibility_check 1
        elif isPlatform "mesa"; then
            # Create Video-Rice section in .cfg
            if ! grep -q "\[Video-Rice\]" "$config"; then
                echo "[Video-Rice]" >> "$config"
            fi
            # Fix flickering and black screen issues with rice video plugin
            iniSet "ScreenUpdateSetting" "7"

            setAutoConf mupen64plus_audio 0
            setAutoConf mupen64plus_compatibility_check 0
        fi
    else
        addAutoConf mupen64plus_audio 0
        addAutoConf mupen64plus_compatibility_check 0
    fi

    addAutoConf mupen64plus_hotkeys 1
    addAutoConf mupen64plus_texture_packs 1

    chown -R $user:$user "$md_conf_root/n64"
}
