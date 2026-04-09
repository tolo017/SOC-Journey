# Day 1: Lab Foundation & Layer 3 Reconnaissance

**Date:** 2026-04-10  
**Time Spent:** 2.5 hours

## Objectives
- Set up VirtualBox NAT Network "SOC-Range".
- Deploy Peppermint (target) and Kali (attacker) VMs.
- Establish ICMP (ping) connectivity.
- Learn to read `man` pages.
- Write a simple connectivity check script.

## Lab Topology
- Network: 10.0.2.0/24 (NAT Network)
- Target IP: 10.0.2.15 (Peppermint)
- Attacker IP: 10.0.2.4 (Kali)

## Commands Used
| Command | Purpose |
|---------|---------|
| `ip a` | Display IP configuration |
| `ping -c 4 <IP>` | Send 4 ICMP echo requests |
| `man ping` | View manual for ping |
| `sudo ufw allow proto icmp` | Allow ICMP on firewall |

## Black Hat Insight
Ping is the sound of a door knock. A response tells me:
- The host is alive.
- Likely OS based on TTL (Linux TTL=64).
- No filtering of ICMP (yet).

## Artifacts
- Screenshot of successful ping: `assets/day1-success.png`
- Script: `check-target.sh`

## Next Steps
- Day 2: Linux filesystem navigation and finding "secrets" on the target.
