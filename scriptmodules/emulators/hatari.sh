rp_module_id="hatari"
rp_module_desc="Atari emulator Hatari"
rp_module_menus="2+"
rp_module_flags="dispmanx nobindist"

function install_hatari() {
    aptInstall hatari
}

function configure_hatari() {
    mkdir -p $romdir/atariststefalcon 

    setESSystem "Atari ST/STE/Falcon" "atariststefalcon" "~/RetroPie/roms/atariststefalcon" ".st .ST .img .IMG .rom .ROM .ipf .IPF" "$rootdir/supplementary/runcommand/runcommand.sh 1 \"hatari %ROM%\" \"$md_id\"" "atarist" "atarist"
}