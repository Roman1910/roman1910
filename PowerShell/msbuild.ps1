
$path = Split-Path $PSCommandPath -Parent
$SettingsFile = "$Path\VSSettings.txt"
$settingsFile

Get-Content $SettingsFile | foreach-object -begin {$h=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $h.Add($k[0], $k[1]) } }

$MsbuildPath=($h.MsbuildPath).Trim()
$InputFolder = ($h.'InputFolder ').Trim()
$ProjectName=($h.'ProjectName ').Trim()
$UpdateURL=($h.'UpdateURL ').Trim()
$DBFolderPath=($h.'DBFolderPath ').Trim()
$ProjectConfiguration=($h.'ProjectConfiguration ').Trim()
$OutputFolder=($h.'OutputFolder ').Trim()
$FTPUsername = ($h.'FTPUsername ').Trim()
$FTPPassword = ($h.'FTPPassword  ').Trim()
$FTPPath= ($h.'FTPPath ').Trim()
$WinScpPath = ($h.'WinSCPPath ').Trim()
$chat_id = ($h.'TGChannelName ').Trim()
$message = ($h.'TGCompleteMessage ').Trim()

Add-Type -Path $WinScpPath

$date=[string](Get-date) + "  ****** BEGIN SCRIPT *********"

$date  >>  $path\LOG.txt

[xml]$xmlDoc = Get-Content "$InputFolder\DeInfoMini\app.config"
$xmlDoc.DocumentElement.appSettings.add.Item(0).value = $UpdateURL
$xmlDoc.Save("$InputFolder\DeInfoMini\app.config")

Copy-Item -Path "$DBFolderPath\*" -Destination "$InputFolder\db-snapshot"

$e
#Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList { "SET PATH=C:\Program Files (x86)\Microsoft Visual Studio\2019\Community;%PATH%"}
Start-Process -Wait -FilePath $MsbuildPath -ArgumentList "$InputFolder\$ProjectName /t:Clean,Rebuild /p:Configuration=$ProjectConfiguration;OutDir=$OutputFolder\"  -RedirectStandardOutput $path\LOG.txt
$cont=(get-content $path\LOG.txt) -join "`n"
$date+"`r`n" + $cont > $path\LOG.txt




#Compress AND upload

if (Test-Path "$env:ProgramFiles (x86)\7-Zip\7z.exe")

{$7zipPath = "$env:ProgramFiles (x86)\7-Zip\7z.exe"}
else 
{
if (Test-Path "$env:ProgramFiles\7-Zip\7z.exe")
{$7zipPath = "$env:ProgramFiles\7-Zip\7z.exe"}
else {Write-Host 7z not installed}
}

Set-Alias 7zip $7zipPath







 
  7zip a -tzip -mx5 -r0 $OutputFolder\$ProjectName.zip $OutputFolder
  $date=[string](Get-date) + "   Archive created" + "`n" 
  $date  >>  $path\LOG.txt







 try{ 

$remotePath =$FTPPath.Substring($FTPPath.IndexOf('/'))

$Hostname=$FTPPath.Substring(0, $FTPPath.IndexOf('/'))



# Setup session options
$sessionOptions = New-Object WinSCP.SessionOptions -Property @{
    Protocol = [WinSCP.Protocol]::Ftp
    HostName = $Hostname
    UserName = $FTPUsername
    Password = $FTPPassword
}

$session = New-Object WinSCP.Session

# Connect
$session.Open($sessionOptions)

# Get list of files in the directory






$localPath="$OutputFolder\$ProjectName.zip"
# Download the selected file
$sourcePath = [WinSCP.RemotePath]::EscapeFileMask($remotePath)

$s=$session.PutFiles($localpath,$sourcePath)
if($s.IsSuccess -eq "True"){
$date=[string](Get-date) + "  File uploaded to FTP" + "`n"

$date  >>  $path\LOG.txt
}
$session.Close()

}
catch{[string](Get-Date) + "Failed to UploadFile to FTP" >> $path\log.txt
$_ >> $path\log.txt
Write-Host $_
}


 while($True)
  {
  if($? -like 'False') 

  {Sleep 10
  Write-Host "Add 10 seconds to wait upload FTP" }
  else{break;}
}






$token = "1915011505:AAG-x2SOu6AZgrJcSjwk_6GlhKEZqBoUa9w"

$URI = "https://api.telegram.org/bot" + $token + "/sendMessage?chat_id=" + $chat_id + "&text=" + $message
$Request = Invoke-WebRequest -URI ($URI) 

Remove-Item $OutputFolder\$ProjectName.zip


$date=[string](Get-date) + "  ****** END SCRIPT *********" + "`n"

$date  >>  $path\LOG.txt
