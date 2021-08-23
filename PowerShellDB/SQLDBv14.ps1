$path = Split-Path $PSCommandPath -Parent
$SettingsFile = "$Path\Settings.txt"
$settingsFile


Get-Content $SettingsFile | foreach-object -begin {$h=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $h.Add($k[0], $k[1]) } }

$server = ($h.'ServerName ').Trim()
$database=($h.'DataBaseName ').Trim()
$SQLUsername=($h.'SQLUsername ').Trim()
$SQLPassword=($h.'SQLPassword ').Trim()
$TempPath=($h.'PathToCopy ').Trim()
$FTPUsername = ($h.'FTPUsername ').Trim()
$FTPPassword = ($h.'FTPPassword  ').Trim()
$FTPPath= ($h.'FTPPath ').Trim()
$WinScpPath = ($h.'WinSCPPath ').Trim()

Add-Type -Path $WinScpPath

$begin=Get-Date -Format 'yyyy-MM-dd-HH:mm'
$b="`n`n`n`n*****Script begin to work from directory $PSScriptRoot at $begin with database $database. `n*****Temp directory is $Temppath `n`n`n`n"
Write-Host $b
$b  >> $TempPath\log.txt

$sqlgetpath = "select 
    InstanceDefaultDataPath = serverproperty('InstanceDefaultDataPath'),
    InstanceDefaultLogPath = serverproperty('InstanceDefaultLogPath')
"


$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = "Server=$server;Database=$database;Integrated Security=False;User=$SQLUsername;Password=$SQLPassword"
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand

$SqlCmd.CommandText = $sqlgetpath
$SqlCmd.Connection = $SqlConnection
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $SqlCmd

$DataSet = New-Object System.Data.DataSet

try {
$SqlAdapter.Fill($DataSet)
Write-Host "Successfull get information about SQL server path`n"
}
catch {
Get-Date >> $TempPath\log.txt
$_ >>  $TempPath\log.txt
Write-Host $_
}

$Datapath=$Dataset.Tables[0].Rows[0].ItemArray[0]
$Logpath=$Dataset.Tables[0].Rows[0].ItemArray[1]



$sqlbackcopydatabase="BACKUP DATABASE [$Database] TO DISK = N'$TempPath\copy.bak'  WITH NOFORMAT, INIT, NAME = N'QuestDB-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, STATS = 10;"
$sqlgetbaseinfo="RESTORE FILELISTONLY FROM DISK = '$TempPath\copy.bak' WITH FILE = 1"

$sqlCmd.CommandText=$sqlbackcopydatabase
$SqlAdapter.SelectCommand.CommandTimeout=0
$SqlAdapter.SelectCommand=$sqlcmd
try {
$SqlAdapter.Fill($DataSet)
Write-Host "Successfull backup target database to disk`n"
}
catch {
[string](Get-Date) + "Failed backup target database" >> $TempPath\log.txt
Get-Date >> $TempPath\log.txt 
$_ >> $TempPath\log.txt
Write-Host $_
}

#Sleep 420 

#Timeout to Backup Target Database
 
$sqlCmd.CommandText=$sqlgetbaseinfo
$SqlAdapter.SelectCommand=$sqlcmd

try {
$SqlAdapter.Fill($DataSet)
Write-Host "Successfull get Base Info from temporary backup`n"
}
catch {
[string](Get-Date) + "Failed get Base Info from temporary backup" >> $TempPath\log.txt
Get-Date >> $TempPath\log.txt 
$_ >> $TempPath\log.txt
Write-Host $_
}

$NameBase=$Dataset.Tables[0].Rows[1].LogicalName
$NameLog=$Dataset.Tables[0].Rows[2].LogicalName




$sqlrescopydatabase="RESTORE DATABASE [TempDB_new] FROM DISK = N'$TempPath\copy.bak' WITH RECOVERY, FILE=1, MOVE '$NameBase' TO '$Datapath+Copy1.mdf', MOVE '$NameLog' TO '$LogPath+Copy1_log.ldf';"

$sqlCmd.CommandText=$sqlrescopydatabase
$SqlAdapter.SelectCommand.CommandTimeout=0
$SqlAdapter.SelectCommand=$sqlcmd



try {
$SqlAdapter.Fill($DataSet)
Write-Host "Successfull Restore from backup to temp database`n"
}
catch {
[string](Get-Date) + "Failed Restore from backup to temp database" >> $TempPath\log.txt
Get-Date >> $TempPath\log.txt 
$_ >> $TempPath\log.txt
Write-Host $_
}


$SqlConnection.Close()


#WORK WITH TEMP DATABASE#

