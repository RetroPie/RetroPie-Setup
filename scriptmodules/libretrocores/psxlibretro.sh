rp_module_id="psxlibretro"
rp_module_desc="Playstation 1 LibretroCore"
rp_module_menus="2+"

function depends_psxlibretro() {
    getDepends libpng12-dev libx11-dev
}

function sources_psxlibretro() {
    gitPullOrClone "$md_build" git://github.com/libretro/pcsx_rearmed.git
}

function build_psxlibretro() {
    ./configure --platform=libretro
    make clean
    make
    md_ret_require="$md_build/libretro.so"
}

function install_psxlibretro() {
    md_ret_files=(
        'AUTHORS'
        'ChangeLog.df'
        'COPYING'
        'libretro.so'
        'NEWS'
        'README.md'
        'readme.txt'
    )
}

function configure_psxlibretro() {
    mkRomDir "psx"
    ensureSystemretroconfig "psx"

    # system-specific, PSX
    iniConfig " = " "" "$configdir/psx/retroarch.cfg"
    iniSet "rewind_enable" "false"
    iniSet "input_remapping_directory" "$configdir/psx/"

    setESSystem "Sony Playstation 1" "psx" "~/RetroPie/roms/psx" ".bin .BIN .cue .CUE .cbn .CBN .img .IMG .mdf .MDF .pbp .PBP .toc .TOC .z .Z .znx .ZNX" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$emudir/retroarch/bin/retroarch -L $md_inst/libretro.so --config $configdir/all/retroarch.cfg --appendconfig $configdir/psx/retroarch.cfg %ROM%\" \"$md_id\"" "psx" "psx"
}
