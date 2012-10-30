#!/bin/bash

filelist[0]="./RetroPie/supplementary/EmulationStation/emulationstation"
filelist[1]="./RetroPie/supplementary/EmulationStation/LinLibertine_R.ttf"
filelist[2]="./RetroPie/emulatorcores/fceu-next/libretro.so"
filelist[3]="./RetroPie/emulatorcores/gambatte-libretro/libgambatte/libretro.so"
filelist[4]="./RetroPie/emulatorcores/Genesis-Plus-GX/libretro.so"
filelist[5]="./RetroPie/emulatorcores/imame4all-libretro/libretro.so"
filelist[6]="./RetroPie/emulatorcores/libretro-prboom/libretro.so"
filelist[7]="./RetroPie/emulatorcores/libretro-prboom/prboom.wad"
filelist[8]="./RetroPie/emulatorcores/pocketsnes-libretro/libretro.so"
filelist[9]="./RetroPie/emulatorcores/stella-libretro/libretro.so"
filelist[10]="./RetroPie/emulatorcores/vba-next/libretro.so"
filelist[11]="./RetroPie/emulators/RetroArch/README.md"
filelist[12]="./RetroPie/emulators/RetroArch/retroarch"
filelist[13]="./RetroPie/emulators/RetroArch/retroarch-zip"
filelist[14]="./RetroPie/emulators/RetroArch/retroarch.cfg"
filelist[15]="./RetroPie/emulators/RetroArch/tools/retroarch-joyconfig"
filelist[16]="./RetroPie/supplementary/SNESDev-Rpi/bin/SNESDev"
filelist[17]="./RetroPie/emulatorcores/pcsx_rearmed/libretro.so"
filelist[18]="./RetroPie/emulatorcores/mednafen-pce-libretro/libretro.so"
filelist[19]="./RetroPie/emulators/dgen-sdl-1.30/dgen"
filelist[20]="./RetroPie/emulators/dgen-sdl-1.30/sample.dgenrc"
filelist[21]="./RetroPie/emulators/Wolf4SDL-1.7-src/wolf3d"

tar -c -vf RetroPieSetupBinaries_`date +%d%m%y`.tar ${filelist[0]}

tLen=${#filelist[@]}
for (( i=1; i<${tLen}; i++ ));
do
	tar -r -vf RetroPieSetupBinaries_`date +%d%m%y`.tar ${filelist[$i]}
done

bzip2 RetroPieSetupBinaries_`date +%d%m%y`.tar

echo "Done."
