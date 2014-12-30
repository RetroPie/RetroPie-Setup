rp_module_id="rpix86"
rp_module_desc="DOS Emulator rpix86"
rp_module_menus="2+"

function install_rpix86() {
    wget -O- -q http://downloads.petrockblock.com/retropiearchives/rpix86.tar.gz | tar -xvz -C "$md_inst"
    # install 4DOS.com
    wget http://downloads.petrockblock.com/retropiearchives/4dos.zip -O "$md_inst/4dos.zip"
    unzip -n "$md_inst/4dos.zip" -d "$md_inst"
    rm "$md_inst/4dos.zip"
}

function configure_rpix86() {
    mkRomDir "pc"

    cat > "$romdir/pc/Start rpix86.sh" << _EOF_
#!/bin/bash
pushd "$md_inst"
./rpix86 -a0 -f2
popd
_EOF_
    chmod +x "$romdir/pc/Start rpix86.sh"
    ln -sfn "$romdir/pc" games
    rm -f "$romdir/pc/Start.txt"

    setESSystem "PC (x86)" "pc" "~/RetroPie/roms/pc" ".sh" "$rootdir/supplementary/runcommand/runcommand.sh 0 \"%ROM%\" \"$md_id\"" "pc" "pc"
}