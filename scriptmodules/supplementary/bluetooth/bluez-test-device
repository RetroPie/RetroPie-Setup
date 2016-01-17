#!/usr/bin/python

from __future__ import absolute_import, print_function, unicode_literals

from optparse import OptionParser, make_option
import re
import sys
import dbus
import dbus.mainloop.glib
try:
  from gi.repository import GObject
except ImportError:
  import gobject as GObject
import bluezutils

dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
bus = dbus.SystemBus()
mainloop = GObject.MainLoop()

option_list = [
		make_option("-i", "--device", action="store",
				type="string", dest="dev_id"),
		]
parser = OptionParser(option_list=option_list)

(options, args) = parser.parse_args()

if (len(args) < 1):
	print("Usage: %s <command>" % (sys.argv[0]))
	print("")
	print("  list")
	print("  create <address>")
	print("  remove <address|path>")
	print("  connect <address> [profile]")
	print("  disconnect <address> [profile]")
	print("  class <address>")
	print("  name <address>")
	print("  alias <address> [alias]")
	print("  trusted <address> [yes/no]")
	print("  blocked <address> [yes/no]")
	sys.exit(1)

if (args[0] == "list"):
	adapter = bluezutils.find_adapter(options.dev_id)
	adapter_path = adapter.object_path

	om = dbus.Interface(bus.get_object("org.bluez", "/"),
					"org.freedesktop.DBus.ObjectManager")
	objects = om.GetManagedObjects()

	for path, interfaces in objects.iteritems():
		if "org.bluez.Device1" not in interfaces:
			continue
		properties = interfaces["org.bluez.Device1"]
		if properties["Adapter"] != adapter_path:
			continue;
		print("%s %s" % (properties["Address"], properties["Alias"]))

	sys.exit(0)

def create_device_reply(device):
	print("New device (%s)" % device)
	mainloop.quit()
	sys.exit(0)

def create_device_error(error):
	print("Creating device failed: %s" % error)
	mainloop.quit()
	sys.exit(1)

if (args[0] == "create"):
	if (len(args) < 2):
		print("Need address parameter")
	else:
		adapter = bluezutils.find_adapter(options.dev_id)
		adapter.CreateDevice(args[1],
				reply_handler=create_device_reply,
				error_handler=create_device_error)
	mainloop.run()

if (args[0] == "remove"):
	if (len(args) < 2):
		print("Need address or object path parameter")
	else:
		managed_objects = bluezutils.get_managed_objects()
		adapter = bluezutils.find_adapter_in_objects(managed_objects,
								options.dev_id)
		try:
			dev = bluezutils.find_device_in_objects(managed_objects,
								args[1],
								options.dev_id)
			path = dev.object_path
		except:
			path = args[1]
		adapter.RemoveDevice(path)
	sys.exit(0)

if (args[0] == "connect"):
	if (len(args) < 2):
		print("Need address parameter")
	else:
		device = bluezutils.find_device(args[1], options.dev_id)
		if (len(args) > 2):
			device.ConnectProfile(args[2])
		else:
			device.Connect()
	sys.exit(0)

if (args[0] == "disconnect"):
	if (len(args) < 2):
		print("Need address parameter")
	else:
		device = bluezutils.find_device(args[1], options.dev_id)
		if (len(args) > 2):
			device.DisconnectProfile(args[2])
		else:
			device.Disconnect()
	sys.exit(0)

if (args[0] == "class"):
	if (len(args) < 2):
		print("Need address parameter")
	else:
		device = bluezutils.find_device(args[1], options.dev_id)
		path = device.object_path
		props = dbus.Interface(bus.get_object("org.bluez", path),
					"org.freedesktop.DBus.Properties")
		cls = props.Get("org.bluez.Device1", "Class")
		print("0x%06x" % cls)
	sys.exit(0)

if (args[0] == "name"):
	if (len(args) < 2):
		print("Need address parameter")
	else:
		device = bluezutils.find_device(args[1], options.dev_id)
		path = device.object_path
		props = dbus.Interface(bus.get_object("org.bluez", path),
					"org.freedesktop.DBus.Properties")
		name = props.Get("org.bluez.Device1", "Name")
		print(name)
	sys.exit(0)

if (args[0] == "alias"):
	if (len(args) < 2):
		print("Need address parameter")
	else:
		device = bluezutils.find_device(args[1], options.dev_id)
		path = device.object_path
		props = dbus.Interface(bus.get_object("org.bluez", path),
					"org.freedesktop.DBus.Properties")
		if (len(args) < 3):
			alias = props.Get("org.bluez.Device1", "Alias")
			print(alias)
		else:
			props.Set("org.bluez.Device1", "Alias", args[2])
	sys.exit(0)

if (args[0] == "trusted"):
	if (len(args) < 2):
		print("Need address parameter")
	else:
		device = bluezutils.find_device(args[1], options.dev_id)
		path = device.object_path
		props = dbus.Interface(bus.get_object("org.bluez", path),
					"org.freedesktop.DBus.Properties")
		if (len(args) < 3):
			trusted = props.Get("org.bluez.Device1", "Trusted")
			print(trusted)
		else:
			if (args[2] == "yes"):
				value = dbus.Boolean(1)
			elif (args[2] == "no"):
				value = dbus.Boolean(0)
			else:
				value = dbus.Boolean(args[2])
			props.Set("org.bluez.Device1", "Trusted", value)
	sys.exit(0)

if (args[0] == "blocked"):
	if (len(args) < 2):
		print("Need address parameter")
	else:
		device = bluezutils.find_device(args[1], options.dev_id)
		path = device.object_path
		props = dbus.Interface(bus.get_object("org.bluez", path),
					"org.freedesktop.DBus.Properties")
		if (len(args) < 3):
			blocked = props.Get("org.bluez.Device1", "Blocked")
			print(blocked)
		else:
			if (args[2] == "yes"):
				value = dbus.Boolean(1)
			elif (args[2] == "no"):
				value = dbus.Boolean(0)
			else:
				value = dbus.Boolean(args[2])
			props.Set("org.bluez.Device1", "Blocked", value)
	sys.exit(0)

print("Unknown command")
sys.exit(1)
