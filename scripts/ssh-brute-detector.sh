#!/bin/bash
# SSH Brute Force Detector
# Monitors auth.log for rapid failed logins and alerts

LOGFILE="/var/log/auth.log"
THRESHOLD=5
TIMEFRAME=60  # seconds

echo "[*] Monitoring SSH brute force attempts (threshold: $THRESHOLD failures in ${TIMEFRAME}s)..."

# Use tail -F to follow log even if rotated
sudo tail -F $LOGFILE | while read line; do
    # Look for "Failed password" lines
    if echo "$line" | grep -q "Failed password"; then
        # Extract IP (the field before "port")
        src_ip=$(echo "$line" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        timestamp=$(echo "$line" | awk '{print $1, $2, $3}')
        
        if [ -n "$src_ip" ]; then
            # Log to a temporary tracking file
            echo "$(date +%s) $src_ip" >> /tmp/ssh_failures.log
            
            # Count failures from this IP in last TIMEFRAME seconds
            now=$(date +%s)
            count=$(awk -v now="$now" -v ip="$src_ip" -v tf="$TIMEFRAME" \
                '$2 == ip && $1 > (now - tf) {c++} END {print c}' /tmp/ssh_failures.log)
            
            if [ "$count" -ge "$THRESHOLD" ]; then
                # Avoid duplicate alerts for same IP within timeframe
                last_alert=$(grep "ALERT.*$src_ip" /tmp/ssh_alerts.log 2>/dev/null | tail -1 | awk '{print $1}')
                if [ -z "$last_alert" ] || [ $((now - last_alert)) -gt $TIMEFRAME ]; then
                    echo "[!] ALERT: SSH brute force detected from $src_ip ($count failures in ${TIMEFRAME}s)"
                    echo "$now ALERT $src_ip" >> /tmp/ssh_alerts.log
                    # In a real SOC, you'd trigger a SIEM alert or block the IP here
                fi
            fi
        fi
    fi
done
