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

# install latest rpi-update script (to enable firmware update)
sudo wget http://goo.gl/1BOfJ -O /usr/bin/rpi-update && sudo chmod +x /usr/bin/rpi-update
ask "Do you want to perform a firmware upgrade now?\nThis might take some time." && sudo rpi-update

# update APT repositories and update system
sudo apt-get -y update
ask "Do you want to perform a system upgrade now?\nThis might take some time." && sudo apt-get -y upgrade

# add user pi to groups "video", "audio", and "input"
echo -e "Adding user pi to groups video, audio, and input."
sudo usermod -a -G video pi
sudo usermod -a -G audio pi
sudo usermod -a -G input pi

# make sure ALSA, uinput, and joydev modules are active
echo "Enabling ALSA, uinput, and joydev modules permanently"
sudo modprobe snd_bcm2835
sudo modprobe uinput
sudo modprobe joydev

cp /etc/modules ./temp
sudo mv /etc/modules /etc/modules.old
sudo echo -e "uinput\njoydev" >> ./temp
sudo mv ./temp /etc/modules

# needed by SDL for working joypads
echo "Exporting SDL_MOUSE=1 permanently to .bashrc"
export SDL_NOMOUSE=1
cd
echo -e "\nexport SDL_NOMOUSE=1" >> .bashrc

# make sure that all needed packages are installed
sudo apt-get install -y libsdl1.2-dev screen scons libasound2-dev pkg-config libgtk2.0-dev libsdl-ttf2.0-dev libboost-filesystem-dev zip libxml2

# prepare folder structure for emulator, cores, front end, and roms
rootdir=RetroPie
cd
mkdir $rootdir
mkdir "$rootdir/roms"
mkdir "$rootdir/roms/snes"
mkdir "$rootdir/roms/nes"
mkdir "$rootdir/roms/megadrive"
mkdir "$rootdir/roms/gba"
mkdir "$rootdir/roms/mame"
mkdir "$rootdir/roms/doom"

mkdir "$rootdir/emulatorcores"

# install RetroArch emulator
echo "Installing RetroArch emulator"
cd
git clone git://github.com/Themaister/RetroArch.git "$rootdir/RetroArch-Rpi"
cd "$rootdir/RetroArch-Rpi"
./configure --disable-libpng
make
sudo make install

# install SNES emulator core
echo "Installing SNES core"
cd
git clone git://github.com/ToadKing/pocketsnes-libretro.git "$rootdir/emulatorcores/pocketsnes-libretro"
cd "$rootdir/emulatorcores/pocketsnes-libretro"
make

# install NES emulator core
echo "Installing NES core"
cd
git clone git://github.com/libretro/fceu-next.git "$rootdir/emulatorcores/fceu-next"
cd "$rootdir/emulatorcores/fceu-next"
make -f Makefile.libretro-fceumm

# install Sega Mega Drive emulator core
echo "Installing Mega Drive core"
cd
git clone git://github.com/libretro/Genesis-Plus-GX.git "$rootdir/emulatorcores/Genesis-Plus-GX"
cd "$rootdir/emulatorcores/Genesis-Plus-GX"
make -f Makefile.libretro 

# install Gameboy emulator core
echo "Installing Gameboy core"
cd
git clone git://github.com/libretro/gambatte-libretro.git "$rootdir/emulatorcores/gambatte-libretro"
cd $rootdir/emulatorcores/gambatte-libretro/libgambatte
make -f Makefile.libretro 

# install MAME emulator core
echo "Installing MAME core"
cd
git clone git://github.com/libretro/imame4all-libretro.git "$rootdir/emulatorcores/imame4all-libretro"
cd "$rootdir/emulatorcores/imame4all-libretro"
make -f makefile.libretro ARM=1

# install Doom WADs emulator core
echo "Installing Doom core"
cd 
git clone git://github.com/libretro/libretro-prboom.git "$rootdir/emulatorcores/libretro-prboom"
cd "$rootdir/emulatorcores/libretro-prboom"
make
cd

# install BCM library to enable GPIO access by SNESDev-RPi
echo "Installing BCM2835 library"
cd
wget http://www.open.com.au/mikem/bcm2835/bcm2835-1.3.tar.gz
tar -zxvf bcm2835-1.3.tar.gz
cd bcm2835-1.3
./configure
make
sudo make install
cd
rm bcm2835-1.3.tar.gz
rm -rf bcm2835-1.3

# install SNESDev as GPIO interface for SNES controllers
cd
git clone git://github.com/petrockblog/SNESDev-RPi.git "$rootdir/SNESDev-Rpi"
cd "$rootdir/SNESDev-Rpi"
make clean
make

# install EmulationStation as graphical front end for the emulators
cd
git clone git://github.com/Aloshi/EmulationStation.git "$rootdir/EmulationStation"
cd "$rootdir/EmulationStation"
make clean
make
echo -e "Generating symbolic link to /home/pi/RetroPie/EmulationStation/emulationstation\n -->>\n /usr/bin/emulationstation"
sudo ln -s /home/pi/RetroPie/EmulationStation/emulationstation /usr/bin/emulationstation

# generate EmulationStation configuration
echo -e "Generating configuration file ~/.es_systems.cfg for EmulationStation"
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

cd
echo -e "Finished compiling and installation.\nStart the front end with .emulationstation\nHave fun :-)"
echo -e "You now have to copy roms to the roms folder:\nSNES to roms/snes,\nNES to roms/nes\nGameboy Advance to roms/gba\nMAME to roms/mame\nMega Drive to roms/megadrive"
