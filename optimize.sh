#!/bin/bash
# Optimize system performance on low-resource Linux

echo "[+] Stopping unnecessary services..."
sudo systemctl stop bluetooth.service
sudo systemctl stop cups.service
sudo systemctl stop avahi-daemon.service

echo "[+] Disabling those services permanently..."
sudo systemctl disable bluetooth.service
sudo systemctl disable cups.service
sudo systemctl disable avahi-daemon.service

echo "[+] Setting CPU governor to performance..."
for CPUFREQ in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
  echo performance | sudo tee $CPUFREQ
done

echo "[+] Cleaning memory cache..."
sync; echo 3 | sudo tee /proc/sys/vm/drop_caches

echo "[+] Cleaning apt cache..."
sudo apt clean

echo "[+] Done. Top memory-hungry processes:"
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 15

notify-send "System Optimizer" "Optimization completed successfully."

