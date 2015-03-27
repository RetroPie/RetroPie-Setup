#!/usr/bin/env bash

# This file is part of RetroPie.
# 
# # RetroPie Legal Information
# 
# ## License
# Redistribution and use of the RetroPie code or any derivative works are permitted 
# provided that the following conditions are met:
# 
# Redistributions may not be sold, nor may they be used in a commercial product or 
# activity.
# Redistributions that are modified from the original source must include the complete 
# source code, including the source code for all components used by a binary built from 
# the modified sources. However, as a special exception, the source code distributed 
# need not include anything that is normally distributed (in either source or binary 
# form) with the major components (compiler, kernel, and so on) of the operating system 
# on which the executable runs, unless that component itself accompanies the executable.
# Redistributions must reproduce the above copyright notice, this list of conditions and 
# the following disclaimer in the documentation and/or other materials provided with the 
# distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT 
# SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED 
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR 
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
# ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH 
# DAMAGE.
# 
# ## Copyright
# The code in RetroPie is the work of many developers, each of whom owns the copyright 
# to the code they wrote. There is no central copyright authority you can license the 
# code from. The proper way to use the RetroPie source code is to examine it, using it 
# to understand how the code works, and then write your own code. Sorry, there is no 
# free lunch here.
#
#  Many, many thanks go to all people that provide the individual modules!!!
#

# =============================================================
#  START OF THE MAIN SCRIPT
# =============================================================

scriptdir=$(dirname $0)
scriptdir=$(cd $scriptdir && pwd)

# check, if sudo is used
if [[ $(id -u) -ne 0 ]]; then
    echo "Script must be run as root. Try 'sudo $0'"
    exit 1
fi

"$scriptdir/retropie_packages.sh" setup

