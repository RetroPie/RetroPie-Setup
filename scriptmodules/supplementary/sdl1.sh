rp_module_id="sdl1"
rp_module_desc="SDL 1.2.15 with rpi fixes"
rp_module_menus="2+"
rp_module_flags="!odroid nobin"

function depends_sdl1() {
    getDepends devscripts libx11-dev libxext-dev libxt-dev libxv-dev x11proto-core-dev libts-dev libaudiofile-dev libpulse-dev libgl1-mesa-dev libasound2-dev libcaca-dev libdirectfb-dev libglu1-mesa-dev
}

function sources_sdl1() {
    local src="deb-src http://mirrordirector.raspbian.org/raspbian/ wheezy main contrib non-free rpi"
    if ! grep -q "$src" /etc/apt/sources.list; then
        addLineToFile "$src" /etc/apt/sources.list
    fi
    apt-get update
    apt-get source libsdl1.2-dev
    cd libsdl1.2-1.2.15
    
    # add fixes from pssc https://github.com/raspberrypi/firmware/issues/354
cat >debian/patches/rpi.diff <<\_EOF_
--- a/src/video/fbcon/SDL_fbvideo.c	2012-01-19 06:30:06.000000000 +0000
+++ b/src/video/fbcon/SDL_fbvideo.c	2015-02-05 23:23:59.000000000 +0000
@@ -65,22 +65,29 @@
 #endif /* FB_TYPE_VGA_PLANES */
 
 /* A list of video resolutions that we query for (sorted largest to smallest) */
+/* http://en.wikipedia.org/wiki/Graphics_display_resolution */
 static const SDL_Rect checkres[] = {
-	{  0, 0, 1600, 1200 },		/* 16 bpp: 0x11E, or 286 */
-	{  0, 0, 1408, 1056 },		/* 16 bpp: 0x19A, or 410 */
-	{  0, 0, 1280, 1024 },		/* 16 bpp: 0x11A, or 282 */
-	{  0, 0, 1152,  864 },		/* 16 bpp: 0x192, or 402 */
-	{  0, 0, 1024,  768 },		/* 16 bpp: 0x117, or 279 */
+	{  0, 0, 1920, 1200 },		// WUXGA
+	{  0, 0, 1920, 1080 },		// 1080p FHD 16:9 = 1.7
+	{  0, 0, 1600, 1200 },		/* 16 bpp: 0x11E, or 286 / UXGA */
+	{  0, 0, 1408, 1056 },		/* 16 bpp: 0x19A, or 410 */	
+	{  0, 0, 1280, 1024 },		/* 16 bpp: 0x11A, or 282 / SXGA */
+	{  0, 0, 1280,  720 },		// 720p HD/WXGA 16:9 = 1.7
+	{  0, 0, 1152,  864 },		/* 16 bpp: 0x192, or 402 / XGA+ */
+	{  0, 0, 1024,  768 },		/* 16 bpp: 0x117, or 279 / XGA */
 	{  0, 0,  960,  720 },		/* 16 bpp: 0x18A, or 394 */
-	{  0, 0,  800,  600 },		/* 16 bpp: 0x114, or 276 */
+	{  0, 0,  800,  600 },		/* 16 bpp: 0x114, or 276 / SVGA */
+	{  0, 0,  800,  480 },		// WVGA   5:3 = 1.6
 	{  0, 0,  768,  576 },		/* 16 bpp: 0x182, or 386 */
 	{  0, 0,  720,  576 },		/* PAL */
 	{  0, 0,  720,  480 },		/* NTSC */
 	{  0, 0,  640,  480 },		/* 16 bpp: 0x111, or 273 */
 	{  0, 0,  640,  400 },		/*  8 bpp: 0x100, or 256 */
 	{  0, 0,  512,  384 },
-	{  0, 0,  320,  240 },
-	{  0, 0,  320,  200 }
+	{  0, 0,  480,  320 },		// HVGA   3:2 = 1.5
+	{  0, 0,  480,  272 },		// WQVGA?
+	{  0, 0,  320,  240 },		// QVGA	  4:3 = 1.3
+	{  0, 0,  320,  200 }		// CGA    4:3 = 1.3
 };
 static const struct {
 	int xres;
@@ -177,6 +184,8 @@
 #endif
 }
 
+static void print_finfo(struct fb_fix_screeninfo *finfo);
+
 
 /* Small wrapper for mmap() so we can play nicely with no-mmu hosts
  * (non-mmu hosts disallow the MAP_SHARED flag) */
@@ -329,6 +338,8 @@
 	}
 	while(1);
 
+	SDL_memset(vinfo, 0, sizeof(struct fb_var_screeninfo)); // prevent random junk 
+
 	SDL_sscanf(line, "geometry %d %d %d %d %d", &vinfo->xres, &vinfo->yres, 
 			&vinfo->xres_virtual, &vinfo->yres_virtual, &vinfo->bits_per_pixel);
 	if (read_fbmodes_line(f, line, sizeof(line))==0)
