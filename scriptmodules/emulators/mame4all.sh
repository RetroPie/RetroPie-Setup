rp_module_id="mame4all"
rp_module_desc="MAME emulator MAME4All-Pi"
rp_module_menus="2+"

function depends_mame4all() {
    checkNeededPackages libasound2-dev libsdl1.2-dev
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

    mkdir -p "$configdir/$md_id/"cfg,hi,inp,memcard,nvram,snap,sta}
    chown -R $user:$user "$configdir/$md_id"
    ensureKeyValueShort "cfg" "$configdir/$md_id/cfg" "$md_inst/mame.cfg"
    ensureKeyValueShort "hi" "$configdir/$md_id/hi" "$md_inst/mame.cfg"
    ensureKeyValueShort "inp" "$configdir/$md_id/inp" "$md_inst/mame.cfg"
    ensureKeyValueShort "memcard" "$configdir/$md_id/memcard" "$md_inst/mame.cfg"
    ensureKeyValueShort "nvram" "$configdir/$md_id/nvram" "$md_inst/mame.cfg"
    ensureKeyValueShort "snap" "$configdir/$md_id/snap" "$md_inst/mame.cfg"
    ensureKeyValueShort "sta" "$configdir/$md_id/sta" "$md_inst/mame.cfg"

    ensureKeyValueShort "artwork" "$romdir/mame-artwork" "$md_inst/mame.cfg"
    ensureKeyValueShort "samplepath" "$romdir/mame-samples" "$md_inst/mame.cfg"
    ensureKeyValueShort "rompath" "$romdir/mame" "$md_inst/mame.cfg"

    ensureKeyValueShort "samplerate" "22050" "$md_inst/mame.cfg"

    setESSystem "MAME" "mame" "~/RetroPie/roms/mame" ".zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 4 \"$md_inst/mame %BASENAME%\"" "arcade" "mame"
}
