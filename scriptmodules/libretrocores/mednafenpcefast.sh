rp_module_id="mednafenpcefast"
rp_module_desc="Mednafen PCE Fast LibretroCore"
rp_module_menus="2+"

function sources_mednafenpcefast() {
    gitPullOrClone "$rootdir/libretrocores/mednafenpcefast" https://github.com/libretro/beetle-pce-fast-libretro.git
}

function build_mednafenpcefast() {
    pushd "$rootdir/libretrocores/mednafenpcefast"
    make
     if [[ -z `find $rootdir/libretrocores/mednafenpcefast/ -name "*libretro*.so"` ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile Mednafen PCE Fast core."
    fi
    popd
}

function configure_mednafenpcefast() {
    mkdir -p $romdir/pcengine

    setESSystem "TurboGrafx 16 (PC Engine)" "pcengine" "~/RetroPie/roms/pcengine" ".pce .PCE" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$emudir/$1/bin/retroarch -L `find $rootdir/libretrocores/mednafenpcefast/ -name \"*libretro*.so\" | head -1` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/pcengine/retroarch.cfg %ROM%\"" "pcengine" "pcengine"
}