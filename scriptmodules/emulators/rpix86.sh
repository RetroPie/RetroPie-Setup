rp_module_id="rpix86"
rp_module_desc="DOS Emulator rpix86"
rp_module_menus="2+"

function install_rpix86() {
    wget http://rpix86.patrickaalto.com/rpix86.tar.gz
    rmDirExists "$rootdir/emulators/rpix86"
    mkdir -p "$rootdir/emulators/rpix86"
    tar xvfz rpix86.tar.gz -C "$rootdir/emulators/rpix86"
    rm rpix86.tar.gz

    # install 4DOS.com
    unzip -n $scriptdir/supplementary/4dos.zip -d "$rootdir/emulators/rpix86/"
}

function configure_rpix86() {
    cat > "$rootdir/emulators/rpix86/Start.sh" << _EOF_
#!/bin/bash
pushd $rootdir/emulators/rpix86
./rpix86
popd
_EOF_
    chmod +x "$rootdir/emulators/rpix86/Start.sh"

    mkdir -p "$romdir/pc"
    ln -s $romdir/pc

    touch $romdir/pc/Start.txt
}