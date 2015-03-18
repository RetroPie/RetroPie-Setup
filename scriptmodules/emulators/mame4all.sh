rp_module_id="mame4all"
rp_module_desc="MAME emulator MAME4All-Pi"
rp_module_menus="2+"

function depends_mame4all() {
    getDepends libasound2-dev libsdl1.2-dev
}

function sources_mame4all() {
    gitPullOrClone "$md_build" https://github.com/joolswills/mame4all-pi.git
}

function build_mame4all() {
    make clean
    make
    md_ret_require="$md_build/mame"
}

function install_mame4all() {
    md_ret_files=(
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
    mkRomDir "mame-mame4all"
    mkRomDir "mame-mame4all/artwork"
    mkRomDir "mame-mame4all/samples"

    mkdir -p "$configdir/mame-mame4all/"{cfg,hi,inp,memcard,nvram,snap,sta}

    iniConfig "=" "" "$md_inst/mame.cfg"
    iniSet "cfg" "$configdir/mame-mame4all/cfg"
    iniSet "hi" "$configdir/mame-mame4all/hi"
    iniSet "inp" "$configdir/mame-mame4all/inp"
    iniSet "memcard" "$configdir/mame-mame4all/memcard"
    iniSet "nvram" "$configdir/mame-mame4all/nvram"
    iniSet "snap" "$configdir/mame-mame4all/snap"
    iniSet "sta" "$configdir/mame-mame4all/sta"

    iniSet "artwork" "$romdir/mame-mame4all/artwork"
    iniSet "samplepath" "$romdir/mame-mame4all/samples"
    iniSet "rompath" "$romdir/mame-mame4all"

    iniSet "samplerate" "22050"

    chown -R $user:$user "$configdir/mame-mame4all"

    addSystem 1 "$md_id" "mame-mame4all arcade mame" "$md_inst/mame %BASENAME%"
}
