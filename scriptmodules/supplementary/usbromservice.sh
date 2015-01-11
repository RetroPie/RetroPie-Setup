rp_module_id="usbromservice"
rp_module_desc="USB ROM Service"
rp_module_menus="3+"
rp_module_flags="nobin"

function install_usbromservice() {
    # install usbmount package
    getDepends usbmount
}

function configure_usbromservice() {
    # install hook in usbmount sub-directory
    cp $scriptdir/supplementary/01_retropie_copyroms /etc/usbmount/mount.d/
    sed -i -e "s/USERTOBECHOSEN/$user/g" /etc/usbmount/mount.d/01_retropie_copyroms
    chmod +x /etc/usbmount/mount.d/01_retropie_copyroms
}
