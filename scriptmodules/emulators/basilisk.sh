rp_module_id="basilisk"
rp_module_desc="Macintosh emulator"
rp_module_menus="2+"

function depends_basilisk() {
    rps_checkNeededPackages autoconf automake
}

function sources_basilisk() {
    gitPullOrClone "$builddir/$1" git://github.com/cebix/macemu.git
}

function build_basilisk() {
    cd BasiliskII/src/Unix
    ./autogen.sh
    ./configure --prefix="$emudir/$1" --enable-sdl-video --enable-sdl-audio --disable-vosf --disable-jit-compiler
    make clean
    make
    if [[ -z "BasiliskII" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile BasiliskII."
    fi
    require="$builddir/$1/BasiliskII/src/Unix/BasiliskII"
}

function install_basilisk() {
    cd "BasiliskII/src/Unix"
    make install
}

function configure_basilisk() {
    mkdir -p "$romdir/macintosh"
    touch $romdir/macintosh/Start.txt

    setESSystem "Apple Macintosh" "macintosh" "~/RetroPie/roms/macintosh" ".txt" "xinit $emudir/$1/bin/BasiliskII" "macintosh"

}