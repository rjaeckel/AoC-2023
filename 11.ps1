Function Test-Galaxies {
    [CmdletBinding()]param(
        [Parameter(ValueFromPipeline)][String]$Line,
        [Switch]$Part1
    )
    begin {
        $Map = [System.Collections.Generic.List[string]]::new()
        $Gaps = [System.Collections.Generic.List[hashtable]]::new()
        $GapDistance=if($Part1) {1} else { 999999 }
    }
    process {
        if (-not $Line.Contains('#')) {
            $Gaps.Add(@{'y'=$Map.Count})
        }
        $Map.Add($Line)
    }
    end {
        $_cols = $Map[0].Length -1
        $_rows = $Map.Count -1
        foreach($col in (0..$_cols)) {
            $_line = (0..$_rows |% { $Map[$_][$col] }) -join ''
            if(-not $_line.Contains('#')) { $Gaps.Add(@{'x'=$col}) }
        }
        $Galaxies = $Map |% -Begin {$row=0} {
            $col=0
            $_ -split '(#)' |% {
                if($_ -eq '#') {
                    @{x=$col++;y=$row}
                } else {
                    $col+=$_.Length
                }
            }
            $row+=1
        }
        0..($Galaxies.Count-1)|% {
            for(($i=$_),($j=$i+1); $j-lt$Galaxies.Count; $j++) {
                'x','y' |% {
                    $l,$r = $Galaxies[$i].$_, $Galaxies[$j].$_
                    [Math]::Abs($l-$r)
                    @($Gaps.$_|? {$_ -in $l..$r}).Count*$GapDistance
                }
            }
        } | Measure-Object -Sum | Select-Object -ExpandProperty Sum
    }
}

$Demo = @"
...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#.....
"@
$Demo -split '\r\n' | Test-Galaxies -Part1

#Get-Content "$PSScriptRoot\Input-11.txt" | Test-Galaxies