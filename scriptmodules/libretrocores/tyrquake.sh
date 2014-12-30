rp_module_id="tyrquake"
rp_module_desc="Quake LibretroCore"
rp_module_menus="4+"

function depends_tyrquake() {
    checkNeededPackages lhasa
}

function sources_tyrquake() {
    gitPullOrClone "$md_build" git://github.com/libretro/tyrquake.git
}

function build_tyrquake() {
    make -f Makefile.libretro clean
    make -f Makefile.libretro
    md_ret_require="$md_build/tyrquake_libretro.so"
}

function install_tyrquake() {
    # Download game file
    wget "http://downloads.petrockblock.com/retropiearchives/quake106.zip"
    unzip -o quake106.zip
    rm quake106.zip
    lhasa ef resource.1
    
    # Create ports directory
    mkdir -p $romdir/ports/quake

    # Copy game dir to rom dir
    cp -rf id1 $romdir/ports/quake/id1
    
    # Set game file permission
    chown -R $user:$user "$romdir/ports/quake/"
    
    md_ret_files=(
        'gnu.txt'
        'readme-id.txt'
        'readme.txt'
        'tyrquake_libretro.so'
    )
}

function configure_tyrquake() {
    ensureSystemretroconfig "quake"

    # Create startup script
    cat > "$romdir/ports/Quake.sh" << _EOF_
#!/bin/bash
$rootdir/supplementary/runcommand/runcommand.sh 4 "$emudir/retroarch/bin/retroarch -L $md_inst/tyrquake_libretro.so --config $configdir/all/retroarch.cfg --appendconfig $configdir/quake/retroarch.cfg  $romdir/ports/quake/id1/pak0.pak" "$md_id"
_EOF_

    chmod +x "$romdir/ports/Quake.sh"

    setESSystem 'Ports' 'ports' '~/RetroPie/roms/ports' '.sh .SH' '%ROM%' 'pc' 'ports'
    
    # Quake Shareware: Please copy pak0.pak to rom folder
    # setESSystem "Quake" "quake" "~/RetroPie/roms/quake" ".PAK .pak" "$rootdir/supplementary/runcommand/runcommand.sh 4 \"$emudir/retroarch/bin/retroarch -L $md_inst/tyrquake_libretro.so --config $configdir/all/retroarch.cfg --appendconfig $configdir/quake/retroarch.cfg $__tmpnetplaymode$__tmpnetplayhostip_cfile $__tmpnetplayport$__tmpnetplayframes %ROM%\" \"$md_id\"" "quake" "quake"
}
