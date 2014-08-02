rp_module_id="fastdosbox"
rp_module_desc="DOS emulator FastDosbox"
rp_module_menus="2+"

function sources_fastdosbox() {
    wget http://gaming.capsule-sa.co.za/downloads/fastdosbox-1.5_src.tar.gz
    tar xvfz fastdosbox-1.5_src.tar.gz -C "$rootdir/emulators/"

    # patch sources
    sed -i 's|#include "nofun.h"|//#include "nofun.h"|g' "$rootdir/emulators/fastdosbox-1.5/src/gui/sdl_mapper.cpp"

    mkdir -p $rootdir/emulators/fastdosbox-1.5/installdir
    rm fastdosbox-1.5_src.tar.gz
}

function build_fastdosbox() {
    pushd $rootdir/emulators/fastdosbox-1.5
    ./configure --prefix=$rootdir/emulators/fastdosbox-1.5/installdir
    make
    popd
}

function install_fastdosbox() {
    pushd $rootdir/emulators/fastdosbox-1.5
    make install
    if [[ ! -f $rootdir/emulators/fastdosbox-1.5/installdir/bin/dosbox ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully install FastDosbox."
    fi
    popd
}

function configure_fastdosbox() {
    mkdir -p "$romdir/pc"
    setESSystem "PC (x86)" "pc" "~/RetroPie/roms/pc" ".txt" "$rootdir/emulators/rpix86/Start.sh" "pc" "pc"    
}