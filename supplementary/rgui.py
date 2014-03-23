#!/usr/bin/env python3
import configparser
import shutil
import os

# path variables
home                = os.path.expanduser("~")
retroarch_cfg  	    = home + '/RetroPie/configs/all/retroarch.cfg'
rgui		    = 'retroarch --menu'
rgui_path           = home + '/RetroPie/emulators/RetroArch/installdir/bin/'

# backup current config
shutil.copyfile(retroarch_cfg, retroarch_cfg + '.bak')

# open RGUI
os.system(rgui_path + rgui + ' --config ' + retroarch_cfg)

# read config files
config  = open(retroarch_cfg).read()

# Remove section if necessary
config = config.replace('[start]','')	

# add a section
config  = '[start]\n' + config

# create a configparser opject
parser = configparser.ConfigParser()
parser.read_string(config)

# set special functions
parser.set('start','config_save_on_exit','"false"')

# write config
with open(retroarch_cfg, 'w') as configfile:
	parser.write(configfile)
	configfile.close()	

# read config file, delete section and write config) 
config = open(retroarch_cfg).read()
with open(retroarch_cfg,'w') as configfile:
	configfile.write(config[8:])
	configfile.close()
exit()
