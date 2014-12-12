rp_module_id="fbalibretro"
rp_module_desc="FBA LibretroCore"
rp_module_menus="2+"

function depends_fbalibretro() {
    rps_checkNeededPackages cpp-4.8 gcc-4.8 g++-4.8
}

function sources_fbalibretro() {
    gitPullOrClone "$rootdir/emulatorcores/fba-libretro" git://github.com/libretro/fba-libretro.git
}

function build_fbalibretro() {
    pushd "$rootdir/emulatorcores/fba-libretro"
    cd $rootdir/emulatorcores/fba-libretro/svn-current/trunk/
    make -f makefile.libretro clean
    make -f makefile.libretro CC="gcc-4.8" CXX="g++-4.8" platform=armvhardfloat
    mv `find $rootdir/emulatorcores/fba-libretro/svn-current/trunk/ -name "*libretro*.so"` "$rootdir/emulatorcores/fba-libretro/"
    if [[ -z `find $rootdir/emulatorcores/fba-libretro/ -name "*libretro*.so"` ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile FBA core."
    fi
    popd
}

function configure_fbalibretro() {
    mkdir -p $romdir/fba-libretro

    rps_retronet_prepareConfig
    setESSystem "Final Burn Alpha" "fba-libretro" "~/RetroPie/roms/fba-libretro" ".zip .ZIP .fba .FBA" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$emudir/$1/bin/retroarch -L `find $rootdir/emulatorcores/fba-libretro/ -name \"*libretro*.so\" | head -1` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/fba/retroarch.cfg $__tmpnetplaymode$__tmpnetplayhostip_cfile$__tmpnetplayport$__tmpnetplayframes %ROM%\"" "arcade" "fba"
}