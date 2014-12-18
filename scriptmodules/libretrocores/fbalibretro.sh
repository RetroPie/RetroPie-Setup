rp_module_id="fbalibretro"
rp_module_desc="FBA LibretroCore"
rp_module_menus="2+"

function depends_fbalibretro() {
    checkNeededPackages gcc-4.8 g++-4.8
}

function sources_fbalibretro() {
    gitPullOrClone "$md_build" git://github.com/libretro/fba-libretro.git
}

function build_fbalibretro() {
    cd svn-current/trunk/
    make -f makefile.libretro clean
    make -f makefile.libretro CC="gcc-4.8" CXX="g++-4.8" platform=armvhardfloat
    md_ret_require="$md_build/svn-current/trunk/fb_alpha_libretro.so"
}

function install_fbalibretro() {
    md_ret_files=(
        'svn-current/trunk/fba.chm'
        'svn-current/trunk/fb_alpha_libretro.so'
        'svn-current/trunk/gamelist-gx.txt'
        'svn-current/trunk/gamelist.txt'
        'svn-current/trunk/whatsnew.html'
        'svn-current/trunk/preset-example.zip'
    )
}

function configure_fbalibretro() {
    mkdir -p $romdir/fba-libretro

    rps_retronet_prepareConfig
    setESSystem "Final Burn Alpha" "fba-libretro" "~/RetroPie/roms/fba-libretro" ".zip .ZIP .fba .FBA" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$emudir/retroarch/bin/retroarch -L $md_inst/fb_alpha_libretro.so --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/fba/retroarch.cfg $__tmpnetplaymode$__tmpnetplayhostip_cfile$__tmpnetplayport$__tmpnetplayframes %ROM%\"" "arcade" "fba"
}