# gdapt v1.3 - genesis dithering and pseudo transparency

## Introduction (taken from mdapt)

In many old arcade or console games you will find dithering effects which are there to compensate for platform weaknesses like missing transparency support or small color palettes. This works well since back then the monitors (CRTs) had scanline bleeding and other certain features which merged the dithering through the display technology. But nowadays every pixel will displayed perfectly so dithering won't look like it should be.

There are already shaders out there who are trying to simulate how a CRT displays an image. mdapt though goes a different way and tries to detect dithering patterns by analyzing the relation between neighbored pixels. This way only these specific parts of the image are blended. The resulting image (still in the original resolution) is now a good base for further scaling with advanced algorithms (like xBR) which on there own usually have a hard time with dithering.

## Algorithm

In contrast to mdapt gdapt is a more simple and aggressive version. Which is especially suitable for games with unclear dithering patterns like in many genesis games (hence the name for this shader). Of course you can use it with games from other systems too. The algorithm looks for regular "up and downs" between the pixels in horizontal direction and blends the corresponding pixels.

## Usage

In RetroArch's shader options load one of the provided .cgp files. There are several configuration parameters which you can use via the parameter submenu.