rp_module_id="sdl1dispmanx"
rp_module_desc="SDL 1.2.15 with dispmanx backend"
rp_module_menus="2+"

function depends_sdl1dispmanx() {
    getDepends libudev-dev libasound2-dev libdbus-1-dev libraspberrypi0 libraspberrypi-bin libraspberrypi-dev
}

function sources_sdl1dispmanx() {
    gitPullOrClone "$md_build" https://github.com/vanfanel/SDL12-kms-dispmanx.git
}

function build_sdl1dispmanx() {
    make clean
    ./configure --prefix="$md_inst" --disable-video-opengl --enable-video-dispmanx --disable-video-fbcon --disable-video-kms --disable-video-directfb --disable-oss --disable-alsatest --disable-pulseaudio --disable-pulseaudio-shared --disable-arts --disable-nas --disable-esd --disable-nas-shared --disable-diskaudio --disable-dummyaudio --disable-mintaudio
}

function install_sdl1dispmanx() {
    make install
}
