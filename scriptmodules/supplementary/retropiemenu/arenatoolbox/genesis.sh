#!/bin/bash

infobox= ""
infobox="${infobox}_______________________________________________________\n\n"
infobox="${infobox}\n"
infobox="${infobox}RetroPie Main Menu Swap\n\n"
infobox="${infobox}This script will swap the Sega Genesis and Sega MegaDrive themes to display on the main menu.\n"
infobox="${infobox}\n"
infobox="${infobox}You will need to restart Emulation Station after making the change.\n"

dialog --backtitle "Genesis / MegaDrive Swap" \
--title "Genesis / MegaDrive Swap" \
--msgbox "${infobox}" 15 80

function main_menu() {
    local choice

    while true; do
        choice=$(dialog --backtitle "$BACKTITLE" --title " MAIN MENU " \
            --ok-label OK --cancel-label Exit \
            --menu "What action would you like to perform?" 25 75 20 \
            1 "Change to Sega Genesis" \
            2 "Change to Sega Megadrive" \
            2>&1 > /dev/tty)

        case "$choice" in
            1) genesis  ;;
            2) megadrive  ;;
            *)  break ;;
        esac
    done
}

function genesis() {
dialog --infobox "...processing..." 3 20 ; sleep 2
sudo cp /opt/retropie/configs/all/emulationstation/es_systems.cfg  /opt/retropie/configs/all/emulationstation/es_systems.cfg.bkp
sudo perl -p -i -e 's/<theme>megadrive<\/theme>/<theme>genesis<\/theme>/g'  /opt/retropie/configs/all/emulationstation/es_systems.cfg

}

function megadrive() {
dialog --infobox "...processing..." 3 20 ; sleep 2
sudo cp  /opt/retropie/configs/all/emulationstation/es_systems.cfg  /opt/retropie/configs/all/emulationstation/es_systems.cfg.bkp
sudo perl -p -i -e 's/<theme>genesis<\/theme>/<theme>megadrive<\/theme>/g'  /opt/retropie/configs/all/emulationstation/es_systems.cfg

}

main_menu

