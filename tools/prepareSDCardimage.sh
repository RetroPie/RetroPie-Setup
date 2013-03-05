# Here follows a script for preparing the downloadable SD card image.
# Inspired by article at http://www.cnx-software.com/2012/07/31/84-mb-minimal-raspbian-armhf-image-for-raspberry-pi/

apt-get purge scratch xpdf dillo midori netsurf xarchiver lxterminal lxde lxde-common lxde-icon-theme omxplayer
apt-get autoremove

# remove es_input.cfg
rm ~/.emulationstation/es_input.cfg

# read and compress image of SD card with
#   dd if=/dev/diskX bs=2m | gzip --best > RetroPieImage_verX.img.gz
# create SHA1 hash with 
#   shasum RetroPieImage_verX.img.gz