$SettingsFile = "$PSScriptRoot\SettingsRes.txt"


Get-Content $SettingsFile | foreach-object -begin {$h=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $h.Add($k[0], $k[1]) } }


$Database=($h.'DataBaseName ').Trim()
$SQLUsername=($h.'SQLUsername ').Trim()
$SQLPassword=($h.'SQLPassword ').Trim()
$PathToCopy=($h.'PathToCopy ').Trim()
$FTPUsername = ($h.'FTPUsername ').Trim()
$FTPPassword = ($h.'FTPPassword  ').Trim()
$FTPPath=($h.'FTPPath ').Trim()
$WinScpPath = ($h.'WinSCPPath ').Trim()


Add-Type -Path $WinScpPath



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
$directoryInfo = $session.ListDirectory($remotePath)

# Select the most recent file
$latest =
    $directoryInfo.Files |
    Where-Object { $_.Name -match "backup.zip" } |  Sort-Object LastWriteTime -Descending | Select-Object -First 1

# Any file at all?
if ($latest -eq $Null)
{
    Write-Host "No file found"
    
}
$localPath=[string]($PathToCopy)+"\"
# Download the selected file
$sourcePath = [WinSCP.RemotePath]::EscapeFileMask($remotePath + $latest.Name)
$session.GetFiles($sourcePath, $localpath).Check()
$session.Close()


$begin=Get-Date -Format 'yyyy-MM-dd-HH:mm'
$b="`n`n`n`n*****Restore begin to work from directory $PSScriptRoot at $begin with database $database from $latest backup file `n*****Temp directory is $Temppath `n`n`n`n"
Write-Host $b
$b  >> $PathToCopy\log_res.txt










$File=$PathToCopy+"\"+$latest.Name


if (Test-Path "$env:ProgramFiles (x86)\7-Zip\7z.exe")

{$7zipPath = "$env:ProgramFiles (x86)\7-Zip\7z.exe"}
else 
{
if (Test-Path "$env:ProgramFiles\7-Zip\7z.exe")
{$7zipPath = "$env:ProgramFiles\7-Zip\7z.exe"}
else {Write-Host 7z not installed}
}

Set-Alias 7zip $7zipPath

7zip e $File -o"$PathToCopy" -y

Sleep 5

$sqlgetpath = "select 
    InstanceDefaultDataPath = serverproperty('InstanceDefaultDataPath'),
    InstanceDefaultLogPath = serverproperty('InstanceDefaultLogPath')
"

$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = "Server=$server;Integrated Security=False;User=$SQLUsername;Password=$SQLPassword"
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.Connection = $SqlConnection
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter


#GetSqlFilesPath


$SqlCmd.CommandText=$Sqlgetpath

$SqlAdapter.SelectCommand=$SqlCmd

$DataSet = New-Object System.Data.DataSet
try {
$SqlAdapter.Fill($DataSet)
}
catch {
[string](Get-Date) + "Failed  Get path for sql server" >> $PathToCopy\log_res.txt
$_ >> $PathToCopy\log_res.txt
Write-Host $_
}

$Datapath=$Dataset.Tables[0].Rows[0].ItemArray[0]
$Logpath=$Dataset.Tables[0].Rows[0].ItemArray[1]


$sqlgetbaseinfo="RESTORE FILELISTONLY FROM DISK = '$PathToCopy\backup.bak' WITH FILE = 1"


$sqlCmd.CommandText=$sqlgetbaseinfo
$SqlAdapter.SelectCommand.CommandTimeout=0
$SqlAdapter.SelectCommand=$sqlcmd
try {
$SqlAdapter.Fill($DataSet)
}
catch {
[string](Get-Date) + "Failed get base info from backup file" >> $PathToCopy\log_res.txt
Get-Date >> $PathToCopy\log_res.txt 
$_ >> $PathToCopy\log_res.txt
Write-Host $_
}
$NameBase=$Dataset.Tables[0].Rows[1].LogicalName
$NameLog=$Dataset.Tables[0].Rows[2].LogicalName




$sqlresdatabase="Use Master
alter database $Database set offline with rollback immediate;
RESTORE DATABASE [$Database] FROM DISK = N'$PathToCopy\backup.bak' WITH REPLACE, FILE=1, MOVE '$NameBase' TO '$Datapath+$Database.mdf', MOVE '$NameLog' TO '$LogPath+$Database log.ldf';
alter database $Database set online with rollback immediate;
"

$sqlCmd.CommandText=$sqlresdatabase
$SqlAdapter.SelectCommand.CommandTimeout=0
$SqlAdapter.SelectCommand=$sqlcmd
try {
$SqlAdapter.Fill($DataSet)
}
catch {
[string](Get-Date) + "Failed RESTORE Database" >> $PathToCopy\log_res.txt
Get-Date >> $PathToCopy\log_res.txt 
$_ >> $PathToCopy\log_res.txt
Write-Host $_
}

$SqlConnection.Close()
Remove-Item $File
Remove-Item $PathToCopy\backup.bak



$end=Get-Date -Format 'yyyy-MM-dd-HH:mm'
$e="`n`n`n`n*****Restore end to work from directory $PSScriptRoot at $end with database $database from $latest backup file  `n*****Temp directory is $Temppath `n`n`n`n" 
Write-Host $e
$e >> $PathToCopy\log_res.txt

Get-Date -Format 'yyyy-MM-dd-HH:mm'  

$shell = New-Object -ComObject Wscript.Shell
$shell.popup("Script end")