# Evaluation code

exit 1

# Remediation Code

if ($PSVersionTable.PSVersion -eq "2.0")
{ 
Write-Output "This worklet requires PowerShell version 3.0 or higher!"
exit 0
}
else {
$Policy = "RemoteSigned" 
If ((Get-ExecutionPolicy) -ne $Policy) {    
 Set-ExecutionPolicy $Policy -Force
 Write-Output "Changed execution policy to 'RemoteSigned'. "}

#SAS Token
$sas = ""
 
#Automox Log File Location
$filesource = "C:\Programdata\amagent\amagent.log"
 
#Copy Log File
Copy-Item $filesource -Destination "C:\Programdata\amagent\amagent_upload.log"
$file = "C:\Programdata\amagent\amagent_upload.log"
 
#Get the File-Name without path + add computername + date
$date = (Get-Date).ToString("dd-MM-yy")
$name = (Get-Item $file).Name + "_" + $env:computername + "_" + $date
 
#The target URL wit SAS Token
$uri = "/$($name)$sas"
 
#Define required Headers
$headers = @{
    'x-ms-blob-type' = 'BlockBlob'
}
 
#Upload File...
Invoke-RestMethod -Uri $uri -Method Put -Headers $headers -InFile $file  
 
if ($? -eq "True")
{ Write-Output "Log file successfully uploaded." }
else {Write-Output "Failed to upload log file!" }
 
#Remove Temp File...
Remove-item $file
}
