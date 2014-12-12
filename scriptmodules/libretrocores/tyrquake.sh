rp_module_id="tyrquake"
rp_module_desc="Quake LibretroCore"
rp_module_menus="4+"

function depends_tyrquake() {
    rps_checkNeededPackages lhasa
}

function sources_tyrquake() {
    # rmDirExists "$rootdir/emulatorcores/quake"
    gitPullOrClone "$rootdir/emulatorcores/quake" git://github.com/libretro/tyrquake.git
    # pushd "$rootdir/emulatorcores/quake"
    # popd
}

function build_tyrquake() {
    pushd "$rootdir/emulatorcores/quake"
    make -f Makefile.libretro clean
    make -f Makefile.libretro
    if [[ -z `find $rootdir/emulatorcores/quake/ -name "*libretro*.so"` ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile quake core."
    fi
    popd
}

function install_tyrquake() {
    pushd "$rootdir/emulatorcores/quake"
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
        
        # Remove game file
        rm quake106.zip
    popd
}

function configure_tyrquake() {
    # mkdir -p $romdir/quake
    ensureSystemretroconfig "quake"

    # Create startup script
    cat > "$romdir/ports/Quake.sh" << _EOF_
#!/bin/bash
$rootdir/supplementary/runcommand/runcommand.sh 4 "$emudir/$1/bin/retroarch -L `find $rootdir/emulatorcores/quake/ -name "*libretro*.so" | head -1` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/quake/retroarch.cfg  $romdir/ports/quake/id1/pak0.pak"
_EOF_
    
    # Set startup script permissions
    chmod +x "$romdir/ports/Quake.sh"

    # Add darkplaces quake to emulationstation
    setESSystem 'Ports' 'ports' '~/RetroPie/roms/ports' '.sh .SH' '%ROM%' 'pc' 'ports'
    
    # Quake Shareware: Please copy pak0.pak to rom folder
    # setESSystem "Quake" "quake" "~/RetroPie/roms/quake" ".PAK .pak" "$rootdir/supplementary/runcommand/runcommand.sh 4 \"$emudir/$1/bin/retroarch -L `find $rootdir/emulatorcores/quake/ -name \"*libretro*.so\" | head -1` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/quake/retroarch.cfg $__tmpnetplaymode$__tmpnetplayhostip_cfile $__tmpnetplayport$__tmpnetplayframes %ROM%\"" "quake" "quake"
}
