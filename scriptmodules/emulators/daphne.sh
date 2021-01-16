#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="daphne"
rp_module_desc="Daphne - Laserdisc Emulator"
rp_module_help="ROM Extension: .daphne\n\nCopy your Daphne roms to $romdir/daphne and alg games to $romdir/alg"
rp_module_licence="GPL2 https://raw.githubusercontent.com/RetroPie/daphne-emu/master/COPYING"
rp_module_section="opt"
rp_module_flags=" !mali !kms"

function depends_daphne() {
        if uname -m |grep "x86_64"; then
        dpkg --add-architecture i386
        getDepends libsdl1.2-dev libsdl2-mixer-dev libglew-dev libvorbis-dev libsdl-image1.2-dev libsdl-ttf2.0-dev zlib1g-dev libxmu-dev
        else
    getDepends libsdl1.2-dev libvorbis-dev libglew-dev zlib1g-dev
    fi
}

function sources_daphne() {
        if uname -m |grep "x86_64"; then
    gitPullOrClone "$md_build" https://github.com/MrCoolSpan/Daphne.git
    else
    gitPullOrClone "$md_build" https://github.com/RetroPie/daphne-emu.git retropie
    fi
        
}


function build_daphne() {
        if uname -m |grep "x86_64"; then
        cd src/vldp2 || exit
        ./configure --disable-accel-detect
        make -f Makefile.linux_x64
        cd ../game/singe
        make -f Makefile.linux_x64
        cd ../..
        ln -s Makefile.vars.linux_x64 Makefile.vars
        make
        else
    cd src/vldp2 || exit
    ./configure
    make -f Makefile.rp
    cd ..
    ln -sf Makefile.vars.rp Makefile.vars
    make STATIC_VLDP=1
    fi
}

function install_daphne() {
        if uname -m |grep "x86_64"; then
        md_ret_files=(
        'sound'
        'pics'
        'daphne.bin'
        'singe.sh'
        'COPYING'
        'libsinge.so'
        'libvldp2.so'
    )  
        else
function install_daphne() {        
         md_ret_files=(
        'sound'
        'pics'
        'daphne.bin'
        'COPYING'
    )
    }
    fi
    }
    
        
   
       if grep -q "/opt/retropie/emulators/daphne/lib" /etc/ld.so.conf.d/randomLibs.conf; then
               :
        else
         echo '/opt/retropie/emulators/daphne/lib' > /etc/ld.so.conf.d/randomLibs.conf
       fi
       
# Mayflash Sensor DolphinBar
      FILE=/etc/udev/rules.d/80-dolphinbar.rule
      if [ -f "$FILE" ]; then
      :
      else 
      cat >"/etc/udev/rules.d/80-dolphinbar.rule" <<_EOF_
      SUBSYSTEM=="hidraw", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="0306", MODE="0666"
      SUBSYSTEM=="hidraw*", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="0330", MODE="0666"
_EOF_

      fi

ldconfig

      
   

