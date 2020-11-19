### Variables ###
$username = "" #### Enter username you want to create ###
$password = "" ### Enter initial password ###
### Variables ###

$User=gwmi -class Win32_UserAccount | Where {$_.Name -eq $username}

if (-Not $User)
{ 
[void](net user /add $username $password)
[void](net localgroup administrators $username /add)
    if ($? -eq "True")
        { 
        $Created = "yes"
        Write-Output "User successfully created." }
    else {Write-Output "Failed to create user!" }
}
Else {Write-Output "User already exists." }

$Installed = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName -Match "Local Administrator Password Solution" })

If(-Not $Installed) {
    [void](Start-Process -FilePath 'msiexec.exe' -ArgumentList ('/qn', '/i', '"LAPS.x64.msi"') -Wait -Passthru)
    
    if ($? -eq "True")
        { Write-Output "LAPS client successfully installed." }
    else {Write-Output "Failed to install LAPS client!" }
    } 
else {
    Write-Output "LAPS client already installed."
    }

if ($Created)
{
[void](net user administrator /active:no)
     if ($? -eq "True")
        { Write-Output "Default administrator account disabled." }
    else {Write-Output "Failed to disable default administrator account!" }
}
