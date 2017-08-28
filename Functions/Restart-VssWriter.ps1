function Restart-VssWriter{
<# 
 .Synopsis
  Function to restart VssWriters

 .Description
  Function that will restart the service of a VssWriter and it`s dependent serivces
  
 .Parameter Verbose
  Provides Verbose output which is useful for troubleshooting

 .Parameter Name
  Name of the writer to be restarted
 
 .Example
  Restart-VssWriter -Name "WMI Writer"
  This will restart the WMI Writer and all it`s dependent services

 .Notes
  VERSION:   1.0
  NAME:      Restart-VssWriter
  AUTHOR:    Rudi Steffensen

#>

    [CmdLetBinding()]
    Param(
    [string]$Name = $(throw "-Name is required")
  )
 
if($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) {"verb=true";$verb=$true}
else {"verb=false";$verb=$false}

$ServiceArray = @{
'ASR Writer' = 'VSS';
'Bits Writer' = 'BITS';
'Certificate Authority' = 'EventSystem';
'COM+ REGDB Writer' = 'VSS';
'DFS Replication service writer' = 'DFSR';
'Dhcp Jet Writer' = 'DHCPServer';
'FRS Writer' = 'NtFrs';
'FSRM Writer' = 'srmsvc';
'IIS Config Writer' = 'AppHostSvc';
'IIS Metabase Writer' = 'IISADMIN';
'Microsoft Exchange Writer' = 'MSExchangeIS';
'Microsoft Hyper-V VSS Writer' = 'vmms';
'MS Search Service Writer' = 'EventSystem';
'NPS VSS Writer' = 'EventSystem';
'NTDS' = 'EventSystem';
'OSearch VSS Writer' = 'OSearch';
'OSearch14 VSS Writer' = 'OSearch14';
'Registry Writer' = 'VSS';
'Shadow Copy Optimization Writer' = 'VSS';
'Sharepoint Services Writer' = 'SPWriter';
'SPSearch VSS Writer' = 'SPSearch';
'SPSearch4 VSS Writer' = 'SPSearch4';
'SqlServerWriter' = 'SQLWriter';
'System Writer' = 'CryptSvc';
'WMI Writer' = 'Winmgmt';
'TermServLicensing' = 'TermServLicensing';
}
    try{
        if($ServiceArray.Keys -inotcontains $Name) {Write-Error "Writer $($Name) does not existe "}
        else{
            $dependtSrv = $Name | ForEach-Object {Get-Service $ServiceArray.Item($_) -DependentServices} | where-object {$_.Status -eq "Running"} | select -uniq
            if(!$dependtSrv) {Write-Verbose "No dependent services"}
            else{
                Write-Verbose "Stopping dependent services"
                $dependtSrv | ForEach-Object {Stop-Service $_.Name -Force -Verbose:$verb}
                }
            Write-Verbose "Restarts vsswriters"
            $Name | ForEach-Object {Restart-Service $ServiceArray.Item($_) -Force -Verbose:$verb}
            if ($dependtSrv) {
                Write-Verbose "Starting dependent services"
                $dependtSrv | ForEach-Object {Start-Service $_.Name -Verbose:$verb}}
            }
        }
    catch{
          $_
      }
}