# Handy documentation:
#
#    BlueZ v5: https://git.kernel.org/pub/scm/bluetooth/bluez.git/tree/doc?h=5.50
#    dbus-python: https://dbus.freedesktop.org/doc/dbus-python/
#    dbus: https://dbus.freedesktop.org/doc/dbus-specification.html


from __future__ import absolute_import, print_function, unicode_literals

# Third-party
import bluezutils
import dbus
from dbus import DBusException
import dbus.service
from dbusutils import dbus_error_is, dbus_unwrap
from debugutils import debug_dict, debug_message

# Python built-ins
import sys
import time


def _get_bluez_iface_props(obj_, interface):
	properties = dbus.Interface(obj_, "org.freedesktop.DBus.Properties")
	properties = properties.GetAll(bluezutils.SERVICE_NAME + "." + interface)
	return dbus_unwrap(properties)


def get_device(adapter, adapter_name, device_mac, timeout=30):
	device = None
	seconds_elapsed = 0
	while device is None:
		try:
			device = bluezutils.find_device(device_mac, adapter_name)
		except Exception as e:
			seconds_elapsed += 1
			if seconds_elapsed > timeout:
				break
			time.sleep(1)

	if device is None:
		print("ERROR: could not find device")
		sys.exit(1)

	debug_message("object_path: " + dbus_unwrap(device.object_path))
	properties = _get_bluez_iface_props(device, "Device1")
	debug_dict("properties", properties)
	return device


def remove_device_registration(adapter, adapter_name, device_mac):
	device = get_device(adapter, adapter_name, device_mac)

	properties = _get_bluez_iface_props(device, "Device1")
        if properties.get("Name", None) == "Sony PLAYSTATION(R)3 Controller":
		print("Preserving already-established PS3 controller registration...")
		return

	try:
		device_path = device.object_path
		debug_message("device path: %s" % (device_path))
		print("Removing device registration...")
		adapter.RemoveDevice(device_path)
		debug_message("removed")
	except DBusException as e:
		if dbus_error_is(e, bluezutils.SERVICE_NAME + '.Error.DoesNotExist'):
			debug_message("no existing pairing")
		else:
			print(e.get_dbus_message())
			print("ERROR: Failed to remove device pairing.")
			sys.exit(1)


def connect_device(adapter, adapter_name, device_mac):
	device = get_device(adapter, adapter_name, device_mac) 
	properties = dbus.Interface(device, "org.freedesktop.DBus.Properties")
	try:
		connected = dbus_unwrap(properties.Get("org.bluez.Input1", "Connected"))
	except Exception:
		connected = False

	if connected:
		print("Already connected.")
	else:
		print("Connecting...")
		sys.stdout.flush()
		try:
			device.Connect()
		except DBusException as e:
			print(e.get_dbus_message())
			print("ERROR: Connecting failed.")
			sys.exit(1)


def trust_device(adapter, adapter_name, device_mac):
	device = get_device(adapter, adapter_name, device_mac) 
	properties = dbus.Interface(device, "org.freedesktop.DBus.Properties")
	try:
		trusted = dbus_unwrap(properties.Get("org.bluez.Device1", "Trusted"))
	except Exception:
		trusted = False

	if trusted:
		print("Already trusted.")
	else:
		print("Trusting...")
		sys.stdout.flush()
		try:
			properties.Set("org.bluez.Device1", "Trusted", True)
		except DBusException as e:
			print(e.get_dbus_message())
			print("ERROR: Trusting failed.")
			sys.exit(1)

