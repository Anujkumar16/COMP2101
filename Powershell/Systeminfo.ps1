function hardwareInfo
{
" System Hardware Description"
get-ciminstance win32_computersystem |
foreach{ 
New-Object -Typename psobject -property @{Description=$_.Description
                                          
}} | 
format-list Description
}
hardwareInfo
"*******************************************************"
function OperatingsysInfo{
"Operating System Name and Version"
get-ciminstance win32_operatingsystem | 
foreach{
New-Object -Typename psobject -Property @{
                        Name=$_.Caption
					    Version=$_.Version}

}|Format-list Name, Version
}
OperatingsysInfo

"*********************************************************"
function ProcessorInfo{
"Processor Description"
get-ciminstance win32_processor |
foreach {
new-object -typename psobject -property @{
                                          Description=$_.Description
                                          Numberofcores=$_.NumberOfCores                                         
                                                     
                                          L1CacheSize=if($_.L1CacheSize -eq $empty)
                                                            {"Data Unavailable"}
                                                            else {$_.L1CacheSize/1Mb}
                                          L2CacheSize=if($_.L1CacheSize -eq $empty)
                                                            {"Data Unavailable"}
                                                            else {$_.L2CacheSize/1Mb}
                                          L3CacheSize=if($_.L1CacheSize -eq $empty)
                                                            {"Data Unavailable"}
                                                            else {$_.L3CacheSize/1Mb}                                             
                                          }
 }|format-list Description, NumberOfCores, L1CacheSize, L2CacheSize, L3CacheSize
 }
ProcessorInfo
"****************************************************************"
Function RAMSummary{
"RAM Summary"
$totalcapacity=0
get-ciminstance win32_physicalmemory | 
foreach {
New-object -TypeName psobject -property @{Vendor=$_.Manufacturer
                                          Description=$_.Description
                                          "Size(Mb)"=$_.Capacity/1mb
                                          Bank=$_.Banklabel
                                          Slot=$_.devicelocator
                                          }
                                          $totalcapacity+=$_.Capacity/1mb
                                          }|
Format-table Vendor, Description, "Size(Mb)", Bank, Slot
"Total RAM: $totalcapacity Mb"
}
RAMSummary
"****************************************************"
function physicaldisk{
"Summary of physical disk drives"
$diskdrives = Get-CIMInstance win32_diskdrive

  foreach ($disk in $diskdrives) {
      $partitions = $disk|get-cimassociatedinstance -resultclassname win32_diskpartition
      foreach ($partition in $partitions) {
            $logicaldisks = $partition | get-cimassociatedinstance -resultclassname win32_logicaldisk
            foreach ($logicaldisk in $logicaldisks) {
                     new-object -typename psobject -property @{Manufacturer=$disk.Manufacturer
                                                               Location=$partition.deviceid
                                                               Drive=$logicaldisk.deviceid
                                                               "Size(GB)"=$logicaldisk.size / 1gb -as [int]
                                                               }
                                                              
           }
      }
  } 
  }
physicaldisk
"*******************************************************************************"
function Adapterconf{
"Network Adapter Configuration"
Get-Ciminstance Win32_NetworkAdapterConfiguration | where-object IPenabled |
foreach{
new-object -typename psobject -property @{Description=$_.Description
                                           Index=$_.Index
                                           SubnetMask=$_.IPSubnet
                                           DNSDomainName=$_.DNSHostName
                                           DNSServer=$_.DNSServerSearchOrder
                                           IPAddress=$_.IPAddress 
                                           }
                                           }| format-table Description, Index, DNSDomainName, DNSServer, IPAddress
                    }
Adapterconf
"********************************************************************************"
function videocard{
"video card Info"
Get-wmiobject -class win32_videocontroller | 
foreach {
$Vertical=$_.CurrentVerticalResolution -as [string]
$Horizontal=$_.CurrentHorizontalResolution -as [string]
$CurrentReso=$Horizontal+"x"+$Vertical
New-Object -TypeName psobject -Property @{ Vendor=if($_.Manufacturer -eq $empty)
                                                       {"Data Unavailable"}
                                                       else{$_.Manufacturer}
                                          
                                          Description=$_.Description
                                          "CurrentVideoResolution"=$CurrentReso
                                          }
                                          

         }| format-list Vendor, Description, "CurrentVideoResolution"
        }

videocard
         