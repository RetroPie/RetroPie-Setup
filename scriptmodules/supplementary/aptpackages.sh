rp_module_id="aptpackages"
rp_module_desc="Update APT packages"
rp_module_menus="2+"
rp_module_flags="nobin"

function install_aptpackages() {
    apt-get -y autoremove
    aptUpdate
    apt-get -y upgrade
}
