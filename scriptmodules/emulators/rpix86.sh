#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="rpix86"
rp_module_desc="DOS Emulator rpix86"
rp_module_menus="2+"
rp_module_flags="nobin"

function install_rpix86() {
    wget -O- -q $__archive_url/rpix86.tar.gz | tar -xvz -C "$md_inst"
    # install 4DOS.com
    wget $__archive_url/4dos.zip -O "$md_inst/4dos.zip"
    unzip -n "$md_inst/4dos.zip" -d "$md_inst"
    rm "$md_inst/4dos.zip"
}

function configure_rpix86() {
    mkRomDir "pc"

    rm -f "$romdir/pc/Start rpix86.sh" "$romdir/pc/+Start.txt"
    cat > "$romdir/pc/+Start rpix86.sh" << _EOF_
#!/bin/bash
params="\$1"
pushd "$md_inst"
./rpix86 -a0 -f2 "\$params"
popd
_EOF_
    chmod +x "$romdir/pc/+Start rpix86.sh"
    chown $user:$user "$romdir/pc/+Start rpix86.sh"
    ln -sfn "$romdir/pc" games

    addSystem 0 "$md_id" "pc" "$romdir/pc/+Start\ rpix86.sh %ROM%"
}