$SqlConnectionTemp = New-Object System.Data.SqlClient.SqlConnection
$SqlConnectionTemp.ConnectionString = "Server=$server;Database=TempDB_new;Integrated Security=False;User=$SQLUsername;Password=$SQLPassword"
$SqlCmd1 = New-Object System.Data.SqlClient.SqlCommand
$SqlAdapter1 = New-Object System.Data.SqlClient.SqlDataAdapter

$SqlEmail="UPDATE dbo.Partners SET Email = REPLACE (Email, SUBSTRING(Email, 2, CHARINDEX('@', Email)-2), REPLICATE('*',CHARINDEX('@', Email)-2 ));
UPDATE dbo.Partners SET Email = REPLACE (Email, SUBSTRING(Email, CHARINDEX('@', Email)+1,LEN(SUBSTRING(Email, CHARINDEX('@', Email)+1, len(email)))-2), REPLICATE('*', LEN(SUBSTRING(Email, CHARINDEX('@', Email)+1, len(Email)))-3));"

$SqlCmd1.Connection = $SqlConnectionTemp
$SqlCmd1.CommandText = $SqlEmail


$SqlAdapter1.SelectCommand = $SqlCmd1

$SqlAdapter1.SelectCommand.CommandTimeout=0
$DataSet = New-Object System.Data.DataSet

try {
$SqlAdapter1.Fill($DataSet)
Write-Host "Successfull update Email in dbo.Partners`n"
}
catch {
[string](Get-Date) + "Failed Update Email in dbo.Partners" >> $TempPath\log.txt
$_ >> $TempPath\log.txt
Write-Host $_
}



$Sqlpass="UPDATE dbo.Partners SET PasswordHash=0xB17C2531FF43FA293A6238B2ABB05797AB8A070384FCFF82E8F746381C36B019;
UPDATE dbo.Partners SET SaltHash=0x743536396F5135364E304254727441312B794A706270306263736953536A4F7A46673378754532635A6C5A56544C503030595736714A6C543171684F74512F2F6574633D;"
$SqlCmd1.CommandText=$Sqlpass

$SqlAdapter1.SelectCommand.CommandTimeout=0
$SqlAdapter1.SelectCommand=$SqlCmd1

try {
$SqlAdapter1.Fill($DataSet)
Write-Host "Successfull update PasswordHash in dbo.Partners`n"
}
catch {
[string](Get-Date) + "Failed Update PasswordHash in dbo.Partners" >> $TempPath\log.txt
$_ >> $TempPath\log.txt
Write-Host $_
}


$Sqlphone="UPDATE dbo.Phones SET CityOrOperatorCode=REPLACE (CityOrOperatorCode, SUBSTRING(CityOrOperatorCode, CHARINDEX('(', CityOrOperatorCode)+1, CHARINDEX(')', CityOrOperatorCode)-2), REPLICATE('*', LEN(CityOrOperatorCode)-2));
UPDATE dbo.Phones SET PhoneNumber=REPLACE (PhoneNumber, SUBSTRING(PhoneNumber, 1, len(PhoneNumber)-2), REPLICATE('*', LEN(PhoneNumber)-2));
UPDATE dbo.Phones SET CountryCode =REPLACE (CountryCode, SUBSTRING(CountryCode, 3, len(CountryCode)-2), REPLICATE('*', LEN(CountryCode)-2));
"
$SqlCmd1.CommandText=$Sqlphone
$SqlAdapter1.SelectCommand.CommandTimeout=0
$SqlAdapter1.SelectCommand=$SqlCmd1

try {
$SqlAdapter1.Fill($DataSet)
Write-Host "Successfull update Phone in dbo.Phones`n"
}
catch {
[string](Get-Date) + "Failed Update Phone in dbo.Phones" >> $TempPath\log.txt
$_ >> $TempPath\log.txt
Write-Host $_
}



$SqlAddress="
UPDATE dbo.Addresses SET PostalCode = REPLICATE('*', LEN(PostalCode));
UPDATE dbo.Addresses SET Street = REPLICATE('*', LEN(Street));
UPDATE dbo.Addresses SET House = REPLICATE('*', LEN(House));
UPDATE dbo.Addresses SET Building = REPLICATE('*', LEN(Building));
UPDATE dbo.Addresses SET FlatOrOffice = REPLICATE('*', LEN(FlatOrOffice));
UPDATE dbo.Addresses SET AddressAdditional = REPLICATE('*', LEN(AddressAdditional));
UPDATE dbo.Addresses SET ImportedAddress = REPLICATE('*', LEN(ImportedAddress));
"
$SqlCmd1.CommandText=$SqlAddress
$SqlAdapter1.SelectCommand.CommandTimeout=0
$SqlAdapter1.SelectCommand=$SqlCmd1

