sRGB Helpers by TroggleMonkey:

BASIC USAGE:
The .cg shaders in this file should be helpful to shader authors wanting to make
multi-pass gamma-correct shaders with sRGB framebuffers.  Follow these steps:

1.) Start every multi-pass sRGB shader pass0 = "first-pass-linearize.cg" or
    similar, and set srgb_framebuffer0 = "true" for every pass except the last.
    This converts the input from gamma-encoded RGB (usually with an NTSC gamma
    of 2.2) to linear RGB in the first pass and lets you use linear RGB
    throughout your pipeline (without banding from direct 8-bit quantization).
2.) Whenever you want to read from ORIG.texture, read from PASS1.texture instead.
    Don't linearize any inputs yourself, unless you're reading from a gamma-
    encoded LUT that wasn't already linearized.
3.) The output of the last pass should be gamma-corrected.  You can do this one
    of two ways:
    a.) Manually gamma-correct with pow().  This works for simple use cases.
    b.) Add a "last-pass-gamma-correct*.cg" shader as your last shader.  This
        works like a gamma-correcting stock shader, and it makes it easier to
        use the .cg file for your "real" last pass in other contexts without
        changing whether it gamma-corrects its output.
    c.) Do what option b. does in the context of a larger shader:
        i.)   #define LAST_PASS at the beginning
        ii.)  #include "include/gamma-management.h" (prefix with
              "../" to go up a directory) after that
        iii.) "return encode_output(color);" at the end

ADVANCED USAGE:
Option c. is overkill if you're only targeting sRGB-capable platforms, but it
allows for the easiest code reuse if you're targeting mixed platforms.  The
description in gamma-management.h details its functionality more concisely
than this README, but the rest of this file is devoted to going into more detail
about what it's useful for (mostly extreme industrial-sized shader projects ;)).

The purpose of gamma-management.h is to help shaders to be gamma-correct
without banding whether sRGB framebuffers are supported or not.  Normally, it
would take a lot of work to switch between a gamma-correct sRGB pipeline and a
gamma-correct pipeline where sRGB isn't supported, but gamma-management.h
wrappers let you do it by changing a single #define.

If you replace tex*D*() calls with tex*D*_linearize(), samples are automatically
linearized according to global gamma constants depending on whether your #define
settings say they need to be.  Similarly, if you replace your "return color"
statement with "return encode_output(color)," the output is automatically
gamma-encoded depending on whether your #defines say it needs to be.  These are:
1.) FIRST_PASS (if this is the first pass)
2.) LAST_PASS (if this is the last pass)
3.) GAMMA_ENCODE_EVERY_FBO (if you want to be gamma-correct without sRGB)
If GAMMA_ENCODE_EVERY_FBO is #defined, the linearizing read functions will
automatically linearize every pass, and the output encoding function will
automatically gamma-encode every pass.  Otherwise, only the first pass will
linearize its inputs, and only the last pass will gamma-correct its outputs.
Using these functions allows you to easily switch between gamma-correct
pipelines with and without sRGB support just by changing a single #define in
each pass...as opposed to changing every shader output and every single line
of code that reads from a texture.  As a result, you can even use the same code
for both shader versions and simply #include it from a skeleton file that
#defines the appropriate settings.

CONTROLLING GAMMA VALUES SYSTEMATICALLY:
The encode_output() function may seem silly at first, but gamma-management.h
can work with any kind of different input and output gammas.  If you want to be
direct, you can #define OVERRIDE_FINAL_GAMMA and define the following three
constants yourself:
    static const float input_gamma
    static const float intermediate_gamma (for GAMMA_ENCODE_EVERY_FBO)
    static const float output_gamma

gamma-management.h can also correctly simulate e.g. Game Boy Advance gamma on
a desktop LCD by #defining the appropriate macro in the first and last passes
(SIMULATE_GBA_ON_LCD in this case).  A number of linearize-first-pass*.cg and
gamma-correct-last-pass*.cg shaders are included which do this.  If you want to
use this functionality but you prefer to use different gamma values, you can
change its assumptions about standard gamma values by #defining
OVERRIDE_DEVICE_GAMMA and defining the following constants:
    static const float crt_gamma (default 2.5)
    static const float gba_gamma (default 3.5)
    static const float lcd_gamma (default 2.2)

ROLLING YOUR OWN:
If gamma-management.h is overkill for you and you want to manually simulate
other displays, remember to keep track of which pass is first (so you don't
double-apply a device's gamma/transfer function).  Also note that output
encoding is a bit trickier than usual too:
a.) If you're linearizing input based on a video standard (like NTSC 2.2 gamma),
    you should just output to the video standard your monitor expects (usually
    sRGB, but 2.2 gamma is a decent approximation).  Your true display device
    may have a higher gamma than 2.2 (2.5 is reference CRT level), but encoding
    for your device gamma overrides the "perceptual rendering intent" baked into
    old video standards: Basically, video standards undercorrect for reference
    CRT gamma due to a longstanding assumption of dark room viewing:
        http://www.poynton.com/GammaFAQ.html
    This non-unity end-to-end gamma was designed with camera video in mind, but
    game art was made based on the same standards and output devices...and then
    display engineers misunderstood the standard and started making CRT's target
    2.2 gamma with circuitry anyway, but I don't know when that happened.
b.) If you're linearizing by simulating the light output of another device, e.g.
    a CRT or a Game Boy Advance, it's important to encode the final output with
    the gamma of your actual display technology.  Otherwise, the gamma output
    could be like looking at a photo of your simulated device rather than the
    real thing.  For a trivial example, consider the case of simulating a
    Game Boy Advance screen on a 2.5-gamma reference CRT: If you decode with 3.5
    gamma and reencode for 2.2 gamma, the output will be too dark.  This "photo
    effect" comes from virtually double-displaying on devices whose output gamma
    doesn't match video standard gamma (for the reason mentioned in a.).  Once
    you convert to the linear light output of a simulated device in the first
    pass (and optionally simulate light mixing), you want your actual display
    device to emit the same amount of light you painstakingly simulated.  To do
    this, compensate for your display's potentially "artistic" gamma by encoding
    directly for its true gamma level.
