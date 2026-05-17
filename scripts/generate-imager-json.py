#!/usr/bin/env python3
# generate-imager-json.py
# Generiert eine JSON-Datei für rpi-imager mit allen Releases

import json
import sys
import re
import urllib.request
from collections import defaultdict

OWNER = "florian-asche"
REPO = "PiCompose"
OUTPUT_FILE = "rpi-imager.json"
API_URL = f"https://api.github.com/repos/{OWNER}/{REPO}/releases"

HARDWARE_TYPES = ["Respeaker-lite", "2MicHat", "2MicHat-v1", "2MicHat-v2", "Satellite1-v1.0", "Satellite1-v1.1", "None"]


def fetch_releases():
    """Fetch releases from GitHub API."""
    print("Fetching releases from GitHub...")
    try:
        with urllib.request.urlopen(API_URL) as response:
            releases_data = json.loads(response.read().decode())
    except Exception as e:
        print(f"Error: Failed to fetch releases - {e}")
        sys.exit(1)
    print("Successfully fetched releases")
    return releases_data


def get_latest_version(releases):
    """Get the latest version tag from releases (only tags starting with 'v')."""
    for release in releases:
        tag = release['tag_name']
        if tag.startswith('v') and len(tag) > 1:
            version = tag[1:]
            return tag, version
    return None, None


def find_release_by_tag(releases, tag):
    """Find a specific release by tag name."""
    for release in releases:
        if release['tag_name'] == tag:
            return release
    return None


def extract_image_files(release):
    """Extract .xz and .zip image files from a release."""
    xz_files = []
    for asset in release['assets']:
        if asset['name'].endswith('.xz') or asset['name'].endswith('.zip'):
            xz_files.append({
                'name': asset['name'],
                'url': asset['browser_download_url']
            })
    return xz_files


def get_releases_with_files(releases):
    """Get all releases that have image files, excluding 'main' branch."""
    releases_with_files = []
    for release in releases:
        tag_name = release['tag_name']
        files = extract_image_files(release)
        if files and tag_name != "main":
            version = tag_name[1:] if tag_name.startswith('v') else tag_name
            releases_with_files.append({
                'tag_name': tag_name,
                'version': version,
                'files': files
            })
    return releases_with_files


def extract_metadata(filename):
    """Extract date and hardware type from filename."""
    original = filename
    name = filename.replace('.img.xz', '').replace('.zip', '')
    
    date_match = re.match(r'^image_(\d{4}-\d{2}-\d{2})', name)
    date_prefix = date_match.group(1) if date_match else ''
    name = re.sub(r'^image_\d{4}-\d{2}-\d{2}-?', '', name)
    
    hardware = "None"
    
    if 'Respeaker' in name and 'lite' in name.lower():
        hardware = "Respeaker-lite"
    elif '2MicHat' in name:
        if '2MicHat-v2' in name:
            hardware = "2MicHat-v2"
        else:
            hardware = "2MicHat-v1"
    
    parts = name.split('_')
    
    return date_prefix, hardware, parts, original


def format_image_name(parts, original):
    """Format clean image name from parts."""
    clean_parts = [p.strip() for p in parts if p.strip()]
    clean_name = ' - '.join(clean_parts)
    return clean_name, original


def create_image_entry(filename, url):
    """Create a single image entry for subitems."""
    date_prefix, hardware, parts, original = extract_metadata(filename)
    clean_name, original = format_image_name(parts, original)
    
    return {
        "name": clean_name,
        "description": "PiCompose image",
        "url": url,
        "init_format": "systemd",
        "devices": ["pi5-64bit", "pi4-64bit", "pi3-64bit", "pi3-32bit"],
        "capabilities": ["ssh", "wifi", "hostname", "locale"]
    }


def group_files_by_date_and_hardware(files):
    """Group files by date and hardware type."""
    grouped = defaultdict(lambda: defaultdict(list))
    
    for f in files:
        date_prefix, hardware, parts, original = extract_metadata(f['name'])
        
        if date_prefix:
            grouped[date_prefix][hardware].append(f)
    
    return grouped


