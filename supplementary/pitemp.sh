#!/bin/bash
cpuTemp0=$(cat /sys/class/thermal/thermal_zone0/temp)
cpuTemp1=$cpuTemp0/1000
cpuTempC=$(echo "scale=3; ${cpuTemp1}" | bc)
cpuTempF=$(echo "scale=3; (${cpuTempC}*(9/5))+32" | bc)

gpuTemp0=$(/opt/vc/bin/vcgencmd measure_temp)
gpuTemp0=${gpuTemp0//\'/}
gpuTemp0=${gpuTemp0//C/}
gpuTempC=${gpuTemp0//temp=/}
gpuTempF=$(echo "scale=3; (${gpuTempC}*(9/5))+32" | bc)

echo CPU Temp: $cpuTempCºC or $cpuTempFºF
echo GPU Temp: $gpuTempCºC or $gpuTempFºF
