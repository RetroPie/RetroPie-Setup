rp_module_id="jzintv"
rp_module_desc="Intellivision emulator"
rp_module_menus="2+"

function depends_jzintv() {
    checkNeededPackages libsdl1.2-dev
}

function sources_jzintv() {
    # wget 'http://spatula-city.org/~im14u2c/intv/dl/jzintv-1.0-beta4-src.zip' -O jzintv.zip
    wget http://downloads.petrockblock.com/retropiearchives/jzintv-svn.zip -O jzintv.zip
    unzip -n jzintv.zip
    rm jzintv.zip
    cd jzintv/src
    # use our default gcc-4.7
    sed -i "s/-4\.8\.0/-4.7/" Makefile
    sed -i "s|LFLAGS   = -L../lib|LFLAGS   = -L../lib -lm|" Makefile
    # don't build event_diag.rom/emu_ver.rom/joy_diag.rom/jlp_test.bin due to missing example/library files from zip
    sed -i '/^PROGS/,$d' {event,joy,jlp,util}/subMakefile
}

function build_jzintv() {
    mkdir -p jzintv/bin
    cd jzintv/src
    make clean
    make OPT_FLAGS="-O3 -fomit-frame-pointer -fprefetch-loop-arrays -march=armv6 -mfloat-abi=hard -mfpu=vfp"
    __INFMSGS="$__INFMSGS You need to copy Intellivision BIOS files to the folder '/usr/local/share/jzintv/rom'."
    md_ret_require="$md_build/bin/jzintv"
}

function install_jzintv() {
    md_ret_files=(
        'jzintv/bin'
        'jzintv/src/COPYING.txt'
        'jzintv/src/COPYRIGHT.txt'
    )
}

function configure_jzintv() {
    mkdir -p "$romdir/intellivision"

    setESSystem "Intellivision" "intellivision" "~/RetroPie/roms/intellivision" ".int .INT .bin .BIN" "$md_inst/bin/jzintv -z1 -f1 -q %ROM%" "intellivision" ""
}