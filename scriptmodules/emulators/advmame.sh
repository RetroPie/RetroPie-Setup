rp_module_id="advmame"
rp_module_desc="AdvMame"
rp_module_menus="2+"

function depends_advmame() {
    rps_checkNeededPackages libsdl1.2-dev
}

function sources_advmame() {
    wget -O advmame.tar.gz http://downloads.petrockblock.com/retropiearchives/advancemame-0.94.0.tar.gz
}

function build_advmame() {
    mkdir -p "$rootdir/emulators/"
    tar xzvf advmame.tar.gz -C "$rootdir/emulators/"
    pushd "$rootdir/emulators/advancemame-0.94.0"
    sed -i 's/MAP_SHARED | MAP_FIXED,/MAP_SHARED,/' advance/linux/vfb.c
    sed -i 's/misc_quiet\", 0/misc_quiet\", 1/' advance/osd/global.c
    sed -i '/#include <string>/ i\#include <stdlib.h>' advance/d2/d2.cc
    ./configure CC="gcc-4.7" CXX="g++-4.7" --prefix="$rootdir/emulators/advancemame-0.94.0/installdir"
    sed -i 's/LDFLAGS=-s/LDFLAGS=-s -lm -Wl,--no-as-needed/' Makefile
    make
    popd
    rm advmame.tar.gz
}

function install_advmame() {
    pushd "$rootdir/emulators/advancemame-0.94.0"
    make install
    chmod -R 755 "$rootdir/emulators/advancemame-0.94.0"
    popd
}

function configure_advmame() {
    rmDirExists /root/.advance
    rmDirExists /home/$user/.advance
    $rootdir/emulators/advancemame-0.94.0/installdir/bin/advmame
    mv /root/.advance /home/$user/
    echo 'device_video_clock 5 - 50 / 15.62 / 50 ; 5 - 50 / 15.73 / 60' >> /home/$user/.advance/advmame.rc
    chown -R $user:$user /home/$user/.advance/
}