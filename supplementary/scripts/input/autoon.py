#!/usr/bin/env python3
import configparser
import shutil
import os

# path variables
home                = os.path.expanduser("~")
retroarch_main_cfg  = home + '/RetroPie/configs/all/retroarch.cfg'

# backup current config
shutil.copyfile(retroarch_main_cfg, retroarch_main_cfg + '.bak')

# read config files
main_config  = open(retroarch_main_cfg).read()

# Remove section if necessary
main_config = main_config.replace('[start]','')	

# add a section
main_config  = '[start]\n' + main_config

# create a configparser opject
main_parser = configparser.ConfigParser()
main_parser.read_string(main_config)

# set special functions
main_parser.set('start','input_autodetect_enable','"true"')

# write config
with open(retroarch_main_cfg, 'w') as configfile:
	main_parser.write(configfile)
	configfile.close()	

# read config file, delete section and write config) 
config = open(retroarch_main_cfg).read()
with open(retroarch_main_cfg,'w') as configfile:
	configfile.write(config[8:])
	configfile.close()
exit()
