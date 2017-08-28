<#
.SYNOPSIS
 Script that will restart failed vsswriters and there depended services
.DESCRIPTION
 The script checks vsswriters and will restart any writers that are not in stable state och have errors
 It will alsow put the server in downtime wile restarting rervices and afterwards check if any vsswriters got unregisterd 
.PARAMETER Verbose
 Provides Verbose output which is useful for troubleshooting
.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>
.INPUTS
  None
.OUTPUTS
  None
.NOTES
  Version:        1.0
  Author:         Rudi Steffensen
  Creation Date:  <Date>
  Purpose/Change: Initial script development
#>

[CmdletBinding()]
Param()

Import-Module VssWriter

$service= Get-Service "TSM Client Scheduler"
if ($service.Status -eq "Running") {
    Write-Verbose "$($service.Name) is running, stopping serivce"
    Stop-Service $service}
else{Write-Verbose "$($service.Name) Not running"}

if($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) {"verb=true";$verb=$true}
else {"verb=false";$verb=$false}

$vsswriters = Get-VssWriter -Verbose:$verb
$failedvsswriters = $vsswriters | where-object {$_.StateID -ne "1" -or $_.LastError -ne "No error"} 

if (!$failedvsswriters) {Write-Verbose "No VssWriters failed"}

else{
    Try{
        #Puts the host and services in downtime
        Invoke-Downtime -user Powershell -comment "Downtime for restarting vsswriters" -Verbose:$verb
        #Restarts failed vsswriters
        $failedvsswriters | ForEach-Object {Restart-VssWriter -Name $_.WriterName -Verbose:$verb}
        #Lists all Vsswriters after restarting
        $vsswriters2 = Get-VssWriter -Verbose:$verb
        #Checks if any VssWriters are missing
        $c = Compare-Object -ReferenceObject $vsswriters.WriterName -DifferenceObject $vsswriters2.WriterName -PassThru
        if($c) {Write-Error "$($c) Is missing"}
        }
        catch{
          $Error | Out-File "C:\dcsto\scripts\fixvsswriters.log" -Append
      }
}