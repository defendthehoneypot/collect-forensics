@echo off
CLS
REM ------------------------------------------------------------------------------------------------------------------------
REM collect_forensics v1.0
REM by Doug Richmond (doug@defendthehoneypot.com)
REM
REM About:
REM Script to automate collecting forensic data from remote systems
REM 
REM Additional Tools Needed:
REM Microsoft psexec.exe, Download and Info: https://technet.microsoft.com/en-us/sysinternals/pxexec
REM Microsoft autorunssc.exe, Download and Info: https://technet.microsoft.com/en-us/sysinternals/bb963902
REM 
REM Folder Structure:
REM		- Main Directory containing collect_forensics.cmd

echo.
echo #######################################
echo Create Local Directory by Computer name
echo #######################################
echo.
for /F %%i in (hosts.txt) do mkdir C:\Tools\forensics\output\%%i

echo.
echo #######################################
echo Create Remote Directory for tools
echo #######################################
echo.
for /F %%i in (hosts.txt) do mkdir \\%%i\c$\windows\tools

echo.
echo #######################################
echo copy executable files to remote system
echo #######################################
echo.
for /F %%i in (hosts.txt) do xcopy /y c:\tools\autorunsc.exe \\%%i\c$\windows\tools

echo.
echo #######################################
echo Search for executable files within Users directory
echo #######################################
echo.
for /F %%i in (hosts.txt) do dir /s /a \\%%i\c$\Users\*.exe  >> .\output\%%i\%%i-binaries.txt
for /F %%i in (hosts.txt) do dir /s /a \\%%i\c$\Users\*.ps1  >> .\output\%%i\%%i-binaries.txt
for /F %%i in (hosts.txt) do dir /s /a \\%%i\c$\Users\*.vbs  >> .\output\%%i\%%i-binaries.txt
for /F %%i in (hosts.txt) do dir /s /a \\%%i\c$\Users\*.vb  >> .\output\%%i\%%i-binaries.txt

echo.
echo #######################################
echo Run network statistics command
echo #######################################
echo.
for /F %%i in (hosts.txt) do psexec.exe -accepteula \\%%i netstat -n >> .\output\%%i\%%i-networkinfo.txt

echo.
echo #######################################
echo Run network statistics command
echo #######################################
echo.
for /F %%i in (hosts.txt) do psexec.exe -accepteula \\%%i ipconfig /displaydns >> .\output\%%i\%%i-dns.txt

echo.
echo #######################################
echo Run autorunsc.exe to collect information about autostart locations
echo #######################################
echo.
for /F %%i in (hosts.txt) do psexec.exe -accepteula \\%%i c:\windows\tools\autorunsc.exe -accepteula -a * -ct >> .\output\%%i\%%i.csv

echo.
echo #######################################
echo Run streams to collect ADS information
echo #######################################
echo.
for /F %%i in (hosts.txt) do streams.exe -accepteula -s \\%%i\c$\windows\system32 >> .\output\%%i\%%i-streams.txt

echo.
echo #######################################
echo delete executable files copied to remote system
echo #######################################
echo.
for /F %%i in (hosts.txt) do del \\%%i\c$\windows\tools\*.exe
