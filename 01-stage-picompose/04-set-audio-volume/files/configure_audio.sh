#!/bin/bash

# Funktion zum Setzen der Audio-Einstellungen
configure_audio() {
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
    touch /var/lib/alsa/audio_configured
    # Deaktiviere den Service nach erfolgreicher Konfiguration
    systemctl disable configure_audio.service

}

# Wenn die Konfiguration bereits erfolgreich war, beenden
if [ -f /var/lib/alsa/audio_configured ]; then
    exit 0
else
    # Versuche die Audio-Einstellungen zu setzen
    configure_audio
fi
