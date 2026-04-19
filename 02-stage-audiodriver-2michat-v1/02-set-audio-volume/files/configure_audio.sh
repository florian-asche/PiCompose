#!/bin/bash
set -u

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

if wait_for_card_and_control seeed2micvoicec Headphone; then
  CARD="seeed2micvoicec"
  echo "seeed2micvoicec found"
else
  echo "No supported sound card became ready"
  exit 1
fi

set_control_if_exists "$CARD" Headphone 100%
set_control_if_exists "$CARD" Speaker 100%
set_control_if_exists "$CARD" Master 100%
set_control_if_exists "$CARD" PCM 100%

# Set pipewire sink to 100%
wpctl set-volume @DEFAULT_AUDIO_SINK@ 1.0

# Alsa save
alsactl store
