# http://www.gtkdb.de/index_36_2176.html
rp_module_id="xbmc"
rp_module_desc="Install XBMC"
rp_module_menus="4+"
rp_module_flags="nobin"

function depends_xbmc() {
    echo "deb http://archive.mene.za.net/raspbian wheezy contrib" > /etc/apt/sources.list.d/mene.list
    apt-key adv --keyserver keyserver.ubuntu.com --recv-key 5243CDED
}

function build_xbmc() {
    getDepends xbmc
}

function configure_xbmc() {
    echo 'SUBSYSTEM=="input", GROUP="input", MODE="0660"' > /etc/udev/rules.d/99-input.rules

    mkRomDir "ports"

    cat > "$romdir/ports/xbmc.sh" << _EOF_
#!/bin/bash
xbmc-standalone
_EOF_

    chmod +x "$romdir/ports/xbmc.sh"

    setESSystem 'Ports' 'ports' '~/RetroPie/roms/ports' '.sh .SH' '%ROM%' 'pc' 'ports'    
}
