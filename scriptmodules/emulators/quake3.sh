rp_module_id="quake3"
rp_module_desc="Quake 3"
rp_module_menus="2+"

function depends_quake3() {
    rps_checkNeededPackages git gcc build-essential libsdl1.2-dev
}

function sources_quake3() {
    gitPullOrClone "$md_build" git://github.com/raspberrypi/quake3.git
    sed -i "s#/opt/bcm-rootfs##g" build.sh
    sed -i "s/^CROSS_COMPILE/#CROSS_COMPILE/" build.sh
}

function build_quake3() {
    ./build.sh
}

function install_quake3() {
    md_ret_files=(
        'build/release-linux-arm/baseq3'
        'build/release-linux-arm/client'
        'build/release-linux-arm/clientsmp'
        'build/release-linux-arm/ded'
        'build/release-linux-arm/ioquake3.arm'
        'build/release-linux-arm/missionpack'
        'build/release-linux-arm/tools'
    )

    wget http://downloads.petrockblock.com/retropiearchives/Q3DemoPaks.zip
    unzip -o Q3DemoPaks.zip -d "$md_inst"
    rm Q3DemoPaks.zip

    chmod +x "$md_inst/"*.arm 
}

function configure_quake3() {
    # Add user for no sudo run
    usermod -a -G video $user

    mkdir -p "$romdir/quake3"
    mkdir -p "$romdir/ports"

    cat > "$romdir/ports/Quake III Arena.sh" << _EOF_
#!/bin/bash
LD_LIBRARY_PATH=lib "$md_instioquake3.arm"
_EOF_

    chmod +x "$romdir/ports/Quake III Arena.sh"

    setESSystem 'Ports' 'ports' '~/RetroPie/roms/ports' '.sh .SH' '%ROM%' 'pc' 'ports'    
}
