rp_module_id="setavoidsafemode"
rp_module_desc="Set avoid_safe_mode"
rp_module_menus="2+"

function install_setavoidsafemode() {
    iniConfig "=" "" "/boot/config.txt"
    iniSet "avoid_safe_mode" 1
}