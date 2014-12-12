rp_module_id="darkplaces"
rp_module_desc="Darkplaces Quake"
rp_module_menus="4+"

function depends_darkplaces() {
    rps_checkNeededPackages lhasa libtxc-dxtn-s2tc0
}

function sources_darkplaces() {
    gitPullOrClone "$builddir/$1" git://github.com/autonomous1/darkplacesrpi.git
}

function install_darkplaces() {
    # Install darkplaces debian package
    dpkg -i darkplaces-rpi.deb
    rm darkplaces-rpi.deb

    # Download game file
    wget ftp://ftp.idsoftware.com/idstuff/quake/quake106.zip
    unzip -o quake106.zip
    rm quake106.zip
    lhasa ef resource.1
    
    # Create ports directory
    mkdir -p $romdir/ports/quake

    # Copy game dir to rom dir
    cp -rf id1 $romdir/ports/quake/id1
    
    # Set game file permission
    chown -R $user:$user "$romdir/ports/quake/"
}

function configure_darkplaces() {
    # Create startup script
    cat > "$romdir/ports/darkplacesquake.sh" << _EOF_
#!/bin/bash
sudo darkplaces-sdl -basedir $romdir/ports -quake
_EOF_
    
    # Set startup script permissions
    chmod u+x "$romdir/ports/darkplacesquake.sh"
    chown $user:$user "$romdir/ports/darkplacesquake.sh"
    
    # Add darkplaces quake to emulationstation
    setESSystem 'Ports' 'ports' '~/RetroPie/roms/ports' '.sh .SH' '%ROM%' 'pc' 'ports'
}
