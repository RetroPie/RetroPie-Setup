from __future__ import print_function

from collections import Mapping
import inspect
import os
import sys

_DEBUG = False

def set_debug(enabled):
	global _DEBUG
	_DEBUG = bool(enabled)


def debug_message(message):
	if _DEBUG:
		frame_number = 1
		caller_name = inspect.stack()[frame_number][3]
		while caller_name.startswith('debug_') or caller_name.startswith('_debug_'):
			frame_number += 1
			caller_name = inspect.stack()[frame_number][3]
		print("DEBUG: %s: %s" % (caller_name, message))
		sys.stdout.flush()


def _debug_dict(dict_, level=0):
	if _DEBUG:
		for k, v in dict_.items():
			prefix = "    " * (level + 1) + "{}:".format(str(k))
			if isinstance(v, Mapping):
				debug_message(prefix)
				_debug_dict(v, level=level+1)
			else:
				debug_message(prefix + " " + str(v))


def debug_dict(title, dict_):
	debug_message(title + ":")
	_debug_dict(dict_)
