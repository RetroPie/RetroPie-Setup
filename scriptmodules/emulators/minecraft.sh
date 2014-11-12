rp_module_id="minecraft"
rp_module_desc="Minecraft"
rp_module_menus="4+"

function install_minecraft() {
    mkdir "$rootdir/emulators/minecraft"
    pushd "$rootdir/emulators/minecraft"
    wget https://s3.amazonaws.com/assets.minecraft.net/pi/minecraft-pi-0.1.1.tar.gz
    tar -zxvf minecraft-pi-0.1.1.tar.gz
    popd
}

function configure_minecraft() {
    mkdir -p "$romdir/ports"

    cat > "$romdir/ports/Minecraft.sh" << _EOF_
#!/bin/bash
xinit /opt/retropie/emulators/minecraft/mcpi/minecraft-pi
_EOF_

    chmod +x "$romdir/ports/Minecraft.sh"

    setESSystem 'Ports' 'ports' '~/RetroPie/roms/ports' '.sh .SH' '%ROM%' 'pc' 'ports'
}
