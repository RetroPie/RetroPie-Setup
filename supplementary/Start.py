#!/usr/bin/env python3
import configparser
# package apt-get install python-iniparse preserves file structure 
# from iniparse import configparser 
import shutil
import os

# path variables
retroarch_main_cfg  = '/home/pi/RetroPie/configs/all/retroarch.cfg'
retroarch_input_cfg = '/home/pi/RetroPie/configs/all/retroarchinput.cfg'
gngeo_main_cfg      = '/home/pi/.gngeo/gngeorc'
gngeo_input_cfg     = '/home/pi/.gngeo/gngeorcinput'
dgen_main_cfg       = '/home/pi/RetroPie/configs/all/dgenrc'
dgen_input_cfg      = '/home/pi/RetroPie/configs/all/dgenrcinput'

if os.path.exists('/home/pi/.gngeo') == False:
	os.system('mkdir /home/pi/.gngeo')

# create or flush input dummy files
open(retroarch_input_cfg,'w').close()
open(dgen_input_cfg,'w').close()
open(gngeo_input_cfg,'w').close()

# settings.xml should look like this
#<changeConfigPath from="retroarch.cfg" to="/home/pi/RetroPie/configs/all/retroarchinput.cfg" />
#<changeConfigPath from="dgen.cfg" to="/home/pi/RetroPie/configs/all/dgenrcinput" />
#<changeConfigPath from="gngeo.rc" to="/home/pi/.gngeo/gngeorcinput" />

# start ES-Config	
os.system("cd /home/pi/RetroPie/supplementary/ES-config; ./es-config --settings /home/pi/RetroPie/supplementary/ES-config/settings.xml")

# retroarchinput.cfg?
if os.path.getsize(retroarch_input_cfg) > 0:
	# backup current config
	shutil.copyfile(retroarch_main_cfg, '/home/pi/RetroPie/configs/all/retroarch.bak')

	# read config files
	main_config  = open(retroarch_main_cfg).read()
	input_config = open(retroarch_input_cfg).read()

	# Remove section if necessary
	main_config = main_config.replace('[start]','')	

	# add a section
	main_config  = '[start]\n' + main_config
	input_config = '[start]\n' + input_config

	# create a configparser opject
	main_parser  = configparser.ConfigParser()
	input_parser = configparser.ConfigParser()

	# merge both configs
	main_parser.read_string(main_config)
	input_parser.read_string(input_config)
	section = 'start'
	for name, value in input_parser.items(section):
		main_parser.set(section,name,value)

	# set special functions
	main_parser.set(section,'input_enable_hotkey_btn',main_parser.get(section,'input_player1_select_btn'))
	main_parser.set(section,'input_exit_emulator_btn',main_parser.get(section,'input_player1_start_btn'))
	main_parser.set(section,'input_menu_toggle_btn',main_parser.get(section,'input_player1_x_btn'))
	main_parser.set(section,'input_load_state_btn',main_parser.get(section,'input_player1_l_btn'))
	main_parser.set(section,'input_save_state_btn',main_parser.get(section,'input_player1_r_btn'))
	main_parser.set(section,'input_state_slot_increase_axis',main_parser.get(section,'input_player1_right_axis'))
	main_parser.set(section,'input_state_slot_decrease_axis',main_parser.get(section,'input_player1_left_axis'))
	main_parser.set(section,'input_reset_btn',main_parser.get(section,'input_player1_b_btn'))

	# delete wrong ES-config settings
	main_parser.remove_option(section,'input_player1_l_y_plus')
	main_parser.remove_option(section,'input_player1_l_y_minus')
	main_parser.remove_option(section,'input_player1_l_x_plus')
	main_parser.remove_option(section,'input_player1_l_x_minus')

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
# dgenrcinput.cfg?
if os.path.getsize(dgen_input_cfg) > 0:
	# check and backup current config
	if os.path.exists(dgen_main_cfg) == True:
		shutil.copyfile(dgen_main_cfg, '/home/pi/RetroPie/configs/all/dgenrc.bak')
	else:
		open(dgen_main_cfg,'w').close()	

	# read config files
	main_config  = open(dgen_main_cfg).read()
	input_config = open(dgen_input_cfg).read()

	# Remove section if necessary
	main_config = main_config.replace('[start]','')	

	# add a section
	main_config  = '[start]\n' + main_config
	input_config = '[start]\n' + input_config

	# create a configparser opject
	main_parser  = configparser.ConfigParser()
	input_parser = configparser.ConfigParser()

	# merge both configs
	main_parser.read_string(main_config)
	input_parser.read_string(input_config)
	section = 'start'
	for name, value in input_parser.items(section):
		main_parser.set(section,name,value)

	# write config
	with open(dgen_main_cfg, 'w') as configfile:
		main_parser.write(configfile)
		configfile.close()	

	# read config file, delete section and write config) 
	config = open(dgen_main_cfg).read()
	with open(dgen_main_cfg,'w') as configfile:
		configfile.write(config[8:])
		configfile.close()
	exit()
# gngeorcinput.cfg?
if os.path.getsize(gngeo_input_cfg) > 0:
	# check and backup current config
	if os.path.exists(gngeo_main_cfg) == True:
		shutil.copyfile(gngeo_main_cfg, '/home/pi/.gngeo/gngeorc.bak')
	else:
		if os.path.exists('/home/pi/RetroPie/emulators/gngeo-0.7/sample_gngeorc') == True:
			shutil.copyfile('/home/pi/RetroPie/emulators/gngeo-0.7/sample_gngeorc', gngeo_main_cfg)
		else:
			open(gngeo_main_cfg,'w').close()
			
	# read configs
	config = open(gngeo_main_cfg,'r').read()
	input = open(gngeo_input_cfg,'r').read()
	
	# merge configs
	config = config + input
	
	# write config
	with open(gngeo_main_cfg,'w') as configfile:
		configfile.write(config)
		configfile.close()
	exit()
else:
	exit()
