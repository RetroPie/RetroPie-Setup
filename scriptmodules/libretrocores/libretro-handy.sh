rp_module_id="libretro-handy"
rp_module_desc="Atari Lynx LibretroCore handy"
rp_module_menus="4+"

function sources_libretro-handy() {
    gitPullOrClone "$rootdir/emulatorcores/libretro-handy" https://github.com/libretro/libretro-handy.git
}

function build_libretro-handy() {
    pushd "$rootdir/emulatorcores/libretro-handy"
    make clean
    make
    popd
    if [[ -z `find $rootdir/emulatorcores/libretro-handy/ -name "*libretro*.so"` ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile Lynx core."
    fi
}

function configure_libretro-handy() {
    mkdir -p $romdir/lynx
    ensureSystemretroconfig "lynx"
    rps_retronet_prepareConfig
    setESSystem "Atari Lynx" "lynx" "~/RetroPie/roms/lynx" ".lnx .LNX" "$rootdir/supplementary/runcommand/runcommand.sh 4 \"$emudir/$1/bin/retroarch -L `find $rootdir/emulatorcores/libretro-handy/ -name \"*libretro*.so\" | head -1` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/lynx/retroarch.cfg $__tmpnetplaymode$__tmpnetplayhostip_cfile$__tmpnetplayport$__tmpnetplayframes %ROM%\"" "lynx" "lynx"
}
