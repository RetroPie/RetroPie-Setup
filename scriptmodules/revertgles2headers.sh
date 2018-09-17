#!/bin/bash

# Reverts to ORA v1.1 GLES2 headers

mv /usr/include/GLES2/gl2.h /usr/include/GLES2/gl2.h.org
mv /usr/include/GLES2/gl2ext.h /usr/include/GLES2/gl2ext.h.org
mv /usr/include/GLES2/gl2platform.h /usr/include/GLES2/gl2platform.h.org
wget -S /usr/include/GLES2/gl2.h https://raw.githubusercontent.com/Retro-Arena/xu4-bins/master/GLES2/gl2.h
wget -S /usr/include/GLES2/gl2ext.h https://raw.githubusercontent.com/Retro-Arena/xu4-bins/master/GLES2/gl2ext.h
wget -S /usr/include/GLES2/gl2platform.h https://raw.githubusercontent.com/Retro-Arena/xu4-bins/master/GLES2/gl2platform.h
