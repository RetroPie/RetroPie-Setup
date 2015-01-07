rp_module_id="ps3controller"
rp_module_desc="Install PS3 controller driver"
rp_module_menus="3+"
rp_module_flags="nobindist"

function depends_ps3controller() {
    checkNeededPackages bluez-utils bluez-compat bluez-hcidump checkinstall libusb-dev libbluetooth-dev joystick
}

function sources_ps3controller() {
    wget -nv http://www.pabr.org/sixlinux/sixpair.c -O "$md_build/sixpair.c"
    wget -O- -q http://sourceforge.net/projects/qtsixa/files/QtSixA%201.5.1/QtSixA-1.5.1-src.tar.gz | tar -xvz --strip-components=1
}

function build_ps3controller() {
    gcc -o sixpair sixpair.c -lusb
    cd sixad
    make clean
    make CXX="g++-4.6"
}

function install_ps3controller() {
    cd sixad
    checkinstall -y --fstrans=no
    update-rc.d sixad defaults

    md_ret_files=(
        'sixpair'
    )
}

function configure_ps3controller() {
    dialog --backtitle "$__backtitle" --msgbox "Please make sure that your Bluetooth dongle is connected to the Raspberry Pi and press ENTER." 22 76
    if [[ -z `hciconfig | grep BR/EDR` ]]; then
        dialog --backtitle "$__backtitle" --msgbox "Cannot find the Bluetooth dongle. Please try to (re-)connect it and try again." 22 76
        break
    fi

    dialog --backtitle "$__backtitle" --msgbox "Please connect your PS3 controller via USB-CABLE and press ENTER." 22 76
    if [[ -z `./sixpair | grep "Setting master"` ]]; then
        dialog --backtitle "$__backtitle" --msgbox "Cannot find the PS3 controller via USB-connection. Please try to (re-)connect it and try again." 22 76
        break
    fi

    dialog --backtitle "$__backtitle" --msgbox "The driver and configuration tools for connecting PS3 controllers have been installed. Please visit https://github.com/petrockblog/RetroPie-Setup/wiki/Setting-up-a-PS3-controller for further information." 22 76
}