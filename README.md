RetroPie-Setup
==============

General Usage
-------------

Shell script to setup Raspberry Pi (TM) with RetroArch emulator, various cores, and EmulationStation as graphical front end.

First of all, make sure that your APT repositories are up-to-date and that Git and the dialog package are installed:

```shell
sudo apt-get update
sudo apt-get upgrade
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

For more information visit the blog at http://petrockblog.wordpress.com or the repository at https://github.com/petrockblog/RetroPie-Setup.

Thanks
------

This script just simplifies the usage of the great works of many other people that enjoy the spirit of retrogaming. Many thanks go to them!
