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
rp_module_section="config"

function install_bashwelcometweak() {
    remove_bashwelcometweak
    cat >> "$home/.bashrc" <<\_EOF_
# RETROPIE PROFILE START

function getIPAddress() {
    local ip_route
    declare -a roots_ipv4=(198.41.0.4 199.9.14.201 192.33.4.12 199.7.91.13 192.203.230.10
                           192.5.5.241 192.112.36.4 198.97.190.53 192.36.148.17 192.58.128.30
                           193.0.14.129 199.7.83.42 202.12.27.33)
    declare -a roots_ipv6=(2001:503:ba3e::2:30 2001:500:200::b 2001:500:2::c 2001:500:2d::d
                           2001:500:a8::e 2001:500:2f::f 2001:500:12::d0d 2001:500:1::53
                           2001:7fe::53 2001:503:c27::2:30 2001:7fd::1 2001:500:9f::42 2001:dc3::35)
    for ((i=0;i<13;i++)) {
        ip_route=$(ip -4 route get ${roots_ipv4[RANDOM%13]} ${dev:+dev $dev} 2>/dev/null) \
            && break
    }
    if [[ -z "$ip_route" ]]; then
        for ((i=0;i<13;i++)) {
            ip_route=$(ip -6 route get ${roots_ipv6[RANDOM%13]} ${dev:+dev $dev} 2>/dev/null) \
                && break
        }
    fi
    [[ -n "$ip_route" ]] && grep -oP "src \K[^\s]+" <<< "$ip_route"
}

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

    local rst="$(tput sgr0)"
    local fgblk="${rst}$(tput setaf 0)" # Black - Regular
    local fgred="${rst}$(tput setaf 1)" # Red
    local fggrn="${rst}$(tput setaf 2)" # Green
    local fgylw="${rst}$(tput setaf 3)" # Yellow
    local fgblu="${rst}$(tput setaf 4)" # Blue
    local fgpur="${rst}$(tput setaf 5)" # Purple
    local fgcyn="${rst}$(tput setaf 6)" # Cyan
    local fgwht="${rst}$(tput setaf 7)" # White

    local bld="$(tput bold)"
    local bfgblk="${bld}$(tput setaf 0)"
    local bfgred="${bld}$(tput setaf 1)"
    local bfggrn="${bld}$(tput setaf 2)"
    local bfgylw="${bld}$(tput setaf 3)"
    local bfgblu="${bld}$(tput setaf 4)"
    local bfgpur="${bld}$(tput setaf 5)"
    local bfgcyn="${bld}$(tput setaf 6)"
    local bfgwht="${bld}$(tput setaf 7)"

    local logo=(
        "${fgred}   .***.   "
        "${fgred}   ***${bfgwht}*${fgred}*   "
        "${fgred}   \`***'   "
        "${bfgwht}    |*|    "
        "${bfgwht}    |*|    "
        "${bfgred}  ..${bfgwht}|*|${bfgred}..  "
        "${bfgred}.*** ${bfgwht}*${bfgred} ***."
        "${bfgred}*******${fggrn}@@${bfgred}**"
        "${fgred}\`*${bfgred}****${bfgylw}@@${bfgred}*${fgred}*'"
        "${fgred} \`*******'${fgrst} "
        "${fgred}   \`\"\"\"'${fgrst}   "
        )

    local out
    local i
    for i in "${!logo[@]}"; do
        out+="  ${logo[$i]}  "
        case "$i" in
            0)
                out+="${fggrn}$(date +"%A, %e %B %Y, %X")"
                ;;
            1)
                out+="${fggrn}$(uname -srmo)"
                ;;
            3)
                out+="${fgylw}${df_out[0]}"
                ;;
            4)
                out+="${fgwht}${df_out[1]}"
                ;;
            5)
                out+="${fgred}Uptime.............: ${UPTIME}"
                ;;
            6)
                out+="${fgred}Memory.............: $(grep MemFree /proc/meminfo | awk {'print $2'})kB (Free) / $(grep MemTotal /proc/meminfo | awk {'print $2'})kB (Total)"
                ;;
            7)
                out+="${fgred}Running Processes..: $(ps ax | wc -l | tr -d " ")"
                ;;
            8)
                out+="${fgred}IP Address.........: $(getIPAddress)"
                ;;
            9)
                out+="Temperature........: CPU: ${cpuTempC}°C/${cpuTempF}°F GPU: ${gpuTempC}°C/${gpuTempF}°F"
                ;;
            10)
                out+="${fgwht}The RetroPie Project, https://retropie.org.uk"
                ;;
        esac
        out+="${rst}\n"
    done
    echo -e "\n$out"
}

retropie_welcome
# RETROPIE PROFILE END
_EOF_


}

function remove_bashwelcometweak() {
    sed -i '/RETROPIE PROFILE START/,/RETROPIE PROFILE END/d' "$home/.bashrc"
}

function gui_bashwelcometweak() {
    local cmd=(dialog --backtitle "$__backtitle" --menu "Bash Welcome Tweak Configuration" 22 86 16)
    local options=(
        1 "Install Bash Welcome Tweak"
        2 "Remove Bash Welcome Tweak"
    )
    local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    if [[ -n "$choice" ]]; then
        case "$choice" in
            1)
                rp_callModule bashwelcometweak install
                printMsgs "dialog" "Installed Bash Welcome Tweak."
                ;;
            2)
                rp_callModule bashwelcometweak remove
                printMsgs "dialog" "Removed Bash Welcome Tweak."
                ;;
        esac
    fi
}
