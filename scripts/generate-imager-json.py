#!/usr/bin/env python3
# generate-imager-json.py
# Generiert eine JSON-Datei für rpi-imager mit allen Releases

import json
import sys
import re
import urllib.request

OWNER = "florian-asche"
REPO = "PiCompose"
OUTPUT_FILE = "rpi-imager.json"
API_URL = f"https://api.github.com/repos/{OWNER}/{REPO}/releases"

def main():
    print("Fetching releases from GitHub...")
    
    try:
        with urllib.request.urlopen(API_URL) as response:
            releases_data = json.loads(response.read().decode())
    except Exception as e:
        print(f"Error: Failed to fetch releases - {e}")
        sys.exit(1)

    print("Successfully fetched releases")

    # Get the latest version
    LATEST_VERSION = releases_data[0]['tag_name']
    if LATEST_VERSION.startswith('v'):
        LATEST_VERSION = LATEST_VERSION[1:]
    print(f"Latest version: {LATEST_VERSION}")

    # Find the first release that has .xz or .zip files (this will be our "latest" with files)
    latest_with_files_tag = None
    for release in releases_data:
        for asset in release['assets']:
            if asset['name'].endswith('.xz') or asset['name'].endswith('.zip'):
                latest_with_files_tag = release['tag_name']
                break
        if latest_with_files_tag:
            break

    # Collect all releases with .xz or .zip files
    releases_with_files = []
    for release in releases_data:
        tag_name = release['tag_name']
        
        xz_files = []
        for asset in release['assets']:
            if asset['name'].endswith('.xz') or asset['name'].endswith('.zip'):
                xz_files.append({
                    'name': asset['name'],
                    'url': asset['browser_download_url']
                })
        
        if xz_files and tag_name != "main":
            # Format version name
            version = tag_name[1:] if tag_name.startswith('v') else tag_name
            
            releases_with_files.append({
                'tag_name': tag_name,
                'version': version,
                'files': xz_files
            })

    def format_image_name(filename):
        """Extract clean image name from filename"""
        # Remove .img.xz suffix
        name = filename.replace('.img.xz', '')
        # Remove date prefix (image_YYYY-MM-DD-)
        name = re.sub(r'^image_\d{4}-\d{2}-\d{2}-?', '', name)
        # Replace underscores and hyphens with spaces
        name = name.replace('_', ' ').replace('-', ' ')
        clean_name = name.strip()
        # Add original filename in brackets for clarity
        return f"{clean_name} ({filename})"

    def build_release_subitems(files):
        """Build subitems list from files"""
        # Umgekehrte Sortierung: neueste / letzte Datei zuerst anzeigen
        reversed_files = reversed(files)
        return [
            {
                "name": format_image_name(f['name']),
                "description": "PiCompose image",
                "url": f['url'],
                "init_format": "systemd",
                "devices": ["pi5-64bit", "pi4-64bit", "pi3-64bit", "pi3-32bit"],
                "capabilities": ["ssh", "wifi", "hostname", "locale"]
            }
            for f in reversed_files
        ]

    os_list = []

    # Find main branch release (nightly)
    main_release = None
    for release in releases_data:
        if release['tag_name'] == "main":
            main_xz_files = []
            for asset in release['assets']:
                if asset['name'].endswith('.xz') or asset['name'].endswith('.zip'):
                    main_xz_files.append({
                        'name': asset['name'],
                        'url': asset['browser_download_url']
                    })
            if main_xz_files:
                main_release = main_xz_files
            break

    # PiCompose (Latest) - all files from the first stable release with .xz files
    if releases_with_files:
        latest = releases_with_files[0]
        os_list.append({
            "name": "PiCompose (Latest)",
            "description": "Latest stable PiCompose images",
            "icon": "icons/cat_raspberry_pi_os.png",
            "subitems": build_release_subitems(latest['files'])
        })

    # PiCompose (Nightly) - files from main branch release if available
    if main_release:
        os_list.append({
            "name": "PiCompose (Nightly / Main)",
            "description": "Latest development build from main branch",
            "icon": "icons/cat_raspberry_pi_os.png",
            "subitems": build_release_subitems(main_release)
        })

    # PiCompose (All Versions) - grouped by release
    os_list.append({
        "name": "PiCompose (All Versions)",
        "description": "All available PiCompose versions",
        "icon": "icons/cat_raspberry_pi_os.png",
        "subitems": [
            {
                "name": r['version'],
                "description": f"PiCompose {r['tag_name']} release",
                "icon": "icons/cat_raspberry_pi_os.png",
                "subitems": build_release_subitems(r['files'])
            }
            for r in releases_with_files
        ]
    })

    # Build final JSON
    devices = [
        {"name": "Raspberry Pi 5", "tags": ["pi5-64bit", "pi5-32bit"], "default": True, "icon": "https://downloads.raspberrypi.com/imager/icons/RPi_5.png", "description": "Raspberry Pi 5, 500 / 500+, and Compute Module 5", "matching_type": "exclusive", "capabilities": []},
        {"name": "Raspberry Pi 4", "tags": ["pi4-64bit", "pi4-32bit"], "icon": "https://downloads.raspberrypi.com/imager/icons/RPi_4.png", "description": "Raspberry Pi 4 Model B, 400, and Compute Module 4 / 4S", "matching_type": "inclusive", "capabilities": []},
        {"name": "Raspberry Pi 3", "tags": ["pi3-64bit", "pi3-32bit"], "icon": "https://downloads.raspberrypi.com/imager/icons/RPi_3.png", "description": "Raspberry Pi 3 Model A+ / B / B+ and Compute Module 3 / 3+", "matching_type": "inclusive", "capabilities": []},
        {"name": "Raspberry Pi Zero 2 W", "tags": ["pi3-64bit", "pi3-32bit"], "icon": "https://downloads.raspberrypi.com/imager/icons/RPi_Zero_2_W.png", "description": "Raspberry Pi Zero 2 W", "matching_type": "inclusive", "capabilities": []},
        {"name": "No filtering", "tags": [], "description": "Show every possible image", "matching_type": "inclusive", "capabilities": []}
    ]

    final_data = {
        "imager": {
            "latest_version": LATEST_VERSION,
            "url": "https://www.raspberrypi.com/software/",
            "devices": devices
        },
        "os_list": os_list
    }

    # Write output
    with open(OUTPUT_FILE, 'w') as f:
        json.dump(final_data, f, indent=2)

    print(f"Generated {OUTPUT_FILE}")
    print("")
    print("Content preview:")
    print(json.dumps(final_data, indent=2))
    
    # Count .xz files
    total_xz = sum(len(r['files']) for r in releases_with_files)
    print(f"")
    print(f"Total .xz files: {total_xz}")

if __name__ == "__main__":
    main()
