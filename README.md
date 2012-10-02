RetroPie-Setup
==============

General Usage
-------------

Shell script to setup Raspberry Pi (TM) with several emulators, various cores, and EmulationStation as graphical front end.

This script is tested with the Raspbian distribution. Before using the script, please make sure that you have run the raspi-config script to extend your root file system and that your memory split is set to 192 or 128. You can run the script with

```shell
sudo raspi-config
```

To run the RetroPie Setup Script make sure that your APT repositories are up-to-date and that Git and the dialog package are installed:

```shell
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y git dialog
```

Then you can download the latest RetroPie setup script with

```shell
cd
git clone git://github.com/petrockblog/RetroPie-Setup.git
```

The script is executed with 

```shell
cd RetroPie-Setup
chmod +x retropie_setup.sh
sudo ./retropie_setup.sh
```

Optional arguments can be passed to the script. If called with 
```shell
sudo ./retropie_setup.sh
```
the installation directory is /home/CURRENTUSER/RetroPie for the current user, where CURRENTUSER is the home directory of the current user. If called with 
```shell
sudo ./retropie_setup.sh USERNAME
```
the installation directory is /home/USERNAME/RetroPie for user USERNAME. If called with 
```shell
sudo ./retropie_setup.sh USERNAME ABSPATH
```
the installation directory is ABSPATH for user USERNAME



Binaries and Sources
--------------------

RetroPie Setup offers the possibilities to only install RetroArch, the cores, EmulationStation, and SNESDev either with pre-compiles binaries or by downloading and compiling the sources. The first method is much faster, but does not offer the latest versions of the individual programs. So, to make sure that you are running the latest versions take your time and let RetroPie Setup download and compile the programs from their sources.

For more information visit the blog at http://petrockblog.wordpress.com or the repository at https://github.com/petrockblog/RetroPie-Setup. A forum thread about the RetroPie Setup script in the official Raspberry Pi forum can be found at http://www.raspberrypi.org/phpBB3/viewtopic.php?f=35&t=13600.

Wiki
----

You can find useful information about several components or for several frequently asked questions in the [wiki](https://github.com/petrockblog/RetroPie-Setup/wiki) of the RetroPie Script. If you think that there is something missing you are invited to add it to the wiki.


Thanks
------

This script just simplifies the usage of the great works of many other people that enjoy the spirit of retrogaming. Many thanks go to them!
