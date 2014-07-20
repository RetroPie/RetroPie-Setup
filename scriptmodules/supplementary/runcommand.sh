rp_module_id="runcommand"
rp_module_desc="Video mode script 'runcommand'"
rp_module_menus="2+"

function install_runcommand() {
    mkdir -p "$rootdir/supplementary/runcommand/"
    cp $scriptdir/supplementary/runcommand.sh "$rootdir/supplementary/runcommand/"
    chmod +x "$rootdir/supplementary/runcommand/runcommand.sh"
}