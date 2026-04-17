#!/bin/bash
# Simple Port Scan Detector (Bash version)
# Alerts when a single source IP sends SYNs to >10 different ports in 5 seconds

INTERFACE="any"
THRESHOLD=10
TIMEOUT=5

echo "[*] Monitoring for port scans (threshold: $THRESHOLD SYNs in $TIMEOUT sec)..."

# Declare associative arrays for counting and timestamps
declare -A syn_count
declare -A first_seen

# Use tcpdump to output one line per SYN packet
sudo tcpdump -i $INTERFACE -n -l 'tcp[tcpflags] & tcp-syn != 0' 2>/dev/null | while read line; do
    # Extract source IP (field 3, remove port after colon)
    src_ip=$(echo "$line" | awk '{print $3}' | cut -d. -f1-4)
    
    # If empty, skip
    [ -z "$src_ip" ] && continue
    
    # Current time in seconds since epoch
    now=$(date +%s)
    
    # Increment SYN count for this IP
    syn_count[$src_ip]=$(( ${syn_count[$src_ip]:-0} + 1 ))
    
    # Set first seen time if not set
    if [ -z "${first_seen[$src_ip]}" ]; then
        first_seen[$src_ip]=$now
    fi
    
    # Check if threshold exceeded within timeout
    if [ ${syn_count[$src_ip]} -ge $THRESHOLD ]; then
        elapsed=$(( now - first_seen[$src_ip] ))
        if [ $elapsed -le $TIMEOUT ]; then
            echo "[!] ALERT: Possible port scan from $src_ip (${syn_count[$src_ip]} SYNs in ${elapsed}s)"
            # Reset counters for this IP to avoid repeated alerts
            syn_count[$src_ip]=0
            unset first_seen[$src_ip]
        else
            # Reset if timeout passed without reaching threshold
            syn_count[$src_ip]=1
            first_seen[$src_ip]=$now
        fi
    fi
done
