rp_module_id="darkplaces"
rp_module_desc="Darkplaces Quake"
rp_module_menus="4+"

function depends_darkplaces() {
    rps_checkNeededPackages lhasa libtxc-dxtn-s2tc0
}

function sources_darkplaces() {
    gitPullOrClone "$rootdir/emulators/darkplaces" git://github.com/autonomous1/darkplacesrpi.git
}

function install_darkplaces() {
    pushd "$rootdir/emulators/darkplaces"
        # Install darkplaces debian package
        sudo dpkg -i darkplaces-rpi.deb
    
        # Download game file
        wget ftp://ftp.idsoftware.com/idstuff/quake/quake106.zip
        unzip quake106.zip
        lhasa e resource.1
        
        # Create ports directory
        mkdir -p $romdir/ports
    
        # Copy game dir to rom dir
        cp -rf id1 $romdir/ports/id1
        
        # Set game file permission
        chmod +x "$romdir/ports/id1/pak0.pak"
        
        # Remove game file
        rm quake106.zip
    popd
}

function configure_darkplaces() {
    # Set video permissions
    sudo usermod -a -G video $user
    
    # Create startup script
    cat > "$romdir/ports/darkplacesquake.sh" << _EOF_
#!/bin/bash
sudo darkplaces-sdl -basedir $romdir/ports -quake
_EOF_
    
    # Set startup script permissions
    chmod +x "$romdir/ports/darkplacesquake.sh"
    
    # Add darkplaces quake to emulationstation
    setESSystem 'Ports' 'ports' '~/RetroPie/roms/ports' '.sh .SH' '%ROM%' 'pc' 'ports'
}
