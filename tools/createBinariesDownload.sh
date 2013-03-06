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
filelist+=("`find ./RetroPie/emulatorcores/vba-next/ -name "*libretro*.so"`")
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
filelist+=("./RetroPie/supplementary/SNESDev-Rpi/bin/SNESDev")
filelist+=("./RetroPie/supplementary/SNESDev-Rpi/scripts/SNESDev")

filelist+=("./RetroPie/emulators/dgen-sdl/dgen")
filelist+=("./RetroPie/emulators/dgen-sdl/sample.dgenrc")
filelist+=("./RetroPie/emulators/dgen-sdl/installdir/usr/local/bin/dgen_tobin")
filelist+=("./RetroPie/emulators/dgen-sdl/installdir/usr/local/bin/dgen")
filelist+=("./RetroPie/emulators/dgen-sdl/installdir/usr/local/share/man/man1/dgen_tobin.1")
filelist+=("./RetroPie/emulators/dgen-sdl/installdir/usr/local/share/man/man1/dgen.1")
filelist+=("./RetroPie/emulators/dgen-sdl/installdir/usr/local/share/man/man5/dgenrc.5")
filelist+=("./RetroPie/emulators/Wolf4SDL-1.7-src/wolf3d")
filelist+=("./RetroPie/emulators/osmose-0.8.1+rpi20121122/")
filelist+=("./RetroPie/emulators/gngeo-0.7/installdir/")
filelist+=("./RetroPie/emulators/uae4all/")
filelist+=("./RetroPie/emulators/advancemame-0.94.0/installdir/")
filelist+=("./RetroPie/emulators/jzintv-1.0-beta4/")

tar -c -vf RetroPieSetupBinaries_`date +%d%m%y`.tar ${filelist[0]}

tLen=${#filelist[@]}
for (( i=1; i<${tLen}; i++ ));
do
	tar -r -vf RetroPieSetupBinaries_`date +%d%m%y`.tar ${filelist[$i]}
done

bzip2 RetroPieSetupBinaries_`date +%d%m%y`.tar

echo "Done."
