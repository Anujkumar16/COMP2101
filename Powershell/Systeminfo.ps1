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
get-ciminstance win32_computersystem | 
foreach{
New-Object -Typename psobject -property @{Name=$_.Name
					  Version=switch($_.Version)
{
empty{"Data unavailable"}
default{$_.version}
}

}}|
Format-list Name, Version
}
OperatingsysInfo
"*********************************************************"
function ProcessorInfo{
"Processor Description"
get-ciminstance win32_processor |
foreach {
new-object -typename psobject -property @{Description=switch($_.Description)
				                                 	 {empty{"Data Unavailable"}
                                                      default{$_}                                            
                                                     }
                                          Numberofcores=switch($_.NumberOfCores)
				                                 	 {empty{"Data Unavailable"}
                                                      default{$_}                                            
                                                     }
                                          L1CacheSize=switch($_.L1CacheSize)
				                                 	 {empty{"Data Unavailable"}
                                                      default{$_}                                            
                                                     }
                                          L2CacheSize=switch($_.L2CacheSize)
				                                 	 {empty{"Data Unavailable"}
                                                      default{$_}                                            
                                                     }
                                          L3CacheSize=switch($_.L3CacheSize)
				                                 	 {empty{"Data Unavailable"}
                                                      default{$_.L3CacheSize}                                            
                                                     }
                                          }
 }|
format-list Description, NumberOfCores, L1CacheSize, L2CacheSize, L3CacheSize
}
ProcessorInfo
"****************************************************************"
Function RAMSummary{
"RAM Summary"
$totalcapacity=0
get-ciminstance win32_physicalmemory | 
foreach {
New-object -TypeName psobject -property @{Manufacturer=$_.Manufacturer
                                          Description=$_.Description
                                          "Size(MB)"=$_.Capacity/1mb
                                          Bank=$_.Banklabel
                                          Slot=$_.devicelocator
                                          }
                                          $totalcapacity+=$_Capacity/1mb
                                          }|
Format-table Manufacturer, Description, "Size(MB)", Bank, Slot
"Total RAM:${totalcapacity}MB"
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
Get-CimInstance win32_videocontroller | 
foreach {
New-Object -TypeName psobject -Property @{ Vendor=$_.Name
                                          Description=$_.Description
                                          Verticalpixels=$_.CurrentVerticalResolution
                                          Horizontalpixels=$_.CurrentHorizontalResolution
                                          Currentvideoresolution=$_.VideoModeDescription
                                          }

         }| format-list Vendor, Description, Horizontalpixels, Verticalpixels, Currentvideoresolution 
         
        }

videocard
         

