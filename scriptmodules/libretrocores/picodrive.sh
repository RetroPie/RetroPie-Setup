rp_module_id="picodrive"
rp_module_desc="Genesis LibretroCore Picodrive"
rp_module_menus="2+"

function sources_picodrive() {
    gitPullOrClone "$rootdir/emulatorcores/picodrive" https://github.com/libretro/picodrive.git
    pushd "$rootdir/emulatorcores/picodrive"
    git submodule init && git submodule update
    popd
}

function build_picodrive() {
    pushd "$rootdir/emulatorcores/picodrive"
    make clean
    make -f Makefile.libretro platform=armv6
    if [[ ! -f `find $rootdir/emulatorcores/picodrive/ -name "*libretro*.so"` ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile Genesis core Picodrive."
    fi
    popd
}

function configure_picodrive() {
    mkdir -p $romdir/megadrive
    mkdir -p $romdir/mastersystem
    mkdir -p $romdir/segacd
    mkdir -p $romdir/sega32x
}