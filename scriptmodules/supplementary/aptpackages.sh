rp_module_id="aptpackages"
rp_module_desc="Update APT packages"
rp_module_menus="2+"

function install_aptpackages() {
    apt-get autoremove
    aptUpdate
    apt-get -y upgrade
}
