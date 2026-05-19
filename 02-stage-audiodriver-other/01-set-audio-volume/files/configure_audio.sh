#!/bin/bash
set -u

set_volume_safe() {
    local volume="${1:-1.0}"

    if wpctl get-volume @DEFAULT_AUDIO_SINK@ >/dev/null 2>&1; then
        wpctl set-volume @DEFAULT_AUDIO_SINK@ "$volume"
        echo "Volume set to $volume"
        return 0
    else
        echo "No default audio sink available"
        exit 1
    fi
}

wait_for_audio() {
    local max_tries="${1:-30}"
    local sleep_time="${2:-1}"

    local i=0
    while [ $i -lt $max_tries ]; do
        if wpctl get-volume @DEFAULT_AUDIO_SINK@ >/dev/null 2>&1; then
            echo "Audio ready"
            return 0
        fi

        echo "Waiting for audio... ($i/$max_tries)"
        sleep "$sleep_time"
        i=$((i+1))
    done

    echo "Timeout: Audio not ready"
    exit 1
}

wait_for_card_and_control() {
  local card="$1"
  local control="$2"
  local max_tries=30
  local sleep_sec=1
  local count=0

  while [ "$count" -lt "$max_tries" ]; do
    count=$((count + 1))

    if amixer -c "$card" info >/dev/null 2>&1; then
      if amixer -c "$card" scontrols | grep -Fq "'$control'"; then
        echo "Card $card with control '$control' is ready ($count/$max_tries)"
        return 0
      fi
      echo "Card $card found, but control '$control' not ready yet ($count/$max_tries)"
    else
      echo "Card $card not ready yet ($count/$max_tries)"
    fi

    sleep "$sleep_sec"
  done

  echo "Card $card with control '$control' did not become ready"
  return 1
}

set_control_if_exists() {
  local card="$1"
  local control="$2"
  local value="$3"

  if amixer -c "$card" scontrols | grep -Fq "'$control'"; then
    echo "Setting $control on $card to $value"
    amixer -c "$card" set "$control" "$value"
    return 0
  fi

  echo "Control '$control' not found on $card, skipping"
  return 0
}

# Wait for audio system to be ready
wait_for_audio 30 1

# Set pipewire sink volume
set_volume_safe 1.0

# Alsa save
alsactl store
