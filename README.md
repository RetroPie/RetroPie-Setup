RetroPie-Setup
==============

General Usage
-------------

Shell script to setup the Raspberry Pi, Vero4K, ODroid-C1 or a PC running Ubuntu with many emulators and games, using EmulationStation as the graphical front end. Bootable pre-made images for the Raspberry Pi are available for those that want a ready to go system, downloadable from the releases section of GitHub or via our website at https://retropie.org.uk

This script is designed for use on Raspbian on the Raspberry Pi, OSMC on the Vero4K or Ubuntu on the ODroid-C1 or a PC.

To run the RetroPie Setup Script make sure that your APT repositories are up-to-date and that Git is installed:

```shell
sudo apt-get update
sudo apt-get dist-upgrade
sudo apt-get install git
```

Then you can download the latest RetroPie setup script with

```shell
cd
git clone --depth=1 https://github.com/MrCoolSpan/RetroPie-Setup.git
```

The script is executed with 

```shell
cd RetroPie-Setup
sudo ./retropie_setup.sh
```

When you first run the script it may install some additional packages that are needed.

RPCS3 Setup to Retropie
-----------------------

After dump your original PS3 game, move the game content to a folder with a .PS3 extension under ~/RetroPie/roms/ps3/.

Example: if your game is Skate3, put content under ~/RetroPie/roms/ps3/Skate3.PS3/
PSN game

PSN games uses .pkg extension.
Install

Open RPCS3: from a terminal, run /opt/retropie/emulators/rpcs3/bin/rpcs3.AppImage.

Then, into RPCS3 menu, select File > Install .pkg.

Browse and select the .pkg content to run.
EmulationStation

In order to create an entry for the PSN game, take note of the game serial (you can copy the game serial on RPCS3 UI, right clicking in the game and select "Copy info" > "Copy game serial").

Then create a folder for your game with a .PS3 extension under ~/RetroPie/roms/ps3/ (remember to replace the game name by your actual game name):

mkdir ~/RetroPie/roms/ps3/<replace-with-your-game-name>.PS3

Create a shortcut from the PS3 internal storage to the ~/RetroPie/roms/ps3/ (remember to replace the serial and game name by your actual game values):

ln -sf  ~/.config/rpcs3/dev_hdd0/game/<serial> ~/RetroPie/roms/ps3/<replace-with-your-game-name>.PS3/PS3_GAME
  
Binaries and Sources
--------------------

On the Raspberry Pi, RetroPie Setup offers the possibility to install from binaries or source. For other supported platforms only a source install is available. Installing from binary is recommended on a Raspberry Pi as building everything from source can take a long time.

For more information visit the blog at https://retropie.org.uk or the repository at https://github.com/RetroPie/RetroPie-Setup.

Wiki
----

You can find useful information about several components or for several frequently asked questions in the [wiki](https://github.com/RetroPie/RetroPie-Setup/wiki) of the RetroPie Script. If you think that there is something missing, you are invited to add it to the wiki.


Thanks
------

This script just simplifies the usage of the great works of many other people that enjoy the spirit of retrogaming. Many thanks go to them!
