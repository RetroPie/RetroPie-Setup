rp_module_id="bluez"
rp_module_desc="Install (PS3) bluetooth controller driver (BLUEZ)"
rp_module_menus="4+"
rp_module_flags="nobin"

function depends_bluez() { 
  getDepends libusb-dev libdbus-1-dev libglib2.0-dev libusb-dev libdbus-1-dev libglib2.0-dev automake libudev-dev libical-dev libreadline-dev
}  

function sources_bluez() {
  wget https://www.kernel.org/pub/linux/bluetooth/bluez-5.27.tar.xz
  tar xJvf bluez-5.27.tar.xz
  cd bluez-5.27
}

function build_bluez() {
  cd bluez-5.27
  ./configure --prefix=/usr --mandir=/usr/share/man --sysconfdir=/etc --localstatedir=/var --disable-systemd --enable-sixaxis
  make
    
  sudo apt-get remove -y --purge bluez
  sudo make install
  sudo install -v -dm755 /etc/bluetooth
  sudo install -v -m644 src/main.conf /etc/bluetooth/main.conf
}

function configure_bluez() {
  cp "$scriptdir/supplementary/bluetooth" "/etc/init.d/"
  chmod +x "/etc/init.d/bluetooth"

  update-rc.d bluetooth defaults

  cat > /etc/udev/rules.d/10-local.rules << _EOF_  
# Set bluetooth power up
ACTION=="add", KERNEL=="hci0", RUN+="/usr/bin/hciconfig hci0 up"
_EOF_
    
  /etc/init.d/bluetooth start
  
  cmd=(dialog --backtitle "$__backtitle" --menu "Choose the desired hotkey behaviour." 22 76 16)
  options=(1 "Set PS3 controller as trusted.")
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choices" ]]; then
        case $choices in
            1) dialog --backtitle "$__backtitle" --msgbox "Instructions:
              1. Connect PS3 controller with a usb cable.
              2. Type <agent on>.
              3. Type <default-agent>.
              4. Press PS button on your controller.
              5. Type <yes> if asked to.
              6. Type <exit>." 22 76
                bluetoothctl
                            ;;
        esac
    fi
}
