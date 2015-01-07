rp_module_id="sdl2binaries"
rp_module_desc="Install SDL 2.0.1 binaries"
rp_module_menus=""
rp_module_flags="nobindist"

function install_sdl2binaries() {
    wget http://downloads.petrockblock.com/retropiearchives/libsdl2-dev_2.0.3_armhf.deb
    wget http://downloads.petrockblock.com/retropiearchives/libsdl2_2.0.3_armhf.deb
    remove_old_sdl2
    # if the packages don't install completely due to missing dependencies the apt-get -y -f install will correct it
    if ! dpkg -i libsdl2_2.0.3_armhf.deb libsdl2-dev_2.0.3_armhf.deb; then
        apt-get -y -f install
    fi
    rm *.deb
}