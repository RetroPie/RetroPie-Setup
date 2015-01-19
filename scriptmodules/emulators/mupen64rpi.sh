rp_module_id="mupen64rpi"
rp_module_desc="N64 emulator MUPEN64Plus-RPi"
rp_module_menus="4+"

function sources_mupen64rpi() {
    gitPullOrClone "$md_build" https://github.com/ricrpi/mupen64plus
}

function build_mupen64rpi() {
    rpSwap on 750
    ./build.sh
    rpSwap off

    md_ret_require="$md_build/mupen64plus"
}

function install_mupen64rpi() {
    ./install.sh
    md_ret_files=(
        'mupen64plus/mupen64plus-input-sdl/data/InputAutoCfg.ini'
        'ricrpi/mupen64plus-video-gles2rice/data/RiceVideoLinux.ini' 
        'ricrpi/mupen64plus-core/data/mupencheat.txt'
        'ricrpi/mupen64plus-core/data/mupen64plus.ini' 
        'ricrpi/mupen64plus-core/data/font.ttf'
    )
}

function configure_mupen64rpi() {
    # to solve startup problems delete old config file 
    rm -f "$home/.config/mupen64plus/mupen64plus.cfg"

    cat > $rootdir/configs/n64/gles2n64.conf << _EOF_
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
framebuffer enable=0
framebuffer bilinear=0
framebuffer width=400
framebuffer height=240
#VI Settings, useful for forcing certain internal resolutions. 
video force=0
video width=320
video height=240
#Frameskipping allows more CPU time be spent on other
#tasks than GPU emulation, but at the cost of a lower
#framerate.
frame render rate=2
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
#Texture Bit Depth (0=force 16bit, 1=either 16/32bit, 2=force 32bit)
texture depth=1
texture 2xSAI=0
texture force bilinear=0
texture max anisotropy=0
texture use IA=0
#
update mode=1
ignore offscreen rendering=0
force screen clear=1
flip vertical=0
z hack=0
_EOF_

    cat > $rootdir/configs/n64/gles2n64rom.conf << _EOF_
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

    # Copy bios files
    cp "$md_inst/"*.* "$rootdir/configs/n64/"
    chown -R $user:$user "$rootdir/configs/n64"

    mkRomDir "n64-mupen64plus"

    setESSystem "Nintendo 64" "n64-mupen64plus" "~/RetroPie/roms/n64-mupen64plus" ".z64 .Z64 .n64 .N64 .v64 .V64" "$rootdir/supplementary/runcommand/runcommand.sh 0 \"mupen64plus --configdir $rootdir/configs/n64 --datadir $rootdir/configs/n64 --osd --windowed %ROM%\" \"$md_id\"" "n64" "n64"
}
