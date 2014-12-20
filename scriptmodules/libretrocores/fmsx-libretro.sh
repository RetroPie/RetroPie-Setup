rp_module_id="fmsx-libretro"
rp_module_desc="MSX LibretroCore fmsx"
rp_module_menus="4+"

function sources_fmsx-libretro() {
    gitPullOrClone "$md_build" git://github.com/libretro/fmsx-libretro.git
}

function build_fmsx-libretro() {
    make clean
    make
    md_ret_require="$md_build/fmsx_libretro.so"
}

function install_fmsx-libretro() {
    cp -v "$md_build/fMSX/ROMs/"* "$home/RetroPie/BIOS/"
    chown -R $user:$user "$home/RetroPie/BIOS/"
    md_ret_files=(
        'fmsx_libretro.so'
        'README.md'
    )
}

function configure_fmsx-libretro() {
    mkRomDir "msx"
    ensureSystemretroconfig "msx"
    rps_retronet_prepareConfig
    setESSystem "MSX" "msx" "~/RetroPie/roms/msx" ".rom .ROM .mx1 .MX1 .mx2 .MX2 .col .COL .dsk .DSK" "$rootdir/supplementary/runcommand/runcommand.sh 4 \"$emudir/retroarch/bin/retroarch -L $md_inst/fmsx_libretro.so --config $configdir/all/retroarch.cfg --appendconfig $configdir/msx/retroarch.cfg $__tmpnetplaymode$__tmpnetplayhostip_cfile$__tmpnetplayport$__tmpnetplayframes %ROM%\"" "msx" "msx"
}
