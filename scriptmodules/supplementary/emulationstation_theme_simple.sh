rp_module_id="esthemesimple"
rp_module_desc="EmulationStation Theme Simple"
rp_module_menus="2+"

function install_esthemesimple() {
    wget -O themesDownload.tar.bz2 http://blog.petrockblock.com/?wpdmdl=7118

    tar xvfj themesDownload.tar.bz2
    rm themesDownload.tar.bz2
    if [[ ! -d "/etc/emulationstation/themes" ]]; then
        mkdir -p "/etc/emulationstation/themes"
    fi
    rmDirExists "/etc/emulationstation/themes/simple"
    mv -f simple/ "/etc/emulationstation/themes/"
}