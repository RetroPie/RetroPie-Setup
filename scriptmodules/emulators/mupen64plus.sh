rp_module_id="mupen64plus"
rp_module_desc="N64 emulator MUPEN64Plus"
rp_module_menus="2+"
rp_module_flags="!odroid"

function depends_mupen64plus() {
    if ! hasPackage libsdl2-dev && isPlatform "rpi"; then
        rp_callModule sdl2 install_bin
    fi
}

function sources_mupen64plus() {
    local repos=(
        'ricrpi core ric_dev'
        'mupen64plus ui-console'
        'ricrpi audio-omx'
        'mupen64plus audio-sdl'
        'mupen64plus input-sdl'
        'ricrpi rsp-hle'
        'ricrpi video-gles2rice'
        'ricrpi video-gles2n64'
    )
    local repo
    local dir
    for repo in "${repos[@]}"; do
        repo=($repo)
        dir="$md_build/mupen64plus-${repo[1]}"
        gitPullOrClone "$dir" https://github.com/${repo[0]}/mupen64plus-${repo[1]} ${repo[2]}
        # the makefile assumes an armv6l machine is a pi so we need to sed it
        if isPlatform "rpi2" && [[ -f "$dir/projects/unix/Makefile" ]]; then
            sed -i "s/armv6l/armv7l/" "$dir/projects/unix/Makefile"
        fi
    done
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
            if isPlatform "rpi2"; then
                [[ "$dir" == "mupen64plus-core" ]] && params+=("USE_GLES=1" "NEON=1")
            else
                [[ "$dir" == "mupen64plus-core" ]] && params+=("USE_GLES=1" "VFP=1")
            fi
            make -C "$dir/projects/unix" all "${params[@]}" OPTFLAGS="$CFLAGS"
        fi
    done

    rpSwap off
}

function install_mupen64plus() {
    for source in *; do
        if [[ -f "$source/projects/unix/Makefile" ]]; then
            # optflags is needed due to the fact the core seems to rebuild 2 files and relink during install stage most likely due to a buggy makefile
            make -C "$source/projects/unix" PREFIX="$md_inst" OPTFLAGS="$CFLAGS" install
        fi
    done
}

function configure_mupen64plus() {
    # to solve startup problems delete old config file
    rm -f "$home/.config/mupen64plus/mupen64plus.cfg"

    mkdir -p "$rootdir/configs/n64/"
    cat > "$rootdir/configs/n64/gles2n64.conf" << _EOF_
#gles2n64 Graphics Plugin for N64
#by Orkin / glN64 developers and Adventus.
config version=2
#These values are the physical pixel dimensions of
#your screen. They are only used for centering the
#window.
screen width=800
screen height=480
#The Window position and dimensions specify how and
#where the games will appear on the screen. Enabling
#Centre will ensure that the window is centered
#within the screen (overriding xpos/ypos).
window enable x11=1
window fullscreen=1
window centre=1
window xpos=0
window ypos=0
window width=800
window height=480
#Enabling offscreen frambuffering allows the resulting
#image to be upscaled to the window dimensions. The
#framebuffer dimensions specify the resolution which
#gles2n64 will render to.
framebuffer enable=1
framebuffer bilinear=0
framebuffer width=640
framebuffer height=480
#VI Settings, useful for forcing certain internal resolutions.
video force=0
video width=640
video height=480
#Frameskipping allows more CPU time be spent on other
#tasks than GPU emulation, but at the cost of a lower
#framerate.
auto frameskip=1
target FPS=20
frame render rate=1
#Vertical Sync Divider (0=No VSYNC, 1=60Hz, 2=30Hz, etc)
vertical sync=0
#These options enable different rendering paths, they
#can relieve pressure on the GPU / CPU.
enable fog=0
enable primitive z=1
enable lighting=1
enable alpha test=1
enable clipping=0
enable face culling=1
enable noise=0
#Texture Bit Depth (0=force 16bit, 1=either 16/32bit, 2=force 32bit)
texture depth=1
texture 2xSAI=0
texture force bilinear=0
texture max anisotropy=0
texture use IA=0
texture fast CRC=1
texture pow2=1
#
update mode=1
ignore offscreen rendering=0
force screen clear=1
tribuffer opt=1
flip vertical=0
hack banjo tooie=0
hack zelda=0
hack alpha=0
hack z=0
_EOF_

    cat > "$rootdir/configs/n64/gles2n64rom.conf" << _EOF_
#rom specific settings

rom name=SUPER MARIO 64
target FPS=25

rom name=Kirby64
target FPS=25

rom name=Banjo-Kazooie
framebuffer enable=1
update mode=4
target FPS=25

rom name=BANJO TOOIE
hack banjo tooie=1
ignore offscreen rendering=1
framebuffer enable=1
update mode=4

rom name=STARFOX64
window width=864
window height=520
target FPS=27

rom name=MARIOKART64
target FPS=27

rom name=THE LEGEND OF ZELDA
texture use IA=0
hack zelda=1
target FPS=17

rom name=ZELDA MAJORA'S MASK
texture use IA=0
hack zelda=1
rom name=F-ZERO X
window width=864
window height=520
target FPS=55
rom name=WAVE RACE 64
window width=864
window height=520
target FPS=27
rom name=SMASH BROTHERS
framebuffer enable=1
window width=864
window height=520
target FPS=27
rom name=1080 SNOWBOARDING
update mode=2
target FPS=27
rom name=PAPER MARIO
update mode=4
rom name=STAR WARS EP1 RACER
video force=1
video width=320
video height=480
rom name=JET FORCE GEMINI
framebuffer enable=1
update mode=2
ignore offscreen rendering=1
target FPS=27
rom name=RIDGE RACER 64
window width=864
window height=520
enable lighting=0
target FPS=27
rom name=Diddy Kong Racing
target FPS=27
rom name=MarioParty
update mode=4
rom name=MarioParty3
update mode=4
rom name=Beetle Adventure Rac
window width=864
window height=520
target FPS=27
rom name=EARTHWORM JIM 3D
rom name=LEGORacers
rom name=GOEMONS GREAT ADV
window width=864
window height=520
rom name=Buck Bumble
window width=864
window height=520
rom name=BOMBERMAN64U2
window width=864
window height=520
rom name=ROCKETROBOTONWHEELS
window width=864
window height=520
rom name=GOLDENEYE
force screen clear=1
framebuffer enable=1
window width=864
window height=520
target FPS=25
rom name=Mega Man 64
framebuffer enable=1
target FPS=25
_EOF_

    # Copy config files
    cp -v "$md_inst/share/mupen64plus/"{*.ini,font.ttf} "$rootdir/configs/n64/"
    chown -R $user:$user "$rootdir/configs/n64"

    su "$user" -c "$md_inst/bin/mupen64plus --configdir $rootdir/configs/n64 --datadir $rootdir/configs/n64"
    iniConfig " = " "" "$rootdir/configs/n64/mupen64plus.cfg"
    iniSet "VideoPlugin" "mupen64plus-video-n64"
    iniSet "AudioPlugin" "mupen64plus-audio-omx"
    # Enable bilinear filtering for rice
    # iniSet "Mipmapping" "2"
    # iniSet "ForceTextureFilter" "2"

    mkRomDir "n64-mupen64plus"

    setESSystem "Nintendo 64" "n64-mupen64plus" "~/RetroPie/roms/n64-mupen64plus" ".z64 .Z64 .n64 .N64 .v64 .V64" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$md_inst/bin/mupen64plus --configdir $rootdir/configs/n64 --datadir $rootdir/configs/n64 %ROM%\" \"$md_id\"" "n64" "n64"
}
