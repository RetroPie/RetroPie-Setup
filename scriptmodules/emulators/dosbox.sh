rp_module_id="dosbox"
rp_module_desc="DOS Emulator Dosbox"
rp_module_menus="2+"

function install_dosbox() {
    aptInstall dosbox
}

function configure_dosbox() {
    mkdir -p "$romdir/pc"

    setESSystem "PC (x86)" "pc" "~/RetroPie/roms/pc" ".txt" "$md_inst/rpix86/Start.sh" "pc" "pc"    

}