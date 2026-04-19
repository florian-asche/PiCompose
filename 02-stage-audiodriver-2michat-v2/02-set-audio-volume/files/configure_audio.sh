#!/bin/bash
set -u

# TLV320AIC3104 mixer defaults on the V2.0 HAT are extremely quiet: the
# HP DAC attenuates by -23.5 dB and the HP analog amp sits at ~89%. Without
# tuning these three separate gain stages, end users report "silent card"
# even with HA / LVA output at maximum.
#
# Runs on every boot via configure_audio.service — PipeWire / WirePlumber
# manages ALSA mixer state per session and can reset controls to 0% between
# reboots, so a first-boot-only guard would let users end up stuck silent.
#
# Values below are the safe defaults calibrated against JST-connected
# speakers (peaks clip at 100% PCM). Tune further in-field with `amixer`
# and persist via `alsactl store`.

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

# Returns 0 on success OR when the control is absent (expected on hardware
# variants without that stage). Returns 1 only when `amixer set` actually
# failed for a control that exists — so a broken tuning surfaces as a
# non-zero exit from the script and triggers the systemd retry.
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

# The kernel alias is the same for V1 and V2: `seeed2micvoicec`. The V2 HAT
# is distinguished by the presence of `PCM`/`HP DAC`/`Line DAC` controls
# (from tlv320aic3x) rather than V1's `Headphone`/`Speaker` (wm8960).
if ! wait_for_card_and_control seeed2micvoicec PCM; then
  echo "No TLV320AIC3104-based card became ready; is the V2.0 overlay loaded?"
  exit 1
fi
CARD="seeed2micvoicec"

FAIL=0

# Digital pre-DAC attenuator. 100% clips on typical speakers; 85% keeps
# headroom while still being clearly audible.
set_control_if_exists "$CARD" "PCM" 85%            || FAIL=1

# DAC output gains (ship at -23.5 dB by default — main source of quietness).
set_control_if_exists "$CARD" "HP DAC"   100%      || FAIL=1
set_control_if_exists "$CARD" "Line DAC" 100%      || FAIL=1

# Analog output amps (ship slightly below max and muted on some units).
set_control_if_exists "$CARD" "HP"   100% unmute   || FAIL=1
set_control_if_exists "$CARD" "Line" 100% unmute   || FAIL=1

if [ "$FAIL" -ne 0 ]; then
  echo "One or more amixer set calls failed; not storing state." >&2
  exit 1
fi

alsactl store
