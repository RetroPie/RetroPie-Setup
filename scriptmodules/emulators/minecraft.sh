rp_module_id="minecraft"
rp_module_desc="Minecraft"
rp_module_menus="4+"

function install_minecraft() {
    wget -O- -q https://s3.amazonaws.com/assets.minecraft.net/pi/minecraft-pi-0.1.1.tar.gz | tar -xvz --strip-components=1 -C "$emudir/$1"
}

function configure_minecraft() {
    mkdir -p "$romdir/ports"

    cat > "$romdir/ports/Minecraft.sh" << _EOF_
#!/bin/bash
xinit "$emudir/$1/minecraft-pi
_EOF_

    chmod +x "$romdir/ports/Minecraft.sh"

    setESSystem 'Ports' 'ports' '~/RetroPie/roms/ports' '.sh .SH' '%ROM%' 'pc' 'ports'
}
