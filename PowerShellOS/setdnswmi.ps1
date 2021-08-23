
get-content C:\Users\chugarov\salons.txt  | ForEach-Object  {
$NICs = Get-WMIObject Win32_NetworkAdapterConfiguration -computername $_ | where{$_.IPEnabled -eq $true }
$newDNSServers = "192.168.210.221","192.168.177.220"
Foreach($NIC in $NICs) {
    
    
   
    $NIC.SetDNSServerSearchOrder($newDNSServers)
    
    $NIC.SetDynamicDNSRegistration("FALSE")
}
}
