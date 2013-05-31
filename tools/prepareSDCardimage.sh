# Here follows a script for preparing the downloadable SD card image.
# Inspired by article at http://www.cnx-software.com/2012/07/31/84-mb-minimal-raspbian-armhf-image-for-raspberry-pi/

sudo apt-get purge scratch xpdf dillo midori netsurf xarchiver omxplayer
sudo apt-get autoremove

# remove es_input.cfg etc.
rm ~/.emulationstation/es_input.cfg
rm ~/ocr_pi.png
rm -rf ~/python_games/
rm -rf ~/Desktop/

# resize partition on SD card to 3200 MB with gparted
# read and compress image of SD card with
#   dd if=/dev/disk2 bs=2m of=RetroPieImage_verX.img count=1650
#   zip -9 RetroPieImage_verX.zip RetroPieImage_verX.img
# create SHA1 hash with 
#   shasum RetroPieImage_verX.zip