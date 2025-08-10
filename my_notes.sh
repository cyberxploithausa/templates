#!/bin/bash

# Notification
export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
notify-send "About To Backup" "Your notes are about to synced to Github at $(date)"
cd /home/cyberxploit/Desktop/projects/ctfs/Notes/CTF-Notes || exit
git add .
git commit -m "Auto-backup: $(date '+%Y-%m-%d %H:%M:%S')"
git push
git push https://cyberxploithausa:access_token@github.com/cyberxploithausa/ctf-notes.git

# Notification
export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
notify-send "Obsidian Backup" "Notes synced to GitHub at $(date)"

