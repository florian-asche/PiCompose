#!/bin/bash

# set custom pipewire path
export XDG_RUNTIME_DIR=/run/user/1000

# run silent output
sox -n -r 16000 -c 1 -b 16 -e signed-integer -t alsa default synth 0 sine 0 vol 0.0
