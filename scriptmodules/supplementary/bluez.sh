rp_module_id="bluez"
rp_module_desc="Install (PS3) bluetooth controller driver (BLUEZ)"
rp_module_menus="4+"
rp_module_flags="nobin"

function depends_bluez() {
    getDepends libusb-dev libdbus-1-dev libglib2.0-dev libusb-dev libdbus-1-dev libglib2.0-dev automake libudev-dev libical-dev libreadline-dev
}

function sources_bluez() {
    wget https://www.kernel.org/pub/linux/bluetooth/bluez-5.29.tar.xz
    tar xJvf bluez-5.29.tar.xz
    cd bluez-5.29
}

function build_bluez() {
    cd bluez-5.29
    ./configure --prefix=/usr --mandir=/usr/share/man --sysconfdir=/etc --localstatedir=/var --disable-systemd --enable-sixaxis
    make
    # Sixad might be installed from a previous RetroPie installation
    if hasPackage sixad; then 
        SIXAD="sixad"
    fi

    sudo apt-get remove -y --purge bluez $SIXAD
    if [[ -n $SIXAD ]]; then
        # Sometimes the services don't get removed by apt-get
        update-rc.d sixad remove
    fi
    sudo make install
    sudo install -v -dm755 /etc/bluetooth
    sudo install -v -m644 src/main.conf /etc/bluetooth/main.conf
    sudo install -v -m644 profiles/input/input.conf /etc/bluetooth/input.conf
}

function configure_bluez() {
    cp "$scriptdir/supplementary/bluetooth" "/etc/init.d/"
    chmod +x "/etc/init.d/bluetooth"

    update-rc.d bluetooth defaults

    cat > /etc/udev/rules.d/10-local.rules << _EOF_  
# Set bluetooth power up
ACTION=="add", KERNEL=="hci0", RUN+="/usr/bin/hciconfig hci0 up pscan"
_EOF_

    /etc/init.d/bluetooth start

    rp_callModule bluezps3
}
