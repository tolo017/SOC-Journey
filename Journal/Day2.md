# Day 2: Linux Navigation & File Hunting

**Date:** 2026-04-11  
**Time Spent:** 2.5 hours

## Objectives
- Understand the Linux Filesystem Hierarchy Standard (FHS) key directories.
- Use `find`, `locate`, and `which` for reconnaissance.
- Simulate post-exploitation file searching.
- Create a stealthy enumeration script.

## Key Directories (Hacker's Cheat Sheet)
| Dir | Purpose | Attack Use |
|-----|---------|------------|
| /etc | Configs | Read shadow, passwd, crontab |
| /var/log | Logs | Clear tracks or read auth logs |
| /home | User files | Grab SSH keys, bash history |
| /tmp | Temporary | Upload tools, execute malware |

## Commands Mastered
- `find / -name "passwords.txt" 2>/dev/null` → Find by name, suppress errors.
- `find / -perm -4000 2>/dev/null` → Find SUID binaries (PrivEsc vector).
- `locate <file>` → Fast, uses database.
- `which <command>` → Locate binary path.

## Black Hat Insight
The difference between `find` and `locate` is the difference between searching the house while the owner is asleep (locate) vs. turning on all the lights and opening drawers (find). A quiet attacker uses `locate` first, then targeted `find` only in user directories.

## Artifacts Created
- Script: `hunter.sh` – Automates discovery of keys/passwords.
- Screenshot: Terminal output of `hunter.sh` finding `passwords.txt`.

## Next Up
Day 3: Permissions, SUID, and Privilege Escalation mindset.
