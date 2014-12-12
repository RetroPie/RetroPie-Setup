rp_module_id="advmame"
rp_module_desc="AdvanceMAME"
rp_module_menus="2+"

function depends_advmame() {
    rps_checkNeededPackages libsdl1.2-dev
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
    su "$user" -c "$md_inst/bin/advmame"
    echo 'device_video_clock 5 - 50 / 15.62 / 50 ; 5 - 50 / 15.73 / 60' >> "/home/$user/.advance/advmame.rc"
}