rp_module_id="cpc"
rp_module_desc="Amstrad CPC emulator"
rp_module_menus="2+"

function sources_cpc() {
    wget http://gaming.capsule-sa.co.za/downloads/cpc4rpi-1.1_src.tar.gz
    rmDirExists "$rootdir/emulators/cpc4rpi-1.1"
    tar xvfz cpc4rpi-1.1_src.tar.gz -C "$rootdir/emulators/"
    rm cpc4rpi-1.1_src.tar.gz
}

function build_cpc() {
    pushd "$rootdir/emulators/cpc4rpi-1.1"
    sed -i 's|LIBS = -L/usr/lib/arm-linux-gnueabihf -lz -lts -L/opt/vc/lib -lGLESv2 -lEGL|LIBS = -L/usr/lib/arm-linux-gnueabihf -lX11 -lz -lts -L/opt/vc/lib -lSDL -lpthread -ldl -lGLESv2 -lEGL|g' makefile
    sed -i 's|$(CC) $(CFLAGS) $(IPATHS) -o cpc4rpi cpc4rpi.cpp crtc.o fdc.o psg.o tape.o z80.o /root/Raspbian/Libs/libSDL.a /root/Raspbian/Libs/libnofun.a $(LIBS)|$(CC) $(CFLAGS) $(IPATHS) -o cpc4rpi cpc4rpi.cpp crtc.o fdc.o psg.o tape.o z80.o   $(LIBS)|g' makefile
    make RELEASE=TRUE
    if [[ ! -f "$rootdir/emulators/cpc4rpi-1.1/cpc4rpi" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile Amstrad CPC emulator CPC4Rpi."
    fi
    popd
}

function configure_cpc() {
    mkdir -p "$romdir/amstradcpc"
}