#!/bin/bash

filelist[0]="./.emulationstation/themes/snes_art/snes_bg.png"
filelist[1]="./.emulationstation/themes/snes_art/snes_logo.png"
filelist[2]="./RetroPie/roms/snes/theme.xml"
filelist[3]="./RetroPie/roms/nes/theme.xml"
filelist[4]="./.emulationstation/themes/nes_art/nes_bg_grey.jpg"
filelist[5]="./.emulationstation/themes/nes_art/nes_bg_stripes.png"
filelist[6]="./.emulationstation/themes/nes_art/nes_logo.png"

tar -c -vf RetroPieSetupThemes_`date +%d%m%y`.tar ${filelist[0]}

tLen=${#filelist[@]}
for (( i=1; i<${tLen}; i++ ));
do
	tar -r -vf RetroPieSetupThemes_`date +%d%m%y`.tar ${filelist[$i]}
done

bzip2 RetroPieSetupThemes_`date +%d%m%y`.tar

echo "Done."
