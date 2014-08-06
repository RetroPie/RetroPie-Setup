rp_module_id="jzint"
rp_module_desc="Intellivision emulator"
rp_module_menus="2+"

function sources_jzint() {
    # wget 'http://spatula-city.org/~im14u2c/intv/dl/jzintv-1.0-beta4-src.zip' -O jzintv.zip
    wget http://downloads.petrockblock.com/retropiearchives/jzintv-svn.zip -O jzintv.zip
    mkdir -p "$rootdir/emulators"
    unzip -n jzintv.zip -d "$rootdir/emulators/"
    rm jzintv.zip
}

function build_jzint() {
    pushd "$rootdir/emulators/jzintv-1.0-beta4/src/"
    mkdir "$rootdir/emulators/jzintv-1.0-beta4/bin"
    make clean
    make OPT_FLAGS="-O3 -fomit-frame-pointer -fprefetch-loop-arrays -march=armv6 -mfloat-abi=hard -mfpu=vfp"
    if [[ ! -f "$rootdir/emulators/jzintv-1.0-beta4/bin/jzintv" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile jzintv."
    else
        __INFMSGS="$__INFMSGS You need to copy Intellivision BIOS files to the folder '/usr/local/share/jzintv/rom'."
    fi
    popd
}

function configure_jzint() {
    mkdir -p "$romdir/intellivision"

    setESSystem "Intellivision" "intellivision" "~/RetroPie/roms/intellivision" ".int .INT .bin .BIN" "$rootdir/emulators/jzintv-1.0-beta4/bin/jzintv -z1 -f1 -q %ROM%" "intellivision" ""
}