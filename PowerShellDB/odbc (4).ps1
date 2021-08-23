Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

if (-not $Global:DbSessions ) { $Global:DbSessions = @{}  }


function Get-Data{
   param(
   [Parameter(Position = 0)]
   [string]$path,
   [string]$query,
   [string]$queryName,
   [string]$Connection
   )
   
   $conn = New-Object System.Data.Odbc.OdbcConnection
   
   Write-host $Connection
   $conn.ConnectionString = $Connection
   $conn.open()
   $DBCommand=New-object System.Data.Odbc.OdbcCommand($query,$conn)
   Write-Host "CConnection opened"


   $resTable = New-Object("System.Data.DataTable")
   ## GETTING DATA
   $limit=100000
   $count=0
   $currentcount=0
   $outFile = "$path"
   Write-Host "Export to csv"

   $rdr = $DBCommand.ExecuteReader()
   $rdr.GetSchemaTable().Rows | ForEach-Object {$resTable.Columns.Add($_.ColumnName) | out-null}
   while ($rdr.read()){

   $outputpath="C:\briq\allen\out_"+$count+".csv"
   $newrow=$resTable.Rows.Add(($resTable.Columns | ForEach-Object {$rdr[$_]} ))

   
   if($currentcount -eq $limit){
         $count+=1
         $currentcount=0
      $resTable | Export-csv -Path $outputpath -Append
      $resTable.Rows.Clear()
      }
   else{

      $currentcount+=1
      
   }
   

}
   $conn.Close()
   ## EXPORT TO CSV
Write-Host "Connecion closed"
   
   	
  
   
}

if ($env:Processor_Architecture -ne "x86")
{ write-warning "Launching x86 PowerShell"

&"$env:windir\syswow64\windowspowershell\v1.0\powershell.exe" -noninteractive -noprofile -file $myinvocation.Mycommand.path -executionpolicy bypass
exit
}
"Always running in 32bit PowerShell at this point."
$env:Processor_Architecture






Get-Data -path "C:\briq\allen_construction\oracle_briq_database_create_timberlinedatasource_validate\output\extracts\JCT_CURRENT__TRANSACTION.csv" -query "select * from JCT_CURRENT__TRANSACTION" -queryName "JCT_CURRENT__TRANSACTION" -Connection "DSN=TimberlineDataSource;DatabaseType=1;DictionaryMode=0;MaxColSupport=1536;ShortenNames=0;StandardMode=1;UID=BRIQ;PWD=mU83`$n4v8eFV"
