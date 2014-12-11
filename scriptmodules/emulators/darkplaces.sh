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
        unzip -o quake106.zip
        lhasa ef resource.1
        
        # Create ports directory
        mkdir -p $romdir/ports
        mkdir -p $romdir/ports/quake
    
        # Copy game dir to rom dir
        cp -rf id1 $romdir/ports/quake/id1
        
        # Set game file permission
        chmod 666 "$romdir/ports/quake/id1/pak0.pak"
        chmod 666 "$romdir/ports/quake/id1/autoexec.cfg"
        chmod 666 "$romdir/ports/quake/id1/config.cfg"
        chmod 666 "$romdir/ports/quake/id1/default.cfg"
        chmod 666 "$romdir/ports/quake/id1/quake.rc"
        chmod 666 "$romdir/ports/quake/id1/textures/quake.tga"
        
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
    chmod 666 "$romdir/ports/darkplacesquake.sh"
    
    # Add darkplaces quake to emulationstation
    setESSystem 'Ports' 'ports' '~/RetroPie/roms/ports' '.sh .SH' '%ROM%' 'pc' 'ports'
}
