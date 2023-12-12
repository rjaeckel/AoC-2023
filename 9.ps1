Function Get-ExtrapolatedValues {
    [CmdletBinding()]param(
        [Parameter(ValueFromPipeline)]$List
    )
    begin {
        $Next = 0
        $Previous = 0
    }
    process {
        [int[]]$row = $List -split '\s'
        $level = 0
        $History=@{}
        do {
            $History+= @{$level++=$row}
            $row = 1..($row.Count-1)|% {
                $row[$_]-$row[$_-1]
            }
            #$row -join ' ' | Write-Host -ForegroundColor Cyan
        } while ($row|Measure-Object -Maximum -Minimum|? {$_.Maximum -ne $_.Minimum })
        $History.$level = $row
        $n = 0
        $p = 0
        $level..0 |% {
            $n+=$History.$_[-1]
            $p=$History.$_[0]-$p
        }
        #Write-Host -ForegroundColor Green $p
        $Next+=$n
        $Previous+=$p
    }
    end {
        $Next
        $Previous
    }
}

$Demo = @"
0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45
"@
$Demo -split '\r\n' | Get-ExtrapolatedValues

Get-Content "$PSScriptRoot\Input-9.txt" | Get-ExtrapolatedValues