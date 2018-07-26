#!/bin/bash

infobox= ""
infobox="${infobox}_______________________________________________________\n\n"
infobox="${infobox}\n"
infobox="${infobox}RetroPie Main Menu Swap\n\n"
infobox="${infobox}This script will swap the NEC PC Engine and TurboGrafx-16 themes to display on the main menu.\n"
infobox="${infobox}\n"
infobox="${infobox}You will need to restart Emulation Station after making the change.\n"

dialog --backtitle "PC Engine / TurboGrafx-16 Swap" \
--title "PC Engine / TurboGrafx-16 Swap" \
--msgbox "${infobox}" 15 80

function main_menu() {
    local choice

    while true; do
        choice=$(dialog --backtitle "$BACKTITLE" --title " MAIN MENU " \
            --ok-label OK --cancel-label Exit \
            --menu "What action would you like to perform?" 25 75 20 \
            1 "Change to pcengine" \
            2 "Change to tg16" \
            2>&1 > /dev/tty)

        case "$choice" in
            1) pcengine  ;;
            2) tg16  ;;
            *)  break ;;
        esac
    done
}

function pcengine() {
dialog --infobox "...processing..." 3 20 ; sleep 2
sudo cp /opt/retropie/configs/all/emulationstation/es_systems.cfg  /opt/retropie/configs/all/emulationstation/es_systems.cfg.bkp
sudo perl -p -i -e 's/<theme>tg16<\/theme>/<theme>pcengine<\/theme>/g'  /opt/retropie/configs/all/emulationstation/es_systems.cfg

}

function tg16() {
dialog --infobox "...processing..." 3 20 ; sleep 2
sudo cp  /opt/retropie/configs/all/emulationstation/es_systems.cfg  /opt/retropie/configs/all/emulationstation/es_systems.cfg.bkp
sudo perl -p -i -e 's/<theme>pcengine<\/theme>/<theme>tg16<\/theme>/g'  /opt/retropie/configs/all/emulationstation/es_systems.cfg

}

main_menu

