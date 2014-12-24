rp_module_id="libretro-handy"
rp_module_desc="Atari Lynx LibretroCore handy"
rp_module_menus="2+"

function sources_libretro-handy() {
    gitPullOrClone "$md_build" https://github.com/libretro/libretro-handy.git
}

function build_libretro-handy() {
    make clean
    make
    md_ret_require="$md_build/handy_libretro.so"
}

function install_libretro-handy() {
    md_ret_files=(
        'handy_libretro.so'
        'README.md'
    )
}

function configure_libretro-handy() {
    mkRomDir "lynx"
    ensureSystemretroconfig "lynx"
    rps_retronet_prepareConfig
    setESSystem "Atari Lynx" "lynx" "~/RetroPie/roms/lynx" ".lnx .LNX" "$rootdir/supplementary/runcommand/runcommand.sh 4 \"$emudir/retroarch/bin/retroarch -L $md_inst/handy_libretro.so --config $configdir/all/retroarch.cfg --appendconfig $configdir/lynx/retroarch.cfg $__tmpnetplaymode$__tmpnetplayhostip_cfile$__tmpnetplayport$__tmpnetplayframes %ROM%\"" "lynx" "lynx"
}
