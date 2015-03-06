rp_module_id="bluezps3"
rp_module_desc="Pair PS3 bluetooth controller (BLUEZ)"
rp_module_menus="4+"
rp_module_flags="nobin"

function configure_bluezps3() {  
  printMsgs "dialog" "Please connect your PS3 controller via USB-CABLE, press PS button and ENTER."
  # wait 5 seconds so bluez has enough to create directories
  sleep 5
  for file in $(grep -l "Name=PLAYSTATION(R)3 Controller" /var/lib/bluetooth/*/*/info); do
    sed -i "s/Trusted=false/Trusted=true/g" $file
  done
  
  printMsgs "dialog" "Please restart."
  /etc/init.d/bluetooth restart
}
