# Day 6: SSH Brute Force and Log Analysis

**Date:** 2026-04-17
**Time Spent:** 2.5 hours

## Objectives
- Set up SSH server with a weak user account.
- Perform a dictionary attack using Hydra.
- Monitor and analyze `/var/log/auth.log` for brute force patterns.
- Create an automated detection script for rapid failed logins.

## Key Log Entries
| Event | Log Sample |
|-------|------------|
| Connection | `sshd[pid]: Connection from IP port` |
| Failed password | `sshd[pid]: Failed password for user from IP port ssh2` |
| Accepted password | `sshd[pid]: Accepted password for user from IP port ssh2` |

## Commands for Log Analysis
- Count failures: `grep "Failed password for bob" /var/log/auth.log | wc -l`
- Unique IPs: `grep "Failed password" /var/log/auth.log | awk '{print $(NF-3)}' | sort | uniq -c`
- Successful logins: `grep "Accepted password" /var/log/auth.log`

## Attack Tools Used
- Hydra: `hydra -l bob -P passlist.txt ssh://<IP>`

## SOC Detection Logic
- Threshold-based alert: >5 failures from same IP within 60 seconds.
- Correlate with successful login to confirm compromise.
- Immediate response: block IP, disable user account, investigate session.

## Artifacts Created
- Script: `ssh-brute-detector.sh`
- Sample wordlist: `passlist.txt`
- Screenshots: Hydra output, log excerpts showing failures and success.

## Troubleshooting: Missing /var/log/auth.log

**Issue:** `tail -f /var/log/auth.log` failed with "No such file or directory".

**Root Cause:** rsyslog not running or log file not yet created.

**Solution:**
- Start rsyslog: `sudo systemctl start rsyslog`
- Alternative: Use `journalctl -u ssh -f` for real-time SSH monitoring.

**Key Learnings:**
- Modern Linux distros may use systemd-journald as primary logger.
- SOC analysts should be comfortable with both traditional log files and journalctl.
- Many SIEMs ingest journald logs natively.

## Next Up
Day 7: Building a "Poor Man's SIEM" with grep, awk, sort, uniq.
