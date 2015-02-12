rp_module_id="sdl1"
rp_module_desc="SDL 1.2.15 with rpi fixes and dispmanx"
rp_module_menus=""
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
Index: libsdl1.2-1.2.15/src/video/fbcon/SDL_fbvideo.c
===================================================================
--- libsdl1.2-1.2.15.orig/src/video/fbcon/SDL_fbvideo.c	2012-01-19 06:30:06.000000000 +0000
+++ libsdl1.2-1.2.15/src/video/fbcon/SDL_fbvideo.c	2015-02-06 13:15:53.000000000 +0000
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
 
@@ -1409,9 +1459,7 @@
 
 static void FB_WaitVBL(_THIS)
 {
-#ifdef FBIOWAITRETRACE /* Heheh, this didn't make it into the main kernel */
-	ioctl(console_fd, FBIOWAITRETRACE, 0);
-#endif
+	ioctl(console_fd, FBIO_WAITFORVSYNC, 0);
 	return;
 }
 
@@ -1426,8 +1474,12 @@
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

cat >debian/patches/dispmanx.diff <<\_EOF_
diff --git a/configure.in b/configure.in
index 08c8e1e..f76e671 100644
--- a/configure.in
+++ b/configure.in
@@ -1252,6 +1252,26 @@ AC_HELP_STRING([--enable-video-fbcon], [use framebuffer console video driver [[d
     fi
 }
 
+dnl Find the DISPMANX includes
+CheckDISPMANX()
+{
+    AC_ARG_ENABLE(video-dispmanx,
+AC_HELP_STRING([--enable-video-dispmanx], [use DISPMANX video modes [[default=yes]]]),
+                  , enable_video_dispmanx=yes)
+    if test x$enable_video = xyes -a x$enable_video_dispmanx = xyes; then
+        AC_MSG_CHECKING(for dispmanx support)
+        DISPMANX_LDFLAGS="-L/opt/vc/lib -lbcm_host -lvcos -lvchiq_arm"
+        DISPMANX_INCLUDES="-I/opt/vc/include -I/opt/vc/include/interface/vcos/pthreads -I/opt/vc/include/interface/vmcs_host/linux"
+        EXTRA_CFLAGS="$EXTRA_CFLAGS $DISPMANX_INCLUDES"
+        EXTRA_LDFLAGS="$EXTRA_LDFLAGS $DISPMANX_LDFLAGS"
+        SOURCES="$SOURCES $srcdir/src/video/dispmanx/*.c"
+        AC_DEFINE(SDL_VIDEO_DRIVER_DISPMANX)
+        video_dispmanx=yes
+        have_video=yes
+        AC_MSG_RESULT($video_dispmanx)
+    fi
+}
+
 dnl Find DirectFB
 CheckDirectFB()
 {
@@ -2363,6 +2383,7 @@ case "$host" in
         CheckX11
         CheckNANOX
         CheckFBCON
+        CheckDISPMANX
         CheckDirectFB
         CheckPS2GS
         CheckPS3
diff --git a/include/SDL_config.h.in b/include/SDL_config.h.in
index 8bb1773..31cb2a4 100644
--- a/include/SDL_config.h.in
+++ b/include/SDL_config.h.in
@@ -263,6 +263,7 @@
 #undef SDL_VIDEO_DRIVER_DRAWSPROCKET
 #undef SDL_VIDEO_DRIVER_DUMMY
 #undef SDL_VIDEO_DRIVER_FBCON
+#undef SDL_VIDEO_DRIVER_DISPMANX
 #undef SDL_VIDEO_DRIVER_GAPI
 #undef SDL_VIDEO_DRIVER_GEM
 #undef SDL_VIDEO_DRIVER_GGI
diff --git a/src/SDL.c b/src/SDL.c
index 87f1b1a..84c0cab 100644
--- a/src/SDL.c
+++ b/src/SDL.c
@@ -86,7 +86,7 @@ int SDL_InitSubSystem(Uint32 flags)
 #if !SDL_VIDEO_DISABLED
 	/* Initialize the video/event subsystem */
 	if ( (flags & SDL_INIT_VIDEO) && !(SDL_initialized & SDL_INIT_VIDEO) ) {
-		if ( SDL_VideoInit(SDL_getenv("SDL_VIDEODRIVER"),
+		if ( SDL_VideoInit(SDL_getenv("SDL1_VIDEODRIVER"),
 		                   (flags&SDL_INIT_EVENTTHREAD)) < 0 ) {
 			return(-1);
 		}
diff --git a/src/video/SDL_sysvideo.h b/src/video/SDL_sysvideo.h
index 436450e..17fa785 100644
--- a/src/video/SDL_sysvideo.h
+++ b/src/video/SDL_sysvideo.h
@@ -344,6 +344,9 @@ extern VideoBootStrap FBCON_bootstrap;
 #if SDL_VIDEO_DRIVER_DIRECTFB
 extern VideoBootStrap DirectFB_bootstrap;
 #endif
+#if SDL_VIDEO_DRIVER_DISPMANX
+extern VideoBootStrap DISPMANX_bootstrap;
+#endif
 #if SDL_VIDEO_DRIVER_PS2GS
 extern VideoBootStrap PS2GS_bootstrap;
 #endif
diff --git a/src/video/SDL_video.c b/src/video/SDL_video.c
index 46285c9..8f7dfaa 100644
--- a/src/video/SDL_video.c
+++ b/src/video/SDL_video.c
@@ -57,6 +57,9 @@ static VideoBootStrap *bootstrap[] = {
 #if SDL_VIDEO_DRIVER_FBCON
 	&FBCON_bootstrap,
 #endif
+#if SDL_VIDEO_DRIVER_DISPMANX
+	&DISPMANX_bootstrap,
+#endif
 #if SDL_VIDEO_DRIVER_DIRECTFB
 	&DirectFB_bootstrap,
 #endif
diff --git a/src/video/dispmanx/SDL_dispmanxvideo.c b/src/video/dispmanx/SDL_dispmanxvideo.c
new file mode 100644
index 0000000..5daf763
--- /dev/null
+++ b/src/video/dispmanx/SDL_dispmanxvideo.c
@@ -0,0 +1,407 @@
+/*
+	SDL - Simple DirectMedia Layer
+	Copyright (C) 1997-2012 Sam Lantinga
+
+	This library is free software; you can redistribute it and/or
+	modify it under the terms of the GNU Lesser General Public
+	License as published by the Free Software Foundation; either
+	version 2.1 of the License, or (at your option) any later version.
+
+	This library is distributed in the hope that it will be useful,
+	but WITHOUT ANY WARRANTY; without even the implied warranty of
+	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+	Lesser General Public License for more details.
+
+	You should have received a copy of the GNU Lesser General Public
+	License along with this library; if not, write to the Free Software
+	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
+
+	Sam Lantinga
+	slouken@libsdl.org
+*/
+
+#include "SDL_config.h"
+
+#include <stdio.h>
+
+#include <string.h>
+
+#include <bcm_host.h>
+
+#include "SDL_video.h"
+#include "SDL_mouse.h"
+#include "../SDL_sysvideo.h"
+#include "../SDL_pixels_c.h"
+#include "../fbcon/SDL_fbmouse_c.h"
+#include "../fbcon/SDL_fbevents_c.h"
+
+#define min(a,b) ((a)<(b)?(a):(b))
+#define RGB565(r,g,b) (((r)>>3)<<11 | ((g)>>2)<<5 | (b)>>3)
+
+/* Initialization/Query functions */
+static int DISPMANX_VideoInit(_THIS, SDL_PixelFormat *vformat);
+static SDL_Rect **DISPMANX_ListModes(_THIS, SDL_PixelFormat *format, Uint32 flags);
+static SDL_Surface *DISPMANX_SetVideoMode(_THIS, SDL_Surface *current, int width, int height, int bpp, Uint32 flags);
+static int DISPMANX_SetColors(_THIS, int firstcolor, int ncolors, SDL_Color *colors);
+static void DISPMANX_VideoQuit(_THIS);
+
+/* Hardware surface functions */
+static void DISPMANX_WaitVBL(_THIS);
+static void DISPMANX_WaitIdle(_THIS);
+static void DISPMANX_DirectUpdate(_THIS, int numrects, SDL_Rect *rects);
+static void DISPMANX_BlankBackground(void);
+static void DISPMANX_FreeResources(void);
+static void DISPMANX_FreeBackground (void);
+
+typedef struct {
+	DISPMANX_DISPLAY_HANDLE_T   display;
+	DISPMANX_MODEINFO_T         amode;
+	void                        *pixmem;
+	DISPMANX_UPDATE_HANDLE_T    update;
+	DISPMANX_RESOURCE_HANDLE_T  resources[2];
+	DISPMANX_ELEMENT_HANDLE_T   element;
+	VC_IMAGE_TYPE_T             pix_format;
+	uint32_t                    vc_image_ptr;
+	VC_DISPMANX_ALPHA_T         *alpha;
+	VC_RECT_T                   src_rect;
+	VC_RECT_T                   dst_rect;
+	VC_RECT_T                   bmp_rect;
+	int bits_per_pixel;
+	int pitch;
+
+	DISPMANX_RESOURCE_HANDLE_T  b_resource;
+	DISPMANX_ELEMENT_HANDLE_T   b_element;
+	DISPMANX_UPDATE_HANDLE_T    b_update;
+
+	int ignore_ratio;
+
+} __DISPMAN_VARIABLES_T;
+
+
+static __DISPMAN_VARIABLES_T _DISPMAN_VARS;
+static __DISPMAN_VARIABLES_T *dispvars = &_DISPMAN_VARS;
+
+static int DISPMANX_Available(void)
+{
+	return (1);
+}
+
+static void DISPMANX_DeleteDevice(SDL_VideoDevice *device)
+{
+	SDL_free(device->hidden);
+	SDL_free(device);
+}
+
+static SDL_VideoDevice *DISPMANX_CreateDevice(int devindex)
+{
+	SDL_VideoDevice *this;
+
+	/* Initialize all variables that we clean on shutdown */
+	this = (SDL_VideoDevice *)SDL_malloc(sizeof(SDL_VideoDevice));
+	if ( this ) {
+		SDL_memset(this, 0, (sizeof *this));
+		this->hidden = (struct SDL_PrivateVideoData *)
+				SDL_malloc((sizeof *this->hidden));
+	}
+	if ( (this == NULL) || (this->hidden == NULL) ) {
+		SDL_OutOfMemory();
+		if ( this ) {
+			SDL_free(this);
+		}
+		return(0);
+	}
+	SDL_memset(this->hidden, 0, (sizeof *this->hidden));
+	wait_vbl = DISPMANX_WaitVBL;
+	wait_idle = DISPMANX_WaitIdle;
+	mouse_fd = -1;
+	keyboard_fd = -1;
+
+	/* Set the function pointers */
+	this->VideoInit = DISPMANX_VideoInit;
+	this->ListModes = DISPMANX_ListModes;
+	this->SetVideoMode = DISPMANX_SetVideoMode;
+	this->SetColors = DISPMANX_SetColors;
+	this->UpdateRects = DISPMANX_DirectUpdate;
+	this->VideoQuit = DISPMANX_VideoQuit;
+	this->CheckHWBlit = NULL;
+	this->FillHWRect = NULL;
+	this->SetHWColorKey = NULL;
+	this->SetHWAlpha = NULL;
+	this->SetCaption = NULL;
+	this->SetIcon = NULL;
+	this->IconifyWindow = NULL;
+	this->GrabInput = NULL;
+	this->GetWMInfo = NULL;
+	this->InitOSKeymap = FB_InitOSKeymap;
+	this->PumpEvents = FB_PumpEvents;
+	this->CreateYUVOverlay = NULL;
+
+	this->free = DISPMANX_DeleteDevice;
+
+	return this;
+}
+
+VideoBootStrap DISPMANX_bootstrap = {
+	"dispmanx", "Dispmanx Raspberry Pi VC",
+	DISPMANX_Available, DISPMANX_CreateDevice
+};
+
+static int DISPMANX_VideoInit(_THIS, SDL_PixelFormat *vformat)
+{
+#if !SDL_THREADS_DISABLED
+	/* Create the hardware surface lock mutex */
+	hw_lock = SDL_CreateMutex();
+	if ( hw_lock == NULL ) {
+		SDL_SetError("Unable to create lock mutex");
+		DISPMANX_VideoQuit(this);
+		return(-1);
+	}
+#endif
+
+	/* Enable mouse and keyboard support */
+	if ( FB_OpenKeyboard(this) < 0 ) {
+		DISPMANX_VideoQuit(this);
+		return(-1);
+	}
+	if ( FB_OpenMouse(this) < 0 ) {
+		const char *sdl_nomouse;
+
+		sdl_nomouse = SDL_getenv("SDL_NOMOUSE");
+		if ( ! sdl_nomouse ) {
+			SDL_SetError("Unable to open mouse");
+			DISPMANX_VideoQuit(this);
+			return(-1);
+		}
+	}
+
+	vformat->BitsPerPixel = 16;
+	vformat->Rmask = 0;
+	vformat->Gmask = 0;
+	vformat->Bmask = 0;
+
+	/* We're done! */
+	return(0);
+}
+
+static SDL_Surface *DISPMANX_SetVideoMode(_THIS, SDL_Surface *current, int width, int height, int bpp, Uint32 flags)
+{
+	if ((width == 0) | (height == 0)) goto go_video_console;
+
+	uint32_t screen = 0;
+
+	bcm_host_init();
+
+	dispvars->display = vc_dispmanx_display_open( screen );
+
+	vc_dispmanx_display_get_info( dispvars->display, &(dispvars->amode));
+	printf( "Dispmanx: Physical video mode is %d x %d\n",
+	dispvars->amode.width, dispvars->amode.height );
+
+	DISPMANX_BlankBackground();
+
+	Uint32 Rmask;
+	Uint32 Gmask;
+	Uint32 Bmask;
+
+	dispvars->bits_per_pixel = bpp;
+	dispvars->pitch = ( ALIGN_UP( width, 16 ) * (bpp/8) );
+
+	height = ALIGN_UP( height, 16);
+
+	switch (bpp) {
+		case 8:
+			dispvars->pix_format = VC_IMAGE_8BPP;
+			break;
+		case 16:
+			dispvars->pix_format = VC_IMAGE_RGB565;
+			break;
+		case 32:
+			dispvars->pix_format = VC_IMAGE_XRGB8888;
+			break;
+		default:
+			printf ("Dispmanx: [ERROR] - wrong bpp: %d\n",bpp);
+			return (NULL);
+	}
+
+	printf ("Dispmanx: Using internal program mode: %d x %d %d bpp\n",
+		width, height, dispvars->bits_per_pixel);
+
+	printf ("Dispmanx: Using physical mode: %d x %d %d bpp\n",
+		dispvars->amode.width, dispvars->amode.height,
+		dispvars->bits_per_pixel);
+
+	dispvars->ignore_ratio = (int) SDL_getenv("SDL_DISPMANX_IGNORE_RATIO");
+
+	if (dispvars->ignore_ratio)
+		vc_dispmanx_rect_set( &(dispvars->dst_rect), 0, 0, dispvars->amode.width , dispvars->amode.height );
+	else {
+		float width_scale, height_scale;
+		width_scale = (float) dispvars->amode.width / width;
+		height_scale = (float) dispvars->amode.height / height;
+		float scale = min(width_scale, height_scale);
+		int dst_width = width * scale;
+		int dst_height = height * scale;
+
+		int dst_xpos  = (dispvars->amode.width - dst_width) / 2;
+		int dst_ypos  = (dispvars->amode.height - dst_height) / 2;
+
+		printf ("Dispmanx: Scaling to %d x %d\n", dst_width, dst_height);
+
+		vc_dispmanx_rect_set( &(dispvars->dst_rect), dst_xpos, dst_ypos,
+		dst_width , dst_height );
+	}
+
+	vc_dispmanx_rect_set (&(dispvars->bmp_rect), 0, 0, width, height);
+
+	vc_dispmanx_rect_set (&(dispvars->src_rect), 0, 0, width << 16, height << 16);
+
+	VC_DISPMANX_ALPHA_T layerAlpha;
+
+	layerAlpha.flags = DISPMANX_FLAGS_ALPHA_FIXED_ALL_PIXELS;
+	layerAlpha.opacity = 255;
+	layerAlpha.mask	   = 0;
+	dispvars->alpha = &layerAlpha;
+
+	dispvars->resources[0] = vc_dispmanx_resource_create( dispvars->pix_format, width, height, &(dispvars->vc_image_ptr) );
+	dispvars->resources[1] = vc_dispmanx_resource_create( dispvars->pix_format, width, height, &(dispvars->vc_image_ptr) );
+
+	dispvars->pixmem = calloc( 1, dispvars->pitch * height);
+
+	Rmask = 0;
+	Gmask = 0;
+	Bmask = 0;
+	if ( ! SDL_ReallocFormat(current, bpp, Rmask, Gmask, Bmask, 0) ) {
+		return(NULL);
+	}
+
+	current->w = width;
+	current->h = height;
+
+	current->pitch  = dispvars->pitch;
+	current->pixels = dispvars->pixmem;
+
+	dispvars->update = vc_dispmanx_update_start( 0 );
+
+	dispvars->element = vc_dispmanx_element_add( dispvars->update,
+		dispvars->display, 0 /*layer*/, &(dispvars->dst_rect),
+		dispvars->resources[flip_page], &(dispvars->src_rect),
+		DISPMANX_PROTECTION_NONE, dispvars->alpha, 0 /*clamp*/,
+		/*VC_IMAGE_ROT0*/ 0 );
+
+	vc_dispmanx_update_submit_sync( dispvars->update );
+
+	go_video_console:
+	if ( FB_EnterGraphicsMode(this) < 0 )
+		return(NULL);
+
+	return(current);
+}
+
+static void DISPMANX_BlankBackground(void)
+{
+	VC_IMAGE_TYPE_T type = VC_IMAGE_RGB565;
+	uint32_t vc_image_ptr;
+	uint16_t image = 0x0000; // black
+
+	VC_RECT_T dst_rect, src_rect;
+
+	dispvars->b_resource = vc_dispmanx_resource_create( type, 1 /*width*/, 1 /*height*/, &vc_image_ptr );
+
+	vc_dispmanx_rect_set( &dst_rect, 0, 0, 1, 1);
+
+	vc_dispmanx_resource_write_data( dispvars->b_resource, type, sizeof(image), &image, &dst_rect );
+
+	vc_dispmanx_rect_set( &src_rect, 0, 0, 1<<16, 1<<16);
+	vc_dispmanx_rect_set( &dst_rect, 0, 0, 0, 0);
+
+	dispvars->b_update = vc_dispmanx_update_start(0);
+
+	dispvars->b_element = vc_dispmanx_element_add(dispvars->b_update, dispvars->display, -1 /*layer*/, &dst_rect,
+		dispvars->b_resource, &src_rect, DISPMANX_PROTECTION_NONE, NULL, NULL, (DISPMANX_TRANSFORM_T)0 );
+
+	vc_dispmanx_update_submit_sync( dispvars->b_update );
+}
+
+static void DISPMANX_WaitVBL(_THIS)
+{
+	return;
+}
+
+static void DISPMANX_WaitIdle(_THIS)
+{
+	return;
+}
+
+static void DISPMANX_DirectUpdate(_THIS, int numrects, SDL_Rect *rects)
+{
+	vc_dispmanx_resource_write_data( dispvars->resources[flip_page],
+		dispvars->pix_format, dispvars->pitch, dispvars->pixmem,
+		&(dispvars->bmp_rect) );
+
+	dispvars->update = vc_dispmanx_update_start( 0 );
+
+	vc_dispmanx_element_change_source(dispvars->update, dispvars->element, dispvars->resources[flip_page]);
+
+	vc_dispmanx_update_submit_sync( dispvars->update );
+
+	flip_page = !flip_page;
+
+	return;
+}
+
+static int DISPMANX_SetColors(_THIS, int firstcolor, int ncolors, SDL_Color *colors)
+{
+	int i;
+	static unsigned short pal[256];
+
+	//Set up the colormap
+	for (i = 0; i < ncolors; i++) {
+		pal[i] = RGB565 ((colors[i]).r, (colors[i]).g, (colors[i]).b);
+	}
+	vc_dispmanx_resource_set_palette(  dispvars->resources[flip_page], pal, 0, sizeof pal );
+	vc_dispmanx_resource_set_palette(  dispvars->resources[!flip_page], pal, 0, sizeof pal );
+
+	return(1);
+}
+
+static SDL_Rect **DISPMANX_ListModes(_THIS, SDL_PixelFormat *format, Uint32 flags)
+{
+	return((SDL_Rect **)-1);
+}
+
+static void DISPMANX_FreeResources(void){
+	dispvars->update = vc_dispmanx_update_start( 0 );
+	vc_dispmanx_element_remove(dispvars->update, dispvars->element);
+	vc_dispmanx_update_submit_sync( dispvars->update );
+
+	vc_dispmanx_resource_delete( dispvars->resources[0] );
+	vc_dispmanx_resource_delete( dispvars->resources[1] );
+
+	vc_dispmanx_display_close( dispvars->display );
+}
+
+static void DISPMANX_FreeBackground (void) {
+	dispvars->b_update = vc_dispmanx_update_start( 0 );
+
+	vc_dispmanx_resource_delete( dispvars->b_resource );
+	vc_dispmanx_element_remove ( dispvars->b_update, dispvars->b_element);
+
+	vc_dispmanx_update_submit_sync( dispvars->b_update );
+}
+
+static void DISPMANX_VideoQuit(_THIS)
+{
+	/* Clear the lock mutex */
+	if ( hw_lock ) {
+		SDL_DestroyMutex(hw_lock);
+		hw_lock = NULL;
+	}
+
+	if (dispvars->pixmem != NULL){
+		DISPMANX_FreeBackground();
+		DISPMANX_FreeResources();
+	}
+
+	FB_CloseMouse(this);
+	FB_CloseKeyboard(this);
+}
_EOF_

    echo "rpi.diff" >>debian/patches/series
    echo "dispmanx.diff" >>debian/patches/series
    DEBEMAIL="Jools Wills <buzz@exotica.org.uk>" dch -v 1.2.15-6rpi "Added rpi fixes from pssc - https://github.com/raspberrypi/firmware/issues/354"
    DEBEMAIL="Jools Wills <buzz@exotica.org.uk>" dch -v 1.2.15-7rpi "Added dispmanx support from vanfanel & buzz"
}

function build_sdl1() {
    cd libsdl1.2-1.2.15
    dpkg-buildpackage
}

function install_sdl1() {
    # if the packages don't install completely due to missing dependencies the apt-get -y -f install will correct it
    if ! dpkg -i libsdl1.2debian_1.2.15-7rpi_armhf.deb libsdl1.2-dev_1.2.15-7rpi_armhf.deb; then
        apt-get -y -f install
    fi
    # remove unused sdl1dispmanx library
    rm -rf "$rootdir/supplementary/sdl1dispmanx"
}

function install_bin_sdl1() {
    isPlatform "rpi" || fatalError "$mod_id is only available as a binary package for platform rpi"
    wget "$__binary_url/libsdl1.2debian_1.2.15-7rpi_armhf.deb"
    wget "$__binary_url/libsdl1.2-dev_1.2.15-7rpi_armhf.deb"
    install_sdl1
    rm ./*.deb
}
