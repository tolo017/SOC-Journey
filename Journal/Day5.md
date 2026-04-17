# Day 5: Networking for Hunters – TCP/IP and Nmap Reconnaissance

**Date:** 2026-04-16
**Time Spent:** 2.5 hours

## Objectives
- Understand the TCP three-way handshake (SYN, SYN-ACK, ACK).
- Capture and analyze network traffic with `tcpdump`.
- Perform and detect port scans (`nmap -sS` vs `-sT`).
- Create a basic scan detection script.

## TCP Flags Quick Reference
| Flag | tcpdump Symbol | Meaning |
|------|----------------|---------|
| SYN | `S` | Connection request |
| SYN-ACK | `S.` | Connection acknowledgment |
| RST | `R` | Reset (port closed) |
| FIN | `F` | Finish connection |

## Key Commands
- Capture all traffic: `sudo tcpdump -i any -w capture.pcap`
- Read PCAP: `tcpdump -r capture.pcap -n`
- Filter SYN packets: `tcpdump -r capture.pcap -n 'tcp[tcpflags] & tcp-syn != 0'`
- Stealth scan: `nmap -sS <target>`
- Connect scan: `nmap -sT <target>`

## Black Hat Insight
- SYN scan (`-sS`) is faster and quieter; it never completes the handshake.
- Open ports reply with SYN-ACK; closed ports reply with RST.
- A lack of response (filtered) suggests a firewall, which may be hiding services.

## SOC Detection
- Monitor for SYN packets from a single source to many destination ports (threshold-based alert).
- Baseline normal network behavior; deviations indicate reconnaissance.
- Logs to check: firewall logs, `tcpdump` captures, SIEM alerts.

## Artifacts Created
- Script: `scan-detector.sh` – Simple port scan alerting.
- PCAP file: `lab-capture.pcap` (sample of nmap scan).
- Screenshots: tcpdump showing SYN, SYN-ACK, RST packets.

## Script Troubleshooting: scan-detector.sh

### Issue
`awk: line 11: syntax error at or near =` when running original script. 
Cause: The default `awk` (mawk) lacks GNU extensions like `systime()`.

### Resolution
Rewrote detection logic in pure Bash using associative arrays and `date +%s`. 
This version is more portable and easier to understand.

### Key Bash Features Used
- `declare -A` for associative arrays.
- `${var:-default}` for default values.
- `$(date +%s)` for epoch seconds.
- `while read` loop with `tcpdump -l`.

## Next Up
Day 6: SSH, Syslog, and Brute Force Detection.
