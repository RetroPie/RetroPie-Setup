#!/bin/bash

filelist=()

filelist+=("./RetroPie/supplementary/EmulationStation/emulationstation")

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

filelist+=("./RetroPie/emulators/RetroArch/README.md")
filelist+=("./RetroPie/emulators/RetroArch/retroarch")
filelist+=("./RetroPie/emulators/RetroArch/retroarch-zip")
filelist+=("./RetroPie/emulators/RetroArch/retroarch.cfg")
filelist+=("./RetroPie/emulators/RetroArch/tools/retroarch-joyconfig")

filelist+=("./RetroPie/supplementary/bcm2835-1.14/")
filelist+=("./RetroPie/supplementary/SNESDev-Rpi/SNESDev")
filelist+=("./RetroPie/supplementary/SNESDev-Rpi/scripts/SNESDev")
filelist+=("./RetroPie/supplementary/dispmanx/build/.libs/")

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
filelist+=("./RetroPie/emulators/gngeo-0.7/installdir/")
filelist+=("./RetroPie/emulators/vice-2.3.dfsg/installdir/")
filelist+=("./RetroPie/emulators/uae4all/")
filelist+=("./RetroPie/emulators/advancemame-0.94.0/installdir/")
filelist+=("./RetroPie/emulators/jzintv-1.0-beta4/")
filelist+=("./RetroPie/emulators/linapple-src_2a/")
filelist+=("./RetroPie/emulators/rpix86/")
filelist+=("./RetroPie/emulators/gpsp/raspberrypi/")
filelist+=("./RetroPie/emulators/snes9x-rpi/snes9x")
filelist+=("./RetroPie/emulators/pisnes/snes9x")
filelist+=("./RetroPie/emulators/pisnes/snes9x.gui")
filelist+=("./RetroPie/emulators/pisnes/zipit")
filelist+=("./RetroPie/emulators/pisnes/roms/")
filelist+=("./RetroPie/emulators/pisnes/skins/")
filelist+=("./RetroPie/emulators/basiliskii/installdir/")

# check if all directories/files exist
tLen=${#filelist[@]}
for (( i=0; i<${tLen}; i++ ));
do
	if [[ ! -d "${filelist[$i]}" && ! -f "${filelist[$i]}" ]]
	then
	  echo "Cannot find directory ${filelist[$i]}."
	  exit
	fi
done

# put everything into an archive file
tar -c -vf RetroPieSetupBinaries_`date +%d%m%y`.tar ${filelist[0]}

for (( i=1; i<${tLen}; i++ ));
do
	tar -r -vf RetroPieSetupBinaries_`date +%d%m%y`.tar ${filelist[$i]}
done

# compress the archive
bzip2 RetroPieSetupBinaries_`date +%d%m%y`.tar

echo "Done."
