#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="sdl2"
rp_module_desc="SDL (Simple DirectMedia Layer) v2.x"
rp_module_menus=""
rp_module_flags="nobin !x86"

function get_ver_sdl2() {
    local ver="2.0.4+2"
    isPlatform "rpi" && ver+="rpi"
    isPlatform "mali" && ver+="mali"
    echo "$ver"
}

function depends_sdl2() {
    # Dependencies from the debian package control + additional dependencies for the pi (some are excluded like dpkg-dev as they are
    # already covered by the build-essential package retropie relies on.
    local depends=(devscripts debhelper dh-autoreconf libasound2-dev libudev-dev libibus-1.0-dev libdbus-1-dev libx11-dev libxcursor-dev libxext-dev libxi-dev libxinerama-dev libxrandr-dev libxss-dev libxt-dev libxxf86vm-dev)
    isPlatform "rpi" && depends+=(libraspberrypi-dev)
    isPlatform "mali" && depends+=(mali-fbdev)
    getDepends "${depends[@]}"
}

function sources_sdl2() {
    local branch="release-2.0.4"
    isPlatform "rpi" && branch="retropie-2.0.4"
    isPlatform "mali" && branch="mali-2.0.4"
    gitPullOrClone "$md_build/$(get_ver_sdl2)" https://github.com/RetroPie/SDL-mirror.git "$branch"
    cd $(get_ver_sdl2)
    DEBEMAIL="Jools Wills <buzz@exotica.org.uk>" dch -v $(get_ver_sdl2) "SDL 2.0.4 configured for the $__platform"
}

function build_sdl2() {
    cd $(get_ver_sdl2)
    dpkg-buildpackage
    md_ret_require="$md_build/libsdl2-dev_$(get_ver_sdl2)_armhf.deb"
    local dest="$__tmpdir/archives/$__raspbian_name/$__platform"
    mkdir -p "$dest"
    cp ../*.deb "$dest/"
}

function remove_old_sdl2() {
    # remove old libSDL
    if [[ -f /usr/local/bin/sdl2-config ]]; then
        echo "Removing old SDL2 files"
        while read file; do
            rm -f $file
        done << _EOF_
/usr/local/bin/sdl2-config
/usr/local/include/SDL2/SDL.h
/usr/local/include/SDL2/SDL_assert.h
/usr/local/include/SDL2/SDL_atomic.h
/usr/local/include/SDL2/SDL_audio.h
/usr/local/include/SDL2/SDL_bits.h
/usr/local/include/SDL2/SDL_blendmode.h
/usr/local/include/SDL2/SDL_clipboard.h
/usr/local/include/SDL2/SDL_cpuinfo.h
/usr/local/include/SDL2/SDL_endian.h
/usr/local/include/SDL2/SDL_error.h
/usr/local/include/SDL2/SDL_events.h
/usr/local/include/SDL2/SDL_filesystem.h
/usr/local/include/SDL2/SDL_gamecontroller.h
/usr/local/include/SDL2/SDL_gesture.h
/usr/local/include/SDL2/SDL_haptic.h
/usr/local/include/SDL2/SDL_hints.h
/usr/local/include/SDL2/SDL_joystick.h
/usr/local/include/SDL2/SDL_keyboard.h
/usr/local/include/SDL2/SDL_keycode.h
/usr/local/include/SDL2/SDL_loadso.h
/usr/local/include/SDL2/SDL_log.h
/usr/local/include/SDL2/SDL_main.h
/usr/local/include/SDL2/SDL_messagebox.h
/usr/local/include/SDL2/SDL_mouse.h
/usr/local/include/SDL2/SDL_mutex.h
/usr/local/include/SDL2/SDL_name.h
/usr/local/include/SDL2/SDL_opengl.h
/usr/local/include/SDL2/SDL_opengles.h
/usr/local/include/SDL2/SDL_opengles2.h
/usr/local/include/SDL2/SDL_pixels.h
/usr/local/include/SDL2/SDL_platform.h
/usr/local/include/SDL2/SDL_power.h
/usr/local/include/SDL2/SDL_quit.h
/usr/local/include/SDL2/SDL_rect.h
/usr/local/include/SDL2/SDL_render.h
/usr/local/include/SDL2/SDL_rwops.h
/usr/local/include/SDL2/SDL_scancode.h
/usr/local/include/SDL2/SDL_shape.h
/usr/local/include/SDL2/SDL_stdinc.h
/usr/local/include/SDL2/SDL_surface.h
/usr/local/include/SDL2/SDL_system.h
/usr/local/include/SDL2/SDL_syswm.h
/usr/local/include/SDL2/SDL_thread.h
/usr/local/include/SDL2/SDL_timer.h
/usr/local/include/SDL2/SDL_touch.h
/usr/local/include/SDL2/SDL_types.h
/usr/local/include/SDL2/SDL_version.h
/usr/local/include/SDL2/SDL_video.h
/usr/local/include/SDL2/begin_code.h
/usr/local/include/SDL2/close_code.h
/usr/local/include/SDL2/SDL_test_assert.h
/usr/local/include/SDL2/SDL_test_common.h
/usr/local/include/SDL2/SDL_test_compare.h
/usr/local/include/SDL2/SDL_test_crc32.h
/usr/local/include/SDL2/SDL_test_font.h
/usr/local/include/SDL2/SDL_test_fuzzer.h
/usr/local/include/SDL2/SDL_test.h
/usr/local/include/SDL2/SDL_test_harness.h
/usr/local/include/SDL2/SDL_test_images.h
/usr/local/include/SDL2/SDL_test_log.h
/usr/local/include/SDL2/SDL_test_md5.h
/usr/local/include/SDL2/SDL_test_random.h
/usr/local/include/SDL2/SDL_config.h
/usr/local/include/SDL2/SDL_revision.h
/usr/local/lib/libSDL2.la
/usr/local/lib/libSDL2.la
/usr/local/lib/libSDL2-2.0.so.0.1.0
/usr/local/lib/libSDL2-2.0.so.0
/usr/local/lib/libSDL2.so
/usr/local/lib/libSDL2.a
/usr/local/lib/libSDL2main.a
/usr/local/lib/libSDL2_test.a
/usr/local/share/aclocal/sdl2.m4
/usr/local/lib/pkgconfig/sdl2.pc
_EOF_
    fi
    # remove our old libsdl2 packages
    hasPackage libsdl2 && dpkg --remove libsdl2 libsdl2-dev
}

function install_sdl2() {
    remove_old_sdl2
    # if the packages don't install completely due to missing dependencies the apt-get -y -f install will correct it
    if ! dpkg -i libsdl2-2.0-0_$(get_ver_sdl2)_armhf.deb libsdl2-dev_$(get_ver_sdl2)_armhf.deb; then
        apt-get -y -f install
    fi
    echo "libsdl2-dev hold" | dpkg --set-selections
}

function install_bin_sdl2() {
    isPlatform "rpi" || fatalError "$mod_id is only available as a binary package for platform rpi"
    wget -c "$__binary_url/libsdl2-dev_$(get_ver_sdl2)_armhf.deb"
    wget -c "$__binary_url/libsdl2-2.0-0_$(get_ver_sdl2)_armhf.deb"
    install_sdl2
    rm ./*.deb
}

function remove_sdl2() {
    apt-get remove -y --force-yes libsdl2-dev
    apt-get autoremove -y
}
