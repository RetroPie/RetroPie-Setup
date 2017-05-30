
#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="yarman"
rp_module_desc=" YARMan Web (Yet Another RetroPie Manager) on port 8080"
rp_module_help="PHP and JQuery based web frontend for managing your retropie installation"
rp_module_section="exp"

function depends_yarman() {
    getDepends sqlite3 php5 php5-sqlite
}

function install_bin_yarman() {
    gitPullOrClone "$md_inst" "https://github.com/daeks/yarman"
}

function configure_yarman() {
    killall php
    php -S "$(ip route get 8.8.8.8 | head -1 | cut -d' ' -f8):8080" -t "$md_inst" > /dev/null 2>&1 &

    local config="php -S \"\$\(ip route get 8.8.8.8 \| head -1 \| cut -d' ' -f8\):8080\" -t \"$md_inst\" > /dev/null 2>\&1 \&"
    sed -i "s|^exit 0$|${config}\\nexit 0|" /etc/rc.local
}

function remove_yarman() {
    killall php
    sed -i "/php/d" /etc/rc.local
    rm -R "$md_inst"
}
