rp_module_id="zmachine"
rp_module_desc="ZMachine"
rp_module_menus="2+"

function install_zmachine() {
    aptInstall frotz
    wget -U firefox http://downloads.petrockblock.com/retropiearchives/zork1.zip
    wget -U firefox http://downloads.petrockblock.com/retropiearchives/zork2.zip
    wget -U firefox http://downloads.petrockblock.com/retropiearchives/zork3.zip
    mkdir -p $romdir/zmachine/zork1
    mkdir -p $romdir/zmachine/zork2
    mkdir -p $romdir/zmachine/zork3
    unzip -n zork1.zip -d "$romdir/zmachine/zork1/"
    unzip -n zork2.zip -d "$romdir/zmachine/zork2/"
    unzip -n zork3.zip -d "$romdir/zmachine/zork3/"
    rm zork1.zip
    rm zork2.zip
    rm zork3.zip
    __INFMSGS="$__INFMSGS The text adventures Zork 1 - 3 have been installed in the directory '$romdir/zmachine/'. You can start, e.g., Zork 1 with the command 'frotz $romdir/roms/zmachine/zork1/DATA/ZORK1.DAT'."
}