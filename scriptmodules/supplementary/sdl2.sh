rp_module_id="sdl2"
rp_module_desc="SDL 2.0.1"
rp_module_menus="2-"

function depends_sdl2() {
    # These packages are listed in SDL2's "README-raspberrypi.txt" file as build dependencies.
    # If libudev-dev is not installed before compiling, the keyboard will mysteriously not work!
    # The rest should already be installed, but just to be safe, include them all.
    checkNeededPackages libudev-dev libasound2-dev libdbus-1-dev libraspberrypi0 libraspberrypi-bin libraspberrypi-dev
}

function sources_sdl2() {
    wget -O- -q http://downloads.petrockblock.com/retropiearchives/SDL2-2.0.1.tar.gz | tar -xvz --strip-components=1
}

function build_sdl2() {
    ./configure 
    make clean
    make
}

function install_sdl2() {
    make install
}