#!/usr/bin/python3

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

import os, sys, struct, time, fcntl, termios, signal
import curses, errno, logging, re
from pyudev import Context

logging.basicConfig(level=os.environ.get("JOY2KEY_LOGLEVEL", "INFO"))

#    struct js_event {
#        __u32 time;     /* event timestamp in milliseconds */
#        __s16 value;    /* value */
#        __u8 type;      /* event type */
#        __u8 number;    /* axis/button number */
#    };

JS_MIN = -32768
JS_MAX = 32768
JS_REP = 0.20

JS_THRESH = 0.75

JS_EVENT_BUTTON = 0x01
JS_EVENT_AXIS = 0x02
JS_EVENT_INIT = 0x80

CONFIG_DIR = '/opt/retropie/configs/'
RETROARCH_CFG = CONFIG_DIR + 'all/retroarch.cfg'

_TTY_FD = []
_JS_DEVICES = set()
_AXIS_CODES = []
_EVENT_FORMAT = 'IhBB'
_EVENT_SIZE = struct.calcsize(_EVENT_FORMAT)


def ini_get(key, cfg_file):
    pattern = r'[ |\t]*' + key + r'[ |\t]*=[ |\t]*'
    value_m = r'"*([^"\|\r]*)"*'
    value = ''
    with open(cfg_file, 'r') as ini_file:
        for line in ini_file:
            if re.match(pattern, line):
                value = re.sub(pattern + value_m + '.*\n', r'\1', line)
                break
    return value

def get_btn_num(btn, cfg):
    num = ini_get('input_' + btn + '_btn', cfg)
    if num: return num
    num = ini_get('input_player1_' + btn + '_btn', cfg)
    if num: return num
    return ''

def sysdev_get(key, sysdev_path):
    value = ''
    for line in open(sysdev_path + key, 'r'):
        value = line.rstrip('\n')
        break
    return value

def get_button_codes(dev_path, default_button_codes):
    js_cfg_dir = CONFIG_DIR + 'all/retroarch-joypads/'
    js_cfg = ''
    dev_name = ''
    dev_button_codes = list(default_button_codes)

    for device in Context().list_devices(DEVNAME=dev_path):
        sysdev_path = os.path.normpath('/sys' + device.get('DEVPATH')) + '/'
        if not os.path.isfile(sysdev_path + 'name'):
            sysdev_path = os.path.normpath(sysdev_path + '/../') + '/'
        # getting joystick name
        dev_name = sysdev_get('name', sysdev_path)
        # getting joystick vendor ID
        dev_vendor_id = int(sysdev_get('id/vendor', sysdev_path), 16)
        # getting joystick product ID
        dev_product_id = int(sysdev_get('id/product', sysdev_path), 16)
    if not dev_name:
        logging.debug("Unable to find " + sysdev_path)
        return dev_button_codes

    # getting retroarch config file for joystick
    for f in os.listdir(js_cfg_dir):
        if f.endswith('.cfg'):
            input_device = ini_get('input_device', js_cfg_dir + f)
            input_vendor_id = ini_get('input_vendor_id', js_cfg_dir + f)
            input_product_id = ini_get('input_product_id', js_cfg_dir + f)
            if (input_device == dev_name and
               (input_vendor_id  == '' or int(input_vendor_id)  == dev_vendor_id) and
               (input_product_id == '' or int(input_product_id) == dev_product_id)):
                js_cfg = js_cfg_dir + f
                break
    if not js_cfg:
        js_cfg = RETROARCH_CFG

    # getting configs for dpad, buttons A, B, X and Y
    btn_map = [ 'left', 'right', 'up', 'down', 'a', 'b', 'x', 'y' ]
    btn_num = {}
    biggest_num = 0
    i = 0
    for btn in list(btn_map):
        if i >= len(dev_button_codes):
            break
        try:
            btn_num[btn] = int(get_btn_num(btn, js_cfg))
        except ValueError:
            btn_map.pop(i)
            dev_button_codes.pop(i)
            btn_num.pop(btn, None)
            continue
        if btn_num[btn] > biggest_num:
            biggest_num = btn_num[btn]
        i += 1

    # building the button codes list
    btn_codes = [''] * (biggest_num + 1)
    i = 0
    for btn in btn_map:
        if i >= len(dev_button_codes):
            break
        btn_codes[btn_num[btn]] = dev_button_codes[i]
        i += 1
    try:
        # if button A is <enter> and menu_swap_ok_cancel_buttons is true, swap buttons A and B functions
        if (ini_get('menu_swap_ok_cancel_buttons', RETROARCH_CFG) == 'true' and
           'a' in btn_num and 'b' in btn_num and btn_codes[btn_num['a']] == '\n'):
            btn_codes[btn_num['a']] = btn_codes[btn_num['b']]
            btn_codes[btn_num['b']] = '\n'
    except (IOError, ValueError):
        pass

    return btn_codes

def signal_handler(signum, frame):
    _exit(0)

def _exit(code):
    signal.signal(signal.SIGINT, signal.SIG_IGN)
    signal.signal(signal.SIGTERM, signal.SIG_IGN)
    close_devices(_JS_DEVICES)
    if (_TTY_FD):
        os.close(_TTY_FD)
    sys.exit(code)

def get_hex_chars(key_str):
    if (key_str.startswith("0x")):
        out = bytes.fromhex(key_str[2:])
    else:
        out = curses.tigetstr(key_str)
    if type(out) is bytes:
        out = out.decode('utf-8')
    return out


