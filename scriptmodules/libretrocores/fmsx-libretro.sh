rp_module_id="fmsx-libretro"
rp_module_desc="MSX LibretroCore fmsx"
rp_module_menus="4+"

function sources_fmsx-libretro() {
    gitPullOrClone "$rootdir/emulatorcores/fmsx-libretro" git://github.com/libretro/fmsx-libretro.git
}

function build_fmsx-libretro() {
    pushd "$rootdir/emulatorcores/fmsx-libretro"
    make clean
    make
    popd
    if [[ -z `find $rootdir/emulatorcores/fmsx-libretro/ -name "*libretro*.so"` ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile MSX core."
    fi
}

function configure_fmsx-libretro() {
    mkdir -p $romdir/msx
    ensureSystemretroconfig "msx"
    cp -a $rootdir/emulatorcores/fmsx-libretro/fMSX/ROMs/. $home/RetroPie/BIOS/
    rps_retronet_prepareConfig
    setESSystem "MSX" "msx" "~/RetroPie/roms/msx" ".rom .ROM .mx1 .MX1 .mx2 .MX2 .col .COL .dsk .DSK" "$rootdir/supplementary/runcommand/runcommand.sh 4 \"$rootdir/emulators/RetroArch/installdir/bin/retroarch -L `find $rootdir/emulatorcores/fmsx-libretro/ -name \"*libretro*.so\" | head -1` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/msx/retroarch.cfg $__tmpnetplaymode$__tmpnetplayhostip_cfile$__tmpnetplayport$__tmpnetplayframes %ROM%\"" "msx" "msx"
}
