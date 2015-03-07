Windowed Shaders
=======
These shaders are called windowed because their kernels are formed by the convolution of two functions: the first one is the ideal resampler for 1D signals, the Sinc function, or the ideal resampler for 2D signals, the Jinc function (this is indicated when using cylindrical coordinates). These two functions have infinite zeros and, for a practical resampler, it's necessary to cut it at some of their zeros, commonly at the second one for real time shaders. To achieve this, a second function is used as a window to vanishes the first one at some zero. The window function can be anything and because of this, there are many different kernels based on the window function that is applied to the first function. So, the shaders here are called according to the window function.

lanczos2-sharp.cg
--------------

Lanczos is a known resampler with a kernel of sinc functions. It's normally implemented using ortoghonal coordinates, but this one in particular employs cylindrical coordinates. For a better image quality, it was inserted an anti-ringing code. This shader provides a sharp image, without ringing, though some aliasing is perceived in diagonal lines. It's recommended for games with subtle color gradients (digitized games, for example).

This shader has this kernel:

First function: `Sinc`
Second (window) function:  `Sinc`

jinc2.cg
--------------

Jinc is the ideal resampler for 2D sinals. This shader implementation uses an approximation of the jinc function, based on sinc functions. For a better image quality, it was inserted an anti-ringing code. This shader provides a blurry image, without ringing, and no aliasing at all is perceived in diagonal lines. It's recommended for any games.

This shader has this kernel:

First function: `Jinc`
Second (window) function:  `Jinc`

jinc2-sharp.cg
--------------

Jinc is the ideal resampler for 2D sinals. This shader implementation uses an approximation of the jinc function, based on sinc functions. For a better image quality, it was inserted an anti-ringing code. In this shader, some parameters were tweaked to provide a much less blurry image than the original jinc2 shader. Besides that, it completely blurs dithering. So, it provides a sharp image, without ringing or dithering, and no aliasing at all is perceived in diagonal lines. It's recommended for any games, mainly Genesis games or others plagued by ditherings.

This shader has this kernel:

First function: `Jinc`
Second (window) function:  `Jinc`

jinc2-sharper.cg
--------------

Jinc is the ideal resampler for 2D sinals. This shader implementation uses an approximation of the jinc function, based on sinc functions. For a better image quality, it was inserted an anti-ringing code. In this shader, some parameters were tweaked to provide a much sharper image than the original jinc2 shader. This shader provides a very sharp image, without ringing, and no aliasing at all is perceived in diagonal lines. It's recommended for cartoony games.

This shader has this kernel:

First function: `Jinc`
Second (window) function:  `Jinc`

