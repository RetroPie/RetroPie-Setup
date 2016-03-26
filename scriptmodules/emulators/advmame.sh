#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="advmame"
rp_module_desc="AdvanceMAME"
rp_module_menus="2+"
rp_module_flags="!mali"

function depends_advmame() {
    getDepends libsdl1.2-dev
}

function sources_advmame() {
    local version
    for version in 0.94.0 1.4; do
        mkdir -p "$version"
        pushd "$version"
        wget -O- -q "$__archive_url/advancemame-$version.tar.gz" | tar -xvz --strip-components=1

        # update internal names to separate out config files (due to incompatible options)
        sed -i "s/advmame\.rc/advmame-$version.rc/" advance/v/v.c advance/cfg/cfg.c
        if [[ "$version" == "0.94.0" ]]; then
            sed -i "s/ADVANCE_NAME \"advmame\"/ADVANCE_NAME \"advmame-$version\"/" advance/osd/emu.h
        else
            sed -i "s/ADV_NAME \"advmame\"/ADV_NAME \"advmame-$version\"/" advance/osd/emu.h
        fi

        if isPlatform "rpi"; then
            if [[ "$version" == "0.94.0" ]]; then
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
--- a/advance/osd/frame.c
+++ b/advance/osd/frame.c
@@ -2425,6 +2425,7 @@ void advance_video_mode_preinit(struct advance_video_context* context, struct ma
 	}
 	log_std(("emu:video: suggested debugger size %dx%d\n", option->debug_width, option->debug_height));
 
+#if 0
 	/* set the vector game size */
 	if (mame_is_game_vector(option->game)) {
 		unsigned mode_size_x;
@@ -2484,6 +2485,7 @@ void advance_video_mode_preinit(struct advance_video_context* context, struct ma
 		option->vector_width = 0;
 		option->vector_height = 0;
 	}
+#endif
 }
 
 /**
--- a/advance/osd/glue.c
+++ b/advance/osd/glue.c
@@ -2866,6 +2866,9 @@ adv_error mame_init(struct advance_context* context)
 	conf_float_register_limit_default(context->cfg, "display_gamma", 0.5, 2.0, 1.0);
 	conf_float_register_limit_default(context->cfg, "display_brightness", 0.1, 10.0, 1.0);
 
+	conf_int_register_default(context->cfg, "display_width", 640);
+	conf_int_register_default(context->cfg, "display_height", 480);
+
 	conf_bool_register_default(context->cfg, "misc_cheat", 0);
 	conf_string_register_default(context->cfg, "misc_languagefile", "english.lng");
 	conf_string_register_default(context->cfg, "misc_cheatfile", "cheat.dat");
@@ -2915,6 +2918,8 @@ adv_error mame_config_load(adv_conf* cfg_context, struct mame_option* option)
 
 	option->gamma = conf_float_get_default(cfg_context, "display_gamma");
 	option->brightness = conf_float_get_default(cfg_context, "display_brightness");
+	option->vector_width = conf_int_get_default(cfg_context, "display_width");
+	option->vector_height = conf_int_get_default(cfg_context, "display_height");
 
 	option->cheat_flag = conf_bool_get_default(cfg_context, "misc_cheat");
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
    mkRomDir "arcade"
    mkRomDir "mame-advmame"

    # delete old install files
    rm -rf "$md_inst/"{bin,man,share}

    moveConfigDir "$home/.advance" "$md_conf_root/mame-advmame"

    local version
    local default
    for version in *; do
        su "$user" -c "$md_inst/$version/bin/advmame --default"

        iniConfig " " "" "$md_conf_root/mame-advmame/advmame-$version.rc"

        iniSet "misc_quiet" "yes"
        iniSet "dir_rom" "$romdir/mame-advmame:$romdir/arcade"
        iniSet "dir_artwork" "$romdir/mame-advmame/artwork:$romdir/arcade/artwork"
        iniSet "dir_sample" "$romdir/mame-advmame/samples:$romdir/arcade/sample"

        if isPlatform "rpi"; then
            iniSet "device_video" "fb"
            iniSet "device_video_cursor" "off"
            iniSet "device_keyboard" "raw"
            iniSet "device_sound" "alsa"
            iniSet "display_vsync" "no"
            iniSet "sound_latency" "0.2"
            iniSet "sound_normalize" "no"
        else
            iniSet "device_video_output" "overlay"
            iniSet "display_aspectx" 16
            iniSet "display_aspecty" 9
        fi

        if isPlatform "armv6"; then
            iniSet "sound_samplerate" "22050"
        else
            iniSet "sound_samplerate" "44100"
        fi

        default=0
        if isPlatform "rpi"; then
            [[ "$version" == "0.94.0" ]] && default=1
        else
            [[ "$version" == "1.4" ]] && default=1
        fi
        addSystem 0 "$md_id-$version" "arcade" "$md_inst/$version/bin/advmame %BASENAME%"
        addSystem $default "$md_id-$version" "mame-advmame arcade mame" "$md_inst/$version/bin/advmame %BASENAME%"
    done
}
