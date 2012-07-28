#!/bin/bash

#  RetroPie-Setup - Shell script for initializing Raspberry Pi 
#  with RetroArch, various cores, and EmulationStation (a graphical 
#  front end).
# 
#  (c) Copyright 2012  Florian Müller (petrockblock@gmail.com)
# 
#  RetroPie-Setup homepage: https://github.com/petrockblog/RetroPie-Setup
# 
#  Permission to use, copy, modify and distribute RetroPie-Setup in both binary and
#  source form, for non-commercial purposes, is hereby granted without fee,
#  providing that this license information and copyright notice appear with
#  all copies and any derived work.
# 
#  This software is provided 'as-is', without any express or implied
#  warranty. In no event shall the authors be held liable for any damages
#  arising from the use of this software.
# 
#  RetroPie-Setup is freeware for PERSONAL USE only. Commercial users should
#  seek permission of the copyright holders first. Commercial use includes
#  charging money for RetroPie-Setup or software derived from RetroPie-Setup.
# 
#  The copyright holders request that bug fixes and improvements to the code
#  should be forwarded to them so everyone can benefit from the modifications
#  in future versions.
# 
# Many, many thanks go to all people that provide the individual packages!!!
# 
#  Raspberry Pi is a trademark of the Raspberry Pi Foundation.
# 

function ask()
{   
    echo -e -n "$@" '[y/n] ' ; read ans
    case "$ans" in
        y*|Y*) return 0 ;;
        *) return 1 ;;
    esac
}

function addLineToFile()
{
	if [[ -f "$2" ]]; then
        cp "$2" ./temp
        sudo mv "$2" "$2.old"
    fi
    echo "$1" >> ./temp
    sudo mv ./temp "$2"
    echo "Added $1 to file $2"
}

function printMsg()
{
	echo -e "\n= = = = = = = = = = = = = = = = = = = = =\n$1\n= = = = = = = = = = = = = = = = = = = = =\n"
}