try {
$SqlAdapter1.Fill($DataSet)
Write-Host "Successfull update Address in dbo.Address`n"
}
catch {
[string](Get-Date) + "Failed Update Address in dbo.Address" >> $TempPath\log.txt
$_ >> $TempPath\log.txt
Write-Host $_
}

$Sqlfio="UPDATE dbo.Partners SET LastName = REPLICATE('*', LEN(LastName));
UPDATE dbo.Partners SET FirstName = REPLICATE('*', LEN(FirstName));
UPDATE dbo.Partners SET MiddleName = REPLICATE('*', LEN(MiddleName));
UPDATE dbo.Partners SET Passport = REPLICATE('*',len(Passport));
"
$SqlCmd1.CommandText=$Sqlfio
$SqlAdapter1.SelectCommand.CommandTimeout=0
$SqlAdapter1.SelectCommand=$SqlCmd1

try {
$SqlAdapter1.Fill($DataSet)
Write-Host "Successfull update FirstName MiddleName LastName and Passport in dbo.Partners`n"
}
catch {
[string](Get-Date) + "Failed Update FirstName MiddleName LastName and Passport in dbo.Partners" >> $TempPath\log.txt
$_ >> $TempPath\log.txt
Write-Host $_
}



$sqldelwaremail="UPDATE dbo.DeliveryWarehouse SET WarehouseEmail =  REPLACE (WarehouseEmail, SUBSTRING(WarehouseEmail, 2, CHARINDEX('@', WarehouseEmail)-2), REPLICATE('*',CHARINDEX('@', WarehouseEmail)-2 ));
UPDATE dbo.DeliveryWarehouse SET WarehouseEmail = REPLACE (WarehouseEmail, SUBSTRING(WarehouseEmail, CHARINDEX('@', WarehouseEmail)+1,LEN(SUBSTRING(WarehouseEmail, CHARINDEX('@', WarehouseEmail)+1, len(WarehouseEmail)))-2), REPLICATE('*', LEN(SUBSTRING(WarehouseEmail, CHARINDEX('@', WarehouseEmail)+1, len(WarehouseEmail)))-3));"
$SqlCmd1.CommandText=$sqldelwaremail
$SqlAdapter1.SelectCommand.CommandTimeout=0
$SqlAdapter1.SelectCommand=$SqlCmd1
try {
$SqlAdapter1.Fill($DataSet)
Write-Host "Successfull update Email in dbo.DeliveryWarehouse`n"
}
catch {
[string](Get-Date) +"  Failed Update Email in dbo.DeliveryWarehouse" >> $TempPath\log.txt
$_ >> $TempPath\log.txt
Write-Host $_
}


$sqlfiledata="UPDATE dbo.Files SET FileData = convert(varbinary(max), '*');"
$SqlCmd1.CommandText=$sqlfiledata
$SqlAdapter1.SelectCommand.CommandTimeout=0
$SqlAdapter1.SelectCommand=$SqlCmd1
try {
$SqlAdapter1.Fill($DataSet)
Write-Host "Successfull update FileData in dbo.Files`n"
}
catch {
[string](Get-Date) +"  Failed Update FileData in dbo.Files" >> $TempPath\log.txt
$_ >> $TempPath\log.txt
Write-Host $_
}

$sqlmoneysh="UPDATE dbo.MoneySharing SET AccountNumber=REPLICATE('*', LEN(AccountNumber));"
$SqlCmd1.CommandText=$sqlmoneysh
$SqlAdapter1.SelectCommand.CommandTimeout=0
$SqlAdapter1.SelectCommand=$SqlCmd1
try {
$SqlAdapter1.Fill($DataSet)
Write-Host "Successfull update AccountNumber in dbo.MoneySharing`n"
}
catch {
[string](Get-Date) +"  Failed Update AccountNumber in dbo.MoneySharing" >> $TempPath\log.txt
$_ >> $TempPath\log.txt
Write-Host $_
}


$SqlwareEmail="UPDATE dbo.Warehouses SET Email = REPLACE (Email, SUBSTRING(Email, 2, CHARINDEX('@', Email)-2), REPLICATE('*',CHARINDEX('@', Email)-2 ));
UPDATE dbo.Warehouses SET Email = REPLACE (Email, SUBSTRING(Email, CHARINDEX('@', Email)+1,LEN(SUBSTRING(Email, CHARINDEX('@', Email)+1, len(email)))-2), REPLICATE('*', LEN(SUBSTRING(Email, CHARINDEX('@', Email)+1, len(Email)))-3));"
$SqlCmd1.CommandText = $SqlWareEmail

$SqlAdapter1.SelectCommand.CommandTimeout=0
$SqlAdapter1.SelectCommand = $SqlCmd1


