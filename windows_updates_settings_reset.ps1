#Evaluation Code
Exit 1

#Remediation Code
$arch = Get-WMIObject -Class Win32_Processor -ComputerName LocalHost | Select-Object AddressWidth

$windowsUpdateServices = @(
    "BITS",
    "wuauserv",
    "appidsvc",
    "cryptsvc"
)

#1.0 Check if services are stopping
$Services = Get-WmiObject -Class win32_service -Filter "state = 'stop pending'"
if ($Services) {
foreach ($service in $Services) {
{
Stop-Process -Id $service.processid -Force -PassThru -ErrorAction SilentlyContinue
}
}
}

#1.1 Stopping Windows Update Services...
foreach ($service in $windowsUpdateServices){
    Stop-Service -Name $service
}

#1.2 Check if services are stopping
$Services = Get-WmiObject -Class win32_service -Filter "state = 'stop pending'"
if ($Services) {
foreach ($service in $Services) {
{
Stop-Process -Id $service.processid -Force -PassThru -ErrorAction SilentlyContinue
}
}
}

#2. Remove QMGR Data file...
Remove-Item "$env:allusersprofile\Microsoft\Network\Downloader\qmgr*.dat" -Force -ErrorAction SilentlyContinue

#3. Renaming the Software Distribution and CatRoot Folder...
Remove-Item $env:systemroot\SoftwareDistribution.bak -Recurse -Force -ErrorAction SilentlyContinue
Rename-Item $env:systemroot\SoftwareDistribution SoftwareDistribution.bak -Force -ErrorAction SilentlyContinue
# This may not work if the folder is locked by having a contained file being accessed
Remove-Item $env:systemroot\System32\Catroot2.bak -Recurse -Force -ErrorAction SilentlyContinue
Rename-Item $env:systemroot\System32\Catroot2 catroot2.bak -Force -ErrorAction SilentlyContinue

#4. Removing old Windows Update log...
Remove-Item $env:systemroot\WindowsUpdate.log -Force -ErrorAction SilentlyContinue

#5. Resetting the Windows Update Services to default settings...

[void]("sc.exe sdset bits D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)")
[void]("sc.exe sdset wuauserv D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)")

Set-Location $env:systemroot\system32

#6. Registering some DLLs...
$dlls = @("atl.dll","urlmon.dll","mshtml.dll","shdocvw.dll","browseui.dll","jscript.dll","vbscript.dll","scrrun.dll","msxml.dll","msxml3.dll","msxml6.dll","actxprxy.dll","softpub.dll","wintrust.dll","dssenh.dll","rsaenh.dll","gpkcsp.dll","sccbase.dll","slbcsp.dll","cryptdlg.dll","oleaut32.dll","ole32.dll","shell32.dll","initpki.dll","wuapi.dll","wuaueng.dll","wuaueng1.dll","wucltui.dll","wups.dll","wups2.dll","wuweb.dll","qmgr.dll","qmgrprxy.dll","wucltux.dll","muweb.dll","wuwebv.dll")
foreach($dll in $dlls){
    regsvr32.exe /s $dll
}

#7) Removing WSUS client settings...
REG DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate" /v AccountDomainSid /f
REG DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate" /v PingID /f
REG DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate" /v SusClientId /f

#8) Resetting the WinSock...
[void](netsh winsock reset)
[void](netsh winhttp reset proxy)

#9) Delete all BITS jobs...
Get-BitsTransfer | Remove-BitsTransfer

#10) Attempting to install the Windows Update Agent...
if($arch -eq 64){
    wusa Windows8-RT-KB2937636-x64 /quiet
}
else{
    wusa Windows8-RT-KB2937636-x86 /quiet
}

#11) Starting Windows Update Services...
foreach ($service in $windowsUpdateServices){
    Start-Service -Name $service
}

#12) Forcing discovery...
wuauclt /resetauthorization /detectnow

Write-Output "Windows Update settings restored to default."
