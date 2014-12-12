rp_module_id="psxlibretro"
rp_module_desc="Playstation 1 LibretroCore"
rp_module_menus="2+"

function depends_psxlibretro() {
    checkNeededPackages libpng12-dev libx11-dev
}

function sources_psxlibretro() {
    gitPullOrClone "$rootdir/emulatorcores/pcsx_rearmed" git://github.com/libretro/pcsx_rearmed.git
}

function build_psxlibretro() {
    pushd "$rootdir/emulatorcores/pcsx_rearmed"
    ./configure --platform=libretro
    make clean
    make
    if [[ -z `find $rootdir/emulatorcores/pcsx_rearmed/ -name "*libretro*.so"` ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile Playstation core."
    fi
    popd
}

function configure_psxlibretro() {
    mkdir -p $romdir/psx

    rps_retronet_prepareConfig
    setESSystem "Sony Playstation 1" "psx" "~/RetroPie/roms/psx" ".img .IMG .7z .7Z .pbp .PBP .bin .BIN .cue .CUE" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$emudir/$1/bin/retroarch -L `find $rootdir/emulatorcores/pcsx_rearmed/ -name \"*libretro*.so\" | head -1` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/psx/retroarch.cfg %ROM%\"" "psx" "psx"
}