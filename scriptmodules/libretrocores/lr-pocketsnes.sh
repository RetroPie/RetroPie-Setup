rp_module_id="lr-pocketsnes"
rp_module_desc="SNES emu - ARM based SNES emulator for libretro"
rp_module_menus="2+"

function sources_lr-pocketsnes() {
    gitPullOrClone "$md_build" git://github.com/ToadKing/pocketsnes-libretro.git
    patch -p1 <<\_EOF_
diff --git a/src/ppu.cpp b/src/ppu.cpp
index 19340fb..6d1af27 100644
--- a/src/ppu.cpp
+++ b/src/ppu.cpp
@@ -714,7 +714,7 @@ uint8 S9xGetCPU(uint16 Address)
 						}
 					}
 					return (
-						(IPPU.Joypads[0]
+						(IPPU.Joypads[1]
 							>> (PPU.Joypad2ButtonReadPos++ ^ 15))
 							& 1);
 				}
_EOF_
}

function build_lr-pocketsnes() {
    make clean
    make
    md_ret_require="$md_build/libretro.so"
}

function install_lr-pocketsnes() {
    md_ret_files=(
        'libretro.so'
        'README.txt'
    )
}

function configure_lr-pocketsnes() {
    # remove old install folder
    rm -rf "$rootdir/$md_type/pocketsnes"

    mkRomDir "snes"
    ensureSystemretroconfig "snes"

    # system-specific shaders, SNES
    iniConfig " = " "" "$configdir/snes/retroarch.cfg"
    iniSet "video_shader" "$emudir/retroarch/shader/snes_phosphor.glslp"
    iniSet "video_shader_enable" "false"
    iniSet "video_smooth" "false"

    local def=0
    isPlatform "rpi1" && def=1
    addSystem $def "$md_id" "snes" "$md_inst/libpocketsnes.so"
}
