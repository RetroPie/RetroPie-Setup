rp_module_id="zmachine"
rp_module_desc="ZMachine"
rp_module_menus="2+"

function install_zmachine() {
    aptInstall frotz

    mkRomDir "zmachine"
    local i
    for i in 1 2 3; do
        wget http://downloads.petrockblock.com/retropiearchives/zork$i.zip
        unzip -n zork$i.zip -d "$romdir/zmachine/zork$i"
        rm zork$i.zip
    done
    chown -R $user:$user "$romdir/zmachine/"*
    __INFMSGS="$__INFMSGS The text adventures Zork 1 - 3 have been installed in the directory '$romdir/zmachine/'. You can start, e.g., Zork 1 with the command 'frotz $romdir/zmachine/zork1/DATA/ZORK1.DAT'."
}