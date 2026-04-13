#!/bin/bash
# SUID Hunter - Find potentially dangerous SUID binaries
# Author: Tolo Otieno
# Date: 2026-04-12

echo "=============================================="
echo "   SUID Binary Audit Report"
echo "   Host: $(hostname) | Date: $(date)"
echo "=============================================="

# Known safe SUID binaries (whitelist)
SAFE_LIST="passwd|sudo|su|mount|umount|ping|newgrp|chsh|chfn|gpasswd|pkexec|unix_chkpwd"

echo -e "\n[+] Scanning for SUID binaries..."
echo "------------------------------------------------"

# Find all SUID files, exclude /proc and /sys
find / -path /proc -prune -o -path /sys -prune -o -type f -perm -4000 -exec ls -la {} \; 2>/dev/null | while read line; do
    # Extract filename
    filename=$(echo "$line" | awk '{print $NF}')
    basename=$(basename "$filename")
    
    # Check if in safe list
    if echo "$basename" | grep -qE "^($SAFE_LIST)$"; then
        echo "[SAFE] $line"
    else
        echo "[!] SUSPICIOUS: $line"
        # Additional check: is the binary world-writable?
        if [ -w "$filename" ]; then
            echo "    -> CRITICAL: World-writable SUID binary!"
        fi
    fi
done

echo -e "\n[+] Searching for world-writable SUID scripts..."
find / -path /proc -prune -o -path /sys -prune -o -type f -perm -4002 -exec ls -la {} \; 2>/dev/null

echo -e "\n[*] Audit complete."
