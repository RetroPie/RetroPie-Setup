rp_module_id="libsdlbinaries"
rp_module_desc="Install SDL 2.0.1 binaries"
rp_module_menus="2-"

function install_libsdlbinaries() {
    rps_checkNeededPackages libudev-dev libasound2-dev libdbus-1-dev libraspberrypi0 libraspberrypi-bin libraspberrypi-dev

    wget -O libsdlbinaries.tar.gz http://downloads.petrockblock.com/libsdl2.0.1.tar.gz
    tar xvfz libsdlbinaries.tar.gz
    rm libsdlbinaries.tar.gz
    cp libsdl2.0.1/* /usr/local/lib/
    rm -rf libsdl2.0.1/
}