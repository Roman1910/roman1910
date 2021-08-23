
function getimap ($settings){


Add-Type -Path "$PSScriptRoot\imapx.dll"



# Initialize the IMAP client

$SettingsFile = $settings
Get-Content $SettingsFile | foreach-object -begin {$h=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $h.Add($k[0], $k[1]) } }


$date=(Get-Date).ToString('dd-MMM-yyyy',[cultureinfo]::GetCultureInfo('en-US'))
$date

$server = ($h.'ServerName ').Trim()
$Port=[int](($h.'Port ').Trim())
$UseSSL= ($h.'UseSSL ').Trim()
$User=($h.'Username ').Trim()
$Password=($h.'Password ').Trim()
$folder=($h.'PathToCopy ').Trim()
$subject=($h.'Subject ').Trim()
$from=($h.'From ').Trim()
$filename=($h.'Filename ').Trim()

$client = New-Object ImapX.ImapClient
$client.Behavior.MessageFetchMode = "Full"
$client.Host =$server
$client.Port = $port
$client.UseSsl = $UseSSL
$client.Connect()
$client.Login($User,$Password)



$splits= -split $Subject
$attachs= -split $filename

$messages = $client.Folders.Inbox.Search("FROM $From SINCE $date", $client.Behavior.MessageFetchMode,  1000)

$f=$false

foreach($m in $messages){
foreach($split in $splits){
 if(($m.Subject) -match $split){
$f=$true
 }
 else
 {$f=$false
  break}}

 if ($f -eq $true){
$m.Subject +" "+ $m.Date + " " +$m.From
$a=$false
 
 foreach($r in $m.Attachments){
 foreach($attach in $attachs){
 if([string]($r.FileName) -Match $attach)
 {
 $a=$true
 }
 else {
 $a=$false
 break
 }
 }
 if ($a -eq $true){
 $r.Download()
 $r.Save($folder, $r.FileName)
 }
 
 }
}
}


}

Get-ChildItem $PSScriptRoot | ForEach-Object{


if([string]($_.Fullname) -match "imapset")
{
 
getimap("$PSScriptRoot\$_") 
}
}

