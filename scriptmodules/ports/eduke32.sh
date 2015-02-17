rp_module_id="eduke32"
rp_module_desc="Duke3D Port"
rp_module_menus="2+"
rp_module_flags="nobin"

function install_eduke32() {
    printHeading "Downloading eDuke core"
    wget http://downloads.petrockblock.com/retropiearchives/eduke32_2.0.0rpi+svn2789_armhf.deb
    printHeading "Downloading eDuke32 Shareware files"
    wget http://downloads.petrockblock.com/retropiearchives/duke3d-shareware_1.3d-23_all.deb
    dpkg -i ./*.deb
    rm ./*.deb
    md_ret_require="/usr/games/eduke32"
}

function configure_eduke32() {
    mkRomDir "ports/duke3d"

    cp /usr/share/games/eduke32/DUKE.RTS "$romdir/ports/duke3d/"
    cp /usr/share/games/eduke32/duke3d.grp "$romdir/ports/duke3d/"

    cat > "$romdir/ports/Duke3D Shareware.sh" << _EOF_
#!/bin/bash
$rootdir/supplementary/runcommand/runcommand.sh 4 "/usr/games/eduke32 -j$romdir/ports/duke3d" "$md_id"
_EOF_
    chmod +x "$romdir/ports/Duke3D Shareware.sh"   
    setESSystem 'Ports' 'ports' '~/RetroPie/roms/ports' '.sh .SH' '%ROM%' 'pc' 'ports' 
}
