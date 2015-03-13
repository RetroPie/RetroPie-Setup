rp_module_id="lr-fceu-next"
rp_module_desc="NES emu - FCEUmm / FCEUX NES port for libretro"
rp_module_menus="2+"

function sources_lr-fceu-next() {
    gitPullOrClone "$md_build" git://github.com/libretro/fceu-next.git
}

function build_lr-fceu-next() {
    cd fceumm-code
    make -f Makefile.libretro clean
    make -f Makefile.libretro
    md_ret_require="$md_build/fceumm-code/fceumm_libretro.so"
}

function install_lr-fceu-next() {
    md_ret_files=(
        'fceumm-code/Authors'
        'fceumm-code/changelog.txt'
        'fceumm-code/Copying'
        'fceumm-code/fceumm_libretro.so'
        'fceumm-code/whatsnew.txt'
        'fceumm-code/zzz_todo.txt'
    )
}

function configure_lr-fceu-next() {
    # remove old install folder
    rm -rf "$rootdir/$md_type/neslibretro"

    mkRomDir "nes"
    ensureSystemretroconfig "nes" "phosphor.glslp"

    addSystem 1 "$md_id" "nes" "$md_inst/fceumm_libretro.so"
}
