rp_module_id="fastdosbox"
rp_module_desc="DOS emulator FastDosbox"
rp_module_menus="2+"

function depends_fastdosbox() {
    checkNeededPackages libsdl1.2-dev libsdl-net1.2-dev
}

function sources_fastdosbox() {
    wget -O- -q http://downloads.petrockblock.com/retropiearchives/fastdosbox-1.5_src.tar.gz | tar -xvz --strip-components=1
    sed -i 's|#include "nofun.h"|//#include "nofun.h"|g' "$md_build/src/gui/sdl_mapper.cpp"
}

function build_fastdosbox() {
    ./configure --prefix="$md_inst"
    make clean
    make
    md_ret_require="$md_build/src/dosbox"
}

function install_fastdosbox() {
    make install
    md_ret_require="$md_inst/bin/dosbox"
}

function configure_fastdosbox() {
    mkRomDir "pc"

    cat > "$romdir/pc/Start FastDosBox.sh" << _EOF_
#!/bin/bash
pushd "$md_inst"
$md_inst/bin/dosbox -c "MOUNT C \"$romdir/pc\"" 
popd
_EOF_
    chmod +x "$romdir/pc/Start FastDosBox.sh"

    setESSystem "PC (x86)" "pc" "~/RetroPie/roms/pc" ".sh" "$rootdir/supplementary/runcommand/runcommand.sh 0 \"%ROM%\" \"$md_id\"" "pc" "pc"
}