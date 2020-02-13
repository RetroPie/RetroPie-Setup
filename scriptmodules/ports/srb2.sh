#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="srb2"
rp_module_desc="Sonic Robo Blast 2 - 3D Sonic the Hedgehog fan-game built using a modified version of the Doom Legacy source port of Doom"
rp_module_licence="GPL2 https://raw.githubusercontent.com/STJr/SRB2/master/LICENSE"
rp_module_section="exp"

function depends_srb2() {
    local depends=(cmake libsdl2-dev libsdl2-mixer-dev libgme-dev)
    compareVersions "$__os_debian_ver" gt 9 && depends+=(libopenmpt-dev)
    getDepends "${depends[@]}"
}

function sources_srb2() {
    gitPullOrClone "$md_build" https://github.com/STJr/SRB2.git
    downloadAndExtract "$__archive_url/srb2-assets.tar.gz" "$md_build"
}

function build_srb2() {
    mkdir build
    cd build

    # Disable OpenMPT on Debian Stretch and old, its version is too old
    local extra
    compareVersions "$__os_debian_ver" lt 10 && extra="-DSRB2_CONFIG_HAVE_OPENMPT=Off"
    cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$md_inst" $extra
    make
    md_ret_require="$md_build/build/bin/lsdlsrb2"
}

function install_srb2() {
    # copy and dereference, so we get a srb2 binary rather than a symlink to lsdlsrb2-version
    cp -L 'build/bin/lsdlsrb2' "$md_inst/srb2"
    md_ret_files=(
        'assets/installer/music.dta'
        'assets/installer/player.dta'
        'assets/installer/zones.pk3'
        'assets/installer/srb2.pk3'
        'assets/README.txt'
        'assets/LICENSE.txt'
    )
}

function configure_srb2() {
    addPort "$md_id" "srb2" "Sonic Robo Blast 2" "pushd $md_inst; ./srb2; popd"

    moveConfigDir "$home/.srb2"  "$md_conf_root/$md_id"
}
