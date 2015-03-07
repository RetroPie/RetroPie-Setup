Blurs by TroggleMonkey:

DESCRIPTION:
Gaussian blurs are common building blocks in multi-pass shaders, and this
library of optimized and tested blurs should make it easier to use whatever size
blur you need.  All of these shaders are based on the tex2Dblur* functions in
include/blur-functions.h, so you can use those directly if you ever need to
add more processing to the same pass as a Gaussian blur.

PICK THE RIGHT BLUR FOR YOUR USE CASE:
There are several different types of blurs, ranging in size from 3-12 texels:
a.) "Resize" separable blurs use vertical and horizontal passes and require N
    taps for an Nx blur.  These are arbitrarily resizable.
b.) "Fast" separable blurs use vertical and horizontal passes and require N taps
    for an (N*2 - 1)x blur.  They exploit bilinear filtering to reduce the
    required taps from e.g. 9 to 5.  These are always faster, but they have
    strict image scale requirements.
c.) "Resize" one-pass blurs combine the vertical/horizontal passes of the
    "resize" separable blurs, and they require NxN taps for an NxN blur.  These
    perform slowly enough that only tex2Dblur3x3resize is useful/included.
d.) Other one-pass blurs combine the vertical/horizontal passes of the "fast"
    separable blurs, and they exploit bilinear filtering the same way.  They're
    faster than separable blurs at 3x3, competitive at 5x5 depending on options,
    and slower at 7x7 and above...but larger blurs may still be useful if you're
    hurting for passes.
e.) "Shared" one-pass blurs go a step further: They also use quad-pixel
    communication with fine-grained derivatives to distribute texture samples
    across a 2x2 pixel quad.  (ddx() and ddy() are required, as well as a GPU
    that uses fine-grained derivatives).  These blurs are faster than the other
    one-pass blurs, but they have some artifacts from combining sample-sharing
    with bilinear sampling, so they're best reserved for reblurring an already-
    blurred input.

Every blur expects linear filtering.  Except for resize separable blurs, all
require a pass scale of (1/(2^M)) for some M >= 0.  That is, the output image
has to have a 1:1 pixel:texel ratio with some mipmap of the input image, so use
e.g. scaleN = "1.0" or scaleN = "0.25", not scaleN = "0.33" or scaleN = "2.0".
Note: mipmap_inputN must = "true" in your .cgp file for scales other than 1.0.

There are two suffixes on the .cg files relating to gamma correction:
* Blurs with no suffix assume linear RGB input and output.
* Blurs with a "-last-pass" suffix use pow() to gamma-correct their output.
* Blurs with a "-gamma-encode-every-fbo" suffix use pow() to linearize each
  input sample and again to gamma-correct the output.  These blurs are MUCH
  slower than blurs without this suffix, but they're provided in case you want
  to be [almost] gamma-correct on platforms without sRGB FBO's.  (The "almost"
  is because bilinear filtering still won't be gamma-correct without sRGB.)
* There are also blurs with both suffixes.  This may seem redundant, but they
  make it easier to use a different output gamma for the last pass than for
  the rest of the pipeline (such as when simulating another display device like
  a Game Boy Advance or CRT).  See srgb-helpers/README.txt for more information.

BENCHMARK RESULTS:
Blurs have different performance characteristics depending on whether the input
is mipmapped and depending on whether they're gamma-encoding every FBO.  Here's
an excerpt from the blur-functions.h description with a comparison.  Note that
benchmarks without an sRGB heading use "-gamma-encode-every-fbo" suffixes, and
you can just look at the sRGB performance figures if you don't care about gamma:
//  Here are some framerates from a GeForce 8800GTS.  The first pass resizes to
//  viewport size (4x in this test) and linearizes for sRGB codepaths, and the
//  remaining passes perform 6 full blurs.  Mipmapped tests are performed at the
//  same scale, so they just measure the cost of mipmapping each FBO (only every
//  other FBO is mipmapped for separable blurs, to mimic realistic usage).
//  Mipmap      Neither     sRGB+Mipmap sRGB        Function
//  76.0        92.3        131.3       193.7       tex2Dblur3fast
//  63.2        74.4        122.4       175.5       tex2Dblur3resize
//  93.7        121.2       159.3       263.2       tex2Dblur3x3
//  59.7        68.7        115.4       162.1       tex2Dblur3x3resize
//  63.2        74.4        122.4       175.5       tex2Dblur5fast
//  49.3        54.8        100.0       132.7       tex2Dblur5resize
//  59.7        68.7        115.4       162.1       tex2Dblur5x5
//  64.9        77.2        99.1        137.2       tex2Dblur6x6shared
//  55.8        63.7        110.4       151.8       tex2Dblur7fast
//  39.8        43.9        83.9        105.8       tex2Dblur7resize
//  40.0        44.2        83.2        104.9       tex2Dblur7x7
//  56.4        65.5        71.9        87.9        tex2Dblur8x8shared
//  49.3        55.1        99.9        132.5       tex2Dblur9fast
//  33.3        36.2        72.4        88.0        tex2Dblur9resize
//  27.8        29.7        61.3        72.2        tex2Dblur9x9
//  37.2        41.1        52.6        60.2        tex2Dblur10x10shared
//  44.4        49.5        91.3        117.8       tex2Dblur11fast
//  28.8        30.8        63.6        75.4        tex2Dblur11resize
//  33.6        36.5        40.9        45.5        tex2Dblur12x12shared

BASIC USAGE:
The .cgp presets in the quality-test-presets folder provide usage examples for
basically every .cg blur shader.  The "-srgb" suffix on some .cgp presets is an
explicit notice that they use sRGB FBO's.  Note how and when the "-last-pass"
suffix is used for each .cg file, etc.

The provided .cgp files with the "-mipmap" suffix are used to test quality and
benchmarking with mipmapping enabled, but none of them actually use mipmapping
as a feature in and of itself.  The following contrived .cgp would do that:
    shaders = "4"

    # Pass0: Linearize RGB:
    shader0 = ../../srgb-helpers/first-pass-linearize.cg
    filter_linear0 = "true"
    scale_type0 = "source"
    scale0 = "1.0"
    srgb_framebuffer0 = "true"
    
    # Pass1: Upsize to 4x.  Pretend this pass does significant processing at 4x.
    shader1 = ../../stock.cg
    filter_linear1 = "true"
    scale_type1 = "source"
    scale1 = "4.0"
    srgb_framebuffer1 = "true"
    
    # Pass2: Blur a source-sized mipmap 9x vertically; just shrink horizontally.
    shader2 = ../blur9fast-vertical.cg
    filter_linear2 = "true"
    scale_type2 = "source"
    scale2 = "0.25"
    srgb_framebuffer2 = "true"
    mipmap_input = "true"

    # Pass3: Blur 9x horizontally
    shader3 = ../blur9fast-horizontal.cg
    filter_linear3 = "true"
    scale_type3 = "source"
    scale3 = "1.0"
    srgb_framebuffer3 = "true"

    # Pass4: Scale to the screen size and gamma-correct the output:
    shader4 = ../../srgb-helpers/last-pass-gamma-correct.cg
    filter_linear4 = "true"
    scale_type4 = "viewport"
    scale4 = "1.0"
