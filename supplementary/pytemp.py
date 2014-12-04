#!/usr/bin/python

import commands

def get_cpu_temp_celsius():
    tempFile = open( "/sys/class/thermal/thermal_zone0/temp" )
    cpu_temp = tempFile.read()
    tempFile.close()
    return float(cpu_temp)/1000

def get_cpu_temp_fahrenheit():
    cpu_temp = get_cpu_temp_celsius()
    return float(1.8*cpu_temp)+32

def get_gpu_temp_celsius():
    gpu_temp = commands.getoutput( '/opt/vc/bin/vcgencmd measure_temp' ).replace( 'temp=','' ).replace( "'C","" )
    return float(gpu_temp)

def get_gpu_temp_fahrenheit(gpu_tempC):
    return float(1.8* gpu_tempC)+32

def main():
    gpu_tempC = get_gpu_temp_celsius();
    print "CPU temp: ", str(get_cpu_temp_fahrenheit()), "*F == ", str(get_cpu_temp_celsius()), "*C"
    print "GPU temp: ", str(get_gpu_temp_fahrenheit(gpu_tempC)), "*F == ", str(gpu_tempC), "*C"

if __name__ == '__main__':
    main()
