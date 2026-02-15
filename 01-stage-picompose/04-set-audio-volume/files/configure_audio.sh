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

if amixer -c seeed2micvoicec info >/dev/null 2>&1; then
    echo "seeed2micvoicec found"
    amixer -c seeed2micvoicec set Headphone 100%
    amixer -c seeed2micvoicec set Speaker 100%
elif amixer -c Lite info >/dev/null 2>&1; then
    echo "Lite found"
    amixer -c Lite set Headphone 100%
    amixer -c Lite set Speaker 100%
    amixer set Master 100%
else
    exit 1
fi

alsactl store
