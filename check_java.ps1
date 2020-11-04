$installed = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where { $_.DisplayName -Match "Java" -or $_.DisplayName -match "Corretto" })
$version = "(Vendor: " + $installed.Publisher + " " + "Version: " + $installed.DisplayName + ")"

If(-Not $installed) {
    Write-Output "Java is not installed"
	EXIT 0
} else {
    IF (Get-Process -Name "java" -ErrorAction SilentlyContinue) {
	Write-Output "$version is installed and currently running."
    }
    else {
    Write-Output "$version installed but not being used at the moment."
    }
}