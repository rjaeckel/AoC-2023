Function Test-NavigationNetwork {
    [CmdletBinding()]param(
        [Parameter(ValueFromPipeline)]$Line,
        [Switch]$Part1
    )
    begin {
        $Directions=''
        $Nodes = @{}
        $L=[char]'L'
        $R=[char]'R'
        $a2z = '([0-9A-Z]{3})'
        $NodeMatch = '^{0}\s=\s\({0},\s{0}\)' -F $a2z
    }
    process {
        switch -Regex ($Line) {
            '^([RL]+)$' { $Directions=$Matches[1] }
             $NodeMatch { $Nodes[$Matches[1]]=@{
                $L=$Matches[2]
                $R=$Matches[3]
             }}
        }
    }
    end {
        $C=$Directions.Length
        if($Part1) {
            $Start='AAA'
            $End='ZZZ'
            $Moves=0
            $Location = $Start
            while ($Location -ne $End) {
                $Move = $Directions[$Moves++ % $C]
                $Location = $Nodes.$Location.$Move
            }
            "Part1: $Moves"
        } else {
            $Locations = $Nodes.Keys |? {$_[2] -eq 'A'}
            $Primes = <#2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,#>53,59,61,67,71,73,79 #,83,89,97,101,103,107,109,113,127,131,137,139,149,151,157
            # Find Least common_multiple
            $Factors = @{}
            $Locations |% {
                $Moves = 0
                $Location = $_
                Write-Host -ForegroundColor Yellow -NoNewline "$Location->"
                while($Location[2] -ne 'Z') {
                    $Move = $Directions[$Moves++ % $C]
                    $Location = $Nodes.$Location.$Move
                }
                Write-Host -ForegroundColor Green "$Location $Moves"
                $primes|% {
                    $n = 0
                    while ($Moves % $_ -eq 0) { $n++; $Moves=$Moves/$_}
                    if($n -and $Factors.$_ -lt $n) { $Factors.$_=$n }
                }
                if($Factors.$Moves -lt 1) { $Factors.$Moves=1 }
            }
            $product = 1
            $Factors.GetEnumerator() |% {
                $product *= [Math]::Pow($_.Key,$_.Value)
                Write-Host -ForegroundColor Cyan ('{0} ^ {1}' -F $_.Key,$_.Value)
            }
            "Part2: $product"
        }
    }
}

$Demo = @"
LLR

AAA = (BBB, BBB)
BBB = (AAA, ZZZ)
ZZZ = (ZZZ, ZZZ)
"@
#$Demo -split '\r\n' | Test-NavigationNetwork -Part1

Get-Content "$PSScriptRoot\Input-8.txt" | Test-NavigationNetwork -Part1

$Demo2 = @"
LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)
"@
#$Demo2 -split '\r\n' | Test-NavigationNetwork

Get-Content "$PSScriptRoot\Input-8.txt" | Test-NavigationNetwork
