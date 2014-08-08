rp_module_id="gpsp"
rp_module_desc="GameBoy Advance emulator"
rp_module_menus="2+"

# install Game Boy Advance emulator gpSP
function sources_gpsp() {
    gitPullOrClone "$rootdir/emulators/gpsp" git://github.com/gizmo98/gpsp.git
    pushd "$rootdir/emulators/gpsp"
    cd raspberrypi

    if [ "$__chroot" == "0" ]; then
        #if we are on the 256mb model, we will never have enough RAM to compile gpSP with compiler optimization
        #if this is the case, use sed to remove the -O3 in the Makefile (line 20, "CFLAGS     += -O3 -mfpu=vfp")
        local RPiRev=`grep 'Revision' "/proc/cpuinfo" | cut -d " " -f 2`
        if [ $RPiRev == "000000d" ] || [ $RPiRev == "000000e" ] || [ $RPiRev == "000000f" ] || [ $RPiRev == "100000d" ]; then
            #RAM = 512mb, we're good
            echo "512mb Pi, no de-optimization fix needed."
        else
        #RAM = 256mb, need to compile unoptimized
            echo "Stripping -O[1..3] from gpSP Makefile to compile unoptimized on 256mb Pi..."
            sed -i 's/-O[1..3]//g' Makefile
            sed -i 's/-Ofast//g' Makefile
        fi
    fi

    #gpSP is missing an include in the Makefile
    if [[ ! -z `grep "\-I/opt/vc/include/interface/vmcs_host/linux" Makefile` ]]; then
       echo "Skipping adding missing include to gpSP Makefile."
    else
       echo "Adding -I/opt/vc/include/interface/vmcs_host/linux to Makefile"
       sed -i '23iCFLAGS     += -I/opt/vc/include/interface/vmcs_host/linux' Makefile
    fi
    popd
}

function build_gpsp() {
    dphys-swapfile swapoff
    echo "CONF_SWAPSIZE=512" > /etc/dphys-swapfile
    dphys-swapfile setup
    dphys-swapfile swapon

    pushd "$rootdir/emulators/gpsp"
    cd raspberrypi
    make clean
    make
    cp "$rootdir/emulators/gpsp/game_config.txt" "$rootdir/emulators/gpsp/raspberrypi/"
    # TODO copy gpsp into /opt/retropie/emulators/gpsp directory
    if [[ -z `find $rootdir/emulators/gpsp/ -name "gpsp"` ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile Game Boy Advance emulator."
    fi
    popd

    dphys-swapfile swapoff
    echo "CONF_SWAPSIZE=99" > /etc/dphys-swapfile
    dphys-swapfile setup
    dphys-swapfile swapon
}

function configure_gpsp() {
    mkdir -p "$romdir/gba"
    chown $user:$user -R "$rootdir/emulators/gpsp/raspberrypi/"

    setESSystem "Game Boy Advance" "gba" "~/RetroPie/roms/gba" ".gba .GBA" "$rootdir/supplementary/runcommand/runcommand.sh 4 \"$rootdir/emulators/gpsp/raspberrypi/gpsp %ROM%\"" "gba" "gba"
}
