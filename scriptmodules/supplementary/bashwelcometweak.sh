rp_module_id="bashwelcometweak"
rp_module_desc="Bash Welcome Tweak"
rp_module_menus="2+"

function install_bashwelcometweak() {
    if [[ -z `cat "$home/.bashrc" | grep "# RETROPIE PROFILE START"` ]]; then
        cat >> "$home/.bashrc" <<\_EOF_
# RETROPIE PROFILE START
# Thanks to http://blog.petrockblock.com/forums/topic/retropie-mushroom-motd/#post-3965

let upSeconds="$(/usr/bin/cut -d. -f1 /proc/uptime)"
let secs=$((${upSeconds}%60))
let mins=$((${upSeconds}/60%60))
let hours=$((${upSeconds}/3600%24))
let days=$((${upSeconds}/86400))
UPTIME=$(printf "%d days, %02dh%02dm%02ds" "$days" "$hours" "$mins" "$secs")

# calculate rough CPU and GPU temperatures:
cpuTempC=$(($(cat /sys/class/thermal/thermal_zone0/temp)/1000))
cpuTempF=$(($cpuTempC*9/5+32))

gpuTempC=$(/opt/vc/bin/vcgencmd measure_temp)
gpuTempC=${gpuTempC:5:2}
gpuTempF=$(($gpuTempC*9/5+32))

# get the load averages
read one five fifteen rest < /proc/loadavg

echo "$(tput setaf 2)
   .~~.   .~~.    `date +"%A, %e %B %Y, %r"`
  '. \ ' ' / .'   `uname -srmo`$(tput setaf 1)
   .~ .~~~..~.   
  : .~.'~'.~. :   $(tput setaf 3)`df -h | grep Filesystem`$(tput setaf 1)
 ~ (   ) (   ) ~  $(tput setaf 7)`df -h|grep rootfs`$(tput setaf 1)
( : '~'.~.'~' : ) Uptime.............: ${UPTIME}
 ~ .~       ~. ~  Memory.............: `cat /proc/meminfo | grep MemFree | awk {'print $2'}`kB (Free) / `cat /proc/meminfo | grep MemTotal | awk {'print $2'}`kB (Total)$(tput setaf 7)
  (  $(tput setaf 4) |   | $(tput setaf 7)  )  $(tput setaf 1) Running Processes..: `ps ax | wc -l | tr -d " "`$(tput setaf 7)
  '~         ~'  $(tput setaf 1) IP Address.........: `ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ printf "%s ", $1}'` $(tput setaf 7)
    *--~-~--*    $(tput setaf 7) The RetroPie Project, www.petrockblock.com

CPU Temperature: $cpuTempCºC or $cpuTempFºF
GPU Temperature: $gpuTempCºC or $gpuTempFºF
$(tput sgr0)"

# RETROPIE PROFILE END
_EOF_

    fi
}

function remove_bashwelcometweak() {
    sed -i '/RETROPIE PROFILE START/,/RETROPIE PROFILE END/d' "$home/.bashrc"
}