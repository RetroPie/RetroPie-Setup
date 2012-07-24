#!/bin/bash

#  RetroPie-Setup - Shell script for initializing Raspberry Pi 
#  with RetroArch and various cores.
# 
#  (c) Copyright 2012  Florian Müller (petrockblock@gmail.com)
# 
#  RetroPie-Setup homepage: https://github.com/petrockblog/RetroPie-Setup
# 
#  Permission to use, copy, modify and distribute SNESDev in both binary and
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
#  Raspberry Pi is a trademark of the Raspberry Pi Foundation.
# 

# add user pi to groups "video", "audio", and "input"
sudo usermod -a -G video pi
sudo usermod -a -G audio pi
sudo usermod -a -G input pi

# make sure ALSA soundmodule is active
echo "Enabling ALSA module"
sudo modprobe snd_bcm2835

# needed by SDL for working joypads
export SDL_NOMOUSE=1

# make sure that joydev and uinput modules are loaded
sudo modprobe joydev
sudo modprobe uinput

# update APT repositories and update system
sudo apt-get -y update
sudo apt-get -y upgrade

# make sure that all needed packages are installed
sudo apt-get install -y libsdl1.2-dev screen scons libasound2-dev pkg-config libgtk2.0-dev libsdl-ttf2.0-dev libboost-filesystem-dev

# install latest rpi-update script (to enable firmware update)
sudo wget http://goo.gl/1BOfJ -O /usr/bin/rpi-update && sudo chmod +x /usr/bin/rpi-update

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

mkdir "$rootdir/emulatorcores"

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

# install RetroArch emulator
echo "Installing RetroArch emulator"
cd
git clone git://github.com/ToadKing/RetroArch-Rpi.git "$rootdir/RetroArch-Rpi"
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
cd gambatte-libretro/libgambatte
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
make

cd
echo "Finishes with RetroPie setup. Have fun :-)"
