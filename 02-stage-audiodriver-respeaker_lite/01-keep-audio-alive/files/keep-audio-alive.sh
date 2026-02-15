#!/bin/bash

check_pipewire() {
  local MAX_TRIES=30
  local SLEEP_SEC=1
  local COUNT=0

  while [ $COUNT -lt $MAX_TRIES ]; do
    COUNT=$((COUNT + 1))

    # Check if XDG_RUNTIME_DIR is set
    if [ -z "$XDG_RUNTIME_DIR" ]; then
      echo "❌ XDG_RUNTIME_DIR is not set"
      return 1
    fi

    # Check if PipeWire is running
    if pw-cli info 0 >/dev/null 2>&1; then
      echo "✅ PipeWire is running (checked $COUNT/$MAX_TRIES)"
      return 0
    fi

    echo "⏳ PipeWire not running yet ($COUNT/$MAX_TRIES), retrying in $SLEEP_SEC s..."
    sleep $SLEEP_SEC
  done

  echo "❌ PipeWire did not start after $MAX_TRIES seconds"
  return 2
}

# Run pipewire check
check_pipewire

# set custom pipewire path
export XDG_RUNTIME_DIR=/run/user/1000

# run silent output
sox -n -r 16000 -c 1 -b 16 -e signed-integer -t alsa pipewire synth 0 sine 0 vol 0.0
