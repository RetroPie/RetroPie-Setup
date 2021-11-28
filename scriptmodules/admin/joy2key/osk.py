"""
This file is part of The RetroPie Project
The RetroPie Project is the legal property of its developers, whose names are
too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
See the LICENSE.md file at the top-level directory of this distribution and
https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md.

OnScreen Keyboard console utility.

Allows the user to enter a string (ASCII) and outputs the string.
It should be wrapped by 'joy2key' helper script,
so that the gamepad can be used to navigate and enter the necessary characters.

Keys:
 - directional keys to move around
 - Enter to select a key / press a button
 - Esc to exit the form

It uses the [URWID](https://urwid.org) Python library to show a nice console based keyboard.


Example usage:
 <script> WindowTitle StringName [min char number]

Exit code can be:
 - 0 (success), the string entered by the user is written to STDERR
 - 1 (cancel/error) if the user chose cancel to exit
"""

import sys

from os import get_terminal_size
from argparse import ArgumentParser

import urwid
from urwid.widget import Text, Divider
from urwid.container import Columns, Frame, GridFlow, Overlay, Pile, WidgetWrap
from urwid.decoration import AttrMap, AttrWrap, Filler, Padding
from urwid.graphics import LineBox
from urwid.signals import connect_signal
from urwid.command_map import ACTIVATE


ASCII_BLOCK = '█'

# What we consider a small screen
SMALL_SCREEN_COLS = 43
SMALL_SCREEN_ROWS = 22

"""
Colors used in the application controls
"""
PALETTE = [
    # Input box: border, text and prompt
    ('input',      'dark gray', 'light gray'),
    ('input text', 'black',     'light gray'),
    ('prompt',     'dark red',  'dark cyan' ),

    # Body
    ('body',     'black',  'light gray'),
    ('bg',       'white',  'dark blue'),

    # Focused key
    ('focus key', 'white', 'dark blue'),

    # Header
    ('header',      'light cyan', 'dark blue'),
    ('bold header', 'dark cyan',  'dark blue'),

    # Buttons
    ('button',         'black',     'light gray'),
    ('selected',       'white',     'dark blue' ),
    ('label',          'dark gray', 'light gray'),
    ('label selected', 'yellow',    'dark blue' ),

    # Error dialog
    ('error', 'dark red', 'light gray')
]


class CenteredButton(WidgetWrap):
    """
    Custom button class that:
      * centers the label text
      * allows to disable the left/righ button margins/characters
      * disables the 'space' key handling
    """
    def selectable(self):
        return True

    def sizing(self):
        return frozenset([FLOW])

    signals = ["click"]

    def __init__(self, label, on_press=None, user_data=None, delimiters=True):
        self._label = Text(label, align='center')

        if delimiters:
            cols = Columns(
                [
                    ('fixed', 1, Text("<")),
                    self._label,
                    ('fixed', 1, Text(">"))
                ],
                dividechars=1)
        else:
            cols = self._label

        self.__super.__init__(cols)

        if on_press:
            connect_signal(self, 'click', on_press, user_data)

    # The rest of the methods are taken from urwid.Button

    def set_label(self, label):
        self._label.set_text(label)

    def get_label(self):
        return self._label.text
    label = property(get_label)

    def keypress(self, size, key):
        # don't activate with the 'Space' key
        if self._command_map[key] != ACTIVATE or key == ' ':
            return key

        self._emit('click')

    def mouse_event(self, size, event, button, x, y, focus):
        return False


class KeyButton(CenteredButton):
    """
    Custom button class to model a keyboard key
    It has primary and secondary key values, returned based on the shift state
    """
    def __init__(self, text, primary=None, secondary=None, on_press=None, user_data=None):
        self.__super.__init__(text, on_press, user_data, delimiters=False)

        # store the primary and secondary key values
        if primary is None:
            self.primary_val = text
        else:
            self.primary_val = primary

        # calculate the secondary value when the label is a letter
        if secondary is None and len(text) == 1:
            self.secondary_val = text.upper()
        else:
            self.secondary_val = secondary

    def shift(self, shifted):
        """
        Simulate a shift key press, changing the key's label
        This may change the button's appearance
        """
        if (shifted
                and self.secondary_val is not None
                and len(self.secondary_val.strip()) > 0):
            self.set_label(self.secondary_val)

        if (not shifted
                and self.primary_val is not None
                and len(self.primary_val.strip()) > 0):
            self.set_label(self.primary_val)

    def get_value(self, shifted):
        if shifted and self.secondary_val:
            return self.secondary_val

        if not shifted and self.primary_val:
            return self.primary_val


