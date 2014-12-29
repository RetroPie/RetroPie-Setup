rp_module_id="rpix86"
rp_module_desc="DOS Emulator rpix86"
rp_module_menus="2+"

function install_rpix86() {
    wget -O- -q http://downloads.petrockblock.com/retropiearchives/rpix86.tar.gz | tar -xvz -C "$md_inst"
    # install 4DOS.com
    unzip -n $scriptdir/supplementary/4dos.zip -d "$md_inst"
}

function configure_rpix86() {
    mkRomDir "pc"

    cat > "$md_inst/Start.sh" << _EOF_
#!/bin/bash
pushd "$md_inst"
./rpix86 -a0 -f2
popd
_EOF_
    chmod +x "$md_inst/Start.sh"

    ln -s $romdir/pc games
    touch $romdir/pc/Start.txt

    setESSystem "PC (x86)" "pc" "~/RetroPie/roms/pc" ".txt" "$rootdir/supplementary/runcommand/runcommand.sh 0 \"$md_inst/Start.sh\" \"$md_id\"" "pc" "pc"
}