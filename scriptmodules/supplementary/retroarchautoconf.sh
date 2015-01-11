rp_module_id="retroarchautoconf"
rp_module_desc="RetroArch-AutoConfigs"
rp_module_menus="2+"
rp_module_flags="nobin"

function install_retroarchautoconf() {
    mkdir -p "$emudir/retroarch/configs/"
    cp "$scriptdir/supplementary/RetroArchConfigs/"*.cfg "$emudir/retroarch/configs/"
}
