#!/bin/bash
echo "                         Storage System" > line1
echo " " > free
 df -h | tail -n +4 > temp-disk3
 sed '1 i "         Name                    Total  Used  Free Load Mountpoint"' temp-disk3 > temp-disk2
 sed '/^tmpfs/ d' temp-disk2 > temp-disk
 sed -i 's,'"/dev/sda1"',Usb Storage                 ,' temp-disk
 sed -i 's,'"/dev/mmcblk0p1"',Emmc/Sd Boot partition           ,' temp-disk
 sed -i 's,'"/dev/mmcblk0p2"',Emmc/Sd Retropie partition       ,' temp-disk
 sed '1 i "Name Total Used Free Load Mountpoint"' temp-disk
 echo "                     Temperature Monitoring" > temph
 cpuTempC=$(($(cat /sys/class/thermal/thermal_zone0/temp)/1000)) && cpuTempF=$((cpuTempC*9/5+32))
 echo $cpuTempC > tempc
 sed 's/^/Cpu Temperature in Celcius degree :   /' tempc > tempC
 echo $cpuTempF > tempf
 sed 's/^/Cpu Temperature in Farenheit degree : /' tempf > tempF
 echo "                         Network Info" > net
 ip route get 8.8.8.8 2>/dev/null | awk '{print $NF; exit}' > ip
 sed 's/^/Local Ip address :           /' ip > IP
 wget -qO- http://ipecho.net/plain > wan
sed 's/^/Public Ip address :          /' wan > WAN
cat /sys/class/net/eth0/operstate > wired
sed 's/^/Ethernet Connection status : /' wired > WIRED
cat /sys/class/net/lo/operstate > loop
sed 's/^/Loopback interface status :  /' loop > LOOP
cat /sys/class/net/wlan0/operstate > wlan
sed 's/^/Wireless Connection status : /' wlan > WLAN
sed h line1 free temp-disk free free temph free tempC tempF free free net free IP WAN LOOP WIRED WLAN > display
whiptail --backtitle "SysInfo script by Luc Francoeur" --title "ORA System Information" --textbox display 27 72


