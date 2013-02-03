#!/bin/bash

filelist=()

filelist+=("./RetroPie/supplementary/EmulationStation/emulationstation")
filelist+=("./RetroPie/emulatorcores/fceu-next/fceumm-code/libretro.so")
filelist+=("./RetroPie/emulatorcores/gambatte-libretro/libgambatte/libretro.so")
filelist+=("./RetroPie/emulatorcores/imame4all-libretro/libretro.so")
filelist+=("./RetroPie/emulatorcores/libretro-prboom/libretro.so")
filelist+=("./RetroPie/emulatorcores/libretro-prboom/prboom.wad")
filelist+=("./RetroPie/emulatorcores/pocketsnes-libretro/libretro.so")
filelist+=("./RetroPie/emulatorcores/stella-libretro/libretro.so")
filelist+=("./RetroPie/emulatorcores/vba-next/libretro.so")
filelist+=("./RetroPie/emulators/RetroArch/README.md")
filelist+=("./RetroPie/emulators/RetroArch/retroarch")
filelist+=("./RetroPie/emulators/RetroArch/retroarch-zip")
filelist+=("./RetroPie/emulators/RetroArch/retroarch.cfg")
filelist+=("./RetroPie/emulators/RetroArch/tools/retroarch-joyconfig")
filelist+=("./RetroPie/supplementary/SNESDev-Rpi/bin/SNESDev")
filelist+=("./RetroPie/emulatorcores/pcsx_rearmed/libretro.so")
filelist+=("./RetroPie/emulatorcores/mednafen-pce-libretro/libretro.so")
filelist+=("./RetroPie/emulators/dgen-sdl-1.31/dgen")
filelist+=("./RetroPie/emulators/dgen-sdl-1.31/sample.dgenrc")
filelist+=("./RetroPie/emulators/dgen-sdl-1.31/installdir/usr/local/bin/dgen_tobin")
filelist+=("./RetroPie/emulators/dgen-sdl-1.31/installdir/usr/local/bin/dgen")
filelist+=("./RetroPie/emulators/dgen-sdl-1.31/installdir/usr/local/share/man/man1/dgen_tobin.1")
filelist+=("./RetroPie/emulators/dgen-sdl-1.31/installdir/usr/local/share/man/man1/dgen.1")
filelist+=("./RetroPie/emulators/dgen-sdl-1.31/installdir/usr/local/share/man/man5/dgenrc.5")
filelist+=("./RetroPie/emulators/Wolf4SDL-1.7-src/wolf3d")
filelist+=("./RetroPie/supplementary/SNESDev-Rpi/scripts/SNESDev")

tar -c -vf RetroPieSetupBinaries_`date +%d%m%y`.tar ${filelist[0]}

tLen=${#filelist[@]}
for (( i=1; i<${tLen}; i++ ));
do
	tar -r -vf RetroPieSetupBinaries_`date +%d%m%y`.tar ${filelist[$i]}
done

bzip2 RetroPieSetupBinaries_`date +%d%m%y`.tar

echo "Done."
