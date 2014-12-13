rp_module_id="basilisk"
rp_module_desc="Macintosh emulator"
rp_module_menus="2+"

function depends_basilisk() {
    checkNeededPackages autoconf automake
}

function sources_basilisk() {
    gitPullOrClone "$md_build" git://github.com/cebix/macemu.git
}

function build_basilisk() {
    cd BasiliskII/src/Unix
    ./autogen.sh --prefix="$md_inst" --enable-sdl-video --enable-sdl-audio --disable-vosf --disable-jit-compiler
    make clean
    make
    md_ret_require="$md_build/BasiliskII/src/Unix/BasiliskII"
}

function install_basilisk() {
    cd "BasiliskII/src/Unix"
    make install
}

function configure_basilisk() {
    mkdir -p "$romdir/macintosh"
    touch "$romdir/macintosh/Start.txt"

    setESSystem "Apple Macintosh" "macintosh" "~/RetroPie/roms/macintosh" ".txt" "xinit $md_inst/bin/BasiliskII" "macintosh"

}