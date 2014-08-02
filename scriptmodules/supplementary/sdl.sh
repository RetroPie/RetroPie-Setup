rp_module_id="sdl1"
rp_module_desc="SDL 1.2.15 with dispmanx backend"
rp_module_menus="2+"

function depen_sdl() {
    rps_checkNeededPackages libudev-dev libasound2-dev libdbus-1-dev libraspberrypi0 libraspberrypi-bin libraspberrypi-dev
}

function sources_sdl() {
    gitPullOrClone "$rootdir/supplementary/SDL12-kms-dispmanx" https://github.com/vanfanel/SDL12-kms-dispmanx.git || return 1
}

function build_sdl() {
    pushd "$rootdir/supplementary/SDL12-kms-dispmanx" || return 1
    ./MAC_ConfigureDISPMANX.sh || return 1
    make || return 1
    popd || return 1
}

function install_sdl() {
    pushd "$rootdir/supplementary/SDL12-kms-dispmanx" || return 1
    make install || return 1
    popd || return 1
}
