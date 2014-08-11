rp_module_id="jzintv"
rp_module_desc="Intellivision emulator"
rp_module_menus="2+"

function depends_jzintv() {
    rps_checkNeededPackages libsdl1.2-dev
}

function sources_jzintv() {
    # wget 'http://spatula-city.org/~im14u2c/intv/dl/jzintv-1.0-beta4-src.zip' -O jzintv.zip
    wget http://downloads.petrockblock.com/retropiearchives/jzintv-svn.zip -O jzintv.zip
    mkdir -p "$rootdir/emulators"
    rmDirExists "$rootdir/emulators/jzintv"
    unzip -n jzintv.zip -d "$rootdir/emulators/"
    rm jzintv.zip
    # use our default gcc-4.7
    sed -i "s/-4\.8\.0/-4.7/g" "$rootdir/emulators/jzintv/src/Makefile"
    # don't build event_diag.rom/emu_ver.rom/joy_diag.rom/jlp_test.bin due to missing example/library files from zip
    sed -i '/^PROGS/,$d' \
        "$rootdir/emulators/jzintv/src/"{event,joy,jlp,util}/subMakefile \
        "$rootdir/emulators/jzintv/src/util/subMakefile" \
        "$rootdir/emulators/jzintv/src/joy/subMakefile"
}

function build_jzintv() {
    pushd "$rootdir/emulators/jzintv/src/"
    mkdir -p "$rootdir/emulators/jzintv/bin"
    make clean
    make OPT_FLAGS="-O3 -fomit-frame-pointer -fprefetch-loop-arrays -march=armv6 -mfloat-abi=hard -mfpu=vfp"
    if [[ ! -f "$rootdir/emulators/jzintv/bin/jzintv" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile jzintv."
    else
        __INFMSGS="$__INFMSGS You need to copy Intellivision BIOS files to the folder '/usr/local/share/jzintv/rom'."
    fi
    popd
}

function configure_jzintv() {
    mkdir -p "$romdir/intellivision"

    setESSystem "Intellivision" "intellivision" "~/RetroPie/roms/intellivision" ".int .INT .bin .BIN" "$rootdir/emulators/jzintv/bin/jzintv -z1 -f1 -q %ROM%" "intellivision" ""
}