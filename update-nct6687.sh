#!/bin/bash
# Auto-update nct6687 driver for current Unraid kernel
# Place in /boot/extra/ and add to /boot/config/go:
#   bash /boot/extra/update-nct6687.sh

KERNEL_V=$(uname -r)
PACKAGE_DIR="/boot/extra"
MODULE_DIR="/lib/modules/$KERNEL_V/updates"
PACKAGE_NAME="nct6687d"

# Check if driver is already loaded and matches kernel
if modinfo nct6687 >/dev/null 2>&1; then
  exit 0
fi

# Get release info from GitHub API
RELEASE_JSON=$(wget -qO- "https://api.github.com/repos/ich777/unraid-nct6687-driver/releases/tags/$KERNEL_V" 2>/dev/null)

# Extract the .txz download URL (not .md5)
DL_URL=$(echo "$RELEASE_JSON" | grep -o '"browser_download_url": "[^"]*\.txz"' | head -1 | cut -d'"' -f4)

if [ -z "$DL_URL" ]; then
  echo "No NCT6687 driver release found for kernel $KERNEL_V"
  exit 1
fi

FILENAME=$(basename "$DL_URL")

# Check if already downloaded
if [ ! -f "$PACKAGE_DIR/$FILENAME" ]; then
  echo "Downloading NCT6687 driver for $KERNEL_V ..."
  wget -q --show-progress -O "$PACKAGE_DIR/$FILENAME" "$DL_URL"
  if [ $? -ne 0 ]; then
    echo "Download failed"
    exit 1
  fi
fi

# Install
installpkg "$PACKAGE_DIR/$FILENAME"
depmod -a
modprobe nct6687

echo "NCT6687 driver installed for kernel $KERNEL_V"
