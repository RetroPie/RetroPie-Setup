#!/usr/bin/env python3
import configparser
import shutil
import os

section = 'start'

# write RetroArch Autoconfig
def WriteAutoConfig(main_parser):	
	# add special keys
	main_parser = AutoConfigHelper(main_parser,'input_enable_hotkey','input_select')
	main_parser = AutoConfigHelper(main_parser,'input_exit_emulator','input_start')
	main_parser = AutoConfigHelper(main_parser,'input_menu_toggle','input_x')
	main_parser = AutoConfigHelper(main_parser,'input_load_state','input_l')
	main_parser = AutoConfigHelper(main_parser,'input_save_state','input_r')
	main_parser = AutoConfigHelper(main_parser,'input_reset','input_b')
	main_parser = AutoConfigHelper(main_parser,'input_state_slot_increase','input_right')
	main_parser = AutoConfigHelper(main_parser,'input_state_slot_decrease','input_left')
		
	# create filename
	filename = main_parser.get(section,'input_device')
	
	# remove special characters
	filename = filename.replace(' ','')
	filename = filename.replace("'",'')
	filename = filename.replace('"','')
	filename = filename.replace('*','')
	filename = filename.replace('/','')
	filename = filename.replace('\ ','')
	filename = auto_path + filename + '.cfg'
	
	# write autoconfig
	with open(filename, 'w') as configfile:
		main_parser.write(configfile)
		configfile.close()	

	# read config file, delete section and write autoconfig 
	config = open(filename).read()
	with open(filename,'w') as configfile:
		configfile.write(RemoveDummySection(config))
		configfile.close()
	return(0)
	
def WriteESConfig(main_parser):
	# read config files
	if os.path.exists(es_cfg) == True:
		# backup current config
		shutil.copyfile(es_cfg, es_cfg + '.bak')
		config 	 = open(es_cfg).read()
		joystick = main_parser.get(section,'input_device')

		# build a new input config string
		inputConfig  = '	<inputConfig type="joystick" deviceName=' + joystick + '>\n'
		inputConfig += '		<input name="a" ' 	+ ESConfigHelper(main_parser, 'input_b')	+ '\n'
		inputConfig += '		<input name="b" ' 	+ ESConfigHelper(main_parser, 'input_a')	+ '\n'
		inputConfig += '		<input name="down" ' 	+ ESConfigHelper(main_parser, 'input_down')	+ '\n'
		inputConfig += '		<input name="left" ' 	+ ESConfigHelper(main_parser, 'input_left')	+ '\n' 
		inputConfig += '		<input name="menu" ' 	+ ESConfigHelper(main_parser, 'input_start')	+ '\n'
		inputConfig += '		<input name="pagedown" '+ ESConfigHelper(main_parser, 'input_x')	+ '\n'
		inputConfig += '		<input name="pageup" ' 	+ ESConfigHelper(main_parser, 'input_y')	+ '\n'
		inputConfig += '		<input name="right" ' 	+ ESConfigHelper(main_parser, 'input_right')	+ '\n'
		inputConfig += '		<input name="select" ' 	+ ESConfigHelper(main_parser, 'input_select')	+ '\n'
		inputConfig += '		<input name="up" ' 	+ ESConfigHelper(main_parser, 'input_up')	+ '\n'
		inputConfig += '	</inputConfig>\n'

		
		# if joystick does not already exist
		if not joystick in config:
			# add xml end marker to the input config string
			inputConfig += '</inputList>'
		    	# replace the end marker with our new input config string
			config = config.replace('</inputList>',inputConfig)
		else:
			# set start point
			start = '	<inputConfig type="joystick" deviceName=' + joystick +	'>'
			# set end point
			end   = '</inputConfig>'
			# check location of current start point
			startpos = config.find(start,0)
			# check location of current end point
			endpos   = config.find(end,startpos)+15
			# remove old config with new config
			config   = config [:startpos] + inputConfig +config [endpos:]
		# write new config to es_input.cfg
		with open(es_cfg,'w') as configfile:
			configfile.write(config)
			configfile.close()		
		return(0)
	return(-1)

