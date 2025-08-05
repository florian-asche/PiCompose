#!/bin/bash

# Funktion zum Setzen der Audio-Einstellungen
configure_hostname() {

    # Aktives Interface ermitteln
    IFACE=$(ip route | grep default | awk '{print $5}' | head -n 1)

    # Prüfen, ob IFACE leer ist
    if [ -z "$IFACE" ]; then
        echo "Kein aktives Netzwerkinterface gefunden."
        exit 1
    fi

    # Prüfen, ob Interface-Verzeichnis existiert
    if [ ! -e "/sys/class/net/$IFACE/address" ]; then
        echo "Interface $IFACE existiert nicht oder hat keine MAC-Adresse."
        exit 1
    fi

    # MAC-Adresse auslesen und ":" entfernen
    MAC=$(cat /sys/class/net/$IFACE/address | tr -d ':')

    if [ -z "$MAC" ]; then
        echo "Konnte MAC-Adresse nicht lesen."
        exit 1
    fi

    # CLIENT_NAME daraus generieren
    CLIENT_NAME="picompose-${MAC}"

    # Hostname setzen
    echo "Setze Hostname auf $CLIENT_NAME"
    hostnamectl set-hostname "$CLIENT_NAME"

    # Marker-Datei erstellen
    touch /var/lib/configure_hostname

    # Deaktiviere den Service nach erfolgreicher Konfiguration
    systemctl disable configure_hostname.service
}

# Wenn die Konfiguration bereits erfolgreich war, beenden
if [ -f /var/lib/configure_hostname ]; then
    exit 0
fi

# Versuche die Audio-Einstellungen zu setzen
configure_hostname
