#!/usr/bin/env bash
set -euo pipefail

# ==============================
# CONFIG
# ==============================

REPO_OWNER="florian-asche"
REPO_NAME="PiCompose"
RELEASE_TAG="${1:-}"  # Required: Release tag (e.g., v1.0.4)
TEMP_DIR="${2:-/tmp/rpi-imager-images}"

# Output file
OUTPUT_JSON="rpi-imager-repo.json"

if [ -z "${RELEASE_TAG}" ]; then
    echo "Error: Release tag is required"
    echo "Usage: $0 <release-tag> [temp-dir]"
    exit 1
fi

# Base URL for releases
BASE_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/releases/download/${RELEASE_TAG}"

# ==============================
# IMAGE DEFINITIONS
# ==============================
# Alle 5 PiCompose Image-Varianten

declare -A IMAGES
IMAGES["PiCompose"]="Base Image with Docker & Docker Compose, Pipewire Audio, SSH enabled"
IMAGES["PiCompose-2MicHat"]="Base Image + Seeed Voicecard Driver for ReSpeaker 2-Mic HAT v1"
IMAGES["PiCompose_2MicHat_Linux-Voice-Assistant"]="2MicHAT Image + Linux Voice Assistant + Snapcast"
IMAGES["PiCompose-Respeaker_lite"]="Base Image + Audio keep-alive service for ReSpeaker Lite"
IMAGES["PiCompose_Respeaker-lite_Linux-Voice-Assistant"]="Respeaker Lite Image + Linux Voice Assistant + Snapcast"

# Supported models per image (rpi-imager format)
declare -A SUPPORTED_MODELS
SUPPORTED_MODELS["PiCompose"]='["Raspberry Pi 4", "Raspberry Pi 5", "Raspberry Pi 3", "Raspberry Pi 3B+", "Raspberry Pi 2", "Raspberry Pi Zero 2 W"]'
SUPPORTED_MODELS["PiCompose-2MicHat"]='["Raspberry Pi 4", "Raspberry Pi 5", "Raspberry Pi 3", "Raspberry Pi 3B+"]'
SUPPORTED_MODELS["PiCompose_2MicHat_Linux-Voice-Assistant"]='["Raspberry Pi 4", "Raspberry Pi 5", "Raspberry Pi 3", "Raspberry Pi 3B+"]'
SUPPORTED_MODELS["PiCompose-Respeaker_lite"]='["Raspberry Pi 4", "Raspberry Pi 5", "Raspberry Pi 3", "Raspberry Pi 3B+", "Raspberry Pi 2"]'
SUPPORTED_MODELS["PiCompose_Respeaker-lite_Linux-Voice-Assistant"]='["Raspberry Pi 4", "Raspberry Pi 5", "Raspberry Pi 3", "Raspberry Pi 3B+", "Raspberry Pi 2"]'

# Architecture per image
declare -A ARCHITECTURES
ARCHITECTURES["PiCompose"]="arm64"
ARCHITECTURES["PiCompose-2MicHat"]="arm64"
ARCHITECTURES["PiCompose_2MicHat_Linux-Voice-Assistant"]="arm64"
ARCHITECTURES["PiCompose-Respeaker_lite"]="arm64"
ARCHITECTURES["PiCompose_Respeaker-lite_Linux-Voice-Assistant"]="arm64"

# ==============================
# FUNCTIONS
# ==============================

function get_release_assets() {
    local tag="$1"
    curl -sSL "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/tags/${tag}" | \
        jq -r '.assets[] | "\(.name)|\(.size)|\(.browser_download_url)"'
}

function find_asset_for_image() {
    local image_name="$1"
    local tag="$2"
    
    while IFS='|' read -r name size url; do
        # Check if the asset name contains the image name
        if [[ "$name" == *"${image_name}"* ]]; then
            echo "${name}|${size}|${url}"
            return 0
        fi
    done < <(get_release_assets "$tag")
    
    return 1
}

# Find SHA256 file for an image (e.g., PiCompose-v1.0.4.img.xz.sha256)
function find_sha256_asset_for_image() {
    local image_name="$1"
    local tag="$2"
    
    while IFS='|' read -r name size url; do
        # Check if the asset name matches the image name pattern with .sha256 extension
        if [[ "$name" == *"${image_name}"* ]] && [[ "$name" == *.sha256 ]]; then
            echo "${name}|${size}|${url}"
            return 0
        fi
    done < <(get_release_assets "$tag")
    
    return 1
}

function get_sha256_from_file() {
    local file="$1"
    if [ -f "$file" ]; then
        # Read SHA256 from file (format: "sha256hash  filename" or just "sha256hash")
        local content
        content=$(cat "$file" 2>/dev/null | head -1 | xargs)
        echo "$content" | awk '{print $1}'
    else
        echo ""
    fi
}

