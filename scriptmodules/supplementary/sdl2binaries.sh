rp_module_id="sdl2binaries"
rp_module_desc="Install SDL 2.0.1 binaries"
rp_module_menus=""

function install_sdl2binaries() {
    wget http://downloads.petrockblock.com/retropiearchives/libsdl2-dev_2.0.3_armhf.deb
    wget http://downloads.petrockblock.com/retropiearchives/libsdl2_2.0.3_armhf.deb
    if ! dpkg -i libsdl2*.deb; then
        apt-get -f install
    fi
    rm *.deb
}