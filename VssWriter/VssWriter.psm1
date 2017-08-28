Set-StrictMode -Version Latest
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

# Internal Functions
. $here\Functions\Get-VssWriter.ps1
. $here\Functions\Invoke-Downtime.ps1
. $here\Functions\Restart-VssWriter.ps1

$functionsToExport = @(
    'Get-VssWriters',
    'Invoke-Downtime',
    'Restart-VssWriter'
)

Export-ModuleMember -Function $functionsToExport