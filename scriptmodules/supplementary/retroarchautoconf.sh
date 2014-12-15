rp_module_id="retroarchautoconf"
rp_module_desc="RetroArch-AutoConfigs"
rp_module_menus="2+"

function install_retroarchautoconf() {
    mkdir -p "$rootdir/emulators/retroarch/configs/"
    cp "$scriptdir/supplementary/RetroArchConfigs/"*.cfg "$rootdir/emulators/retroarch/configs/"
}