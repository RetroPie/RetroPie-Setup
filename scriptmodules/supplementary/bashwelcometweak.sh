#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="bashwelcometweak"
rp_module_desc="Bash Welcome Tweak (shows additional system info on login)"
rp_module_menus="3+configure"
rp_module_flags="nobin"

function install_bashwelcometweak() {
    remove_bashwelcometweak
    cat >> "$home/.bashrc" <<\_EOF_
# RETROPIE PROFILE START
# Thanks to http://blog.petrockblock.com/forums/topic/retropie-mushroom-motd/#post-3965

function retropie_welcome() {
    local upSeconds="$(/usr/bin/cut -d. -f1 /proc/uptime)"
    local secs=$((upSeconds%60))
    local mins=$((upSeconds/60%60))
    local hours=$((upSeconds/3600%24))
    local days=$((upSeconds/86400))
    local UPTIME=$(printf "%d days, %02dh%02dm%02ds" "$days" "$hours" "$mins" "$secs")

    # calculate rough CPU and GPU temperatures:
    local cpuTempC
    local cpuTempF
    local gpuTempC
    local gpuTempF
    if [[ -f "/sys/class/thermal/thermal_zone0/temp" ]]; then
        cpuTempC=$(($(cat /sys/class/thermal/thermal_zone0/temp)/1000)) && cpuTempF=$((cpuTempC*9/5+32))
    fi

    if [[ -f "/opt/vc/bin/vcgencmd" ]]; then
        if gpuTempC=$(/opt/vc/bin/vcgencmd measure_temp); then
            gpuTempC=${gpuTempC:5:2}
            gpuTempF=$((gpuTempC*9/5+32))
        else
            gpuTempC=""
        fi
    fi

    local df_out=()
    local line
    while read line; do
        df_out+=("$line")
    done < <(df -h /)

echo "$(tput setaf 2)
   .~~.   .~~.    $(date +"%A, %e %B %Y, %r")
  '. \ ' ' / .'   $(uname -srmo)$(tput setaf 1)
   .~ .~~~..~.   
  : .~.'~'.~. :   $(tput setaf 3)${df_out[0]}$(tput setaf 1)
 ~ (   ) (   ) ~  $(tput setaf 7)${df_out[1]}$(tput setaf 1)
( : '~'.~.'~' : ) Uptime.............: ${UPTIME}
 ~ .~       ~. ~  Memory.............: $(grep MemFree /proc/meminfo | awk {'print $2'})kB (Free) / $(grep MemTotal /proc/meminfo | awk {'print $2'})kB (Total)$(tput setaf 7)
  (  $(tput setaf 4) |   | $(tput setaf 7)  )  $(tput setaf 1) Running Processes..: $(ps ax | wc -l | tr -d " ")$(tput setaf 7)
  '~         ~'  $(tput setaf 1) IP Address.........: $(ip route get 8.8.8.8 2>/dev/null | head -1 | cut -d' ' -f8) $(tput setaf 7)
    *--~-~--*    $(tput setaf 1) Temperature........: CPU: $cpuTempC°C/$cpuTempF°F GPU: $gpuTempC°C/$gpuTempF°F
                 $(tput setaf 7) The RetroPie Project, https://retropie.org.uk

$(tput sgr0)"
}

retropie_welcome

# RETROPIE PROFILE END
_EOF_
}

function remove_bashwelcometweak() {
    sed -i '/RETROPIE PROFILE START/,/RETROPIE PROFILE END/d' "$home/.bashrc"
}

function configure_bashwelcometweak() {
    cmd=(dialog --backtitle "$__backtitle" --menu "Bash Welcome Tweak Configuration" 22 86 16)
    options=(
        1 "Install Bash Welcome Tweak"
        2 "Remove Bash Welcome Tweak"
    )
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choices" ]]; then
        case $choices in
            1)
                install_bashwelcometweak
                printMsgs "dialog" "Installed Bash Welcome Tweak."
                ;;
            2)
                remove_bashwelcometweak
                printMsgs "dialog" "Removed Bash Welcome Tweak."
                ;;
        esac
    fi
}