# Write gngeorc
# there is something fishy going on. Cannot read gngeorc cause of utf8.
def WriteGNGEO(main_parser, x):
	# read config files
	# open(gngeo_cfg,'w').close()
	if os.path.exists(gngeo_cfg) == True:
		# backup current config
		shutil.copyfile(gngeo_cfg, gngeo_cfg + '.bak')
		config = open(gngeo_cfg).read()
		
		# read variables
		joystick 	= str(x)
		# gngeo 0.8 should look like this
		# p1control A=J0B2,B=J0B1,C=J0B3,D=J0B0,START=J0B9,COIN=J0B8,UP=J0a1,DOWN=J0a1,LEFT=J0A0,RIGHT=J0A0
		inputConfig  = '\np' 	 + str(x + 1) + 'control '  
		inputConfig += ' A=J' 	 + joystick + GNGEOHelper(main_parser,'input_b')
		inputConfig += ' B=J' 	 + joystick + GNGEOHelper(main_parser,'input_a')
		inputConfig += ' C=J' 	 + joystick + GNGEOHelper(main_parser,'input_y')
		inputConfig += ' D=J' 	 + joystick + GNGEOHelper(main_parser,'input_x')
		inputConfig += ' START=J'+ joystick + GNGEOHelper(main_parser,'input_start')
		inputConfig += ' COIN=J' + joystick + GNGEOHelper(main_parser,'input_select')
		inputConfig += ' UP=J' 	 + joystick + GNGEOHelper(main_parser,'input_up')
		inputConfig += ' DOWN=J' + joystick + GNGEOHelper(main_parser,'input_down')
		inputConfig += ' LEFT=J' + joystick + GNGEOHelper(main_parser,'input_left')
		inputConfig += ' RIGHT=J'+ joystick + GNGEOHelper(main_parser,'input_right')
	
		#config  = config.replace('p' + joystick +'control',# 'p' + joystick + 'control'")
		config += inputConfig
		
		# write gngeorc
		with open(gngeo_cfg,'w') as configfile:
			configfile.write(config)
			configfile.close()
		return(0)
	return(-1)

# Add dummy section. ini parser needs at least one section
def AddDummySection(string):
	return ('[start]\n' + string)

# Remove dummy section. retroarch needs no section
def RemoveDummySection(string):
	return (string.replace('[start]\n',''))

# change main_parser key settings
def AutoConfigHelper(parser, hotkey, key):
	if parser.has_option(section,   key + '_axis'):
		parser.set(section, hotkey  + '_axis', parser.get(section,key + '_axis'))
	elif parser.has_option(section, key + '_btn'):
		parser.set(section, hotkey  + '_btn',  parser.get(section,key + '_btn'))
	return(parser)	

# write a formated key settings string
def ESConfigHelper(parser, string):
	output	='type="'
	if parser.has_option(section,string + '_axis'):
		option = string + '_axis'
		id     = parser.get(section,option)[2:].replace('"','')
		value  = parser.get(section,option)[1].replace('+','')
		output += 'axis" id="' + id + '" value="' + value +'1" />'
		return(output)
	elif parser.has_option(section,string + '_btn'):
		option = string + '_btn'
		id     = parser.get(section,option).replace('"','')
		output += 'button" id="' + id + '" value="1" />'
		return(output)
	else:
		return('type="btn" id="255" value="1" />')

# write a formated settings string
def GNGEOHelper(parser, string):
	if parser.has_option(section, string + '_axis'):
		option = string + '_axis'
		id     = parser.get(section,option)[2:].replace('"','')
		output = 'a' + id 
		return(output)
	elif parser.has_option(section, string + '_btn'):
		option = string + '_btn'
		id     = parser.get(section,option).replace('"','')
		output = 'B' + id 
		return(output)
	else:
		return('B255')

########################################################################################
# main script
########################################################################################
# path variables
home            = os.path.expanduser("~")
source_path	= home + '/RetroPie/emulators/RetroArch/installdir/bin/'
source_cfg	= source_path + 'config.ini'
auto_path   	= home + '/RetroPie/emulators/RetroArch/configs/'
gngeo_cfg      	= home + '/.gngeo/gngeorc.retropie'
dgen_cfg       	= home + '/RetroPie/configs/all/dgenrc'
es_cfg		= home + '/.emulationstation/es_input.cfg'

# check paths and mkdir if necessary
if os.path.exists(home + '/.gngeo/') == False:
	os.system('mkdir ' + home + '.gngeo/')
open(gngeo_cfg,'w').close()
if os.path.exists(home + '/RetroPie/configs/all/') == False:
	os.system('mkdir ' + home + '/RetroPie/configs/all/')

# for joystick 0-7
for x in range(0, 7):

	# check if joystick x is present
	if os.path.exists( '/dev/input/js' + str(x) ) == True:
	
		# start retroarch joyconfig and write dummy file source_cfg
		os.system('cd ' + source_path +'; ./retroarch-joyconfig -p1 -j'+ str(x) +' -a ' + source_cfg )
		# Read dummy file
		main_cfg  = open(source_cfg).read()	
			
		# Remove section if necessary
		config = RemoveDummySection(main_cfg)	
			
		# Add a section at the beginning. Configparser needs at least one section
		config  = AddDummySection(main_cfg)
			
		# Add a configparser and read config
		parser  = configparser.ConfigParser()
		parser.read_string(config)
			
		# Add config to retroarch autoconfig /RetroPie/emulators/RetroArch/configs/*.cfg
		WriteAutoConfig(parser)	
			
		# Add config to emulationstation config /.emulationstation/es_input.cfg
		WriteESConfig(parser)
			
		# Add config to gngeo config /.gngeo/gngeorc
		WriteGNGEO(parser, x)

		# Add config to dgen /RetroPie/emulators/RetroArch/configs/dgenrc
		# WriteDGEN(parser)
exit()	
########################################################################################
# End
########################################################################################