function configure_daphne() {
    mkRomDir "daphne"
    mkRomDir "alg"
    mkRomDir "daphne/roms"
    mkRomDir "alg/roms"
    mkRomDir "actionmax"
    mkRomDir "actionmax/roms"
    
    mkUserDir "$md_conf_root/daphne"
    mkUserDir "$md_conf_root/alg"
    mkUserDir "$md_conf_root/actionmax"    

    if [[ ! -f "$md_conf_root/daphne/dapinput.ini" ]]; then
        cp -v "$md_data/dapinput.ini" "$md_conf_root/daphne/dapinput.ini"
    fi
   if [[ ! -f "$romdir/alg/roms/ActionMax" ]]; then
        cp -r "$md_data/ActionMax" "$romdir/alg/roms/ActionMax"
    fi
    if [[ ! -f "$romdir/alg/roms/Framework.singe" ]]; then
        cp -r "$md_data/ActionMax" "$romdir/alg/roms/Framework.singe"
    fi
    ln -snf "$romdir/daphne/roms" "$md_inst/roms"
    ln -snf "$romdir/alg/roms" "$md_inst/singe" 
    ln -sf "$md_conf_root/$md_id/dapinput.ini" "$md_inst/dapinput.ini"
      
echo '
#!/bin/bash
mkdir ~/RetroPie/roms/alg/tmp
ln -s ~/RetroPie/roms/alg/roms/* ~/RetroPie/roms/alg/tmp/ && ls -l ~/RetroPie/roms/alg/tmp/
cd tmp
for i in *; do mv "$i" "$i".daphne; done
mv *.* ~/RetroPie/roms/alg
rm -r ~/RetroPie/roms/alg/tmp
rm -r ~/RetroPie/roms/alg/Framework.singe.daphne
rm -r ~/RetroPie/roms/alg/ActionMax.daphne' > "$romdir/alg/symlink.sh"

echo '
#!/bin/bash
mkdir ~/RetroPie/roms/actionmax/tmp
ln -s ~/RetroPie/roms/actionmax/roms/* ~/RetroPie/roms/actionmax/tmp/ && ls -l ~/RetroPie/roms/actionmax/tmp/
cd tmp
for i in *; do mv "$i" "$i".daphne; done
mv *.* ~/RetroPie/roms/actionmax
rm -r ~/RetroPie/roms/actionmax/tmp' > "$romdir/actionmax/symlink.sh"


    cat >"$md_inst/daphne.sh" <<_EOF_
#!/bin/bash
# point to our linked libs that user may not have
export LD_LIBRARY_PATH=$SCRIPT_DIR:$DAPHNE_SHARE:$LD_LIBRARY_PATH
dir="\$1"
name="\${dir##*/}"
name="\${name%.*}"

if [[ -f "\$dir/\$name.commands" ]]; then
    params=\$(<"\$dir/\$name.commands")
fi

"$md_inst/daphne.bin" "\$name" vldp -nohwaccel -framefile "\$dir/\$name.txt" -homedir "$md_inst" -fullscreen \$params

xrandr --output "HDMI-0" --mode 1920x1080
_EOF_
   
echo '
#!/bin/bash
# point to our linked libs that user may not have
export LD_LIBRARY_PATH=$SCRIPT_DIR:$DAPHNE_SHARE:$LD_LIBRARY_PATH

SCRIPT_DIR=`dirname "$0"`
if realpath / >/dev/null; then SCRIPT_DIR=$(realpath "$SCRIPT_DIR"); fi
DAPHNE_BIN=daphne.bin
DAPHNE_SHARE=/opt/retropie/emulators/daphne

function STDERR () {
	/bin/cat - 1>&2
}

echo "Singe Launcher : Script dir is $SCRIPT_DIR"
cd "$SCRIPT_DIR"

dir="$1"
name="${dir##*/}"
name="${name%.*}"

"/opt/retropie/emulators/daphne/daphne.bin" singe vldp -FULLSCREEN -framefile "$dir/$name.txt" -script "$dir/$name.singe" -homedir "$DAPHNE_SHARE" -datadir "$DAPHNE_SHARE" -sound_buffer 2048 -noserversend -x 800 -y 600

xrandr --output "HDMI-0" --mode 1920x1080' > "$md_inst/singe.sh"


    chmod +x "$md_inst/daphne.sh"
    chmod +x "$md_inst/singe.sh"
    chmod +x "$romdir/alg/symlink.sh"
    chmod +x "$romdir/actionmax/symlink.sh"

    chown -R "$user":"$user" "$md_inst"
    chown -R "$user":"$user" "$md_conf_root/daphne/dapinput.ini"
    chown -R "$user":"$user" "$romdir/alg/"

    addEmulator 1 "$md_id" "daphne" "$md_inst/daphne.sh %ROM%"
    addSystem "daphne"
    addEmulator 1 "$md_id" "alg" "$md_inst/singe.sh %ROM%"
    addSystem "alg"
    addEmulator 1 "$md_id" "actionmax" "$md_inst/singe.sh %ROM%"
    addSystem "actionmax"    
}


