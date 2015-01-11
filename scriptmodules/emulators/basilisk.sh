rp_module_id="basilisk"
rp_module_desc="Macintosh emulator"
rp_module_menus="2+"
rp_module_flags="dispmanx"

function depends_basilisk() {
    getDepends libsdl1.2-dev autoconf automake
}

function sources_basilisk() {
    gitPullOrClone "$md_build" git://github.com/cebix/macemu.git
}

function build_basilisk() {
    cd BasiliskII/src/Unix
    ./autogen.sh --prefix="$md_inst" --enable-sdl-video --enable-sdl-audio --disable-vosf --disable-jit-compiler --without-x --without-mon --without-esd --without-gtk
    make clean
    make
    md_ret_require="$md_build/BasiliskII/src/Unix/BasiliskII"
}

function install_basilisk() {
    cd "BasiliskII/src/Unix"
    make install
}

function configure_basilisk() {
    mkRomDir "macintosh"
    touch "$romdir/macintosh/Start.txt"

    setESSystem "Apple Macintosh" "macintosh" "~/RetroPie/roms/macintosh" ".txt" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$md_inst/bin/BasiliskII --rom $romdir/macintosh/mac.rom --disk $romdir/macintosh/disk.img\" \"$md_id\"" "macintosh"

}
