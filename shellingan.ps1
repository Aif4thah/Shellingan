function Invoke-Shellingan{
    param(
        [Parameter(Mandatory=$true, Position=0)]
        $cmd,
        [Parameter(Mandatory=$false, Position=1)]
        [System.Boolean] $iex,
        [Parameter(Mandatory=$false, Position=2)]
        [int] $recurse
    )
    
    if($rot -eq $null){
    Write-Host "<O> SHELLINGAN : Simple Recursive Powershell Command Obfuscation - for training purpose" -ForegroundColor DarkRed
    Write-Host "|" -ForegroundColor DarkRed
    Write-Host "<cmd> : $cmd" -ForegroundColor DarkRed
    Write-Host "<iex> : $iex" -ForegroundColor DarkRed
    Write-Host "<rec> : $recurse" -ForegroundColor DarkRed
    Write-Host "|" -ForegroundColor DarkRed
    }

    #random UPPER-lower function
    function rul($in){
        $array = $in.Toupper(),$in.ToLower()
        for($i=0; $i -lt $in.length; $i++){
            $output += ($array[(get-random -min 0 -max 2)][$i]).ToString()
        }
        return $output
    }

    #byte rotation
    $cmd = rul($cmd)
    [byte[]] $scriptBytes = [system.Text.Encoding]::UTF8.GetBytes($cmd)    
    $rot = Get-Random -Maximum 254 -Minimum 5
    $derot = 255 - $rot
    $rotbytes = [system.Text.Encoding]::UTF8.GetBytes('')
    $scriptBytes |%{ $rotbytes += ($_ + $rot)%255}

    #tostring
    $output = ""
    $rotBytes |%{$output += $_.tostring()+ ","}
    $output = $output -replace ".$"

    #payload generation
    $rand1 = Get-Random -Maximum 254 -Minimum 5 ; $rand2 = Get-Random -Maximum 254 -Minimum 5 ; $rand3 = Get-Random -Maximum 254 -Minimum 5
    $output =  "`$$rand2=255;`$$rand1=[sYsTeM.TeXT.eNcOdInG];`$$rand3=`$$rand1::utF8.gEtbYtES('');`$$rand1::asCii.gEtsTRiNG(`$(([bYtE]" + $output + ")|%{`$$rand3+=(`$_+(`$$rand2+$derot))%`$$rand2};`$$rand3))"
    
    #options
    if($iex){$output+= "|iex"}
    if($recurse -gt 1){Invoke-Shellingan $output $iex ($recurse-=1)  }
    else{
        write-host -ForegroundColor DarkRed "<O> SHELLINGAN:"
        return rul($output)
    }
}
