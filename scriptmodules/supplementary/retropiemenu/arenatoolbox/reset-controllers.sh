#!/bin/bash
echo "This will reset all of your controllers, then reboot your board"
sleep 5
echo "This will wipe out all controller configurations, and reset everything to factory default."
sleep 2
echo "You will need to reconfigure all of your controllers."
sleep 2
if [ ! -f /usr/bin/curl ]; then
	echo -e "\n Curl is missing. Installing it now.\n"
	sleep 3
	sudo apt-get install -y curl
fi

rm /opt/retropie/configs/all/retroarch-joypads/*
cd $HOME/.emulationstation/
rm es_input.cfg
cd $HOME/.emulationstation/; curl -o es_input.cfg https://raw.githubusercontent.com/Shakz76/Eazy-Hax-RetroPie-Toolkit/master/cfg/es_input.cfg.bkup

sudo reboot