class WrappableColumns(Columns):
    """
    Custom Columns class
    Adds the ability to wrap-around the children (left-right) when navigating
    """
    def keypress(self, size, key):
        if self.__super.keypress(size, key):
            if key not in ('left', 'right'):
                return key

            # we have a key, so it wasn't handled by any parent container
            # handle 'left'/'right' ourselves for cursor wrapping
            if key in ('left'):
                # iterate from last widget to first
                widgets = list(range(len(self.contents) - 1, -1, -1))
            else:
                # iterate from first widget to last
                widgets = list(range(0, len(self.contents)))

            # Find the 1st selectable widget and focus it
            for i in widgets:
                if not self.contents[i][0].selectable():
                    continue

                self.focus_position = i
                break


class ViewExit(Exception):
    pass


class OSK:
    """
    Main class for the on-screen keyboard application
    """

    def __init__(self, title, input_title, min_chars=0, dim=False):
        """
        :param title: the string used in the application heading
        :param input_title: the name of the input string being captured (e.g. Password)
        :param min_chars: minimum number of characters for a valid string (default: 8)
        :param dim: optimize for a smaller screen (True/False)
        """
        self._input_title = input_title
        self._min_chars = min_chars
        self.small_display = dim
        self.def_keys = []
        self.frame = self.setup_frame(title, input_title)
        self.pop_up = self.setup_popup("Error")

        # Create the main view, overlaying the popup widget with the main view
        view = Overlay(self.pop_up, self.frame, 'center', None, 'middle', None)

        self.view = view

    def setup_frame(self, title, input_title):
        """
        Creates the main view, with a 3 horizontal pane container (Frame)
        """
        self.keys = []  # List of keys added to the OSK
        self._shift = False  # OSK Shift key state

        # title frame (header) uses a LineBox with just the bottom line enabled
        # if we're on a small display, use a simple Text with Padding
        if self.small_display:
            header = Padding(Text(title, align='center'))

        else:
            header = LineBox(Text(title),
                             tline=None, rline=' ', lline=' ',
                             trcorner=' ', tlcorner=' ', blcorner='', brcorner='')

        header = AttrWrap(header, 'header')

        # Body frame, containing the input and the OSK widget
        input = Text([('input text', ''), ('prompt', ASCII_BLOCK)])
        self.input = input

        Key = self.add_osk_key  # alias the key creation function
        osk = Pile([
                # 1st keyboard row
                WrappableColumns([
                    (1, Text(" ")),
                    (3, Key('`', shifted='~')),
                    (3, Key('1', shifted='!')),
                    (3, Key('2', shifted='@')),
                    (3, Key('3', shifted='#')),
                    (3, Key('4', shifted='$')),
                    (3, Key('5', shifted='%')),
                    (3, Key('6', shifted='^')),
                    (3, Key('7', shifted='&')),
                    (3, Key('8', shifted='*')),
                    (3, Key('9', shifted='(')),
                    (3, Key('0', shifted=')')),
                    (3, Key('-', shifted='_')),
                    (3, Key('=', shifted='+')),
                    (1, Text(" ")),
                    ], 0),
                Divider(),
                # 2nd keyboard row
                WrappableColumns([
                    (2, Text(" ")),
                    (3, Key('q')),
                    (3, Key('w')),
                    (3, Key('e')),
                    (3, Key('r')),
                    (3, Key('t')),
                    (3, Key('y')),
                    (3, Key('u')),
                    (3, Key('i')),
                    (3, Key('o')),
                    (3, Key('p')),
                    (3, Key('[', shifted='{')),
                    (3, Key(']', shifted='}')),
                    (3, Key('\\', shifted='|')),
                    ], 0),
                Divider(),
                # 3rd keyboard row
                WrappableColumns([
                    (3, Text(" ")),
                    (3, Key('a')),
                    (3, Key('s')),
                    (3, Key('d')),
                    (3, Key('f')),
                    (3, Key('g')),
                    (3, Key('h')),
                    (3, Key('j')),
                    (3, Key('k')),
                    (3, Key('l')),
                    (3, Key(';', shifted=':')),
                    (3, Key('\'', shifted='"')),
                    ], 0),
                Divider(),
                # 4th keyboard row
                WrappableColumns([
                    (4, Text(" ")),
                    (3, Key('z')),
                    (3, Key('x')),
                    (3, Key('c')),
                    (3, Key('v')),
                    (3, Key('b')),
                    (3, Key('n')),
                    (3, Key('m')),
                    (3, Key(',', shifted='<')),
                    (3, Key('.', shifted='>')),
                    (3, Key('/', shifted='?'))
                    ], 0),
                Divider(),
                # 5th (last) keyboard row
                WrappableColumns([
                    (1, Text(" ")),
                    (9, Key('↑ Shift', shifted='↑ SHIFT', callback=self.shift_key_press)),
                    (2, Text(" ")),
                    (15, Key('Space', value=' ', shifted=' ')),
                    (2, Text(" ")),
                    (10, Key('Delete ←', callback=self.bksp_key_press)),
                    ], 0),
                Divider()
              ])

        if self.small_display:
            # small displays: remove last divider line
            osk.contents.pop(len(osk.contents) - 1)

        osk = Padding(osk, 'center', 40)

        # setup the text input and the buttons
        input=AttrWrap(LineBox(input), 'input')
        input = Padding(AttrWrap(input, 'input text'), 'center', ('relative', 80), min_width=30)
        ok_btn = self.setup_button("OK", self.button_press, exitcode=0)
        cancel_btn = self.setup_button("Cancel", self.button_press, exitcode=1)

        # setup the main OSK area, depending on the screen size
        if self.small_display:
            body = Pile([
                        Text(f'Enter the {input_title}', align='center'),
                        input,
                        Divider(),
                        osk,
                        Divider(),
                        GridFlow([ok_btn, cancel_btn], 10, 2, 0, 'center'),
                        Divider()
                        ])
        else:
            body = Pile([
                        Divider(), input,
                        Divider(), osk,
                        LineBox(
                            GridFlow([ok_btn, cancel_btn], 10, 2, 0, 'center'),
                            bline=None, lline=None, rline=None, tlcorner='─', trcorner='─')
                        ])
            body = LineBox(body, f'Enter the {input_title}')

        body = AttrWrap(body, 'body')  # Style the main OSK area

        # wrap and align the main OSK in the frame
        body = Padding(body, 'center', 55, min_width=42)
        body = Filler(body, 'middle')

        body = AttrWrap(body, 'bg')  # Style the body containing the OSK

        frame = Frame(body, header=header, focus_part='body')

        return frame

    def setup_button(self, label, callback, exitcode=None):
        """
        Creates a button and applies the styling
        """
        button = CenteredButton(('label', label), callback, delimiters=True)
        button.exitcode = exitcode
        button = AttrMap(button, {None: 'button'}, {None: 'selected', 'label': 'label selected'})

        return button

    def setup_popup(self, title):
        """
        Overlays a dialog box on top of the working view using a Frame
        """

        # Header
        if self.small_display:
            header = Padding(Text(title, align='center'))
        else:
            header = LineBox(Text(title),
                             tline=None, rline=' ', lline=' ',
                             trcorner=' ', tlcorner=' ', blcorner='', brcorner='')

        header = AttrWrap(header, 'header')

        # Body
        error_text = Text("", align='center')
        # register the Text widget with the application, so we can change it
        self._error = error_text

        error_text = AttrWrap(error_text, 'error')
        body = Pile([
                    Divider(), error_text,
                    Divider(),
                    LineBox(
                        GridFlow([self.setup_button("Dismiss", self.close_popup)],
                                 12, 2, 0, 'center'),
                        bline=None, lline=None, rline=None, tlcorner='─', trcorner='─')
                    ])

        body = LineBox(body)
        body = AttrWrap(body, 'body')

        # on small displays let the popup fill the screen (horizontal)
        if self.small_display:
            body = Padding(Filler(body, 'middle'), 'center')
        else:
            body = Padding(Filler(body, 'middle'), 'center', ('relative', 50))

        body = AttrWrap(body, 'bg')

        # Main dialog widget
        dialog = Frame(
            body,
            header=header,
            focus_part='body'
        )

        return dialog

    def close_popup(self, widget=None):
        self.loop.widget = self.frame

    def open_popup(self):
        self.loop.widget = self.pop_up

    def set_shifted(self, state):
        self._shift = state
        for b in self.keys:
            b.shift(state)

    def get_shifted(self):
        return self._shift

    # create a class property for the shifted state
    shifted = property(get_shifted, set_shifted, "The Shift key state")

    def set_error_text(self, message):
        """
        Sets the error message displayed by 'pop_up'
        """
        self._error.set_text(message)

    def shift_key_press(self, key=None):
        """
        Toggle the Shift key, update display of all printable keys
        """
        self.shifted = not self.shifted

    def button_press(self, btn):
        txt = self.input.get_text()[0].rstrip(ASCII_BLOCK)

        # check the input string length when OK is asking to exit
        if len(txt) < self._min_chars and btn.exitcode == 0:
            self.set_error_text(f"{self._input_title} must have at least {self._min_chars} characters")
            self.open_popup()
            return

        raise ViewExit(btn.exitcode)

    def bksp_key_press(self, key=None):
        """
        Handle the pressing of the erase key
        Remove one char from the end of the text input
        """
        txt = self.input.get_text()[0].rstrip(ASCII_BLOCK)

        if len(txt) > 0:
            txt = txt[:-1]

        self.input.set_text([('input text', txt), ('prompt', ASCII_BLOCK)])

    def def_key_press(self, key):
        """
        Default OSK key press handler, it adds the pressed key to the text input
        """
        _inner = key.get_value(self.shifted)
        if _inner is None:
            return

        # remove the final block from the input control and append the value
        txt = self.input.get_text()[0].rstrip(ASCII_BLOCK)
        self.input.set_text([('input text', txt + _inner), ('prompt', ASCII_BLOCK)])

        # when keyboard is shifted, toggle the shift key after a key press
        if self.shifted:
            self.shift_key_press()

    def add_osk_key(self, key, value=None, shifted=None, callback=None):
        """
        Method to create a KeyButton with the primary/secondary values and the callback handler
        """
        if callback is None:
            callback = self.def_key_press

        btn = KeyButton(key, primary=value, secondary=shifted, on_press=callback)

        # store the key internally, so we can shift it when needed
        self.keys.append(btn)
        self.def_keys.append(btn.get_value(False))
        self.def_keys.append(btn.get_value(True))

        return AttrWrap(btn, None, 'focus key')

    def unhandled_key(self, key):
        """
        Keyboard input handling
        """
        # handle the normal key press
        if len(key) == 1 and ord(key) in range(32, 127):
            txt = self.input.get_text()[0].rstrip(ASCII_BLOCK)
            self.input.set_text([('input text', txt + key), ('prompt', ASCII_BLOCK)])
            return

        if key == 'backspace':
            self.bksp_key_press()

        # handle Esccape:
        # - close the error dialog, if in view, and return to main form
        # - exit application if on main form
        if str(key) in ('esc'):
            if self.loop.widget == self.pop_up:
                self.close_popup()
            else:
                raise urwid.ExitMainLoop()

        # unhandled, pass it on
        return key

    def check_wpa_chars(self):
        """
        Debugging method to check whether the OSK provides all valid WPA chars

        All allowed WPA chars(https://en.wikipedia.org/wiki/Wi-Fi_Protected_Access#cite_note-21):
        Each character in the passphrase must have an encoding in the range of 32 to 126 (decimal), inclusive
        """
        wpa_chars = []
        for i in range(32, 127):
            wpa_chars.append(i)
        print(f' All allowed WPA password characters:\n {[chr(k) for k in wpa_chars]}')

        missing = False
        for k in wpa_chars:
            if chr(k) not in self.def_keys:
                print(f' {chr(k)} is not provided !')
                missing = True

        if not missing:
            print(f'All chars are handled !')

    def on_exit(self, exitcode):
        """
        On exit, return an exitcode and - conditionally - the input text
        """
        if exitcode != 0:
            return exitcode, ''
        else:
            return exitcode, self.input.get_text()[0].rstrip(ASCII_BLOCK)

    def main(self):
        """
        Runs the event/display loop for our view
        When the OK/Cancel buttons are used, 'ViewExit' will be raised,
        otherwise assume the user has used 'Esc' to close the dialog
        """
        self.loop = urwid.MainLoop(self.frame, PALETTE, unhandled_input=self.unhandled_key)
        try:
            self.loop.run()
            return self.on_exit(1)
        except ViewExit as e:
            return self.on_exit(e.args[0])


def parse_arguments(args):
    parser = ArgumentParser(description="Reads a string using an On Screen Keyboard")

    parser.add_argument('--backtitle', type=str, help='Window title', required=True)
    parser.add_argument('--inputbox', type=str, help='Name of the string being captured', required=True)
    parser.add_argument(
        '--minchars', type=int, nargs='?',
        help='Minimum number of characters needed (default: %(default)s)',
        default=8)

    args = parser.parse_args()
    return args.backtitle, args.inputbox, args.minchars


def main():
    backtitle, inputbox, minchars = parse_arguments(sys.argv)

    # get the terminal size to detect small display
    cols, rows = get_terminal_size(0)

    osk = OSK(backtitle, inputbox, minchars, (cols < SMALL_SCREEN_COLS or rows < SMALL_SCREEN_ROWS))
    exitcode, exitstring = osk.main()

    # print the input text when returned by the application
    if exitstring:
        sys.stderr.write(exitstring + "\n")

    sys.exit(exitcode)


if __name__ == "__main__":
    main()
