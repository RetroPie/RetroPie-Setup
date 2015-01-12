rp_module_id="libretro-vecx"
rp_module_desc="VECTREX LibretroCore VECX"
rp_module_menus="4+"

function sources_libretro-vecx() {
    gitPullOrClone "$md_build" https://github.com/libretro/libretro-vecx
}

function build_libretro-vecx() {
    make clean
    make -f Makefile.libretro
    md_ret_require="$md_build/vecx_libretro.so"
}

function install_libretro-vecx() {
    cp -v "$md_build/bios/"* "$home/RetroPie/BIOS/"
    chown -R $user:$user "$home/RetroPie/BIOS/"
    md_ret_files=(
        'vecx_libretro.so'
    )
}

function configure_libretro-vecx() {
    mkRomDir "vectrex"

    rps_retronet_prepareConfig
    setESSystem "Vectrex" "vectrex" "~/RetroPie/roms/vectrex" ".vec .VEC .gam .GAM .bin .BIN" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$emudir/retroarch/bin/retroarch -L $md_inst/vecx_libretro.so --config $configdir/all/retroarch.cfg --appendconfig $configdir/vectrex/retroarch.cfg $__tmpnetplaymode$__tmpnetplayhostip_cfile $__tmpnetplayport$__tmpnetplayframes %ROM%\" \"$md_id\"" "vectrex" "vectrex"
}
