[string]$gateWay = (Get-wmiObject Win32_networkAdapterConfiguration | ? {$_.IPEnabled}).DefaultIPGateway | Where-Object {$_ -match "^([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})$"}
$boastcard= ""
for($i=0; $i -lt 4; $i++){
  if($i -eq 3 ){
    $boastcard = $boastcard +"255"
  }else {
    $boastcard = $boastcard +$gateWay.Split(".")[$i]
  }
  if($i -lt 3){
    $boastcard= $boastcard +"."
  }
}

function Invoke-TSPingSweep { 
  <# 
    .SYNOPSIS 
    Scan IP-Addresses, Ports and HostNames 
 
    .DESCRIPTION 
    Scan for IP-Addresses, HostNames and open Ports in your Network. 
     
    .PARAMETER StartAddress 
    StartAddress Range 
 
    .PARAMETER EndAddress 
    EndAddress Range 
 
    .PARAMETER ResolveHost 
    Resolve HostName 
 
    .PARAMETER ScanPort 
    Perform a PortScan 
 
    .PARAMETER Ports 
    Ports That should be scanned, default values are: 21,22,23,53,69,71,80,98,110,139,111, 
    389,443,445,1080,1433,2001,2049,3001,3128,5222,6667,6868,7777,7878,8080,1521,3306,3389, 
    5801,5900,5555,5901 
 
    .PARAMETER TimeOut 
    Time (in MilliSeconds) before TimeOut, Default set to 100 
 
    .EXAMPLE 
    Invoke-TSPingSweep -StartAddress 192.168.0.1 -EndAddress 192.168.0.254 
 
    .EXAMPLE 
    Invoke-TSPingSweep -StartAddress 192.168.0.1 -EndAddress 192.168.0.254 -ResolveHost 
 
    .EXAMPLE 
    Invoke-TSPingSweep -StartAddress 192.168.0.1 -EndAddress 192.168.0.254 -ResolveHost -ScanPort 
 
    .EXAMPLE 
    Invoke-TSPingSweep -StartAddress 192.168.0.1 -EndAddress 192.168.0.254 -ResolveHost -ScanPort -TimeOut 500 
 
    .EXAMPLE 
    Invoke-TSPingSweep -StartAddress 192.168.0.1 -EndAddress 192.168.10.254 -ResolveHost -ScanPort -Port 80 
 
    .LINK 
    http://www.truesec.com 
 
    .NOTES 
    Goude 2012, TrueSec 
  #> 
  Param( 
    [parameter(Mandatory = $true, 
      Position = 0)] 
    [ValidatePattern("\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b")] 
    [string]$StartAddress, 
    [parameter(Mandatory = $true, 
      Position = 1)] 
    [ValidatePattern("\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b")] 
    [string]$EndAddress, 
    [switch]$ResolveHost, 
    [switch]$ScanPort, 
    [int[]]$Ports = @(21,22,23,53,69,71,80,98,110,139,111,389,443,445,1080,1433,2001,2049,3001,3128,5222,6667,6868,7777,7878,8080,1521,3306,3389,5801,5900,5555,5901), 
    [int]$TimeOut = 100 
  ) 
  Begin { 
    $ping = New-Object System.Net.Networkinformation.Ping 
  } 
  Process { 
    foreach($a in ($StartAddress.Split(".")[0]..$EndAddress.Split(".")[0])) { 
      foreach($b in ($StartAddress.Split(".")[1]..$EndAddress.Split(".")[1])) { 
        foreach($c in ($StartAddress.Split(".")[2]..$EndAddress.Split(".")[2])) { 
          foreach($d in ($StartAddress.Split(".")[3]..$EndAddress.Split(".")[3])) { 
            write-progress -activity PingSweep -status "$a.$b.$c.$d" -percentcomplete (($d/($EndAddress.Split(".")[3])) * 100) 
            $pingStatus = $ping.Send("$a.$b.$c.$d",$TimeOut) 
            if($pingStatus.Status -eq "Success") { 
              if($ResolveHost) { 
                write-progress -activity ResolveHost -status "$a.$b.$c.$d" -percentcomplete (($d/($EndAddress.Split(".")[3])) * 100) -Id 1 
                $getHostEntry = [Net.DNS]::BeginGetHostEntry($pingStatus.Address, $null, $null) 
              } 
              if($ScanPort) { 
                $openPorts = @() 
                for($i = 1; $i -le $ports.Count;$i++) { 
                  $port = $Ports[($i-1)] 
                  write-progress -activity PortScan -status "$a.$b.$c.$d" -percentcomplete (($i/($Ports.Count)) * 100) -Id 2 
                  $client = New-Object System.Net.Sockets.TcpClient 
                  $beginConnect = $client.BeginConnect($pingStatus.Address,$port,$null,$null) 
                  if($client.Connected) { 
                    $openPorts += $port 
                  } else { 
                    # Wait 
                    Start-Sleep -Milli $TimeOut 
                    if($client.Connected) { 
                      $openPorts += $port 
                    } 
                  } 
                  $client.Close() 
                } 
              } 
              if($ResolveHost) { 
                #Write-Host $getHostEntry -ForegroundColor Yellow
                try {
                  $hostName = ([Net.DNS]::EndGetHostEntry([IAsyncResult]$getHostEntry)).HostName
                }
                catch {
                  $hostName ="Unknow"
                } 
              } 
              # Return Object 
              New-Object PSObject -Property @{ 
                IPAddress = "$a.$b.$c.$d"; 
                HostName = $hostName; 
                Ports = $openPorts 
              } | Select-Object IPAddress, HostName, Ports 
            } 
          } 
        } 
      } 
    } 
  } 
  End { 
  } 
}


$pingSweep = Invoke-TSPingSweep -StartAddress $gateWay -EndAddress $boastcard -ResolveHost -ScanPort
#Write-Host "          " "HostName" "                      "  "IPAddress" "                      " "Port"
# for($i=0; $i -lt $pingSweep.Count; $i++){
#   Write-Host $pingSweep[$i].HostName "                  " $pingSweep[$i].IPAddress "              " "{"    $pingSweep[$i].Ports "}" -ForegroundColor Yellow
# }
$pingSweep | Format-Table -AutoSize
Read-Host "Press any key ....."





