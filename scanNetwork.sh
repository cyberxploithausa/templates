#!/usr/bin/env bash

# CTF Recon Script
# Usage:
#   ./scan.sh <ip>           # single IP
#   ./scan.sh ips.txt        # list of IPs

WORDLIST="/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt"
OUTDIR="recon"

mkdir -p "$OUTDIR"

if [ -z "$1" ]; then
  echo "Usage: $0 <ip or file>"
  exit 1
fi

# Load targets
if [[ -f "$1" ]]; then
  targets=$(cat "$1")
else
  targets=$1
fi

for ip in $targets; do
  echo -e "\n==============================="
  echo "[*] Scanning $ip"
  ipdir="$OUTDIR/$ip"
  mkdir -p "$ipdir"

  # Rustscan + nmap
  rustscan -a $ip -- -sV -oN "$ipdir/nmap.txt"

  # Extract open ports
  ports=$(grep -Eo '([0-9]{1,5})/tcp' "$ipdir/nmap.txt" | cut -d'/' -f1 | tr '\n' ',' | sed 's/,$//')
  echo "Open ports: $ports"

  # Web scan
  if echo "$ports" | grep -Eq '(80|443|8080|8000|8888)'; then
    echo "[+] Web ports detected – starting feroxbuster"
    feroxbuster -u http://$ip -w "$WORDLIST" -o "$ipdir/ferox.txt"
  fi

  # SMB scan
  if echo "$ports" | grep -Eq '(445|139)'; then
    echo "[+] SMB detected – listing shares with smbclient"
    smbclient -L //$ip -N | tee "$ipdir/smb.txt"
  fi

  # LDAP / AD detection
  if echo "$ports" | grep -Eq '(389|88)'; then
    echo "[+] Possible Active Directory domain controller (LDAP/Kerberos detected)" | tee "$ipdir/ldap_notice.txt"
  fi

  # FTP banner
  if echo "$ports" | grep -Eq '21'; then
    echo "[+] FTP detected – grabbing banner"
    echo quit | nc $ip 21 | tee "$ipdir/ftp_banner.txt"
  fi

  echo "[*] Done with $ip"
done

