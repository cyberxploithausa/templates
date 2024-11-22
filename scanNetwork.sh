#!/bin/bash


mkdir results
# Check if IP of target is entered
if [ -z "$1" ]
  then
    echo "Correct usage is: scan <IP>"
    exit
  else
    echo "Target IP $1"
    # checking wheather nmap directory exist
    echo "Running Nmap…"
# Run Nmap scan on target and save results to file
    #ports=$(nmap -p- --min-rate=1000 -T4 $1 | grep '^[0-9]' | cut -d '/' -f 1 | tr '\n' ',' | sed s/,$//)
    #nmap -p $ports -sC -sV $1
    nmap -sC -sV -oN ./results/nmapscan $1 -vv
    echo "Scan complete – results written to nmapscan"
fi

echo "==================================================================="
# If the Samba port 445 is found and open, run enum4linux.
if grep 445 ./results/nmapscan | grep -iq open
  then
  	echo "Scanning for SMB"
    smbmap -H $1 | tee ./results/smbscan445
    echo "Samba found. Enumeration complete."
  else
   echo "Open SMB share ports not found."
fi

echo "==================================================================="
if grep 139 ./results/nmapscan | grep -iq open
  then
  	echo "Scanning for SMB"
    smbmap -H $1 | tee ./results/smbscan139
    echo "Samba found. Enumeration complete."
  else
   echo "Open SMB share ports not found."
fi

echo "==================================================================="

if grep 80 ./results/nmapscan | grep -iq open
  then
  	echo "Starting Gobuster Scan..."
    gobuster dir -u http://$1 -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -x php,html,cgi,txt,py,db,bak	| tee ./results/goscan
    echo "HTTP found. Enumeration complete."
  else
   echo "Open http ports not found."
fi
echo "==================================================================="
if grep 8080 ./results/nmapscan | grep -iq open
  then
    echo "Starting Gobuster Scan..."
    gobuster dir -u http://$1 -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -x php,html,cgi,txt,py,db,bak | tee ./results/goscan
    echo "HTTP found. Enumeration complete."
  else
   echo "Open http ports not found."
fi
echo "==================================================================="
if grep 8000 ./results/nmapscan | grep -iq open
  then
    echo "Starting Gobuster Scan..."
    gobuster dir -u http://$1 -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -x php,html,cgi,txt,py,db,bak | tee ./results/goscan
    echo "HTTP found. Enumeration complete."
  else
   echo "Open http ports not found."
fi


