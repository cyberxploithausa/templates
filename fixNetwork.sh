#!/bin/bash
echo "[+] Stoping Anonsurf to re-route DNS..."
sleep(2)
sudo  anonsurf stop
echo "[+] Adding new nameserver: 8.8.8.8"
sleep(2)
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
echo "[+] Restarting NetworkManager..."
sleep(2)
sudo systemctl restart NetworkManager
