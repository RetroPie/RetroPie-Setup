rp_module_id="retroarchautoconf"
rp_module_desc="RetroArch-AutoConfigs"
rp_module_menus="2+"

function install_retroarchautoconf() {
    if [[ ! -d "$rootdir/emulators/RetroArch/configs/" ]]; then
        mkdir -p "$rootdir/emulators/RetroArch/configs/"
    fi
    cp $scriptdir/supplementary/RetroArchConfigs/*.cfg "$rootdir/emulators/RetroArch/configs/"
}