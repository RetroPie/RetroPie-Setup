#!/bin/bash

filelist=()

filelist+=("./RetroPie/supplementary/EmulationStation/emulationstation")
filelist+=("./RetroPie/supplementary/ES-config/")
filelist+=("./RetroPie/supplementary/SNESDev-Rpi/SNESDev")
filelist+=("./RetroPie/supplementary/SNESDev-Rpi/supplementary/snesdev.cfg")
filelist+=("./RetroPie/supplementary/SNESDev-Rpi/scripts/SNESDev")
filelist+=("./RetroPie/supplementary/dispmanx/build/.libs/")

filelist+=("`find ./RetroPie/emulatorcores/stella-libretro/ -name "*libretro*.so"`")
filelist+=("`find ./RetroPie/emulatorcores/nxengine-libretro/ -name "*libretro*.so"`")
filelist+=("./RetroPie/emulatorcores/nxengine-libretro/datafiles/")
filelist+=("`find ./RetroPie/emulatorcores/gambatte-libretro/ -name "*libretro*.so"`")
filelist+=("`find ./RetroPie/emulatorcores/libretro-prboom/ -name "*libretro*.so"`")
filelist+=("./RetroPie/emulatorcores/libretro-prboom/prboom.wad")
filelist+=("`find ./RetroPie/emulatorcores/pocketsnes-libretro/ -name "*libretro*.so"`")
filelist+=("`find ./RetroPie/emulatorcores/stella-libretro/ -name "*libretro*.so"`")
filelist+=("`find ./RetroPie/emulatorcores/pcsx_rearmed/ -name "*libretro*.so"`")
filelist+=("`find ./RetroPie/emulatorcores/mednafen-pce-libretro/ -name "*libretro*.so"`")
filelist+=("`find ./RetroPie/emulatorcores/Genesis-Plus-GX/ -name "*libretro*.so"`")
filelist+=("`find ./RetroPie/emulatorcores/imame4all-libretro/ -name "*libretro*.so"`")
filelist+=("`find ./RetroPie/emulatorcores/fceu-next/fceumm-code/ -name "*libretro*.so"`")
filelist+=("`find ./RetroPie/emulatorcores/fba-libretro/ -name "*libretro*.so"`")
filelist+=("`find ./RetroPie/emulatorcores/picodrive/ -name "*libretro*.so"`")

filelist+=("./RetroPie/emulators/RetroArch/README.md")
filelist+=("./RetroPie/emulators/RetroArch/installdir/")
filelist+=("./RetroPie/emulators/RetroArch/installdir/bin/retroarch")
filelist+=("./RetroPie/emulators/RetroArch/installdir/bin/retroarch-zip")
filelist+=("./RetroPie/emulators/RetroArch/installdir/bin/retroarch-joyconfig")
filelist+=("./RetroPie/emulators/RetroArch/retroarch.cfg")

filelist+=("./RetroPie/emulators/dgen-sdl/dgen")
filelist+=("./RetroPie/emulators/dgen-sdl/sample.dgenrc")
filelist+=("./RetroPie/emulators/dgen-sdl/installdir/usr/local/bin/dgen_tobin")
filelist+=("./RetroPie/emulators/dgen-sdl/installdir/usr/local/bin/dgen")
filelist+=("./RetroPie/emulators/dgen-sdl/installdir/usr/local/share/man/man1/dgen_tobin.1")
filelist+=("./RetroPie/emulators/dgen-sdl/installdir/usr/local/share/man/man1/dgen.1")
filelist+=("./RetroPie/emulators/dgen-sdl/installdir/usr/local/share/man/man5/dgenrc.5")
filelist+=("./RetroPie/emulators/Wolf4SDL-1.7-src/wolf3d")
filelist+=("./RetroPie/emulators/osmose-0.8.1+rpi20121122/")
filelist+=("./RetroPie/emulators/gngeo-pi-0.85/installdir/")
filelist+=("./RetroPie/emulators/gngeo-pi-0.85/gngeo/FAQ")
filelist+=("./RetroPie/emulators/gngeo-pi-0.85/gngeo/README")
filelist+=("./RetroPie/emulators/gngeo-0.7/installdir/")
filelist+=("./RetroPie/emulators/vice-2.4/installdir/")
filelist+=("./RetroPie/emulators/uae4rpi/")
filelist+=("./RetroPie/emulators/advancemame-0.94.0/installdir/")
filelist+=("./RetroPie/emulators/jzintv-1.0-beta4/")
filelist+=("./RetroPie/emulators/linapple-src_2a/")
filelist+=("./RetroPie/emulators/mupen64plus-rpi/test/")

