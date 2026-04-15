#!/bin/bash
# Ghost Hunter - Detect Hidden Processes and Persistence
# SOC Analyst Triage Script

echo "============================================="
echo "   GHOST HUNTER - Incident Response Triage"
echo "   Host: $(hostname) | Time: $(date)"
echo "============================================="

# 1. Suspicious Process Names (masquerading as kernel threads)
echo -e "\n[+] Checking for process masquerading (non-root with brackets):"
ps aux --forest | grep -v grep | grep '\[.*\]' | grep -v '^root'
# (Any non-root process with brackets in the command name is suspicious)

# 2. Listening Ports with Process Info (shows true binary path)
echo -e "\n[+] Active network listeners (potential backdoors):"
sudo lsof -i -P -n | grep LISTEN

# 3. Cron Jobs for All Users
echo -e "\n[+] All user crontabs:"
for user in $(cut -f1 -d: /etc/passwd); do
    sudo crontab -u $user -l 2>/dev/null && echo "   (User: $user)"
done

# 4. Suspicious RC File Modifications (last 7 days)
echo -e "\n[+] Recent modifications to shell startup files:"
find /home -type f \( -name ".bashrc" -o -name ".profile" \) -mtime -7 2>/dev/null

# 5. Non-Standard Systemd Services (user-created)
echo -e "\n[+] User-created or modified systemd services:"
systemctl list-units --type=service --all | grep -v "@" | grep -E "loaded.*service" | grep -v "^●"

# 6. Advanced: Find processes with argv[0] mismatch
echo -e "\n[+] Processes with spoofed names (argv[0] mismatch):"
for pid in $(ps -eo pid --no-header); do
    if [ -r /proc/$pid/exe ] && [ -r /proc/$pid/cmdline ] 2>/dev/null; then
        exe_name=$(basename "$(readlink /proc/$pid/exe 2>/dev/null)")
        cmd_name=$(cat /proc/$pid/cmdline 2>/dev/null | tr '\0' ' ' | awk '{print $1}')
        # Check if command name contains brackets and doesn't match executable name
        if [[ "$cmd_name" == *"["*"]"* ]] && [[ "$exe_name" != "$cmd_name" ]]; then
            echo "[!] PID $pid: exe=$exe_name, cmdline starts with $cmd_name"
        fi
    fi
done

echo -e "\n[*] Triage complete. Investigate any anomalies above."
