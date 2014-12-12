rp_module_id="fastdosbox"
rp_module_desc="DOS emulator FastDosbox"
rp_module_menus="2+"

function sources_fastdosbox() {
    wget -O- -q http://downloads.petrockblock.com/retropiearchives/fastdosbox-1.5_src.tar.gz | tar -xvz --strip-components=1
    sed -i 's|#include "nofun.h"|//#include "nofun.h"|g' "$builddir/$1/src/gui/sdl_mapper.cpp"
}

function build_fastdosbox() {
    ./configure --prefix="$emudir/$1"
    make clean
    make
    require="$builddir/$1/src/dosbox"
}

function install_fastdosbox() {
    make install
    require="$emudir/$1/bin/dosbox"
}

function configure_fastdosbox() {
    mkdir -p "$romdir/pc"
    setESSystem "PC (x86)" "pc" "~/RetroPie/roms/pc" ".txt" "$emudir/$1/dosbox" "pc" "pc"    
}