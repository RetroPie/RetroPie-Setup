rp_module_id="pocketsnes"
rp_module_desc="SNES LibretroCore PocketSNES"
rp_module_menus="2+"

function sources_pocketsnes() {
    gitPullOrClone "$rootdir/emulatorcores/pocketsnes-libretro" git://github.com/ToadKing/pocketsnes-libretro.git
    pushd "$rootdir/emulatorcores/pocketsnes-libretro"
    patch -N -i $scriptdir/supplementary/pocketsnesmultip.patch $rootdir/emulatorcores/pocketsnes-libretro/src/ppu.cpp
    popd
}

function build_pocketsnes() {
    pushd "$rootdir/emulatorcores/pocketsnes-libretro"
    make clean
    make
    if [[ -z `find $rootdir/emulatorcores/pocketsnes-libretro/ -name "*libretro*.so"` ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile SNES core."
    fi
    popd
}

function configure_pocketsnes() {
    mkdir -p $romdir/snes

    # # look for existing configuration
    # xmlstarlet sel -t -c "/systemList/system[name='snes']" -n -v test.xml

    # # delete system
    # xmlstarlet ed -d "/systemList/system[name='snes']" -n test.xml

    # # add new system
    # xml ed -s /config -t elem -n sub -v "" -i /config/sub -t attr -n class -v com.foo test.xml

    # # append to system
    # xmlstarlet ed -a '/xml/block/el[@name="b"]' \
    #           --type 'elem' -n 'el' -v 0
}