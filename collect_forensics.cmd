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
REM Microsoft pslist.exe, Download and Info: https://technet.microsoft.com/en-us/sysinternals/pslist.aspx
REM 
REM Folder Structure:
REM		- Main Directory containing collect_forensics.cmd
REM			-tools: contains binaries need for script

REM Setup:
REM Set base folder, set input source file if needed, and make Results directory.
SET scriptlocation=%~dp0
SET src=%1
SET dtstamp=%date:~-4%%date:~4,2%%date:~7,2%_%time:~0,2%_%time:~3,2%_%time:~6,2%
mkdir Results_%dtstamp%

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
for /F %%i in (hosts.txt) do xcopy /y %scriptlocation%tools\autorunsc.exe \\%%i\c$\windows\tools

echo.
echo #######################################
echo Search for files within Users directory
echo #######################################
echo.
for /F %%i in (hosts.txt) do dir /s /a \\%%i\c$\Users\*.exe \\%%i\c$\Users\*.vbs \\%%i\c$\Users\*.vb \\%%i\c$\Users\*.ps1  >> %scriptlocation%Results_%dtstamp%\%%i-executablefiles.txt

echo.
echo #######################################
echo Collect process list
echo #######################################
echo.
for /F %%i in (hosts.txt) do %scriptlocation%\tools\pslist.exe -accepteula -nobanner -t %%i >> %scriptlocation%Results_%dtstamp%\%%i-processlist.csv

echo.
echo #######################################
echo Collect network statistics command
echo #######################################
echo.
for /F %%i in (hosts.txt) do %scriptlocation%\tools\psexec.exe -accepteula -nobanner \\%%i netstat -n >> %scriptlocation%Results_%dtstamp%\%%i-netstat.txt

echo.
echo #######################################
echo Collect DNS
echo #######################################
echo.
for /F %%i in (hosts.txt) do %scriptlocation%\tools\psexec.exe -accepteula -nobanner \\%%i ipconfig /displaydns >> %scriptlocation%Results_%dtstamp%\%%i-dns.txt

echo.
echo #######################################
echo Run autorunsc.exe to collect information about autostart locations
echo #######################################
echo.
for /F %%i in (hosts.txt) do %scriptlocation%\tools\psexec.exe -accepteula -nobanner \\%%i c:\windows\tools\autorunsc.exe -accepteula -a * -ct >> %scriptlocation%Results_%dtstamp%\%%i-autoruns.csv

REM echo.
REM echo #######################################
REM echo Run streams to collect ADS information
REM echo #######################################
REM echo.
REM for /F %%i in (hosts.txt) do %scriptlocation%\tools\streams.exe -accepteula -nobanner -s \\%%i\c$\windows\system32 >> %scriptlocation%Results_%dtstamp%\%%i-streams.txt

echo.
echo #######################################
echo delete remote folder created on remote system
echo #######################################
echo.
for /F %%i in (hosts.txt) do rmdir /s /q \\%%i\c$\windows\tools\
echo remote folder deleted
