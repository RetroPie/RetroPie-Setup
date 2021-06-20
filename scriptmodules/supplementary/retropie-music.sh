#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="retropie-music"
rp_module_desc="RetroPie Menu Background Music"
rp_module_help="This script enables you to play menu background music on RetroPie!\n\nYou can find the config under /opt/dev_philcomm/config.cfg. Default music location is /home/pi/music.\n\nAccepted music formats are .mp3 and .ogg.\n\nIf you create a subfolder called winter in your music directory, the script will play these songs instead in december."
rp_module_section="exp"
rp_module_flags="noinstclean nobin"

function depends_retropie-music() {
  local depends=(python3-pip libsdl2-mixer-2.0-0)
  getDepends "${depends[@]}"
}

function sources_retropie-music() {
  gitPullOrClone "$md_inst" "https://github.com/OfficialPhilcomm/retropie-music.git" master
}

function install_retropie-music() {
  cd "$md_inst"
  chown -R $user:$user "$md_inst"
  chmod -R 755 "$md_inst"

  sudo ./install.sh
}

function enable_retropie-music() {
  sudo service enable retropie_music
  printMsgs "dialog" "RetroPie Music enabled. It will start automatically on next boot"
}

function disable_retropie-music() {
  sudo service disable retropie_music
  printMsgs "dialog" "RetroPie Music disabled. It will no longer start automatically on boot"
}

function remove_retropie-music() {
  cd "$md_inst"

  sudo ./uninstall.sh
  printMsgs "dialog" "Successfully uninstalled"

  cd ..
  rm -R "$md_inst"
}

function gui_retropie-music() {
  local cmd=()
  local options=(
    1 "Start retropie-music now"
    2 "Stop retropie-music now"
    3 "Enable retropie-music on Boot"
    4 "Disable retropie-music on Boot"
  )
  local choice
  local error_msg
  
  while true; do
    cmd=(dialog --backtitle "$__backtitle" --menu "What do you wanna do?" 22 86 16)
    choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    
    if [[ -n "$choice" ]]; then
      case "$choice" in
        1)
          sudo service retropie_music start
          ;;

        2)
          sudo service retropie_music stop
          ;;

        3)  
          enable_retropie-music
          ;;

        4)
          disable_retropie-music
          ;;
      esac
    else
      break
    fi
  done
}
