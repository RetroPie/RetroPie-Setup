rp_module_id="sdl2binaries"
rp_module_desc="Install SDL 2.0.1 binaries"
rp_module_menus="2-"

function depends_sdl2binaries() {
    checkNeededPackages libudev-dev libasound2-dev libdbus-1-dev libraspberrypi0 libraspberrypi-bin libraspberrypi-dev
}

function install_sdl2binaries() {
    wget -O- -q http://downloads.petrockblock.com/retropiearchives/libsdl2.0.1.tar.gz | tar -xvz -C /
}