try {
$SqlAdapter1.Fill($DataSet)
Write-Host "Successfull update Email in dbo.Warehouses`n"
}
catch {
[string](Get-Date) + "Failed Update Email in dbo.Warehouses" >> $TempPath\log.txt
$_ >> $TempPath\log.txt
Write-Host $_
}



$sqlappsethis="UPDATE dbo.AppSettings SET History = NULL;"

$SqlCmd1.CommandText=$sqlappsethis
$SqlAdapter1.SelectCommand.CommandTimeout=0
$sqlAdapter1.SelectCommand=$SqlCmd1

try {
$SqlAdapter1.Fill($DataSet)
Write-Host "Successfull update History in dbo.AppSettings`n"
}
catch {
[string](Get-Date) + "Failed Update History in dbo.AppSettings" >> $TempPath\log.txt
$_ >> $TempPath\log.txt
Write-Host $_
}



$sqlshrinklog="USE TempDB_new;  
ALTER DATABASE TempDB_new SET RECOVERY Simple ;
DBCC SHRINKFILE ($NameLog, 1);
ALTER DATABASE TempDB_new SET RECOVERY FULL ;
ALTER DATABASE TempDB_new SET READ_WRITE;"

$SqlCmd1.CommandText=$sqlshrinklog
$SqlAdapter1.SelectCommand.CommandTimeout=0
$sqlAdapter1.SelectCommand=$SqlCmd1

try {
$SqlAdapter1.Fill($DataSet)
Write-Host "Successfull shrink temporary database`n"
}
catch {[string](Get-Date) + "Failed shrink temporary database" >> $TempPath\log.txt
$_ >> $TempPath\log.txt
Write-Host $_
}





$sqlbackdatabase="BACKUP DATABASE [TempDB_new] TO DISK = N'$TempPath\backup.bak' WITH NOFORMAT, INIT, NAME = N'QuestDB-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, STATS = 10;"

$SqlCmd1.CommandText=$sqlbackdatabase
$SqlAdapter1.SelectCommand.CommandTimeout=0
$sqlAdapter1.SelectCommand=$SqlCmd1

try {
$SqlAdapter1.Fill($DataSet)
Write-Host "Successfull to Backup temporary database`n"
}
catch {[string](Get-Date) + "Failed to Backup temporary database" >> $TempPath\log.txt
$_ >> $TempPath\log.txt
Write-Host $_
}



$sqlremdatabase="alter database TempDB_new set single_user with rollback immediate;
USE master;
DROP DATABASE TempDB_new; "

$SqlCmd1.CommandText=$sqlremdatabase
$SqlAdapter1.SelectCommand.CommandTimeout=0
$sqlAdapter1.SelectCommand=$SqlCmd1
try {
$SqlAdapter1.Fill($DataSet)
Write-Host "Successfull to drop temporary database"
}
catch {[string](Get-Date) + "Failed to drop temporary database" >> $TempPath\log.txt
$_ >> $TempPath\log.txt
Write-Host $_
}
$SqlConnectionTemp.Close()



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





Get-Date -Format 'yyyy-MM-dd-HH-mm' -OutVariable date
while($True)
{
if
(Test-Path $TempPath\backup.bak)
{ 
 
  7zip a -tzip -mx5 -r0 $TempPath\$date"-backup".zip $TempPath\backup.bak 

  break;

}else {Sleep 10
Write-Host "Wait +10 sec to get backup file"}
} 



 #while($True)
 # {
 # if($? -like 'False')

 # {Sleep 10
 # Write-Host "Add 10 seconds" }
 # else{break;}
#}

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






$localPath=$TempPath+"\"+$date+"-backup.zip"
# Download the selected file
$sourcePath = [WinSCP.RemotePath]::EscapeFileMask($remotePath+$date+"-backup.zip")

$session.PutFiles($localpath,$sourcePath)

$session.Close()

}
catch{[string](Get-Date) + "Failed to UploadFile to FTP" >> $TempPath\log.txt
$_ >> $TempPath\log.txt
Write-Host $_
}


 while($True)
  {
  if($? -like 'False') 

  {Sleep 10
  Write-Host "Add 10 seconds to wait upload FTP" }
  else{break;}
}
Remove-Item $TempPath\backup.bak
Remove-Item $TempPath\$date"-backup".zip





Get-Date -Format 'yyyy-MM-dd-HH:mm'  

$end=Get-Date -Format 'yyyy-MM-dd-HH:mm'
$e="`n`n`n`n*****Script end to work from directory $PSScriptRoot at $end with database $database. `n*****Temp directory is $Temppath `n*****Backup file is $localPath `n`n`n`n" 
Write-Host $e
$e >> $TempPath\log.txt


$shell = New-Object -ComObject Wscript.Shell
$shell.popup("Script end")

