rp_module_id="mupen64plus-testing"
rp_module_desc="N64 emulator MUPEN64Plus (Testing)"
rp_module_menus="4+"
rp_module_flags="!odroid"

function depends_mupen64plus-testing() {
    getDepends libsamplerate0-dev libspeexdsp-dev libsdl2-dev
}

function sources_mupen64plus-testing() {
    local repos=(
        'mupen64plus core'
        'mupen64plus ui-console'
        'gizmo98 audio-omx'
        'mupen64plus audio-sdl'
        'mupen64plus input-sdl'
        'mupen64plus rsp-hle'
        'gizmo98 video-gles2rice'
        #'Narann video-rice'
        'gizmo98 video-gles2n64 testing'
        'gizmo98 video-glide64mk2 rpi'
    )
    local repo
    for repo in "${repos[@]}"; do
        repo=($repo)
        gitPullOrClone "$md_build/mupen64plus-${repo[1]}" https://github.com/${repo[0]}/mupen64plus-${repo[1]} ${repo[2]}
    done
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
            [[ "$dir" == "mupen64plus-video-glide64mk2" ]] && params+=("VC=1")
            [[ "$dir" == "mupen64plus-audio-omx" ]] && params+=("VC=1")
            if isPlatform "rpi2"; then
                [[ "$dir" == "mupen64plus-core" ]] && params+=("VC=1" "NEON=1")
                [[ "$dir" == "mupen64plus-video-gles2n64" ]] && params+=("VC=1" "NEON=1")
                [[ "$dir" == "mupen64plus-video-gles2n64-1" ]] && params+=("VC=1" "NEON=1")
            else
                [[ "$dir" == "mupen64plus-core" ]] && params+=("VC=1" "VFP_HARD=1")
                [[ "$dir" == "mupen64plus-video-gles2n64" ]] && params+=("VC=1")
                [[ "$dir" == "mupen64plus-video-gles2n64-1" ]] && params+=("VC=1")
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
}

function configure_mupen64plus-testing() {
    # to solve startup problems delete old config file
    rm -f "$configdir/n64/mupen64plus.cfg"
    mkdir -p "$configdir/n64/"
    # Copy config files
    cp -v "$md_inst/share/mupen64plus/"{*.ini,font.ttf,*.conf} "$configdir/n64/"
    chown -R $user:$user "$configdir/n64"
    su "$user" -c "$md_inst/bin/mupen64plus --configdir $configdir/n64 --datadir $configdir/n64"

    iniConfig " = " "" "$configdir/n64/mupen64plus.cfg"
    iniSet "AudioPlugin" "\"mupen64plus-audio-omx.so\""

    # create romdir for rice plugin
    mkRomDir "n64-gles2n64"
    setESSystem "Nintendo 64" "n64-gles2n64" "~/RetroPie/roms/n64-gles2n64" ".z64 .Z64 .n64 .N64 .v64 .V64" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$md_inst/bin/mupen64plus --noosd --fullscreen --gfx mupen64plus-video-n64.so --configdir $configdir/n64 --datadir $configdir/n64 %ROM%\" \"$md_id\"" "n64" "n64"

    # create romdir for n64 plugin
    mkRomDir "n64-gles2rice"
    setESSystem "Nintendo 64" "n64-gles2rice" "~/RetroPie/roms/n64-gles2rice" ".z64 .Z64 .n64 .N64 .v64 .V64" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$md_inst/bin/mupen64plus --noosd --fullscreen --gfx mupen64plus-video-rice.so --configdir $configdir/n64 --datadir $configdir/n64 %ROM%\" \"$md_id\"" "n64" "n64"
}
