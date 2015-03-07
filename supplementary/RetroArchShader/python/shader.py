from rarch import *

class Test:
   def saturation(self, frame):
      return input_analog(1, ANALOG_LEFT, ANALOG_X) + 1.0
   def brightness(self, frame):
      return input_analog(1, ANALOG_LEFT, ANALOG_Y) + 1.0