filelist+=("./RetroPie/emulators/mame4all-pi/cfg")
filelist+=("./RetroPie/emulators/mame4all-pi/cheat.dat")
filelist+=("./RetroPie/emulators/mame4all-pi/clrmame.dat")
filelist+=("./RetroPie/emulators/mame4all-pi/folders")
filelist+=("./RetroPie/emulators/mame4all-pi/hi")
filelist+=("./RetroPie/emulators/mame4all-pi/hiscore.dat")
filelist+=("./RetroPie/emulators/mame4all-pi/install.sh")
filelist+=("./RetroPie/emulators/mame4all-pi/Makefile")
filelist+=("./RetroPie/emulators/mame4all-pi/Makefile.debug")
filelist+=("./RetroPie/emulators/mame4all-pi/mame")
filelist+=("./RetroPie/emulators/mame4all-pi/mame4all_pi.zip")
filelist+=("./RetroPie/emulators/mame4all-pi/mame.cfg")
filelist+=("./RetroPie/emulators/mame4all-pi/mame.cfg.template")
filelist+=("./RetroPie/emulators/mame4all-pi/mametest.zip")
filelist+=("./RetroPie/emulators/mame4all-pi/pimenu.zip")
filelist+=("./RetroPie/emulators/mame4all-pi/readme.txt")
filelist+=("./RetroPie/emulators/mame4all-pi/readme.txt.orig")
filelist+=("./RetroPie/emulators/mame4all-pi/roms")
filelist+=("./RetroPie/emulators/mame4all-pi/skins")
filelist+=("./RetroPie/emulators/mame4all-pi/sta")
filelist+=("./RetroPie/emulators/mame4all-pi/zipit")

filelist+=("./RetroPie/emulators/rpix86/")
filelist+=("./RetroPie/emulators/gpsp/raspberrypi/")
filelist+=("./RetroPie/emulators/snes9x-rpi/snes9x")

filelist+=("./RetroPie/emulators/pifba/burn")
filelist+=("./RetroPie/emulators/pifba/capex.cfg")
filelist+=("./RetroPie/emulators/pifba/capex.cfg.template")
filelist+=("./RetroPie/emulators/pifba/cpu")
filelist+=("./RetroPie/emulators/pifba/fba_029671_clrmame_dat.zip")
filelist+=("./RetroPie/emulators/pifba/fba2x")
filelist+=("./RetroPie/emulators/pifba/fba2x.cfg")
filelist+=("./RetroPie/emulators/pifba/fba2x.cfg.template")
filelist+=("./RetroPie/emulators/pifba/FBACache_windows.zip")
filelist+=("./RetroPie/emulators/pifba/FBAcapex_src")
filelist+=("./RetroPie/emulators/pifba/install.sh")
filelist+=("./RetroPie/emulators/pifba/Makefile")
filelist+=("./RetroPie/emulators/pifba/Makefile.debug")
filelist+=("./RetroPie/emulators/pifba/Makefile.gp2x")
filelist+=("./RetroPie/emulators/pifba/piFBA.zip")
filelist+=("./RetroPie/emulators/pifba/readme.txt")
filelist+=("./RetroPie/emulators/pifba/rominfo.fba")
filelist+=("./RetroPie/emulators/pifba/rpi")
filelist+=("./RetroPie/emulators/pifba/skin")
filelist+=("./RetroPie/emulators/pifba/test.zip")
filelist+=("./RetroPie/emulators/pifba/zipit")
filelist+=("./RetroPie/emulators/pifba/zipname.fba")

filelist+=("./RetroPie/emulators/pisnes/snes9x")
filelist+=("./RetroPie/emulators/pisnes/snes9x.gui")
filelist+=("./RetroPie/emulators/pisnes/zipit")
filelist+=("./RetroPie/emulators/pisnes/roms/")
filelist+=("./RetroPie/emulators/pisnes/skins/")
filelist+=("./RetroPie/emulators/basiliskii/installdir/")
filelist+=("./RetroPie/emulators/atari800-3.0.0/installdir/")
filelist+=("./RetroPie/emulators/atari800-3.0.0/README.1ST")
filelist+=("./RetroPie/emulators/fbzx-2.10.0/")
filelist+=("./RetroPie/emulators/cpc4rpi-1.1/cpc4rpi")
filelist+=("./RetroPie/emulators/cpc4rpi-1.1/COPYING.txt")
filelist+=("./RetroPie/emulators/cpc4rpi-1.1/README.txt")
filelist+=("./RetroPie/emulators/cpc4rpi-1.1/joy.txt")
filelist+=("./RetroPie/emulators/fastdosbox-1.5/installdir/")

echo "Checking, if all directories/files exist"
tLen=${#filelist[@]}
doAbort=0
for (( i=0; i<${tLen}; i++ ));
do
	if [[ ! -d "${filelist[$i]}" && ! -f "${filelist[$i]}" ]]
	then
	  echo "Cannot find directory #$i: ${filelist[$i]}."
	  doAbort=1
	fi
done

if [[ $doAbort -eq 1 ]]; then
	exit
fi

echo "Creating the archive file"
tar -c -vf RetroPieSetupBinaries_`date +%d%m%y`.tar ${filelist[0]}

for (( i=1; i<${tLen}; i++ ));
do
	tar -r -vf RetroPieSetupBinaries_`date +%d%m%y`.tar ${filelist[$i]}
done

echo "Compressing the archive file"
bzip2 RetroPieSetupBinaries_`date +%d%m%y`.tar

echo "Done."
