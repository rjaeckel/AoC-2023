function Test-Races {
    [CmdletBinding()]param (
        [Parameter(ValueFromPipeline)]$Line
    )
    begin {
        $Data = [ordered]@{}
    }
    process {
        switch -Regex ($Line) {
            '^(\w+):\s+((?:\d+\s*)+)' { [int[]]$Data[$Matches[1]]=$Matches[2] -split '\s+' }
        }
    }
    end {
        $k, $margins = 0, 1
        $Data.Time |% { $margins *= Get-margin $_ $Data.Distance[$k++] }
        $margins
        # part 2
        [uint64]$Time=$Data.Time -join ''
        [uint64]$Distance=$Data.Distance -join ''
        Get-Margin $Time $Distance
    }
}
function Get-Margin {
    param ($Time,$Distance)
    <#
        d = (t - x) * x -> d = tx - x² -> 0 = -x² + tx - d
        x = (-t ± sqrt(t² + (-4)*(-1)*(-d)) ) / (2*(-1))
        x = (t ± sqrt(t² - 4d)) / 2
        (t² = evil)
        x = (t ± sqrt(t - 2sqrt(d)) * sqrt(t + 2(sqrt(d)) ) / 2
    #>
    $sqrtDist = [Math]::Sqrt($Distance)
    
    $sqrt = [Math]::Sqrt($Time - 2*$sqrtDist) * [Math]::Sqrt($Time + 2*$sqrtDist)
    $left = [Math]::Ceiling(($Time-$sqrt)/2)
    $right = [Math]::Floor(($Time+$sqrt)/2)
    [int]$Count=$right-$left+1
    $Count
    # some testing:
    # count = 1+ (t+s)/2 - (t-s)/2 = 1+(t-t+s+s)/2 = 1+s
    # $mT = $Time % 2 #-1
    # Write-Host -ForegroundColor Green $Count,$left,$right,($sqrt+1)
}

$Demo = @"
Time:      7  15   30
Distance:  9  40  200
"@
$Demo -split '\r\n'|Test-Races

Get-Content "$PSScriptRoot\Input-6.txt" | Test-Races
