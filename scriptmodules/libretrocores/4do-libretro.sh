rp_module_id="4do"
rp_module_desc="3DO LibretroCore 4DO (WIP)"
rp_module_menus="4+"

function sources_4do() {
    gitPullOrClone "$md_build" https://github.com/libretro/4do-libretro.git
}

function build_4do() {
    make clean
    make
    md_ret_require="$md_build/4do_libretro.so"
}

function install_4do() {
    md_ret_files=(
        '4do_libretro.so'
    )
}

function configure_4do() {
    mkRomDir "3do"
    ensureSystemretroconfig "3do"

    # system-specific shaders, 3do
    iniConfig " = " "" "$configdir/3do/retroarch.cfg"
    iniSet "input_remapping_directory" "$configdir/3do/"

    # Place "panafz10.bin" (required) in your RetroArch/libretro "System Directory" folder
    setESSystem "3DO" "3do" "~/RetroPie/roms/3do" ".iso .ISO" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$emudir/retroarch/bin/retroarch -L $md_inst/4do_libretro.so --config $configdir/all/retroarch.cfg --appendconfig $configdir/3do/retroarch.cfg %ROM%\" \"$md_id\"" "3do" "3do"
}