if [ $# -ne 1 ]
then
    rootdir="~/RetroPie"
else
    rootdir=$1
fi
printMsg "Installing all RetroPie-packages into the directory $rootdir"

# install latest rpi-update script (to enable firmware update)
printMsg "Installing latest rpi-update script"
sudo wget http://goo.gl/1BOfJ -O /usr/bin/rpi-update && sudo chmod +x /usr/bin/rpi-update
ask "Do you want to perform a firmware upgrade now?\nThis might take some minutes." && sudo rpi-update

# update APT repositories and update system
sudo apt-get -y update
ask "Do you want to perform a system upgrade now?\nThis might take some minutes." && sudo apt-get -y upgrade

# add user pi to groups "video", "audio", and "input"
printMsg "Adding user pi to groups video, audio, and input."
sudo usermod -a -G video pi
sudo usermod -a -G audio pi
sudo usermod -a -G input pi

# make sure ALSA, uinput, and joydev modules are active
printMsg "Enabling ALSA, uinput, and joydev modules permanently"
sudo modprobe snd_bcm2835
sudo modprobe uinput
sudo modprobe joydev

if ! grep -q "uinput" /etc/modules; then
	addLineToFile "uinput" "/etc/modules"
fi
if ! grep -q "joydev" /etc/modules; then
	addLineToFile "joydev" "/etc/modules"
fi

# needed by SDL for working joypads
printMsg "Exporting SDL_MOUSE=1 permanently to .bashrc"
export SDL_NOMOUSE=1
if [[ ! grep -Fxq "export SDL_NOMOUSE=1" ~/.bashrc ]]; then
    echo -e "\nexport SDL_NOMOUSE=1" >> ~/.bashrc
fi

# make sure that all needed packages are installed
printMsg "Making sure that all needed packaged are installed"
sudo apt-get install -y libsdl1.2-dev screen scons libasound2-dev pkg-config libgtk2.0-dev libsdl-ttf2.0-dev libboost-filesystem-dev zip libxml2

# prepare folder structure for emulator, cores, front end, and roms
if [[ ! -d $rootdir ]]; then
    mkdir $rootdir
fi
if [[ ! -d "$rootdir/roms" ]]; then
    mkdir "$rootdir/roms"
fi
if [[ ! -d "$rootdir/roms/snes" ]]; then
    mkdir "$rootdir/roms/snes"
fi
if [[ ! -d "$rootdir/roms/nes" ]]; then
    mkdir "$rootdir/roms/nes"
fi
if [[ ! -d "$rootdir/roms/megadrive" ]]; then
    mkdir "$rootdir/roms/megadrive"
fi
if [[ ! -d "$rootdir/roms/gba" ]]; then
    mkdir "$rootdir/roms/gba"
fi
if [[ ! -d "$rootdir/roms/mame" ]]; then
    mkdir "$rootdir/roms/mame"
fi
if [[ ! -d "$rootdir/roms/doom" ]]; then
    mkdir "$rootdir/roms/doom"
fi

if [[ ! -d "$rootdir/emulatorcores" ]]; then
    mkdir "$rootdir/emulatorcores"
fi

# install RetroArch emulator
printMsg "Installing RetroArch emulator"
if [[ -d "$rootdir/RetroArch-Rpi" ]]; then
	rm -rf "$rootdir/RetroArch-Rpi"
fi
git clone git://github.com/Themaister/RetroArch.git "$rootdir/RetroArch-Rpi"
pushd "$rootdir/RetroArch-Rpi"
./configure --disable-libpng
make
sudo make install
popd

# install SNES emulator core
printMsg "Installing SNES core"
if [[ -d "$rootdir/emulatorcores/pocketsnes-libretro" ]]; then
	rm -rf "$rootdir/emulatorcores/pocketsnes-libretro"
fi
git clone git://github.com/ToadKing/pocketsnes-libretro.git "$rootdir/emulatorcores/pocketsnes-libretro"
pushd "$rootdir/emulatorcores/pocketsnes-libretro"
make
popd

# install NES emulator core
printMsg "Installing NES core"
if [[ -d "$rootdir/emulatorcores/fceu-next" ]]; then
	rm -rf "$rootdir/emulatorcores/fceu-next"
fi
git clone git://github.com/libretro/fceu-next.git "$rootdir/emulatorcores/fceu-next"
pushd "$rootdir/emulatorcores/fceu-next"
make -f Makefile.libretro-fceumm
popd

# install Sega Mega Drive emulator core
printMsg "Installing Mega Drive core"
if [[ -d "$rootdir/emulatorcores/Genesis-Plus-GX" ]]; then
	rm -rf "$rootdir/emulatorcores/Genesis-Plus-GX"
fi
git clone git://github.com/libretro/Genesis-Plus-GX.git "$rootdir/emulatorcores/Genesis-Plus-GX"
pushd "$rootdir/emulatorcores/Genesis-Plus-GX"
make -f Makefile.libretro 
popd

# install Gameboy emulator core
printMsg "Installing Gameboy core"
if [[ -d "$rootdir/emulatorcores/gambatte-libretro/libgambatte" ]]; then
	rm -rf "$rootdir/emulatorcores/gambatte-libretro/libgambatte"
fi
git clone git://github.com/libretro/gambatte-libretro.git "$rootdir/emulatorcores/gambatte-libretro"
pushd "$rootdir/emulatorcores/gambatte-libretro/libgambatte"
make -f Makefile.libretro 
popd

# install MAME emulator core
printMsg "Installing MAME core"
if [[ -d "$rootdir/emulatorcores/imame4all-libretro" ]]; then
	rm -rf "$rootdir/emulatorcores/imame4all-libretro"
fi
git clone git://github.com/libretro/imame4all-libretro.git "$rootdir/emulatorcores/imame4all-libretro"
pushd "$rootdir/emulatorcores/imame4all-libretro"
make -f makefile.libretro ARM=1
popd

# install Doom WADs emulator core
printMsg "Installing Doom core"
if [[ -d "$rootdir/emulatorcores/libretro-prboom" ]]; then
	rm -rf "$rootdir/emulatorcores/libretro-prboom"
fi
git clone git://github.com/libretro/libretro-prboom.git "$rootdir/emulatorcores/libretro-prboom"
pushd "$rootdir/emulatorcores/libretro-prboom"
make
popd

# install BCM library to enable GPIO access by SNESDev-RPi
printMsg "Installing BCM2835 library"
pushd $rootdir
wget http://www.open.com.au/mikem/bcm2835/bcm2835-1.3.tar.gz
tar -zxvf bcm2835-1.3.tar.gz
cd bcm2835-1.3
./configure
make
sudo make install
cd ..
rm bcm2835-1.3.tar.gz
rm -rf bcm2835-1.3
popd 

# install SNESDev as GPIO interface for SNES controllers
printMsg "Installing SNESDev as GPIO interface for SNES controllers"
if [[ -d "$rootdir/SNESDev-Rpi" ]]; then
	rm -rf "$rootdir/SNESDev-Rpi"
fi
git clone git://github.com/petrockblog/SNESDev-RPi.git "$rootdir/SNESDev-Rpi"
pushd "$rootdir/SNESDev-Rpi"
make clean
make
popd

# install EmulationStation as graphical front end for the emulators
printMsg "Installing EmulationStation as graphical front end"
if [[ -d "$rootdir/EmulationStation" ]]; then
	rm -rf "$rootdir/EmulationStation"
fi
git clone git://github.com/Aloshi/EmulationStation.git "$rootdir/EmulationStation"
pushd "$rootdir/EmulationStation"
make clean
make
printMsg "Generating symbolic link to $rootdir/EmulationStation/emulationstation/emulationstation\n -->>\n /usr/bin/emulationstation"
sudo ln -s "$rootdir/EmulationStation/emulationstation" /usr/bin/emulationstation
popd

# generate EmulationStation configuration
printMsg "Generating configuration file ~/.es_systems.cfg for EmulationStation"
cat > ~/.es_systems.cfg << EOF
NAME=MAME
PATH=~/RetroPie/roms/mame
EXTENSION=.smd
COMMAND=retroarch -L ~/RetroPie/emulatorcores/imame4all-libretro/libretro.so %ROM%
NAME=Nintendo Entertainment System
PATH=~/RetroPie/roms/nes
EXTENSION=.nes
COMMAND=retroarch -L ~/RetroPie/emulatorcores/fceu-next/libretro.so %ROM%
NAME=Sega Mega Drive
PATH=~/RetroPie/roms/megadrive
EXTENSION=.SMD
COMMAND=retroarch -L ~/RetroPie/emulatorcores/Genesis-Plus-GX/libretro.so %ROM%
NAME=Super Nintendo
PATH=~/RetroPie/roms/snes
EXTENSION=.smc
COMMAND=retroarch -L ~/RetroPie/emulatorcores/pocketsnes-libretro/libretro.so %ROM%
NAME=Doom
PATH=~/RetroPie/roms/doom
EXTENSION=.wad
COMMAND=retroarch -L ~/RetroPie/emulatorcores/libretro-prboom/libretro.so %ROM%
NAME=Gameboy Advance
PATH=~/RetroPie/roms/gba
EXTENSION=.gba
COMMAND=retroarch -L ~/RetroPie/emulatorcores/gambatte-libretro/libgambatte/libretro.so %ROM%
EOF

echo -e "Finished compiling and installation.\nStart the front end with .emulationstation\nHave fun :-)"
echo -e "You now have to copy roms to the roms folder:\nSNES to roms/snes,\nNES to roms/nes\nGameboy Advance to roms/gba\nMAME to roms/mame\nMega Drive to roms/megadrive"
