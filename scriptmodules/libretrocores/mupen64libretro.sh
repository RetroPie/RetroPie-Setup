rp_module_id="mupen64plus-libretro"
rp_module_desc="N64 LibretroCore MUPEN64Plus"
rp_module_menus="2+"

function sources_mupen64plus-libretro() {
    if isPlatform "rpi2"; then
        gitPullOrClone "$md_build" https://github.com/gizmo98/mupen64plus-libretro.git rpi2_fix
    else
        gitPullOrClone "$md_build" git://github.com/libretro/mupen64plus-libretro.git
    fi
}

function build_mupen64plus-libretro() {
    rpSwap on 750
    make clean
    if isPlatform "rpi2"; then
        make platform=rpi2
    else
        make platform=rpi
    fi
    rpSwap off
    md_ret_require="$md_build/mupen64plus_libretro.so"
}

function install_mupen64plus-libretro() {
    md_ret_files=(
        'mupen64plus-core/data'
        'mupen64plus_libretro.so'
        'README.md'
    )
}

function configure_mupen64plus-libretro() {
    mkRomDir "n64"
    ensureSystemretroconfig "n64"

    # Set core options
    iniConfig " = " "" "$configdir/all/retroarch-core-options.cfg"
    iniSet "mupen64-gfxplugin" "rice"
    iniSet "mupen64-gfxplugin-accuracy" "low"
    iniSet "mupen64-screensize" "640x480"

    # Copy config files
    cp "$md_inst/data/"{mupen64plus.cht,mupencheat.txt,mupen64plus.ini,font.ttf} "$biosdir/"
    cat > $home/RetroPie/BIOS/gles2n64rom.conf << _EOF_
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
    chown $user:$user "$biosdir/"{mupen64plus.cht,mupencheat.txt,mupen64plus.ini,font.ttf,gles2n64rom.conf}

    setESSystem "Nintendo 64" "n64" "~/RetroPie/roms/n64" ".z64 .Z64 .n64 .N64 .v64 .V64 .zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$emudir/retroarch/bin/retroarch -L $md_inst/mupen64plus_libretro.so --config $configdir/all/retroarch.cfg --appendconfig $configdir/n64/retroarch.cfg %ROM%\" \"$md_id\"" "n64" "n64"
}
