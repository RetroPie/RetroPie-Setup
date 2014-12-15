rp_module_id="sdl1"
rp_module_desc="SDL 1.2.15 with dispmanx backend"
rp_module_menus="4+"

function depends_sdl1() {
    checkNeededPackages libudev-dev libasound2-dev libdbus-1-dev libraspberrypi0 libraspberrypi-bin libraspberrypi-dev
}

function sources_sdl1() {
    gitPullOrClone "$md_build" https://github.com/vanfanel/SDL12-kms-dispmanx.git
}

function build_sdl1() {
    make clean
    ./MAC_ConfigureDISPMANX.sh
}

function install_sdl1() {
    make install
}
