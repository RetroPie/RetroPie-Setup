rp_module_id="cavestory"
rp_module_desc="Cave Story LibretroCore"
rp_module_menus="2+"

function sources_cavestory() {
    gitPullOrClone "$rootdir/emulatorcores/nxengine-libretro" git://github.com/libretro/nxengine-libretro.git
}

function build_cavestory() {
    pushd "$rootdir/emulatorcores/nxengine-libretro"
    make
    if [[ -z `find $rootdir/emulatorcores/nxengine-libretro/ -name "*libretro*.so"` ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile NXEngine / Cave Story core."
    fi
    popd
}

function configure_cavestory() {
    if [[ ! -d $romdir/ports ]]; then
        mkdir -p $romdir/ports
    fi
    cat > "$romdir/ports/Cave Story.sh" << _EOF_
#!/bin/bash
$rootdir/supplementary/runcommand/runcommand.sh 1 "$rootdir/emulators/RetroArch/installdir/bin/retroarch -L `find $rootdir/emulatorcores/nxengine-libretro/ -name "*libretro*.so" | head -1` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/cavestory/retroarch.cfg $rootdir/emulatorcores/nxengine-libretro/datafiles/Doukutsu.exe"
_EOF_
    chmod +x "$romdir/ports/Cave Story.sh"
    chown -R $user:$user "$rootdir/emulatorcores/nxengine-libretro/datafiles/"
}