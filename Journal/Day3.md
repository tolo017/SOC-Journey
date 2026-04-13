# Day 3: Permissions, SUID, and the Privilege Escalation Mindset

**Date:** 2026-04-13  
**Time Spent:** 2.5 hours

## Objectives
- Understand Linux file permissions (`rwx`) and special bits (`s`, `t`).
- Identify SUID binaries and their security implications.
- Simulate a SUID-based privilege escalation attack.
- Create a script to hunt for SUID/SGID and world-writable files.

## Key Concepts
- **SUID (`chmod u+s`)** : File runs with owner's permissions, often root.
- **SGID (`chmod g+s`)** : File runs with group permissions.
- **Sticky bit (`chmod +t`)** : Prevents deletion by non-owners in shared directories.

## Commands Mastered
| Command | Purpose |
|---------|---------|
| `chmod 777 file` | Give all permissions (dangerous) |
| `find / -perm -4000 2>/dev/null` | Locate SUID binaries |
| `ls -l /usr/bin/passwd` | Check for `s` bit |
| `find / -type f -perm -o+w 2>/dev/null` | Find world-writable files |

## Black Hat Insight
SUID is a double-edged sword. Legitimate tools like `sudo` and `passwd` use it. But when an admin mistakenly sets SUID on `find`, `vim`, or `python`, they hand over the root key to any user. The attacker's job is to find that mistake.

## Practical Lab
- Set SUID on `/usr/bin/find`.
- Exploited to read `/etc/shadow`: `find /etc/shadow -exec cat {} \;`
- Observed the impact and logged evidence in `/var/log/auth.log` (limited).

## Artifacts Created
- Script: `suid-hunter.sh` – Automates SUID/SGID discovery.
- Screenshot: Terminal showing `find -exec` reading shadow file.

## Next Steps
Day 4: Processes and Persistence – How attackers stay hidden and maintain access.
