rp_module_id="configurationmenu"
rp_module_desc="Configuration Menu"
rp_module_menus="3+"
rp_module_flags="nobin"

function depends_configurationmenu() {
    getDepends mc
}

function configure_configurationmenu()
{
    mkRomDir "configuration"
    
    # Use midnight commander as file manager
    cat > "$romdir/configuration/filemanager.sh" << _EOF_
#!/bin/bash
mc
_EOF_

 	cat > "$romdir/configuration/register_controller.sh" << _EOF_
#!/bin/bash
sudo $scriptdir/retropie_packages.sh retroarchjoyconfig
_EOF_

	cat > "$romdir/configuration/audio_settings.sh" << _EOF_
#!/bin/bash
sudo $scriptdir/retropie_packages.sh audiosettings
_EOF_

	cat > "$romdir/configuration/set_splashscreen.sh" << _EOF_
#!/bin/bash
sudo $scriptdir/retropie_packages.sh splashscreen
_EOF_

	cat > "$romdir/configuration/show_ip.sh" << _EOF_
#!/bin/bash
ip addr show
sleep 5
_EOF_

    # set permissions
    chmod +x "$romdir/configuration"/*.sh
    chown $user:$user "$romdir/configuration/"*

    # add some information
    mkdir -p "$home/.emulationstation/gamelists/configuration/"
    cat > "$home/.emulationstation/gamelists/configuration/gamelist.xml" << _EOF_
<?xml version="1.0"?>
<gameList>
    <game>
        <path>$romdir/configuration/filemanager.sh</path>
        <name>File Manager</name>
    </game>
    <game>
        <path>$romdir/configuration/register_controller.sh</path>
        <name>Register RetroArch controller</name>
    </game>
    <game>
        <path>$romdir/configuration/audio_settings.sh</path>
        <name>Configure audio settings</name>
    </game>
    <game>
        <path>$romdir/configuration/set_splashscreen.sh</path>
        <name>Configure Splashscreen</name>
    </game>
    <game>
        <path>$romdir/configuration/show_ip.sh</path>
        <name>Show IP address</name>
    </game>
</gameList>
_EOF_

	setESSystem 'Configuration' 'configuration' '~/RetroPie/roms/configuration' '.sh .SH' '%ROM%' 'pc' 'configuration'
}
