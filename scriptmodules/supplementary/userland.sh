# If threaded_video runs slower or audio stutters after rpi-update rebuild userland libs.
# Retroarch seems to run slower with prebuild libs.
rp_module_id="userland"
rp_module_desc="Raspbian userland libs"
rp_module_menus="4+"

function depends_userland() {
	checkNeededPackages gcc-4.8 g++-4.8
}

function sources_userland() {
    gitPullOrClone "$md_build" "https://github.com/raspberrypi/userland" NS
    sed -i 's/-mcpu=arm1176jzf-s/-march=armv6j/g' /userland/makefiles/cmake/toolchains/arm-linux-gnueabihf.cmake
}

function build_userland() {
    gcc_version 4.8
    ./buildme
    gcc_version $__default_gcc_version
    sync
}