@@ -495,7 +506,6 @@
 
 static int FB_VideoInit(_THIS, SDL_PixelFormat *vformat)
 {
-	const int pagesize = SDL_getpagesize();
 	struct fb_fix_screeninfo finfo;
 	struct fb_var_screeninfo vinfo;
 	int i, j;
@@ -533,6 +543,10 @@
 		FB_VideoQuit(this);
 		return(-1);
 	}
+#ifdef FBCON_DEBUG
+	print_finfo(&finfo);
+#endif
+
 	switch (finfo.type) {
 		case FB_TYPE_PACKED_PIXELS:
 			/* Supported, no worries.. */
@@ -578,7 +592,7 @@
 
 	/* Memory map the device, compensating for buggy PPC mmap() */
 	mapped_offset = (((long)finfo.smem_start) -
-	                (((long)finfo.smem_start)&~(pagesize-1)));
+	                (((long)finfo.smem_start)&~(SDL_getpagesize()-1)));
 	mapped_memlen = finfo.smem_len+mapped_offset;
 	mapped_mem = do_mmap(NULL, mapped_memlen,
 	                  PROT_READ|PROT_WRITE, MAP_SHARED, console_fd, 0);
@@ -885,6 +899,10 @@
 		while ( read_fbmodes_mode(modesdb, &cinfo) ) {
 			if ( (vinfo->xres == cinfo.xres && vinfo->yres == cinfo.yres) &&
 			     (!matched || (vinfo->bits_per_pixel == cinfo.bits_per_pixel)) ) {
+#ifdef FBCON_DEBUG
+				fprintf(stderr, "Using FBModes timings for %dx%d\n",
+						vinfo->xres, vinfo->yres);
+#endif
 				vinfo->pixclock = cinfo.pixclock;
 				vinfo->left_margin = cinfo.left_margin;
 				vinfo->right_margin = cinfo.right_margin;
@@ -1015,13 +1033,20 @@
 	/* Restore the original palette */
 	FB_RestorePalette(this);
 
+	SDL_memset(&vinfo, 0, sizeof(vinfo));
 	/* Set the video mode and get the final screen format */
 	if ( ioctl(console_fd, FBIOGET_VSCREENINFO, &vinfo) < 0 ) {
 		SDL_SetError("Couldn't get console screen info");
 		return(NULL);
 	}
+	/* Get the type of video hardware */
+	if ( ioctl(console_fd, FBIOGET_FSCREENINFO, &finfo) < 0 ) {
+		SDL_SetError("Couldn't get console hardware info");
+		return(NULL);
+	}
 #ifdef FBCON_DEBUG
-	fprintf(stderr, "Printing original vinfo:\n");
+	fprintf(stderr, "Printing original info:\n");
+	print_finfo(&finfo);
 	print_vinfo(&vinfo);
 #endif
 	/* Do not use double buffering with shadow buffer */
@@ -1031,6 +1056,10 @@
 
 	if ( (vinfo.xres != width) || (vinfo.yres != height) ||
 	     (vinfo.bits_per_pixel != bpp) || (flags & SDL_DOUBLEBUF) ) {
+#ifdef FBCON_DEBUG
+	fprintf(stderr, "Request %dx%d %d Actual %dx%d %d %s flags %x current %dx%d\n",width,height,bpp,vinfo.xres,vinfo.yres,vinfo.bits_per_pixel,(flags & SDL_DOUBLEBUF) ? "SDL_DOUBLEBUF" : "" ,flags , current->w,current->h);
+#endif
+		SDL_memset(&vinfo, 0, sizeof(vinfo));
 		vinfo.activate = FB_ACTIVATE_NOW;
 		vinfo.accel_flags = 0;
 		vinfo.bits_per_pixel = bpp;
@@ -1048,6 +1077,9 @@
 		vinfo.green.length = vinfo.green.offset = 0;
 		vinfo.blue.length = vinfo.blue.offset = 0;
 		vinfo.transp.length = vinfo.transp.offset = 0;
+	//	vinfo.height = 0;
+	//	vinfo.width = 0;
+	//	vinfo.vmode |= FB_VMODE_CONUPDATE;
 		if ( ! choose_fbmodes_mode(&vinfo) ) {
 			choose_vesa_mode(&vinfo);
 		}
@@ -1076,11 +1108,20 @@
 			vinfo.yres_virtual = maxheight;
 		}
 	}
-	cache_vinfo = vinfo;
+	/* Get the fixed information about the console hardware.
+	   This is necessary since finfo.line_length changes.
+	   and in case RPI the frame buffer offsets and length change
+	 */
+	if ( ioctl(console_fd, FBIOGET_FSCREENINFO, &finfo) < 0 ) {
+		SDL_SetError("Couldn't get console hardware info");
+		return(NULL);
+	}
 #ifdef FBCON_DEBUG
-	fprintf(stderr, "Printing actual vinfo:\n");
+	fprintf(stderr, "Printing actual info:\n");
+	print_finfo(&finfo);
 	print_vinfo(&vinfo);
 #endif
+	cache_vinfo = vinfo;
 	Rmask = 0;
 	for ( i=0; i<vinfo.red.length; ++i ) {
 		Rmask <<= 1;
@@ -1100,15 +1141,6 @@
 	                                  Rmask, Gmask, Bmask, 0) ) {
 		return(NULL);
 	}
