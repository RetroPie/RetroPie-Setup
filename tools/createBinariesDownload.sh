#!/bin/bash

#  RetroPie-Setup - Shell script for initializing Raspberry Pi 
#  with RetroArch, various cores, and EmulationStation (a graphical 
#  front end).
# 
#  (c) Copyright 2012-2014  Florian Müller (contact@petrockblock.com)
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
#  Many, many thanks go to all people that provide the individual packages!!!
# 
#  Raspberry Pi is a trademark of the Raspberry Pi Foundation.
# 

pushd "/opt"

rootdir="./retropie"

filelist=()

filelist+=("$rootdir/supplementary/EmulationStation/emulationstation")
filelist+=("$rootdir/supplementary/SNESDev-Rpi/SNESDev")
filelist+=("$rootdir/supplementary/SNESDev-Rpi/supplementary/snesdev.cfg")
filelist+=("$rootdir/supplementary/SNESDev-Rpi/scripts/SNESDev")

filelist+=("$(find $rootdir/emulatorcores/stella-libretro/ -name "*libretro*.so")")
filelist+=("$(find $rootdir/emulatorcores/nxengine-libretro/ -name "*libretro*.so")")
filelist+=("$rootdir/emulatorcores/nxengine-libretro/datafiles/")
filelist+=("$(find $rootdir/emulatorcores/gambatte-libretro/ -name "*libretro*.so")")
filelist+=("$(find $rootdir/emulatorcores/libretro-prboom/ -name "*libretro*.so")")
filelist+=("$rootdir/emulatorcores/libretro-prboom/prboom.wad")
filelist+=("$(find $rootdir/emulatorcores/pocketsnes-libretro/ -name "*libretro*.so")")
filelist+=("$(find $rootdir/emulatorcores/pcsx_rearmed/ -name "*libretro*.so")")
filelist+=("$(find $rootdir/emulatorcores/mednafen-pce-libretro/ -name "*libretro*.so")")
filelist+=("$(find $rootdir/emulatorcores/imame4all-libretro/ -name "*libretro*.so")")
filelist+=("$(find $rootdir/emulatorcores/fceu-next/fceumm-code/ -name "*libretro*.so")")
filelist+=("$(find $rootdir/emulatorcores/fba-libretro/ -name "*libretro*.so")")
filelist+=("$(find $rootdir/emulatorcores/picodrive/ -name "*libretro*.so")")

filelist+=("$rootdir/emulators/RetroArch/README.md")
filelist+=("$rootdir/emulators/RetroArch/installdir/")
filelist+=("$rootdir/emulators/RetroArch/installdir/bin/retroarch")
filelist+=("$rootdir/emulators/RetroArch/installdir/bin/retroarch-zip")
filelist+=("$rootdir/emulators/RetroArch/installdir/bin/retroarch-joyconfig")
filelist+=("$rootdir/emulators/RetroArch/retroarch.cfg")

filelist+=("$rootdir/emulators/osmose-0.8.1+rpi20121122/")
filelist+=("$rootdir/emulators/gngeo-pi-0.85/installdir/")
filelist+=("$rootdir/emulators/gngeo-pi-0.85/gngeo/FAQ")
filelist+=("$rootdir/emulators/gngeo-pi-0.85/gngeo/README")
filelist+=("$rootdir/emulators/vice-2.4/installdir/")
filelist+=("$rootdir/emulators/uae4rpi/")
filelist+=("$rootdir/emulators/advancemame-0.94.0/installdir/")
filelist+=("$rootdir/emulators/jzintv-1.0-beta4/")
filelist+=("$rootdir/emulators/linapple-src_2a/")
filelist+=("$rootdir/emulators/mupen64plus-rpi/")
filelist+=("$rootdir/emulators/mame4all-pi/")
filelist+=("$rootdir/emulators/mame4all-pi/mame")
filelist+=("$rootdir/emulators/rpix86/")
filelist+=("$rootdir/emulators/gpsp/raspberrypi/")
filelist+=("$rootdir/emulators/snes9x-rpi/snes9x")
filelist+=("$rootdir/emulators/pisnes/snes9x")
filelist+=("$rootdir/emulators/pisnes/snes9x.gui")
filelist+=("$rootdir/emulators/pisnes/zipit")
filelist+=("$rootdir/emulators/pisnes/roms/")
filelist+=("$rootdir/emulators/pisnes/skins/")
filelist+=("$rootdir/emulators/pifba/fba2x")
filelist+=("$rootdir/emulators/pifba/capex.cfg")
filelist+=("$rootdir/emulators/pifba/fba2x.cfg")
filelist+=("$rootdir/emulators/pifba/zipname.fba")
filelist+=("$rootdir/emulators/pifba/rominfo.fba")
filelist+=("$rootdir/emulators/pifba/FBACache_windows.zip")
filelist+=("$rootdir/emulators/pifba/fba_029671_clrmame_dat.zip")
filelist+=("$rootdir/emulators/pifba/roms")
filelist+=("$rootdir/emulators/pifba/skin")
filelist+=("$rootdir/emulators/pifba/preview")
filelist+=("$rootdir/emulators/basiliskii/BasiliskII/src/Unix/BasiliskII")
filelist+=("$rootdir/emulators/atari800-3.0.0/installdir/")
filelist+=("$rootdir/emulators/atari800-3.0.0/README.1ST")
filelist+=("$rootdir/emulators/fbzx-2.10.0/")
filelist+=("$rootdir/emulators/cpc4rpi-1.1/cpc4rpi")
filelist+=("$rootdir/emulators/cpc4rpi-1.1/COPYING.txt")
filelist+=("$rootdir/emulators/cpc4rpi-1.1/README.txt")
filelist+=("$rootdir/emulators/cpc4rpi-1.1/joy.txt")
filelist+=("$rootdir/emulators/openmsx-0.10.0/")
filelist+=("$rootdir/emulators/fastdosbox-1.5/installdir/")

echo "Checking, if all directories/files exist"
tLen=${#filelist[@]}
doAbort=0
for (( i=0; i<${tLen}; i++ ));
do
	if [[ ! -d "${filelist[$i]}" && ! -f "${filelist[$i]}" ]]
	then
	  echo "Cannot find directory ${filelist[$i]}."
	  doAbort=1
	fi
done

if [[ $doAbort -eq 1 ]]; then
	exit
fi

echo "Creating the archive file"
tar -c -vf /home/pi/RetroPieSetupBinaries_`date +%d%m%y`.tar ${filelist[0]} --exclude-vcs --exclude="*.o"

for (( i=1; i<${tLen}; i++ ));
do
	tar -r -vf /home/pi/RetroPieSetupBinaries_`date +%d%m%y`.tar ${filelist[$i]} --exclude-vcs --exclude="*.o"
done

echo "Compressing the archive file"
bzip2 /home/pi/RetroPieSetupBinaries_`date +%d%m%y`.tar

echo "Done."

popd
