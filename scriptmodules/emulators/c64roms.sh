rp_module_id="c64roms"
rp_module_desc="C64 ROMs"
rp_module_menus="2+"

function install_c64roms() {
    wget http://www.zimmers.net/anonftp/pub/cbm/crossplatform/emulators/VICE/old/vice-1.5-roms.tar.gz
    tar -xvzf vice-1.5-roms.tar.gz
    mkdir -p "$rootdir/emulators/vice-2.3.dfsg/installdir/lib/vice/"
    cp -a vice-1.5-roms/data/* "$rootdir/emulators/vice-2.3.dfsg/installdir/lib/vice/"
    rm -rf vice-1.5-roms
    rm -rf vice-1.5-roms.tar.gz
}