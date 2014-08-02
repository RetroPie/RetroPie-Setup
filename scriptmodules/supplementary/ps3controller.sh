rp_module_id="ps3controller"
rp_module_desc="Install PS3 controller driver"
rp_module_menus="3+"

function install_ps3controller() {
    rps_checkNeededPackages bluez-utils bluez-compat bluez-hcidump checkinstall libusb-dev libbluetooth-dev joystick
    apt-get remove -y cups
    apt-get autoremove -y
    dialog --backtitle "$__backtitle" --msgbox "Please make sure that your Bluetooth dongle is connected to the Raspberry Pi and press ENTER." 22 76
    if [[ -z `hciconfig | grep BR/EDR` ]]; then
        dialog --backtitle "$__backtitle" --msgbox "Cannot find the Bluetooth dongle. Please try to (re-)connect it and try again." 22 76
        break
     fi

    wget http://www.pabr.org/sixlinux/sixpair.c
    mkdir -p $rootdir/supplementary/sixpair/
    mv sixpair.c $rootdir/supplementary/sixpair/
    pushd $rootdir/supplementary/sixpair/
    gcc -o sixpair sixpair.c -lusb
    dialog --backtitle "$__backtitle" --msgbox "Please connect your PS3 controller via USB-CABLE and press ENTER." 22 76
    if [[ -z `./sixpair | grep "Setting master"` ]]; then
        dialog --backtitle "$__backtitle" --msgbox "Cannot find the PS3 controller via USB-connection. Please try to (re-)connect it and try again." 22 76
        break
    fi
    popd

    pushd $rootdir/supplementary/
    wget -O QtSixA.tar.gz http://sourceforge.net/projects/qtsixa/files/QtSixA%201.5.1/QtSixA-1.5.1-src.tar.gz
    tar xfvz QtSixA.tar.gz
    cd QtSixA-1.5.1/sixad
    make CXX="g++-4.6"
    mkdir -p /var/lib/sixad/profiles
    checkinstall -y
    update-rc.d sixad defaults
    rm QtSixA.tar.gz
    popd

    dialog --backtitle "$__backtitle" --msgbox "The driver and configuration tools for connecting PS3 controllers have been installed. Please visit https://github.com/petrockblog/RetroPie-Setup/wiki/Setting-up-a-PS3-controller for further information." 22 76
}