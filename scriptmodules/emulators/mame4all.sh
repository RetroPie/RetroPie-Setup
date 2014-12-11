rp_module_id="mame4all"
rp_module_desc="MAME emulator MAME4All-Pi"
rp_module_menus="2+"

function depends_mame4all() {
    rps_checkNeededPackages libasound2-dev libsdl1.2-dev
}

function sources_mame4all() {
    gitPullOrClone "$builddir/$1" https://code.google.com/p/mame4all-pi/ NS
    sed -i "s/@mkdir/@mkdir -p/g" "Makefile"
    sed -i 's/-lglib-2.0$/-lglib-2.0 -lrt -lasound/g' Makefile
    sed -i 's/armv6 /armv6j /g' Makefile
}

function build_mame4all() {
    make clean
    make
    require="$emudir/$1/mame"
}

function install_mame4all() {
    files=(
        'cheat.dat'
        'clrmame.dat'
        'folders'
        'hiscore.dat'
        'mame'
        'mame.cfg'
        'readme.txt'
        'skins'
    )
}

function configure_mame4all() {
    mkdir -p "$romdir/mame"
    mkdir -p "$emudir/$1/"{cfg,hi,sta,roms}
    chown -R $user:$user "$emudir/$1"
    ensureKeyValueShort "samplerate" "22050" "$emudir/$1/mame.cfg"
    ensureKeyValueShort "rompath" "$romdir/mame" "$emudir/$1/mame.cfg"

    setESSystem "MAME" "mame" "~/RetroPie/roms/mame" ".zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 4 \"$emudir/$1/mame %BASENAME%\"" "arcade" "mame"
}
