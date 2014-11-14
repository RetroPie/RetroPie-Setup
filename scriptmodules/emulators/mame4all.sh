rp_module_id="mame4all"
rp_module_desc="MAME emulator MAME4All-Pi"
rp_module_menus="2+"

function depends_mame4all() {
	rps_checkNeededPackages libasound2-dev
}

function sources_mame4all() {
    gitPullOrClone "$rootdir/emulators/mame4all-pi" https://code.google.com/p/mame4all-pi/ NS
    sed -i "s/@mkdir/@mkdir -p/g" "$rootdir/emulators/mame4all-pi/Makefile"
}

function build_mame4all() {
    pushd "$rootdir/emulators/mame4all-pi"
    make clean
    make
    if [[ ! -f "$rootdir/emulators/mame4all-pi/mame" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully mame4all-pi emulator."
    fi
    popd
}

function configure_mame4all() {
    mkdir -p "$romdir/mame"
    mkdir -p "$rootdir/emulators/mame4all-pi/"{cfg,hi,sta,roms}
    chown -R $user:$user "$rootdir/emulators/mame4all-pi"
    ensureKeyValueShort "samplerate" "22050" "$rootdir/emulators/mame4all-pi/mame.cfg"
    ensureKeyValueShort "rompath" "$romdir/mame" "$rootdir/emulators/mame4all-pi/mame.cfg"

    setESSystem "MAME" "mame" "~/RetroPie/roms/mame" ".zip .ZIP" "$rootdir/supplementary/runcommand/runcommand.sh 4 \"$rootdir/emulators/mame4all-pi/mame %BASENAME%\"" "arcade" "mame"
}
