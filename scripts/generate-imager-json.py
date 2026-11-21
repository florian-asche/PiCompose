#!/usr/bin/env python3
# generate-imager-json.py
# Generiert eine JSON-Datei für rpi-imager mit allen Releases

import io
import json
import os
import sys
import re
import urllib.request
import zipfile
from collections import defaultdict
from functools import lru_cache

OWNER = "florian-asche"
REPO = "PiCompose"
OUTPUT_FILE = "rpi-imager.json"
API_URL = f"https://api.github.com/repos/{OWNER}/{REPO}/releases?per_page=100"

def get_api_headers():
    """Build the GitHub API headers, authenticated when GITHUB_TOKEN is set to avoid the anonymous rate limit."""
    headers = {'Accept': 'application/vnd.github+json'}
    token = os.environ.get('GITHUB_TOKEN')
    if token:
        headers['Authorization'] = f'Bearer {token}'
    return headers


def fetch_releases():
    """Fetch releases from GitHub API."""
    print("Fetching releases from GitHub...")
    releases_data = []
    try:
        page = 1
        while True:
            request = urllib.request.Request(f"{API_URL}&page={page}", headers=get_api_headers())
            with urllib.request.urlopen(request) as response:
                page_data = json.loads(response.read().decode())
            if not page_data:
                break
            releases_data.extend(page_data)
            page += 1
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
                'url': asset['browser_download_url'],
                'size': asset['size']
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
    elif 'Satellite1-v1.1' in name:
        hardware = "Satellite1-v1.1"
    elif 'Satellite1' in name:
        hardware = "Satellite1-v1.0"
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


class HttpRangeFile(io.RawIOBase):
    """Read-only seekable file object backed by HTTP range requests."""

    def __init__(self, url, size):
        """
        :param url: Download URL of the file, the server must support range requests.
        :param size: Total size of the file in bytes.
        """
        self.url = url
        self.size = size
        self.pos = 0

    def readable(self):
        return True

    def seekable(self):
        return True

    def tell(self):
        return self.pos

    def seek(self, offset, whence=io.SEEK_SET):
        if whence == io.SEEK_SET:
            self.pos = offset
        elif whence == io.SEEK_CUR:
            self.pos += offset
        else:
            self.pos = self.size + offset
        return self.pos

    def read(self, size=-1):
        if size is None or size < 0 or self.pos + size > self.size:
            size = self.size - self.pos
        if size <= 0:
            return b''
        request = urllib.request.Request(self.url, headers={'Range': f'bytes={self.pos}-{self.pos + size - 1}'})
        with urllib.request.urlopen(request) as response:
            data = response.read()
        self.pos += len(data)
        return data


def read_varint(data, offset):
    """Decode an xz variable-length integer and return the value and the next offset."""
    value = 0
    for shift in range(0, 63, 7):
        byte = data[offset]
        offset += 1
        value |= (byte & 0x7F) << shift
        if not byte & 0x80:
            return value, offset
    raise ValueError("Invalid xz varint")


def get_xz_extract_size(file):
    """Sum the uncompressed block sizes from the index of a single-stream xz file."""
    file.seek(-12, io.SEEK_END)
    footer = file.read(12)
    if footer[10:] != b'YZ':
        raise ValueError("Missing xz stream footer")
    index_size = (int.from_bytes(footer[4:8], 'little') + 1) * 4
    file.seek(-12 - index_size, io.SEEK_END)
    index = file.read(index_size)
    if index[0] != 0:
        raise ValueError("Invalid xz index")
    records, offset = read_varint(index, 1)
    total = 0
    for _ in range(records):
        _, offset = read_varint(index, offset)
        uncompressed, offset = read_varint(index, offset)
        total += uncompressed
    return total


def get_zip_extract_size(file):
    """Sum the uncompressed sizes of the files in a zip archive."""
    with zipfile.ZipFile(file) as archive:
        return sum(info.file_size for info in archive.infolist())


@lru_cache(maxsize=None)
def get_extract_size(url, name, size):
    """Get the uncompressed size of an image by reading only its index, None if it cannot be determined."""
    try:
        file = HttpRangeFile(url, size)
        if name.endswith('.zip'):
            return get_zip_extract_size(file)
        return get_xz_extract_size(file)
    except Exception as e:
        print(f"Warning: Could not determine extract size of {name} - {e}")
        return None


def create_image_entry(file_info):
    """
    Create a single image entry for subitems.
    :param file_info: Image file as returned by extract_image_files().
    """
    date_prefix, hardware, parts, original = extract_metadata(file_info['name'])
    clean_name, original = format_image_name(parts, original)

    entry = {
        "name": clean_name,
        "description": "PiCompose image",
        "url": file_info['url'],
        "image_download_size": file_info['size'],
        "init_format": "systemd",
        "devices": ["pi5-64bit", "pi4-64bit", "pi3-64bit", "pi3-32bit"],
        "capabilities": ["ssh", "wifi", "hostname", "locale"]
    }
    extract_size = get_extract_size(file_info['url'], file_info['name'], file_info['size'])
    if extract_size:
        entry["extract_size"] = extract_size
    return entry


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
                create_image_entry(f)
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
        create_image_entry(f)
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