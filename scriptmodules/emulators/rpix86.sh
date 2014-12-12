rp_module_id="rpix86"
rp_module_desc="DOS Emulator rpix86"
rp_module_menus="2+"

function install_rpix86() {
    wget -O- -q http://downloads.petrockblock.com/retropiearchives/rpix86.tar.gz | tar -xvz -C "$emudir/$1"
    # install 4DOS.com
    unzip -n $scriptdir/supplementary/4dos.zip -d "$emudir/$1"
}

function configure_rpix86() {
    mkdir -p "$romdir/pc"

    cat > "$emudir/$1/Start.sh" << _EOF_
#!/bin/bash
pushd "$emudir/$1"
./rpix86 -a0 -f2
popd
_EOF_
    chmod +x "$emudir/$1/Start.sh"

    ln -s $romdir/pc games
    touch $romdir/pc/Start.txt

    setESSystem "PC (x86)" "pc" "~/RetroPie/roms/pc" ".txt" "$emudir/$1/Start.sh" "pc" "pc"    
}