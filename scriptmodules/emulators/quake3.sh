rp_module_id="quake3"
rp_module_desc="Quake 3"
rp_module_menus="2+"

function depen_quake3() {
    rps_checkNeededPackages git gcc build-essential libsdl1.2-dev
}

function sources_quake3() {
    rmDirExists "$rootdir/emulators/quake3src"
    gitPullOrClone "$rootdir/emulators/quake3src" git://github.com/raspberrypi/quake3.git
    mkdir -p "$rootdir/emulators"
    pushd "$rootdir/emulators/quake3src"
    rm build.sh
    wget "http://downloads.petrockblock.com/retropiearchives/buildQuake3.sh"
    mv buildQuake3.sh build.sh
    chmod +x build.sh
    popd
}

function build_quake3() {
    pushd "$rootdir/emulators/quake3src"

    ./build.sh

    # Add user for no sudo run
    usermod -a -G video $user

    # Move the build files to $rootdir/emulators/quake3/
    mkdir -p "$rootdir/emulators/quake3"
    mv "$rootdir/emulators/quake3src/build/release-linux-arm/*" "$rootdir/emulators/quake3/"

    # Delete the build directory
    rm -r "$rootdir/emulators/quake3src/"

    popd
}

function install_quake3() {
    # Get the demo paks and unzip
    cd "$rootdir/emulators/quake3/baseq3"
    wget http://downloads.petrockblock.com/retropiearchives/Q3DemoPaks.zip
    mv Q3DemoPaks.zip Q3pak.zip
    unzip Q3pak.zip -d "$rootdir/emulators/quake3/"
    rm "$rootdir/emulators/quake3/baseq3/Q3pak.zip"

    # Apply chmod to the files
    cd "$rootdir/emulators/quake3"
    chmod +x "$rootdir/emulators/quake3/ioq3ded.arm"
    chmod +x "$rootdir/emulators/quake3/ioquake3.arm"
}

function configure_quake3() {
    mkdir -p "$romdir/quake3"

    cat > "$romdir/ports/Quake III Arena.sh" << _EOF_
#!/bin/bash
LD_LIBRARY_PATH=lib /opt/retropie/emulators/quake3/ioquake3.arm
_EOF_

    chmod +x "$romdir/ports/Quake III Arena.sh"

    setESSystem 'Ports' 'ports' '~/RetroPie/roms/ports' '.sh .SH' '%ROM%' 'pc' 'ports'    
}
