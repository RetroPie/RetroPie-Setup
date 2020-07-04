# Handy documentation:
#
#    dbus-python: https://dbus.freedesktop.org/doc/dbus-python/
#    dbus: https://dbus.freedesktop.org/doc/dbus-specification.html


from __future__ import unicode_literals

import dbus


def dbus_unwrap(val):
	if isinstance(val, dbus.ByteArray):
		return "".join([str(x) for x in val])
	if isinstance(val, (dbus.Array, list, tuple)):
		return [dbus_unwrap(x) for x in val]
	if isinstance(val, (dbus.Dictionary, dict)):
		return dict(
			[(dbus_unwrap(x), dbus_unwrap(y)) for x, y in val.items()])
	if isinstance(val, (dbus.Signature, dbus.String)):
		return str(val)
	if isinstance(val, dbus.Boolean):
		return bool(val)
	if isinstance(val, (dbus.Int16, dbus.UInt16, dbus.Int32,
						dbus.UInt32, dbus.Int64, dbus.UInt64)):
		return int(val)
	if isinstance(val, dbus.Byte):
		return bytes([int(val)])
	return val 


def dbus_error_is(exp, string):
	name = exp.get_dbus_name()
	message = exp.get_dbus_message()
	return name == string or message == string
