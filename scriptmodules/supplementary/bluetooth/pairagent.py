# Handy documentation:
#
#    BlueZ v5: https://git.kernel.org/pub/scm/bluetooth/bluez.git/tree/doc?h=5.50
#    dbus-python: https://dbus.freedesktop.org/doc/dbus-python/
#    dbus: https://dbus.freedesktop.org/doc/dbus-specification.html


from __future__ import print_function, unicode_literals

# Third-party
import dbus
from dbus import DBusException
import dbus.service
import dbus.mainloop.glib
from debugutils import debug_message 
import gobject as GObject
from pairutils import get_device

# Python built-ins
import sys


dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)


class _Agent(dbus.service.Object):
	_instance = None

	class Rejected(dbus.DBusException):
		_dbus_error_name = "org.bluez.Error.Rejected"
		
		def __init__(self, *args, **kwargs):
			debug_message("raising org.bluez.Error.Rejected")
			super(dbus.service.Exception, self).__init__(*args, **kwargs)

	def __init__(self, adapter, capability, *args, **kwargs):
		_Agent._instance = self
		self._path = adapter.object_path + "/agent"
		debug_message("path: " + self._path)
		dbus.service.Object.__init__(self, conn=dbus.SystemBus(), object_path=self._path)
		self._adapter = adapter
		self._capability = capability
		self._mainloop = GObject.MainLoop()
		self._succeeded = False

	@staticmethod
	def _ask(prompt):
		prompt = prompt + "\n(or ENTER to skip): "
		try:
			return raw_input(prompt)
		except Exception:
			return input(prompt)

	@dbus.service.method("org.bluez.Agent1", in_signature="o", out_signature="")
	def RequestAuthorization(self, device):
		debug_message("device: %s" % str(device))
		if not self._confirm("Authorize connection"):
			raise _Agent.Rejected("Connection rejected by user.")
	
	@dbus.service.method("org.bluez.Agent1", in_signature="os", out_signature="")
	def AuthorizeService(self, device, uuid):
		print("AuthorizeService (%s, %s)" % (device, uuid))
		sys.stdout.flush()
		authorize = self._ask("Authorize connection (yes/no): ")
		if (authorize == "yes"):
			return
		raise _Agent.Rejected("Connection rejected by user")

	@dbus.service.method("org.bluez.Agent1", in_signature="o", out_signature="s")
	def RequestPinCode(self, device):
		print("RequestPinCode (%s)" % (device))
		sys.stdout.flush()
		return self._ask("Enter PIN Code: ")

	@dbus.service.method("org.bluez.Agent1", in_signature="o", out_signature="u")
	def RequestPasskey(self, device):
		print("RequestPasskey (%s)" % (device))
		sys.stdout.flush()
		passkey = self._ask("Enter passkey: ")
		return dbus.UInt32(passkey)

	@dbus.service.method("org.bluez.Agent1", in_signature="ouq", out_signature="")
	def DisplayPasskey(self, device, passkey, entered):
		print("DisplayPasskey (%s, %06u entered %u)" % (device, passkey, entered))
		sys.stdout.flush()

	@dbus.service.method("org.bluez.Agent1", in_signature="os", out_signature="")
	def DisplayPinCode(self, device, pincode):
		print("DisplayPinCode (%s, %s)" % (device, pincode))
		sys.stdout.flush()

	@dbus.service.method("org.bluez.Agent1", in_signature="ou", out_signature="")
	def RequestConfirmation(self, device, passkey):
		print("RequestConfirmation (%s, %06d)" % (device, passkey))
		confirm = self._ask("Confirm passkey (yes/no): ")
		if (confirm == "yes"):
			return
		raise _Agent.Rejected("Passkey doesn't match")

	@dbus.service.method("org.bluez.Agent1", in_signature="", out_signature="")
	def Cancel(self):
		print("Cancel")

	@dbus.service.method("org.bluez.Agent1", in_signature="", out_signature="")
	def Release(self):
		print("Release")

	@classmethod
	def _pair_device_reply(cls):
		#debug_message("%s" % (device_path))
		cls._instance._succeeded = True
		cls._instance._mainloop.quit()

	@classmethod
	def _pair_device_error(cls, error):
		debug_message("%s" % (str(error)))
		print("ERROR: " + error.get_dbus_message())
		sys.stdout.flush()
		cls._instance._mainloop.quit()

	@staticmethod
	def _get_bluez_agent_manager():
		obj = dbus.SystemBus().get_object("org.bluez", "/org/bluez")
		debug_message("got %s" % (str(obj)))
		manager = dbus.Interface(obj, "org.bluez.AgentManager1")
		debug_message("returning %s" % (str(manager)))
		return manager

	def pair_device(self, adapter_name, device_mac):
		print("Pairing...")
		sys.stdout.flush()
		manager = _Agent._get_bluez_agent_manager()
		try:
			manager.RegisterAgent(self._path, self._capability)
			debug_message("agent registered")
			self._succeeded = False
			device = get_device(self._adapter, adapter_name, device_mac)
			device.Pair(
				reply_handler=_Agent._pair_device_reply,
				error_handler=_Agent._pair_device_error,
				timeout=60000)
			self._mainloop.run()
		except Exception as e:
			print("ERROR: " + str(e))
		finally:
			manager.UnregisterAgent(self._path)

		if not self._succeeded:
			print("ERROR: Pairing failed.")
			sys.exit(1)


def pair_device(adapter, adapter_name, device_mac, capability):
	_Agent(adapter, capability).pair_device(adapter_name, device_mac)
