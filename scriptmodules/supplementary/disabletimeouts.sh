rp_module_id="disabletimeouts"
rp_module_desc="Disable system timeouts"
rp_module_menus="2+"
rp_module_flags="nobin"

function install_disabletimeouts() {
    sed -i 's/BLANK_TIME=30/BLANK_TIME=0/g' /etc/kbd/config
    sed -i 's/POWERDOWN_TIME=30/POWERDOWN_TIME=0/g' /etc/kbd/config
}
