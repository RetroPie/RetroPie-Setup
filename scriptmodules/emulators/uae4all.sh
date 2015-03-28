#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# (c) Copyright 2012-2015  Florian Müller (contact@petrockblock.com)
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/petrockblog/RetroPie-Setup/master/LICENSE.md.
#

rp_module_id="uae4all"
rp_module_desc="Amiga emulator UAE4All"
rp_module_menus="2+"
rp_module_flags="dispmanx"

function depends_uae4all() {
    getDepends libsdl1.2-dev libsdl-mixer1.2-dev libsdl-image1.2-dev libsdl-gfx1.2-dev libsdl-ttf2.0-dev
}

function sources_uae4all() {
    gitPullOrClone "$md_build" https://github.com/joolswills/uae4all2.git retropie
    mkdir guichan
    wget -O- -q https://guichan.googlecode.com/files/guichan-0.8.2.tar.gz | tar -xvz --strip-components=1 -C "guichan"
    cd guichan
    # fix from https://github.com/sphaero/guichan
    patch -p1 <<\_EOF_
diff --git a/src/widget.cpp b/src/widget.cpp
index 7dfc7e1..97978a7 100644
--- a/src/widget.cpp
+++ b/src/widget.cpp
@@ -598,7 +598,8 @@ namespace gcn
     {
         if (mFocusHandler == NULL)
         {
-            throw GCN_EXCEPTION("No focushandler set (did you add the widget to the gui?).");
+            return false;
+            //throw GCN_EXCEPTION("No focushandler set (isModalFocused: did you add the widget to the gui?).");
         }
 
         if (getParent() != NULL)
@@ -614,7 +615,8 @@ namespace gcn
     {
         if (mFocusHandler == NULL)
         {
-            throw GCN_EXCEPTION("No focushandler set (did you add the widget to the gui?).");
+            return false;
+            //throw GCN_EXCEPTION("No focushandler set (isModalMouseInputFocused: did you add the widget to the gui?).");
         }
 
         if (getParent() != NULL)
diff --git a/src/widgets/tabbedarea.cpp b/src/widgets/tabbedarea.cpp
index e07d14c..5ed9d39 100644
--- a/src/widgets/tabbedarea.cpp
+++ b/src/widgets/tabbedarea.cpp
@@ -317,6 +317,10 @@ namespace gcn
 
     void TabbedArea::logic()
     {
+        for (unsigned int i = 0; i < mTabs.size(); i++)
+        {
+                  mTabs[i].second->logic();
+        }
     }
 
     void TabbedArea::adjustSize()

_EOF_
}

function build_uae4all() {
    pushd guichan
    make clean
    ./configure --enable-sdlimage --enable-sdl --disable-allegro --disable-opengl --disable-shared
    make
    popd
    make -f Makefile.pi clean
    if isPlatform "rpi2"; then
        make -f Makefile.pi NEON=1 DEFS="-DUSE_ARMV7 -DUSE_ARMNEON"
    else
        make -f Makefile.pi
    fi
    md_ret_require="$md_build/uae4all"
}

function install_uae4all() {
    unzip -o "AndroidData/guichan26032014.zip" -d "$md_inst"
    unzip -o "AndroidData/data.zip" -d "$md_inst"
    unzip -o "AndroidData/aros20140110.zip" -d "$md_inst"
    md_ret_files=(
        'copying'
        'uae4all'
        'Readme.txt'
    )
}

function configure_uae4all() {
    mkRomDir "amiga"

    mkdir -p "$md_inst/conf"
    echo "path=$romdir/amiga" >"$md_inst/conf/adfdir.conf"
    chown -R $user:$user "$md_inst/conf"

    # symlinks to optional kickstart roms in our BIOS dir
    for rom in kick12.rom kick13.rom kick20.rom kick31.rom; do
        ln -sf "$biosdir/$rom" "$md_inst/kickstarts/$rom"
    done

    rm -f "$md_inst/uae4all.sh" "$romdir/amiga/Start.txt"
    cat > "$romdir/amiga/+Start UAE4All.sh" << _EOF_
#!/bin/bash
pushd "$md_inst"
$rootdir/supplementary/runcommand/runcommand.sh 0 ./uae4all "$md_id"
popd
_EOF_
    chmod a+x "$romdir/amiga/+Start UAE4All.sh"
    chown $user:$user "$romdir/amiga/+Start UAE4All.sh"

    setDispmanx "$md_id" 1

    addSystem 1 "$md_id" "amiga" "$romdir/amiga/+Start\ UAE4All.sh" "Amiga" ".sh"
}