def build_date_hardware_subitems(files):
    """Build nested subitems: Date -> Hardware -> Images."""
    grouped = group_files_by_date_and_hardware(files)
    
    if not grouped:
        return build_simple_subitems(files)
    
    date_items = []
    for date in sorted(grouped.keys(), reverse=True):
        hardware_items = []
        
        for hardware in grouped[date]:
            image_entries = [
                create_image_entry(f['name'], f['url'])
                for f in grouped[date][hardware]
            ]
            
            hardware_items.append({
                "name": hardware,
                "description": f"Hardware: {hardware}",
                "icon": "icons/cat_raspberry_pi_os.png",
                "subitems": image_entries
            })
        
        date_items.append({
            "name": date,
            "description": f"Images from {date}",
            "icon": "icons/cat_raspberry_pi_os.png",
            "subitems": hardware_items
        })
    
    return date_items


def build_simple_subitems(files):
    """Build simple subitems without date/hardware grouping."""
    return [
        create_image_entry(f['name'], f['url'])
        for f in reversed(files)
    ]


def get_main_release(releases):
    """Get the main branch (nightly) release if available."""
    for release in releases:
        if release['tag_name'] == "main":
            files = extract_image_files(release)
            if files:
                return files
    return None


def build_devices_list():
    """Build the devices list for rpi-imager."""
    return [
        {"name": "Raspberry Pi 5", "tags": ["pi5-64bit", "pi5-32bit"], "default": True, "icon": "https://downloads.raspberrypi.com/imager/icons/RPi_5.png", "description": "Raspberry Pi 5, 500 / 500+, and Compute Module 5", "matching_type": "exclusive", "capabilities": []},
        {"name": "Raspberry Pi 4", "tags": ["pi4-64bit", "pi4-32bit"], "icon": "https://downloads.raspberrypi.com/imager/icons/RPi_4.png", "description": "Raspberry Pi 4 Model B, 400, and Compute Module 4 / 4S", "matching_type": "inclusive", "capabilities": []},
        {"name": "Raspberry Pi 3", "tags": ["pi3-64bit", "pi3-32bit"], "icon": "https://downloads.raspberrypi.com/imager/icons/RPi_3.png", "description": "Raspberry Pi 3 Model A+ / B / B+ and Compute Module 3 / 3+", "matching_type": "inclusive", "capabilities": []},
        {"name": "Raspberry Pi Zero 2 W", "tags": ["pi3-64bit", "pi3-32bit"], "icon": "https://downloads.raspberrypi.com/imager/icons/RPi_Zero_2_W.png", "description": "Raspberry Pi Zero 2 W", "matching_type": "inclusive", "capabilities": []},
        {"name": "No filtering", "tags": [], "description": "Show every possible image", "matching_type": "inclusive", "capabilities": []}
    ]


def main():
    releases = fetch_releases()

    latest_tag, latest_version = get_latest_version(releases)
    print(f"Latest version: {latest_version}")

    releases_with_files = get_releases_with_files(releases)
    main_release = get_main_release(releases)

    os_list = []

    latest_release = find_release_by_tag(releases, latest_tag)
    if latest_release:
        latest_files = extract_image_files(latest_release)
        if latest_files:
            os_list.append({
                "name": "PiCompose - stable",
                "description": "Latest stable tagged version images",
                "icon": "icons/cat_raspberry_pi_os.png",
                "subitems": build_date_hardware_subitems(latest_files)
            })

    if main_release:
        os_list.append({
            "name": "PiCompose - development",
            "description": "Latest development builds from main branch",
            "icon": "icons/cat_raspberry_pi_os.png",
            "subitems": build_date_hardware_subitems(main_release)
        })

    os_list.append({
        "name": "PiCompose - all versions / branches",
        "description": "All available PiCompose versions",
        "icon": "icons/cat_raspberry_pi_os.png",
        "subitems": [
            {
                "name": r['version'],
                "description": f"PiCompose {r['tag_name']} release",
                "icon": "icons/cat_raspberry_pi_os.png",
                "subitems": build_date_hardware_subitems(r['files'])
            }
            for r in releases_with_files
        ]
    })

    final_data = {
        "imager": {
            "latest_version": latest_version,
            "url": "https://www.raspberrypi.com/software/",
            "devices": build_devices_list()
        },
        "os_list": os_list
    }

    with open(OUTPUT_FILE, 'w') as f:
        json.dump(final_data, f, indent=2)

    print(f"Generated {OUTPUT_FILE}")
    print("")
    print("Content preview:")
    print(json.dumps(final_data, indent=2))

    total_xz = sum(len(r['files']) for r in releases_with_files)
    print(f"")
    print(f"Total .xz files: {total_xz}")


if __name__ == "__main__":
    main()