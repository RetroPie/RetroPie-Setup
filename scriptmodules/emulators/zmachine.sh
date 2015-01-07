rp_module_id="zmachine"
rp_module_desc="ZMachine"
rp_module_menus="2+"
rp_module_flags="nobin"

function install_zmachine() {
    aptInstall frotz

    mkRomDir "zmachine"
    local file
    for file in zork1 zork2 zork3; do
        wget http://downloads.petrockblock.com/retropiearchives/$file.zip
        unzip -n $file.zip -d "$romdir/zmachine/$file"
        rm $file.zip
    done
    chown -R $user:$user "$romdir/zmachine/"*
    __INFMSGS="$__INFMSGS The text adventures Zork 1 - 3 have been installed in the directory '$romdir/zmachine/'. You can start, e.g., Zork 1 with the command 'frotz $romdir/zmachine/zork1/DATA/ZORK1.DAT'."
}