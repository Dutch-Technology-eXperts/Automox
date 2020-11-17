IF (gwmi Win32_Product -filter "name like 'Java%'")
{
[void](gwmi Win32_Product -filter "name like 'Java%'" | % { $_.Uninstall() })

if ($? -eq "True")
{ Write-Output "Java succesfully removed." }
else {Write-Output "Failed to remove Java!" }
}
ELSE {Write-Output "Java not installed."}
