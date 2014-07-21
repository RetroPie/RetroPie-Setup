rp_module_id="esconfig"
rp_module_desc="ES-Config"
rp_module_menus="3+"

function configure_esconfig()
{
    cp "$scriptdir/supplementary/settings.xml" "$rootdir/supplementary/ES-config/"
    sed -i -e "s|/home/pi/RetroPie|$rootdir|g" "$rootdir/supplementary/ES-config/settings.xml"
    if [[ ! -d $romdir/esconfig ]]; then
        mkdir -p $romdir/esconfig
    fi
    # generate new startup scripts for ES-config
    cp "$scriptdir/supplementary/scripts"/*/*.py "$rootdir/roms/esconfig/"
    chmod +x "$rootdir/roms/esconfig"/*.py
    # add some information
    cat > ~/.emulationstation/gamelists/esconfig/gamelist.xml << _EOF_
<?xml version="1.0"?>
<gameList>
    <game>
        <path>$romdir/esconfig/esconfig.py</path>
        <name>Start ES-Config</name>
        <desc>[DGen]
Old Genesis/Megadrive emulator

[RetroArch]
GB,GBC,NES,SNES,MASTERSYSTEM,GENESIS/MEGADRIVE,PSX

[GnGeo]
Old NeoGeo emulator
GNGEO 0.7</desc>
    </game>
    <game>
        <path>$romdir/esconfig/basic.py</path>
        <name>Update Retroarch Autoconfig (Keyboard necessary)</name>
        <desc>Joypad config will be stored under /opt/retropie/emulators/RetroArch/configs.</desc>
    </game>
    <game>
        <path>$romdir/esconfig/autoon.py</path>
        <name>Enable RetroArch Autoconfig</name>
    </game>
    <game>
        <path>$romdir/esconfig/autooff.py</path>
        <name>Disable RetroArch Autoconfig</name>
    </game>
    <game>
        <path>$romdir/esconfig/rgui.py</path>
        <name>Open RGUI</name>
        <desc>RetroArch Menu. (X = ok, Y/Z = cancel). Select "Save On Exit" to store changes.</desc>
    </game>
    <game>
        <path>$romdir/esconfig/showip.py</path>
        <name>Show current IP address</name>
    </game>
</gameList>
_EOF_
chown $user:$user "$romdir/esconfig/"*
}

function install_esconfig()
{
    rmDirExists "$rootdir/supplementary/ES-config"
    gitPullOrClone "$rootdir/supplementary/ES-config" git://github.com/Aloshi/ES-config.git
    pushd "$rootdir/supplementary/ES-config"
    sed -i -e "s/apt-get install/apt-get install -y --force-yes/g" get_dependencies.sh
    ./get_dependencies.sh
    make
    popd

    if [[ ! -f "$rootdir/supplementary/ES-config/es-config" ]]; then
        __ERRMSGS="$__ERRMSGS Could not successfully compile ES-config."
    fi
}