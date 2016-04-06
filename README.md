RetroPie-Setup
==============

General Usage
-------------

Shell script to setup the Raspberry Pi 1 / 2 / 3 with several emulators, various cores, and EmulationStation as graphical front end. Bootable pre-made images are available for those that want a ready to go system, downloadable from the releases section of GitHub or via our website at https://retropie.org.uk

This script is designed for use on Raspbian Jessie and Wheezy for the Raspberry Pi. Before using the script, please **make sure that you have run the raspi-config script to extend your root file system **. You can run the script with

```shell
sudo raspi-config
```

To run the RetroPie Setup Script make sure that your APT repositories are up-to-date and that Git is installed:

```shell
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install git
```

Then you can download the latest RetroPie setup script with

```shell
cd
git clone --depth=1 https://github.com/RetroPie/RetroPie-Setup.git
```

The script is executed with 

```shell
cd RetroPie-Setup
sudo ./retropie_setup.sh
```

When you first run the script it may install some additional packages that are needed. Note that you might **need to reboot your Raspberry**, if your firmware was updated during the installation process.


Binaries and Sources
--------------------

RetroPie Setup offers the possibility to install from binaries or build from source. For most users installing from binary should suffice - but for the very latest versions of some software building from source may be preferred. Building from source can take more than a day on a Raspberry Pi.

For more information visit the blog at https://retropie.org.uk or the repository at https://github.com/RetroPie/RetroPie-Setup. A forum thread about the RetroPie Setup script in the official Raspberry Pi forum can be found at http://www.raspberrypi.org/phpBB3/viewtopic.php?f=35&t=13600.

Wiki
----

You can find useful information about several components or for several frequently asked questions in the [wiki](https://github.com/RetroPie/RetroPie-Setup/wiki) of the RetroPie Script. If you think that there is something missing, you are invited to add it to the wiki.


Thanks
------

This script just simplifies the usage of the great works of many other people that enjoy the spirit of retrogaming. Many thanks go to them!
