#!/usr/bin/env bash
##############

rp_module_id="bezelproject"
rp_module_desc="Easily set up the Bezel Project"
rp_module_help="Follow the instructions on the dialogs to configure the Bezel Project"
rp_module_section="exp"

function sources_bezelproject() {
    wget https://raw.githubusercontent.com/thebezelproject/BezelProject/master/bezelproject.sh
}

function install_bezelproject() {

    cp ./bezelproject.sh "$home/RetroPie/retropiemenu"
    chown -R $user:$user "$datadir/retropiemenu"
}

function remove_bezelproject() {
    rm -rfv "$datadir/retropiemenu/bezelproject.sh"
}

function gui_bezelproject() {
    bash "$md_inst/bezelproject.sh"
}