class _JoystickDevice(object):
    def __init__(self, name, default_button_codes):
        self._name = name
        dev_path = os.path.join('/dev/input', name)
        self._fd = os.open(dev_path, os.O_RDONLY | os.O_NONBLOCK)
        self._button_codes = get_button_codes(dev_path, default_button_codes)
        self._last_event_time = 0

    @property
    def name(self):
        return None if self._name is None else str(self._name)

    @property
    def fd(self):
        return None if self._fd is None else self._fd

    @property
    def button_codes(self):
        return None if self._button_codes is None else dict(self._button_codes)

    def process_event(self):
        event = _read_event(self._fd)
        if event:
            # TODO: There are at least two remaining problems with the
            # following "repeat prevention" logic:
            #
            #   1) Joysticks don't send a continuous stream of "pressed"
            #      events for dpad/buttons.  They only send a "pressed"
            #      event when the button is first pressed down and a
            #      "released" event when the button is released, with no
            #      other events in between for that button.  It's up to
            #      us to generate repeated keystrokes at a sensible
            #      rate during that interval.  Therefore, we don't need
            #      to prevent repetition at all!
            #
            #   2) This logic completely neglects to make the repeat
            #      check specific to each button... so it also has the
            #      annoying side effect of blocking consecutive presses
            #      of two different buttons that occur too quickly.
            #
            # For both of the above reasons, I am leaving this commented
            # out for now.
            #if time.time() - self._last_event_time > JS_REP:
            if True:
                if _process_event(event, self._button_codes):
                    self._last_event_time = time.time()
        return event != False

    def close(self):
        self._name = None
        os.close(self._fd)
        self._fd = None
        self._button_codes = None


def rescan_devices(devices, default_button_codes):
    logging.debug("Rescanning devices...")
    devices = devices.copy()
    known_names = set([dev.name for dev in devices])
    current_names = set([name for name in os.listdir('/dev/input') if name.startswith('js')])

    deleted_names = known_names.difference(current_names)
    for dev in devices.copy():
        if dev.name in deleted_names:
            devices.remove(dev)
            logging.debug("  Removed " + dev.name)
            dev.close()

    added_names = current_names.difference(known_names)
    for name in added_names:
        try:
            devices.add(_JoystickDevice(name, default_button_codes))
            logging.debug("  Added " + name)
        except (OSError, ValueError):
            pass

    logging.debug("Done rescanning devices.")
    return devices


def close_devices(devices):
    for device in devices.copy():
        devices.remove(device)
        device.close()


def _read_event(fd):
    try:
        return os.read(fd, _EVENT_SIZE)
    except OSError as e:
        if e.errno == errno.EWOULDBLOCK:
            return None
        return False


def _process_event(event, button_codes):
    (js_time, js_value, js_type, js_number) = struct.unpack(_EVENT_FORMAT, event)

    # ignore init events
    if js_type & JS_EVENT_INIT:
        return False

    hex_chars = ""

    if js_type == JS_EVENT_BUTTON:
        if js_number < len(button_codes) and js_value == 1:
            hex_chars = button_codes[js_number]

    if js_type == JS_EVENT_AXIS and js_number <= 7:
        if js_number % 2 == 0:
            if js_value <= JS_MIN * JS_THRESH:
                hex_chars = _AXIS_CODES[0]
            if js_value >= JS_MAX * JS_THRESH:
                hex_chars = _AXIS_CODES[1]
        if js_number % 2 == 1:
            if js_value <= JS_MIN * JS_THRESH:
                hex_chars = _AXIS_CODES[2]
            if js_value >= JS_MAX * JS_THRESH:
                hex_chars = _AXIS_CODES[3]

    if hex_chars:
        for c in hex_chars:
            fcntl.ioctl(_TTY_FD, termios.TIOCSTI, c)
        return True

    return False


def _main():
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)

    # NOTE: We cannot use os.fork() to make this script effectively
    # rerun itself as a background process, because that API doesn't
    # work correctly when run within certain contexts, such as from
    # inside of a bash subshell command, i.e. "$(joy2key.py)".

    default_button_codes = []
    curses.setupterm()
    i = 0
    for arg in sys.argv[1:]:
        chars = get_hex_chars(arg)
        if i < 4:
            _AXIS_CODES.append(chars)

        logging.debug("Adding default button code " + str(chars.encode('utf-8')))
        default_button_codes.append(chars)
        i += 1

    try:
        global _TTY_FD
        _TTY_FD = os.open('/dev/tty', os.O_WRONLY)
    except IOError:
        print('Unable to open /dev/tty', file = sys.stderr)
        _exit(1)

    global _JS_DEVICES
    rescan_time = 0
    while True:
        if time.time() - rescan_time > 2:
            _JS_DEVICES = rescan_devices(_JS_DEVICES, default_button_codes)
            rescan_time = time.time()

        while not _JS_DEVICES:
            _JS_DEVICES = rescan_devices(_JS_DEVICES, default_button_codes)
            if _JS_DEVICES:
                rescan_time = time.time()
            else:
                time.sleep(1)
                continue
        
        for jsdev in _JS_DEVICES.copy():
            if not jsdev.process_event():
                logging.debug("Removing " + jsdev.name + " due to process_event() failure")
                _JS_DEVICES.remove(jsdev)
                jsdev.close()

        time.sleep(0.01)


if __name__ == '__main__':
    _main()
