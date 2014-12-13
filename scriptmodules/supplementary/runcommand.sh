rp_module_id="runcommand"
rp_module_desc="Video mode script 'runcommand'"
rp_module_menus="2+"

function install_runcommand() {
    cp "$scriptdir/supplementary/runcommand.sh" "$md_inst/"
    chmod +x "$md_inst/runcommand.sh"
}