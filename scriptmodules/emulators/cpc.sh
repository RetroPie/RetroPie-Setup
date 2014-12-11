rp_module_id="cpc"
rp_module_desc="Amstrad CPC emulator"
rp_module_menus="2+"

function sources_cpc() {
    wget -O- -q http://downloads.petrockblock.com/retropiearchives/cpc4rpi-1.1_src.tar.gz | tar -xvz --strip-components=1
}

function build_cpc() {
    make clean
    sed -i 's|LIBS = -L/usr/lib/arm-linux-gnueabihf -lz -lts -L/opt/vc/lib -lGLESv2 -lEGL|LIBS = -L/usr/lib/arm-linux-gnueabihf -lX11 -lz -lts -L/opt/vc/lib -lSDL -lpthread -ldl -lGLESv2 -lEGL|g' makefile
    sed -i 's|$(CC) $(CFLAGS) $(IPATHS) -o cpc4rpi cpc4rpi.cpp crtc.o fdc.o psg.o tape.o z80.o /root/Raspbian/Libs/libSDL.a /root/Raspbian/Libs/libnofun.a $(LIBS)|$(CC) $(CFLAGS) $(IPATHS) -o cpc4rpi cpc4rpi.cpp crtc.o fdc.o psg.o tape.o z80.o   $(LIBS)|g' makefile
    make RELEASE=TRUE
    require="$builddir/$1/cpc4rpi"
}

function install_cpc() {
    cp -R "$builddir/$1/"{cpc4rpi,*.txt} "$emudir/$1/"
    require="$emudir/$1/cpc4rpi"
}

function configure_cpc() {
    mkdir -p "$romdir/amstradcpc"

    setESSystem "Amstrad CPC" "amstradcpc" "~/RetroPie/roms/amstradcpc" ".cpc .CPC .dsk .DSK" "$rootdir/emulators/cpc4rpi/cpc4rpi %ROM%" "amstradcpc" ""
}