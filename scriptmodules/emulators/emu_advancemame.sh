rp_module_id="advmame"
rp_module_desc="AdvanceMAME"
rp_module_menus="2+"
rp_module_flags="dispmanx"

function depends_advmame() {
    getDepends libsdl1.2-dev
}

function sources_advmame() {
    wget -O- -q "http://downloads.petrockblock.com/retropiearchives/advancemame-0.94.0.tar.gz" | tar -xvz --strip-components=1
    sed -i 's/MAP_SHARED | MAP_FIXED,/MAP_SHARED,/' advance/linux/vfb.c
    sed -i 's/misc_quiet\", 0/misc_quiet\", 1/' advance/osd/global.c
    sed -i '/#include <string>/ i\#include <stdlib.h>' advance/d2/d2.cc
}

function build_advmame() {
    ./configure LDFLAGS="-s -lm -Wl,--no-as-needed" --prefix="$md_inst"
    make
}

function install_advmame() {
    make install
}

function configure_advmame() {
    mkRomDir "mame-advmame"

    rm -rf "$home/.advance"
    su "$user" -c "$md_inst/bin/advmame"

    iniConfig " " "" "$home/.advance/advmame.rc"
    iniSet "device_video" "sdl"
    iniSet "device_video_cursor" "off"
    iniSet "device_keyboard" "sdl"
    iniSet "device_sound" "alsa"
    iniSet "display_vsync" "no"
    iniSet "display_resize" "integer"
    iniSet "dir_rom" "$romdir/mame-advmame"
    iniSet "dir_artwork" "$romdir/mame-artwork"
    iniSet "dir_sample" "$romdir/mame-samples"

    setDispmanx "$md_id" 1

    setESSystem "MAME" "mame-advmame" "~/RetroPie/roms/mame-advmame" ".zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 0 \"$md_inst/bin/advmame %BASENAME%\" \"$md_id\"" "arcade" "mame"
}
