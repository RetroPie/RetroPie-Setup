#!/bin/bash

filelist[0]="./RetroPie/EmulationStation/emulationstation"
filelist[1]="./RetroPie/EmulationStation/LinLibertine_R.ttf"
filelist[2]="./RetroPie/emulatorcores/fceu-next/libretro.so"
filelist[3]="./RetroPie/emulatorcores/gambatte-libretro/libgambatte/libretro.so"
filelist[4]="./RetroPie/emulatorcores/Genesis-Plus-GX/libretro.so"
filelist[5]="./RetroPie/emulatorcores/imame4all-libretro/libretro.so"
filelist[6]="./RetroPie/emulatorcores/libretro-prboom/libretro.so"
filelist[7]="./RetroPie/emulatorcores/libretro-prboom/prboom.wad"
filelist[8]="./RetroPie/emulatorcores/pocketsnes-libretro/libretro.so"
filelist[9]="./RetroPie/emulatorcores/stella-libretro/libretro.so"
filelist[10]="./RetroPie/emulatorcores/vba-next/libretro.so"
filelist[11]="./RetroPie/RetroArch-Rpi/README.md"
filelist[12]="./RetroPie/RetroArch-Rpi/retroarch"
filelist[13]="./RetroPie/RetroArch-Rpi/retroarch-zip"
filelist[14]="./RetroPie/RetroArch-Rpi/retroarch.cfg"
filelist[15]="./RetroPie/RetroArch-Rpi/tools/retroarch-joyconfig"
filelist[16]="./RetroPie/SNESDev-Rpi/bin/SNESDev"

tar -c -vf newRetroPieSetupBinaries.tar ${filelist[0]}

tLen=${#filelist[@]}
for (( i=1; i<${tLen}; i++ ));
do
	tar -r -vf newRetroPieSetupBinaries.tar ${filelist[$i]}
done

echo "Done."
