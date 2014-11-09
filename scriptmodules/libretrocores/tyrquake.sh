rp_module_id="tyrquake"
rp_module_desc="Quake LibretroCore"
rp_module_menus="4+"

function sources_tyrquake() {
    # rmDirExists "$rootdir/emulatorcores/quake"
    gitPullOrClone "$rootdir/emulatorcores/quake" git://github.com/libretro/tyrquake.git
    # pushd "$rootdir/emulatorcores/quake"
    # popd
}

function build_tyrquake() {
    pushd "$rootdir/emulatorcores/quake"
    make -f Makefile.libretro clean
    make -f Makefile.libretro
    if [[ -z `find $rootdir/emulatorcores/quake/ -name "*libretro*.so"` ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile quake core."
    fi
    popd
}

function configure_tyrquake() {
    mkdir -p $romdir/quake
    ensureSystemretroconfig "quake"

    // Quake Shareware: Please copy pak0.pak to rom folder
    setESSystem "Quake" "quake" "~/RetroPie/roms/quake" ".PAK .pak" "$rootdir/supplementary/runcommand/runcommand.sh 4 \"$rootdir/emulators/RetroArch/installdir/bin/retroarch -L `find $rootdir/emulatorcores/quake/ -name \"*libretro*.so\" | head -1` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/quake/retroarch.cfg $__tmpnetplaymode$__tmpnetplayhostip_cfile $__tmpnetplayport$__tmpnetplayframes %ROM%\"" "quake" "quake"
}
