rp_module_id="bashwelcometweak"
rp_module_desc="Bash Welcome Tweak"
rp_module_menus="2+"
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

echo "$(tput setaf 2)
   .~~.   .~~.    $(date +"%A, %e %B %Y, %r")
  '. \ ' ' / .'   $(uname -srmo)$(tput setaf 1)
   .~ .~~~..~.   
  : .~.'~'.~. :   $(tput setaf 3)$(df -h | grep Filesystem)$(tput setaf 1)
 ~ (   ) (   ) ~  $(tput setaf 7)$(df -h / | tail -1)$(tput setaf 1)
( : '~'.~.'~' : ) Uptime.............: ${UPTIME}
 ~ .~       ~. ~  Memory.............: $(grep MemFree /proc/meminfo | awk {'print $2'})kB (Free) / $(grep MemTotal /proc/meminfo | awk {'print $2'})kB (Total)$(tput setaf 7)
  (  $(tput setaf 4) |   | $(tput setaf 7)  )  $(tput setaf 1) Running Processes..: $(ps ax | wc -l | tr -d " ")$(tput setaf 7)
  '~         ~'  $(tput setaf 1) IP Address.........: $(ip route get 8.8.8.8 2>/dev/null | head -1 | cut -d' ' -f8) $(tput setaf 7)
    *--~-~--*    $(tput setaf 1) Temperature........: CPU: $cpuTempC°C/$cpuTempF°F GPU: $gpuTempC°C/$gpuTempF°F
                 $(tput setaf 7) The RetroPie Project, http://www.petrockblock.com

$(tput sgr0)"
}

retropie_welcome

# RETROPIE PROFILE END
_EOF_
}

function remove_bashwelcometweak() {
    sed -i '/RETROPIE PROFILE START/,/RETROPIE PROFILE END/d' "$home/.bashrc"
}
