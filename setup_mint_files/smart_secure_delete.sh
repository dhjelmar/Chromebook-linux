#!/bin/bash
FILE="$1"
# Find the parent disk name (e.g., sda)
DISK=$(lsblk -no pkname "$(df "$FILE" | tail -1 | awk '{print $1}')")
# Check if rotational (1=HDD, 0=SSD)
TYPE=$(cat /sys/block/"$DISK"/queue/rotational)

if [ "$TYPE" -eq 0 ]; then
    # SSD Path: Delete then TRIM
    rm -rf "$FILE" && pkexec fstrim -v /
    notify-send "Secure Delete" "SSD detected. File removed and TRIM issued."
else
    # HDD Path: Shred
    shred -u -n 3 -v "$FILE"
    notify-send "Secure Delete" "HDD detected. File shredded (3 passes)."
fi
