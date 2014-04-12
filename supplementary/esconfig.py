#!/usr/bin/env python3
import configparser
# package apt-get install python-iniparse preserves file structure 
# from iniparse import configparser 
import shutil
import os

# path variables
home                = os.path.expanduser("~")
retroarch_main_cfg  = home + '/RetroPie/configs/all/retroarch.cfg'
retroarch_input_cfg = home + '/RetroPie/configs/all/retroarchinput.cfg'
gngeo_main_cfg      = home + '/.gngeo/gngeorc'
gngeo_input_cfg     = home + '/.gngeo/gngeorcinput'
dgen_main_cfg       = home + '/RetroPie/configs/all/dgenrc'
dgen_input_cfg      = home + '/RetroPie/configs/all/dgenrcinput'
es_config_path	    = home + '/RetroPie/supplementary/ES-config'
section = 'start'
	
# 
def AutoConfigHelper(parser, hotkey, key):
	if parser.has_option(section,   key + '_axis'):
		parser.set(section, hotkey  + '_axis', parser.get(section,key + '_axis'))
	elif parser.has_option(section, key + '_btn'):
		parser.set(section, hotkey  + '_btn',  parser.get(section,key + '_btn'))
	return(parser)	

# Disable invalid cuuurent key binding:
# If we update a already configured retroarch.cfg there can be btn or axis key bindings
# which interfere with our new key bindings. For example some snes controllers use 
# axis for up/down/left/right and a PS3 controller uses btn for the same thing.
def DisableAxisBtnHelper(parser, key, value):
	parser.set(section,key,value)
	if key.find('axis') > 0:
		parser.set(section, key.replace('axis','btn'),'"nul"')
	elif key.find('btn') > 0:
		parser.set(section, key.replace('btn','axis'),'"nul"')
	return(parser)	

if os.path.exists(home + '/.gngeo/') == False:
	os.system('mkdir ' + home + '/.gngeo/')

# create or flush input dummy files
open(retroarch_input_cfg,'w').close()
open(dgen_input_cfg,'w').close()
open(gngeo_input_cfg,'w').close()

# settings.xml should look like this
#<changeConfigPath from="retroarch.cfg" to="/home/pi/RetroPie/configs/all/retroarchinput.cfg" />
#<changeConfigPath from="dgen.cfg" to="/home/pi/RetroPie/configs/all/dgenrcinput" />
#<changeConfigPath from="gngeo.rc" to="/home/pi/.gngeo/gngeorcinput" />

# start ES-Config	
os.system('cd ' + es_config_path + '; ./es-config --settings ' + es_config_path + '/settings.xml')

# retroarchinput.cfg?
if os.path.getsize(retroarch_input_cfg) > 0:
	# backup current config
	shutil.copyfile(retroarch_main_cfg, retroarch_main_cfg + '.bak')

	# read config files
	main_config  = open(retroarch_main_cfg).read()
	input_config = open(retroarch_input_cfg).read()

	# Remove section if necessary
	main_config = main_config.replace('[' + section + ']','')
	# main_config = main_config.replace('input_player','#input_player')	

	# add a section
	main_config  = '[' + section + ']\n' + main_config
	input_config = '[' + section + ']\n' + input_config

	# create a configparser opject
	main_parser  = configparser.ConfigParser()
	input_parser = configparser.ConfigParser()

	# read both configs
	main_parser.read_string(main_config)
	input_parser.read_string(input_config)

	# add hotkeys
	AutoConfigHelper(input_parser,'input_enable_hotkey','input_player1_select')
	AutoConfigHelper(input_parser,'input_exit_emulator','input_player1_start')
	AutoConfigHelper(input_parser,'input_menu_toggle','input_player1_x')
	AutoConfigHelper(input_parser,'input_load_state','input_player1_l')
	AutoConfigHelper(input_parser,'input_save_state','input_player1_r')
	AutoConfigHelper(input_parser,'input_state_slot_increase','input_player1_right')
	AutoConfigHelper(input_parser,'input_state_slot_decrease','input_player1_left')
	AutoConfigHelper(input_parser,'input_reset','input_player1_b')

	# remove unused keys
	for x in range(0,7): 
		input_parser.set(section,'input_player' + str(x) + '_l_y_plus','"nul"')
		input_parser.set(section,'input_player' + str(x) + '_l_y_minus','"nul"')
		input_parser.set(section,'input_player' + str(x) + '_l_x_plus','"nul"')
		input_parser.set(section,'input_player' + str(x) + '_l_x_minus','"nul"')

	# merge both configs
	for name, value in input_parser.items(section):
		# main_parser.set(section,name,value)
		main_parser = DisableAxisBtnHelper(main_parser,name,value)

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
	# backup current config
	if os.path.exists(dgen_main_cfg) == True:
		shutil.copyfile(dgen_main_cfg, dgen_main_cfg + '.bak')
	else:
		open(dgen_main_cfg,'w').close()			

	# read config files
	main_config  = open(dgen_main_cfg).read()
	input_config = open(dgen_input_cfg).read()

	# Remove section if necessary
	main_config = main_config.replace('[' + section + ']','')	

	# add a section
	main_config  = '[' + section + ']\n' + main_config
	input_config = '[' + section + ']\n' + input_config

	# create a configparser opject
	main_parser  = configparser.ConfigParser()
	input_parser = configparser.ConfigParser()

	# merge both configs
	main_parser.read_string(main_config)
	input_parser.read_string(input_config)
	# section = 'start'
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
	# print 'backup current config'
	if os.path.exists(gngeo_main_cfg) == True:
		shutil.copyfile(gngeo_main_cfg, gngeo_main_cfg + '.bak')
	else:
		if os.path.exists(home + '/RetroPie/emulators/gngeo-0.7/sample_gngeorc') == True:
			shutil.copyfile(home + '/RetroPie/emulators/gngeo-0.7/sample_gngeorc', gngeo_main_cfg)
		else:
			open(gngeo_main_cfg,'w').close()			

	# read configs
	config = open(gngeo_main_cfg).read()
	input  = open(gngeo_input_cfg).read()
	
	# merge configs
	config = config + input
	
	# write config
	with open(gngeo_main_cfg,'w') as configfile:
		configfile.write(config)
		configfile.close()
	exit()
else:
	exit()
	
