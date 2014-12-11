rp_module_id="eduke32"
rp_module_desc="Duke3D Port"
rp_module_menus="2+"

function install_eduke32() {
    rmDirExists "$rootdir/emulators/eduke32"
    mkdir -p $rootdir/emulators/eduke32
    pushd "$rootdir/emulators/eduke32"
    printMsg "Downloading eDuke core"
    wget http://downloads.petrockblock.com/retropiearchives/eduke32_2.0.0rpi+svn2789_armhf.deb
    printMsg "Downloading eDuke32 Shareware files"
    wget http://downloads.petrockblock.com/retropiearchives/duke3d-shareware_1.3d-23_all.deb
    if [[ ! -f "$rootdir/emulators/eduke32/eduke32_2.0.0rpi+svn2789_armhf.deb" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully install eDuke32 core."
    else
        dpkg -i *duke*.deb
        if [[ ! -d $romdir/ports/duke3d ]]; then
            mkdir -p $romdir/ports/duke3d
        fi
        cp /usr/share/games/eduke32/DUKE.RTS $romdir/ports/duke3d/
        cp /usr/share/games/eduke32/duke3d.grp $romdir/ports/duke3d/
    fi
    popd
    rm -rf "$rootdir/emulators/eduke32"

    cat > "$romdir/ports/Duke3D Shareware.sh" << _EOF_
#!/bin/bash
$rootdir/supplementary/runcommand/runcommand.sh 4 "eduke32 -j$romdir/ports/duke3d"
_EOF_
    chmod +x "$romdir/ports/Duke3D Shareware.sh"

    setESSystem 'Ports' 'ports' '~/RetroPie/roms/ports' '.sh .SH' '%ROM%' 'pc' 'ports'    
}