-
-	/* Get the fixed information about the console hardware.
-	   This is necessary since finfo.line_length changes.
-	 */
-	if ( ioctl(console_fd, FBIOGET_FSCREENINFO, &finfo) < 0 ) {
-		SDL_SetError("Couldn't get console hardware info");
-		return(NULL);
-	}
-
 	/* Save hardware palette, if needed */
 	FB_SavePalette(this, &finfo, &vinfo);
 
@@ -1129,6 +1161,20 @@
 		}
 	}
 
+	munmap(mapped_mem, mapped_memlen);
+	/* Memory map the device, compensating for buggy PPC mmap() */
+	mapped_offset = (((long)finfo.smem_start) -
+	                (((long)finfo.smem_start)&~(SDL_getpagesize()-1)));
+	mapped_memlen = finfo.smem_len+mapped_offset;
+	mapped_mem = do_mmap(NULL, mapped_memlen,
+	                  PROT_READ|PROT_WRITE, MAP_SHARED, console_fd, 0);
+	if ( mapped_mem == (char *)-1 ) {
+		SDL_SetError("Unable to memory map the video hardware");
+		mapped_mem = NULL;
+		FB_VideoQuit(this);
+		return(NULL);
+	}
+
 	/* Set up the new mode framebuffer */
 	current->flags &= SDL_FULLSCREEN;
 	if (shadow_fb) {
@@ -1167,7 +1213,7 @@
 
 	/* Update for double-buffering, if we can */
 	if ( flags & SDL_DOUBLEBUF ) {
-		if ( vinfo.yres_virtual == (height*2) ) {
+		if ( vinfo.yres_virtual >= (vinfo.yres*2) ) {
 			current->flags |= SDL_DOUBLEBUF;
 			flip_page = 0;
 			flip_address[0] = (char *)current->pixels;
@@ -1176,6 +1222,10 @@
 			this->screen = current;
 			FB_FlipHWSurface(this, current);
 			this->screen = NULL;
+#ifdef FBCON_DEBUG
+                        fprintf(stderr, "SDL_DOUBLEBUF 0:%x 1:%x pitch %x\n",(unsigned int)flip_address[0],(unsigned int) flip_address[1],current->pitch);
+#endif
+
 		}
 	}
 
@@ -1426,8 +1476,12 @@
 		return -2; /* no hardware access */
 	}
 
+#ifdef FBCON_DEBUG
+	fprintf(stderr, "Flip vinfo offset changing to %d current:\n",flip_page*cache_vinfo.yres);
+	print_vinfo(&cache_vinfo);
+#endif
 	/* Wait for vertical retrace and then flip display */
-	cache_vinfo.yoffset = flip_page*surface->h;
+	cache_vinfo.yoffset = flip_page*cache_vinfo.yres;
 	if ( FB_IsSurfaceBusy(this->screen) ) {
 		FB_WaitBusySurfaces(this);
 	}
_EOF_

    echo "rpi.diff" >>debian/patches/series
    DEBEMAIL="Jools Wills <buzz@exotica.org.uk>" dch -v 1.2.15-6rpi "Added rpi fixes from pssc - https://github.com/raspberrypi/firmware/issues/354"
}

function build_sdl1() {
    cd libsdl1.2-1.2.15
    dpkg-buildpackage
}

function install_sdl1() {
    dpkg -i libsdl1.2debian_1.2.15-6rpi_armhf.deb libsdl1.2-dev_1.2.15-6rpi_armhf.deb
    rm *.deb
}

function install_bin_sdl1() {
    isPlatform "rpi" || fatalError "$mod_id is only available as a binary package for platform rpi"
    wget "$__binary_url/libsdl1.2debian_1.2.15-6rpi_armhf.deb"
    wget "$__binary_url/libsdl1.2-dev_1.2.15-6rpi_armhf.deb"
    # if the packages don't install completely due to missing dependencies the apt-get -y -f install will correct it
    if ! dpkg -i libsdl1.2debian_1.2.15-6rpi_armhf.deb libsdl1.2-dev_1.2.15-6rpi_armhf.deb; then
        apt-get -y -f install
    fi
    rm ./*.deb
}
