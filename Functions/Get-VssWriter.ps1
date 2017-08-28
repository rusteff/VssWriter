function Get-VssWriter {
<# 
 .Synopsis
  Function to get information about VSS Writers

 .Description
  Function will parse information from VSSAdmin tool and return object containing
  WriterName, StateID, StateDesc, and LastError

 .Parameter Verbose
  Provides Verbose output which is useful for troubleshooting

 .Example
  Get-VssWriter
  This example will return a list of VSS Writers on localhost

 .OUTPUTS
  Scripts returns a PS Object with the following properties:
    WriterName  
    StateID                                                                                                                                                                                
    StateDesc                                                                                                                                                                              
    LastError    

  .Notes
    VERSION:          1.0
    NAME:             Get-VssWriter
    AUTHOR:           Rudi Steffensen
    Original script:  https://gallery.technet.microsoft.com/scriptcenter/Powershell-ScriptFunction-415e9e70
#>

    [CmdLetBinding()]
    Param(
  )
    
    $Writers = @()
        try {
            Write-Verbose "Getting VssWriter information from computer"
            $RawWriters = Invoke-Command -ErrorAction Stop -ScriptBlock {return (VssAdmin List Writers)}
            if ($RawWriters -like '*Error*') {Write-Error "$($RawWriters)" -ErrorAction Stop}

            for ($i=0; $i -lt ($RawWriters.Count-3)/6; $i++) {
                $Writer = New-Object -TypeName psobject
                $Writer| Add-Member -MemberType NoteProperty -Name WriterName -Value $RawWriters[($i*6)+3].Split("'")[1]
                $Writer| Add-Member -MemberType NoteProperty -Name StateID -Value $RawWriters[($i*6)+6].SubString(11,1)
                $Writer| Add-Member -MemberType NoteProperty -Name StateDesc -Value $RawWriters[($i*6)+6].SubString(14,$RawWriters[($i*6)+6].Length - 14)
                $Writer| Add-Member -MemberType NoteProperty -Name LastError -Value $RawWriters[($i*6)+7].SubString(15,$RawWriters[($i*6)+7].Length - 15)
                $Writers += $Writer 
            }
            Write-verbose "Done"
            return $Writers
        } catch {
            $_
        }
    }