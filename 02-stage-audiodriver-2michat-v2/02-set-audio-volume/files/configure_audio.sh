#!/bin/bash
set -u

# TLV320AIC3104 on V2.0 ships quiet: HP DAC at -23.5 dB, HP/Line amps at
# ~89% and muted on some units. PCM is driven by wpctl as hardware-volume
# passthrough, so only the downstream stages need tuning. Runs every boot
# because WirePlumber can reset ALSA state between sessions.

wait_for_card_and_control() {
  local card="$1"
  local control="$2"
  local max_tries=30
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

    sleep 1
  done

  echo "Card $card with control '$control' did not become ready"
  return 1
}

# Returns 0 on set-success or missing control; 1 on set-failure.
# Non-zero exit triggers the systemd retry.
set_control_if_exists() {
  local card="$1"
  local control="$2"
  shift 2

  if amixer -c "$card" scontrols | grep -Fq "'$control'"; then
    echo "Setting $control on $card to $*"
    if amixer -c "$card" set "$control" "$@"; then
      return 0
    fi
    echo "amixer set failed for '$control' on $card" >&2
    return 1
  fi

  echo "Control '$control' not found on $card, skipping"
  return 0
}

# Same kernel alias as V1 (`seeed2micvoicec`); the PCM control distinguishes
# V2's tlv320aic3x from V1's wm8960.
if ! wait_for_card_and_control seeed2micvoicec PCM; then
  echo "No TLV320AIC3104-based card became ready; is the V2.0 overlay loaded?"
  exit 1
fi
CARD="seeed2micvoicec"

FAIL=0
set_control_if_exists "$CARD" "HP DAC"   100%      || FAIL=1
set_control_if_exists "$CARD" "Line DAC" 100%      || FAIL=1
set_control_if_exists "$CARD" "HP"   100% unmute   || FAIL=1
set_control_if_exists "$CARD" "Line" 100% unmute   || FAIL=1

if [ "$FAIL" -ne 0 ]; then
  echo "One or more amixer set calls failed; not storing state." >&2
  exit 1
fi

# Keep PipeWire sink at unity so HA/LVA volume reaches the ALSA stages
# above. Matches the 2michat-v1 pattern from #42.
wpctl set-volume @DEFAULT_AUDIO_SINK@ 1.0

alsactl store