function get_release_date() {
    local tag="$1"
    curl -sSL "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/tags/${tag}" | \
        jq -r '.published_at' | cut -d'T' -f1
}

# ==============================
# SCRIPT
# ==============================

echo "Generating ${OUTPUT_JSON} for release ${RELEASE_TAG} …"
echo "Base URL: ${BASE_URL}"
echo

# Create temp directory
mkdir -p "${TEMP_DIR}"

# Get release date
RELEASE_DATE=$(get_release_date "$RELEASE_TAG")
echo "Release date: ${RELEASE_DATE}"
echo

# Start JSON
echo '{' > "${OUTPUT_JSON}"
echo '  "os_list": [' >> "${OUTPUT_JSON}"

FIRST=true

# Process each image
for IMAGE_NAME in "${!IMAGES[@]}"; do
    DESCRIPTION="${IMAGES[$IMAGE_NAME]}"
    MODELS="${SUPPORTED_MODELS[$IMAGE_NAME]}"
    ARCH="${ARCHITECTURES[$IMAGE_NAME]}"
    
    echo "Processing: ${IMAGE_NAME}..."
    
    # Find asset for this image
    ASSET_INFO=$(find_asset_for_image "$IMAGE_NAME" "$RELEASE_TAG")
    
    if [ -z "$ASSET_INFO" ]; then
        echo "  ⚠ No asset found for ${IMAGE_NAME}"
        continue
    fi
    
    FILENAME=$(echo "$ASSET_INFO" | cut -d'|' -f1)
    SIZE_BYTES=$(echo "$ASSET_INFO" | cut -d'|' -f2)
    DOWNLOAD_URL=$(echo "$ASSET_INFO" | cut -d'|' -f3)
    
    # Try to get SHA256 from separate SHA256 file (small download, ~100 bytes)
    SHA256=""
    SHA256_ASSET_INFO=$(find_sha256_asset_for_image "$IMAGE_NAME" "$RELEASE_TAG")
    
    if [ -z "$SHA256_ASSET_INFO" ]; then
        # No SHA256 file available - SKIP this image (no fallback)
        echo "  ✗ ERROR: No SHA256 file found for ${IMAGE_NAME}"
        echo "  ✗ Skipping this image - SHA256 verification is required"
        continue
    fi
    
    SHA256_FILENAME=$(echo "$SHA256_ASSET_INFO" | cut -d'|' -f1)
    SHA256_SIZE=$(echo "$SHA256_ASSET_INFO" | cut -d'|' -f2)
    SHA256_URL=$(echo "$SHA256_ASSET_INFO" | cut -d'|' -f3)
    SHA256_TEMP_FILE="${TEMP_DIR}/${SHA256_FILENAME}"
    
    if [ ! -f "$SHA256_TEMP_FILE" ]; then
        echo "  ↓ Downloading SHA256 file (${SHA256_SIZE} bytes)..."
        curl -sSL "$SHA256_URL" -o "$SHA256_TEMP_FILE"
    else
        echo "  ✓ Using cached SHA256 file"
    fi
    
    SHA256=$(get_sha256_from_file "$SHA256_TEMP_FILE")
    echo "  ✓ SHA256: ${SHA256}"
    
    # Extract compression type from file extension
    COMPRESSION_TYPE="zip"
    case "$FILENAME" in
        *.xz) COMPRESSION_TYPE="xz" ;;
        *.gz) COMPRESSION_TYPE="gz" ;;
        *)    COMPRESSION_TYPE="zip" ;;
    esac
    
    if [ "$FIRST" = true ]; then
        FIRST=false
    else
        echo '    ,' >> "${OUTPUT_JSON}"
    fi
    
    # Generate JSON entry for this image
    cat >> "${OUTPUT_JSON}" <<EOF
    {
      "name": "${IMAGE_NAME}",
      "description": "${DESCRIPTION}",
      "url": "${BASE_URL}/${FILENAME}",
      "release_date": "${RELEASE_DATE}",
      "architecture": "${ARCH}",
      "archive_format": "${COMPRESSION_TYPE}",
      "file_size": ${SIZE_BYTES},
      "sha256": "${SHA256}",
      "supported_models": ${MODELS},
      "features": [
        "docker",
        "docker-compose",
        "pipewire-audio"
      ]
    }
EOF
    
    echo "  ✓ Added: ${IMAGE_NAME} -> ${FILENAME} (${SIZE_BYTES} bytes)"
done

echo
echo '  ]' >> "${OUTPUT_JSON}"
echo '}' >> "${OUTPUT_JSON}"

# Cleanup temp SHA256 files (only ~100 bytes each, so safe to remove)
rm -rf "${TEMP_DIR}"

echo "✓ Generated ${OUTPUT_JSON}"
echo
echo "To use with Raspberry Pi Imager, set custom repo URL to:"
echo "  ${BASE_URL}/${OUTPUT_JSON}"
