#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="rpix86"
rp_module_desc="DOS Emulator rpix86"
rp_module_menus="2+"
rp_module_flags="nobin"

function install_rpix86() {
    wget -O- -q http://downloads.petrockblock.com/retropiearchives/rpix86.tar.gz | tar -xvz -C "$md_inst"
    # install 4DOS.com
    wget http://downloads.petrockblock.com/retropiearchives/4dos.zip -O "$md_inst/4dos.zip"
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
if [[ "\$params" =~ \.sh$ ]]; then
    ./rpix86 -a0 -f2
else
    ./rpix86 -a0 -f2 "\$params"
fi
popd
_EOF_
    chmod +x "$romdir/pc/+Start rpix86.sh"
    chown $user:$user "$romdir/pc/+Start rpix86.sh"
    ln -sfn "$romdir/pc" games

    # slight hack so that we set rpix86 as the default emulator for "+Start rpix86.sh"
    iniConfig "=" '"' "$configdir/all/emulators.cfg"
    iniSet "ab8b60b52cfe22d5b794c1aef1b0062b7" "rpix86"
    chown $user:$user "$configdir/all/emulators.cfg"
    addSystem 0 "$md_id" "pc" "$romdir/pc/+Start\ rpix86.sh %ROM%" "" ".sh"
}
