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
    mkRomDir "mame"
    mkRomDir "mame-samples"
    mkRomDir "mame-artwork"

    mkdir -p "$configdir/mame/"{cfg,hi,inp,memcard,nvram,snap,sta}
    chown -R $user:$user "$configdir/mame"

    iniConfig "=" "" "$md_inst/mame.cfg"
    iniSet "cfg" "$configdir/mame/cfg"
    iniSet "hi" "$configdir/mame/hi"
    iniSet "inp" "$configdir/mame/inp"
    iniSet "memcard" "$configdir/mame/memcard"
    iniSet "nvram" "$configdir/mame/nvram"
    iniSet "snap" "$configdir/mame/snap"
    iniSet "sta" "$configdir/mame/sta"

    iniSet "artwork" "$romdir/mame-artwork"
    iniSet "samplepath" "$romdir/mame-samples"
    iniSet "rompath" "$romdir/mame"

    iniSet "samplerate" "22050"

    setESSystem "MAME" "mame" "~/RetroPie/roms/mame" ".zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 4 \"$md_inst/mame %BASENAME%\" \"$md_id\"" "arcade" "mame"
}
