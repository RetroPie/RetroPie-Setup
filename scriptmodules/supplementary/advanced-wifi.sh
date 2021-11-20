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
rp_module_flags="rpi noinstclean nobin"
rp_module_repo="git https://github.com/OfficialPhilcomm/retropie-wifi-manager.git master"

function depends_advanced-wifi() {
  getDepends ruby ruby-dev
}

function sources_advanced-wifi() {
  gitPullOrClone "$md_inst"
}

function install_advanced-wifi() {
  cd "$md_inst"
  chown -R $user:$user "$md_inst"
  chmod -R 755 "$md_inst"

  sudo gem install curses require_all
}

function gui_advanced-wifi() {
  local cmd=()
  local options=(
    1 "Add advanced-wifi to RetroPie Menu"
    2 "Remove advanced-wifi from RetroPie Menu"
  )
  local choice
  local error_msg
  
  while true; do
    cmd=(dialog --backtitle "$__backtitle" --menu "What do you wanna do?" 22 86 16)
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    
    if [[ -n "$choice" ]]; then
      case "$choice" in
        1)
          cp "$md_inst/wifi2.sh" /home/pi/RetroPie/retropiemenu/
          ;;

        2)
          rm /home/pi/RetroPie/retropiemenu/wifi2.sh
          ;;
      esac
    else
      break
    fi
  done
}
