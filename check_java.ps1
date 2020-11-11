# Variables
$apiKey = "" # API key
$orgID = "" # Org ID from URL
$currentMachineName = $env:COMPUTERNAME;
$tag = "Java Running" # Tag to add

Function Add-Tag{
    $apiUrl = "https://console.automox.com/api/servers?o=$($orgID)&limit=1&page=0&filters[device_name][]=$($currentMachineName)"
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", "Bearer $apiKey")
    $headers.Add("Content-Type", "application/json")

    # Search device in Automox by current machine name
    $response = Invoke-RestMethod $apiUrl -Method 'GET' -Headers $headers
    [void]($response | ConvertTo-Json)
    if($response.Length -eq 0){
        Write-Output "Could not find device under device name $($currentMachineName)"
        exit 1
    }
    # Re-create tag list
    $tags = New-Object -TypeName "System.Collections.ArrayList"
    If($response.tags -is [array]){
        [void]$tags.AddRange($response.tags)
    }elseif ($response.tags -is [string]) {
        [void]$tags.Add($response.tags)
    }
    # Assign Tag
    If(-Not $tags.Contains($tag)){
        $deviceID = $response.id
        $groupID = $response.server_group_id
        [void]$tags.Add($tag)
    
        $deviceUrl = "https://console.automox.com/api/servers/$($deviceID)?o=$($orgID)"
        $body = @{"server_group_id" = $groupID; "tags" = $tags}
        $body = ConvertTo-Json -InputObject $body
        $body
        Invoke-RestMethod $deviceUrl -Method 'PUT' -Headers $headers -Body $body
    }else{
        Write-Output "Tag is already assigned"
        exit 0
}
}

# Java service Worklet

$installed = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName -Match "Java" -or $_.DisplayName -match "Corretto" })
$version = "(Vendor: " + $installed.Publisher + " " + "Version: " + $installed.DisplayName + ")"
If(-Not $installed) {
    Write-Output "Java is not installed"
    EXIT 0
} else {
    IF (Get-Process -Name "java" -ErrorAction SilentlyContinue) {
    Write-Output "$version is installed and currently running."
    Add-Tag
    }
    else {
    Write-Output "$version installed but not being used at the moment."
    }
}
