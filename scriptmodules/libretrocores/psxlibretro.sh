rp_module_id="psxlibretro"
rp_module_desc="Playstation 1 LibretroCore"
rp_module_menus="2+"

function depends_psxlibretro() {
    checkNeededPackages libpng12-dev libx11-dev
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
        'README'
        'readme.txt'
        'plugins/gpu-gles/gpu_gles.so'
        'plugins/gpu_unai.so'
        'plugins/gpu_unai/gpu_unai.so'
        'plugins/gpu_peops.so'
        'plugins/spunull.so'
        'plugins/dfxvideo/gpu_peops.so'
        'plugins/spunull/spunull.so'
        'plugins/gpu_gles.so'
        'skin'
    )
}

function configure_psxlibretro() {
    mkRomDir "psx"

    rps_retronet_prepareConfig
    setESSystem "Sony Playstation 1" "psx" "~/RetroPie/roms/psx" ".img .IMG .7z .7Z .pbp .PBP .bin .BIN .cue .CUE" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$emudir/retroarch/bin/retroarch -L $md_inst/libretro.so --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/psx/retroarch.cfg %ROM%\"" "psx" "psx"
}