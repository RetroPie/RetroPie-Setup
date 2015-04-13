#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="advmame"
rp_module_desc="AdvanceMAME"
rp_module_menus="2+"

function depends_advmame() {
    getDepends libsdl1.2-dev
}

function sources_advmame() {
    local version
    for version in 0.94.0 1.2; do
        mkdir -p "$version"
        pushd "$version"
        wget -O- -q "http://downloads.petrockblock.com/retropiearchives/advancemame-$version.tar.gz" | tar -xvz --strip-components=1

        # update internal names to separate out config files (due to incompatible options)
        sed -i "s/advmame\.rc/advmame-$version.rc/" advance/v/v.c advance/cfg/cfg.c
        if [[ "$version" != "1.2" ]]; then
            sed -i "s/ADVANCE_NAME \"advmame\"/ADVANCE_NAME \"advmame-$version\"/" advance/osd/emu.h
        else
            sed -i "s/ADV_NAME \"advmame\"/ADV_NAME \"advmame-$version\"/" advance/osd/emu.h
        fi

        if isPlatform "rpi"; then
            if [[ "$version" != "1.2" ]]; then
                sed -i 's/MAP_SHARED | MAP_FIXED,/MAP_SHARED,/' advance/linux/vfb.c
            fi
            # patch advmame to use a fake generated mode with the exact dimensions for fb - avoids need for configuring monitor / clocks.
            # the pi framebuffer doesn't use any of the framebuffer timing configs - it hardware scales from chosen dimensions to actual size
            patch -p1 <<\_EOF_
--- a/advance/linux/vfb.c
+++ b/advance/linux/vfb.c
@@ -268,7 +268,7 @@
 	var->height = 0;
 	var->width = 0;
 	var->accel_flags = FB_ACCEL_NONE;
-	var->pixclock = (unsigned)(1000000000000LL / pixelclock);
+	var->pixclock = pixelclock;
 	var->left_margin = ht - hre;
 	var->right_margin = hrs - hde;
 	var->upper_margin = vt - vre;
@@ -587,9 +587,8 @@
 		goto err_close;
 	}
 
-	fb_state.flags = VIDEO_DRIVER_FLAGS_MODE_PALETTE8 | VIDEO_DRIVER_FLAGS_MODE_BGR15 | VIDEO_DRIVER_FLAGS_MODE_BGR16 | VIDEO_DRIVER_FLAGS_MODE_BGR24 | VIDEO_DRIVER_FLAGS_MODE_BGR32
-		| VIDEO_DRIVER_FLAGS_PROGRAMMABLE_ALL
-		| VIDEO_DRIVER_FLAGS_OUTPUT_FULLSCREEN;
+	fb_state.flags = VIDEO_DRIVER_FLAGS_MODE_PALETTE8 | VIDEO_DRIVER_FLAGS_MODE_BGR16 | VIDEO_DRIVER_FLAGS_MODE_BGR24 | VIDEO_DRIVER_FLAGS_MODE_BGR32
+		| VIDEO_DRIVER_FLAGS_OUTPUT_WINDOW;
 
 	if (fb_detect() != 0) {
 		goto err_close;
@@ -1120,14 +1119,10 @@
 {
 	assert(fb_is_active());
 
-	if (crtc_is_fake(crtc)) {
-		error_nolog_set("Not programmable modes are not supported.\n");
+	if (!crtc_is_fake(crtc)) {
 		return -1;
 	}
 
-	if (video_mode_generate_check("fb", fb_flags(), 8, 2048, crtc, flags)!=0)
-		return -1;
-
 	mode->crtc = *crtc;
 	mode->index = flags & MODE_FLAGS_INDEX_MASK;

--- a/advance/osd/frame.c
+++ b/advance/osd/frame.c
@@ -1298,9 +1299,9 @@
 		best_vclock = context->state.game_fps;
 
 		video_init_crtc_make_fake(context, "generate", best_size_x, best_size_y);
+		video_init_crtc_make_fake(context, "generate-double-y", best_size_x, best_size_2y);
+		video_init_crtc_make_fake(context, "generate-double-x", best_size_2x, best_size_y);
 		video_init_crtc_make_fake(context, "generate-double", best_size_2x, best_size_2y);
-		video_init_crtc_make_fake(context, "generate-triple", best_size_3x, best_size_3y);
-		video_init_crtc_make_fake(context, "generate-quad", best_size_4x, best_size_4y);
 	} else {
 		unsigned long long factor_x;
 		unsigned long long factor_y;
_EOF_
        fi
        popd
    done
}

function build_advmame() {
    local version
    for version in *; do
        pushd "$version"
        ./configure CFLAGS="$CFLAGS -fsigned-char" LDFLAGS="-s -lm -Wl,--no-as-needed" --prefix="$md_inst/$version"
        make clean
        make
        popd
    done
}

function install_advmame() {
    local version
    for version in *; do
        pushd "$version"
        make install
        popd
    done
}

function configure_advmame() {
    mkRomDir "mame-advmame"

    # delete old install files
    rm -rf "$md_inst/"{bin,man,share}

    mkUserDir "$configdir/mame-advmame"

    # move any old configs to new location
    if [[ -d "$home/.advance" && ! -h "$home/.advance" ]]; then
        mv -v "$home/.advance/advmame.rc" "$configdir/mame-advmame/"
        mv -v "$home/.advance/"* "$configdir/mame-advmame/"
        rmdir "$home/.advance/"
    fi

    ln -snf "$configdir/mame-advmame" "$home/.advance"

    chown -R $user:$user "$configdir/mame-advmame"

    local version
    local default
    for version in *; do
        su "$user" -c "$md_inst/$version/bin/advmame --default"

        iniConfig " " "" "$configdir/mame-advmame/advmame-$version.rc"
        iniSet "misc_quiet" "yes"
        iniSet "device_video" "fb"
        iniSet "device_video_cursor" "off"
        iniSet "device_keyboard" "raw"
        iniSet "device_sound" "alsa"
        iniSet "display_vsync" "no"
        if isPlatform "rpi1"; then
            iniSet "sound_samplerate" "22050"
        else
            iniSet "sound_samplerate" "44100"
        fi
        iniSet "sound_latency" "0.2"
        iniSet "sound_normalize" "no"
        iniSet "dir_rom" "$romdir/mame-advmame"
        iniSet "dir_artwork" "$romdir/mame-advmame/artwork"
        iniSet "dir_sample" "$romdir/mame-advmame/samples"

        default=0
        isPlatform "rpi1" && [[ "$version" == "0.94.0" ]] && default=1
        isPlatform "rpi2" && [[ "$version" == "1.2" ]] && default=1
        addSystem $default "$md_id-$version" "mame-advmame arcade mame" "$md_inst/$version/bin/advmame %BASENAME%"
    done
}
