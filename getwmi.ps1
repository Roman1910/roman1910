<#import-module activedirectory
get-ADcomputer -Filter * | 
Where-Object {$a=$_.name; $_.DistinguishedName -ne "CN=$a,OU=SalonsPC,OU=компьютеры,DC=ladomed,DC=com"} | 
Sort-Object name | Select-Object name | Export-csv C:\users\chugarov\salons.csv -NoTypeInformation 

$csv=Get-content 'C:\Users\chugarov\salons.csv' 
$csv.Replace('"','').TrimStart('"').TrimEnd('"') | set-content C:\Users\chugarov\salons1.txt 
#>


$Excel = New-Object -ComObject Excel.Application
$Excel.Visible = $true
$WorkBook = $Excel.Workbooks.Add()
$Invent =$WorkBook.Worksheets.Item(1)
$Row = 2
$Column = 1

get-content C:\Users\chugarov\salons1.txt  | ForEach-Object  {

if ((Test-Connection $_ -Count 2 -Quiet) -eq "True" -and ((Get-WmiObject win32_operatingsystem  -ComputerName $_ | Select-Object Caption ).Caption -like "*Server*") )

{
$Invent.Cells.Item($Row, $Column)=$_.ToString()
$Invent.Cells.Item($Row, $Column).Interior.ColorIndex = 6
$Row++
$o=Get-WmiObject win32_operatingsystem  -ComputerName $_ 
$Invent.Cells.Item($Row, $Column)=$o.Caption
 $Row++
 $i=[system.net.dns]::Resolve($_).addresslist | select -First 1 -ExpandProperty ipaddresstostring
$Invent.Cells.Item($Row, $Column)=(Resolve-DnsName $i).NameHost
 $Row++
 $m=Get-WmiObject Win32_PhysicalMemory  -ComputerName $_ | Measure-Object -Property capacity -Sum | Select-Object @{name='sum';Expression={$_.sum/1MB}}
 $m.sum=$m.sum.ToString()+"MB RAM"
 $Invent.Cells.Item($Row, $Column)=$m.sum
 $Row++

$p=Get-WmiObject win32_Processor -Computername $_ 
 $Invent.Cells.Item($Row, $Column)=$p.name
 $Row++

 $d=Get-WmiObject win32_logicaldisk -Filter "drivetype=3" -ComputerName $_ 
 
 
$Invent.Cells.Item($Row,2) = "Drive" 
$Invent.Cells.Item($Row,3) = "Total Size (GB)" 
$Invent.Cells.Item($Row,4) = "Free Space (GB)" 
$Invent.Cells.Item($Row,5) = "Free Space (%)"
$Row++
 foreach ($objdisk in $d) 
{ 
$Invent.Cells.Item($Row, 2) = $objDisk.DeviceID 
$Invent.Cells.Item($Row, 3) = "{0:N0}" -f ($objDisk.Size/1GB) 
$Invent.Cells.Item($Row, 4) = "{0:N0}" -f ($objDisk.FreeSpace/1GB) 
$Invent.Cells.Item($Row, 5) = "{0:P0}" -f ([double]$objDisk.FreeSpace/[double]$objDisk.Size) 
$Row = $Row + 1 
} 

 
 
 
 $Row=$Row+4
}
}
$UsedRange = $invent.UsedRange
$UsedRange.EntireColumn.AutoFit() | Out-Null
$Excel.DisplayAlerts = $false
$WorkBook.SaveAs('X:\IT\4it\Инфраструктура\Servers.xlsx')
$WorkBook.Close()
$Excel.Quit()
