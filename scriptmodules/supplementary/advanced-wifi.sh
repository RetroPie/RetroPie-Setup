#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="advanced-wifi"
rp_module_desc="Advanced wifi manager with OSK"
rp_module_help="This is a wifi manager terminal app with an on screen keyboard, for when no keyboard is in reach!"
rp_module_section="exp"
rp_module_flags="noinstclean nobin"

function depends_advanced-wifi() {
  local depends=(ruby ruby-dev)
  getDepends "${depends[@]}"
}

function sources_advanced-wifi() {
  gitPullOrClone "$md_inst" "https://github.com/OfficialPhilcomm/retropie-wifi-manager.git" master
}

function install_advanced-wifi() {
  cd "$md_inst"
  chown -R $user:$user "$md_inst"
  chmod -R 755 "$md_inst"

  mkdir /opt/dev_philcomm
  mv wifi2 /opt/dev_philcomm
  mv wifi2.sh /home/pi/RetroPie/retropiemenu/
  sudo gem install curses require_all
}

function remove_advanced-wifi() {
  cd "$md_inst"

  rm -R /opt/dev_philcomm/wifi2
  rm /home/pi/RetroPie/retropiemenu/wifi2.sh
  printMsgs "dialog" "Successfully uninstalled"

  cd ..
  rm -R "$md_inst"
}
