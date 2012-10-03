#!/bin/bash

# theme.xml files
filelist[0]="./RetroPie/roms/neogeo/theme.xml"
filelist[1]="./RetroPie/roms/mame/theme.xml"
filelist[2]="./RetroPie/roms/snes/theme.xml"
filelist[3]="./RetroPie/roms/psx/theme.xml"
filelist[4]="./RetroPie/roms/megadrive/theme.xml"
filelist[5]="./RetroPie/roms/gba/theme.xml"
filelist[6]="./RetroPie/roms/gb/theme.xml"
filelist[7]="./RetroPie/roms/gbc/theme.xml"
filelist[8]="./RetroPie/roms/nes/theme.xml"
filelist[9]="./RetroPie/roms/ngpc/theme.xml"
filelist[10]="./RetroPie/roms/mastersystem/theme.xml"
filelist[11]="./RetroPie/roms/gamegear/theme.xml"

# art files
filelist[12]="./.emulationstation/themes/snes_art/snes_bg.png"
filelist[13]="./.emulationstation/themes/snes_art/snes_logo.png"
filelist[14]="./.emulationstation/themes/snes_art/snes_bg_grey.jpg"
filelist[15]="./.emulationstation/themes/mastersystem_art/mastersystem_logo.png"
filelist[16]="./.emulationstation/themes/mastersystem_art/mastersystem_bg.png"
filelist[17]="./.emulationstation/themes/megadrive_art/divider.png"
filelist[18]="./.emulationstation/themes/megadrive_art/megadrive_bg_dark_stripes.png"
filelist[19]="./.emulationstation/themes/megadrive_art/megadrive_logo.png"
filelist[20]="./.emulationstation/themes/megadrive_art/megadrive_top_bg.png"
filelist[21]="./.emulationstation/themes/megadrive_art/megadrive_bg_red_stripes.png"
filelist[22]="./.emulationstation/themes/neogeo_art/neogeo_bg.jpg"
filelist[23]="./.emulationstation/themes/neogeo_art/neogeo_logo.png"
filelist[24]="./.emulationstation/themes/neogeo_art/neogeo_divider.png"
filelist[25]="./.emulationstation/themes/gbc_art/gbc_bg.jpg"
filelist[26]="./.emulationstation/themes/gbc_art/plastic_glare.png"
filelist[27]="./.emulationstation/themes/gbc_art/gbc_logo.png"
filelist[28]="./.emulationstation/themes/gamegear_art/divider.png"
filelist[29]="./.emulationstation/themes/gamegear_art/sgg_bg_pink_stripes.png"
filelist[30]="./.emulationstation/themes/gamegear_art/sgg_logo.png"
filelist[31]="./.emulationstation/themes/gamegear_art/sgg_bg_dark_stripes.png"
filelist[32]="./.emulationstation/themes/mame_art/mame_bg_black.jpg"
filelist[33]="./.emulationstation/themes/mame_art/mame_logo.jpg"
filelist[34]="./.emulationstation/themes/mame_art/mame_bg.jpg"
filelist[35]="./.emulationstation/themes/nes_art/nes_bg_grey.jpg"
filelist[36]="./.emulationstation/themes/nes_art/nes_logo.png"
filelist[37]="./.emulationstation/themes/nes_art/nes_bg_stripes.png"
filelist[38]="./.emulationstation/themes/gba_art/gba_bg_stripes.png"
filelist[39]="./.emulationstation/themes/gba_art/shadow.png"
filelist[40]="./.emulationstation/themes/gba_art/gba_logo.png"
filelist[41]="./.emulationstation/themes/gba_art/gba_bg_left.jpg"
filelist[42]="./.emulationstation/themes/psx_art/psx_logo.png"
filelist[43]="./.emulationstation/themes/psx_art/psx_divider.png"
filelist[44]="./.emulationstation/themes/psx_art/psx_bg.jpg"
filelist[45]="./.emulationstation/themes/gb_art/gb_divider.png"
filelist[45]="./.emulationstation/themes/gb_art/gb_logo.png"
filelist[46]="./.emulationstation/themes/gb_art/gb_bg.png"
filelist[47]="./.emulationstation/themes/ngpc_art/ngpc_logo.png"
filelist[48]="./.emulationstation/themes/ngpc_art/ngpc_bg.jpg"

tar -c -vf RetroPieSetupThemes_`date +%d%m%y`.tar ${filelist[0]}

tLen=${#filelist[@]}
for (( i=1; i<${tLen}; i++ ));
do
	tar -r -vf RetroPieSetupThemes_`date +%d%m%y`.tar ${filelist[$i]}
done

bzip2 RetroPieSetupThemes_`date +%d%m%y`.tar

echo "Done."
