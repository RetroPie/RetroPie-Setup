rp_module_id="mupen64plus"
rp_module_desc="N64 LibretroCore Mupen64Plus"
rp_module_menus="4+"

function sources_mupen64plus() {
    rmDirExists "$rootdir/emulatorcores/mupen64plus"
    # Base repo:
    # gitPullOrClone "$rootdir/emulatorcores/mupen64plus" git://github.com/libretro/mupen64plus-libretro.git
    # Freezed fixed repo:
    gitPullOrClone "$rootdir/emulatorcores/mupen64plus" git://github.com/gizmo98/mupen64plus-libretro.git
}

function build_mupen64plus() {
    pushd "$rootdir/emulatorcores/mupen64plus"
    
    # Increase swapfile size to meet memory requirement
    # mupen64plus needs up to 310MB RAM during compilation
    dphys-swapfile swapoff
    echo "CONF_SWAPSIZE=300" > /etc/dphys-swapfile
    dphys-swapfile setup
    dphys-swapfile swapon
    
    # Add missing path --> Fix already merged https://github.com/libretro/mupen64plus-libretro/commit/c035cf1c7a2514aeb14adf51ad825208ff1a068d
    # sed -i 's|GL_LIB := -lGLESv2|GL_LIB := -L/opt/vc/lib -lGLESv2|g' Makefile
    make clean
    make platform=rpi 
    if [[ -z `find $rootdir/emulatorcores/mupen64plus/ -name "*libretro*.so"` ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile N64 core."
    fi
    
    # Set original swapfile size 
    dphys-swapfile swapoff
    echo "CONF_SWAPSIZE=100" > /etc/dphys-swapfile
    dphys-swapfile setup
    dphys-swapfile swapon
    popd
}

function configure_mupen64plus() {
    mkdir -p $romdir/n64

    ensureSystemretroconfig "n64"

    # Set core options
    ensureKeyValue "mupen64-gfxplugin" "rice" "$rootdir/configs/all/retroarch-core-options.cfg"
    ensureKeyValue "mupen64-gfxplugin-accuracy" "low" "$rootdir/configs/all/retroarch-core-options.cfg"
    ensureKeyValue "mupen64-screensize" "640x480" "$rootdir/configs/all/retroarch-core-options.cfg"

    # Copy config files
    cp $rootdir/emulatorcores/mupen64plus/mupen64plus/mupen64plus-core/data/mupen64plus.cht $home/RetroPie/BIOS/mupen64plus.cht
    cp $rootdir/emulatorcores/mupen64plus/mupen64plus/mupen64plus-core/data/mupencheat.txt $home/RetroPie/BIOS/mupencheat.txt
    cp $rootdir/emulatorcores/mupen64plus/mupen64plus/mupen64plus-core/data/mupen64plus.ini $home/RetroPie/BIOS/mupen64plus.ini 
    cp $rootdir/emulatorcores/mupen64plus/mupen64plus/mupen64plus-core/data/font.ttf $home/RetroPie/BIOS/font.ttf

    # Set permissions
    chmod +x "$home/RetroPie/BIOS/mupen64plus.cht"
    chmod +x "$home/RetroPie/BIOS/mupencheat.txt"
    chmod +x "$home/RetroPie/BIOS/mupen64plus.ini"
    chmod +x "$home/RetroPie/BIOS/font.ttf"

    rps_retronet_prepareConfig
    setESSystem "Nintendo 64" "n64" "~/RetroPie/roms/n64" ".z64 .Z64 .n64 .N64 .v64 .V64" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"$rootdir/emulators/RetroArch/installdir/bin/retroarch -L `find $rootdir/emulatorcores/mupen64plus/ -name \"*libretro*.so\" | head -1` --config $rootdir/configs/all/retroarch.cfg --appendconfig $rootdir/configs/n64/retroarch.cfg $__tmpnetplaymode$__tmpnetplayhostip_cfile $__tmpnetplayport$__tmpnetplayframes %ROM%\"" "n64" "n64"
}
