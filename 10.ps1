Function Test-Pipes {
    [CmdletBinding()]param(
        [Parameter(ValueFromPipeline)][string]$Line
    )
    begin {
        $Area = [System.Collections.ArrayList]::new()
        $j='S|-LJ7F.'
        $start = $j[0]
        $StartPosition=@()

        $Junctions = @{
            $j[1]='N','S'
            $j[2]='E','W'
            $j[3]='N','E'
            $j[4]='N','W'
            $j[5]='S','W'
            $j[6]='S','E'
            $j[7]=@()
        }
        $From=@{
            'N'='S'
            'E'='W'
            'S'='N'
            'W'='E'
        }
        function N ($l,$c) { $l-1; $c }
        function S ($l,$c) { $l+1; $c }
        function E ($l,$c) { $l; $c+1 }
        function W ($l,$c) { $l; $c-1 }
        function next ($x) {
            $_line,$_char=$x.pos
            $j=$Junctions[$x.item]|? {$_ -ne $x.from}
            #"$_line|$_char {0} {1}->$j" -F $x.item,$x.from | Write-Host -ForegroundColor Green
            $_from = $From.$j
            $next = "$j $_line $_char" | Invoke-Expression
            $_item=$Area[$next[0]][$next[1]]
            @{pos=$next;item=$_item;from=$_from}
        }
    }
    process {
        $Area.Add($Line) >$null
        $hasStart=$Line.IndexOf($start)
        if($hasStart -gt -1) {
            $StartPosition=@(($Area.Count-1),$hasStart)
        }
    }
    end {
        $max = $Area.Count,$Area[0].Length
        $Left = [System.Collections.ArrayList]::new()
        $Right = [System.Collections.ArrayList]::new()
        
        $line,$char = $StartPosition
        #"$line|$char ({0}|{1})" -F $max[0],$max[1]
        $_left,$_right=@('N','E','S','W' |% {
            $_from=$From.$_
            $_line,$_char="$_ $line $char"|Invoke-Expression
            #"$_ $_line|$_char ($_from) " |Write-Host -ForegroundColor Cyan -NoNewline
            if($_line -ge 0 -and $_char -ge 0 -and
               $_line -lt $max[0] -and $_char -lt $max[1]
            ) {
                $j=$Area[$_line][$_char]
                #$j | Write-Host -ForegroundColor Green -NoNewline
                if($Junctions[$j] -contains $_from) {
                    @{
                        pos = $_line,$_char
                        item = $Area[$_line][$_char]
                        from = $_from
                    }
                #    '+' | Write-Host -ForegroundColor White
                #} else {
                #    '-' | Write-Host -ForegroundColor Red
                }
            #} else {
            #    'x' | Write-Host -ForegroundColor Red
            }
        })
        $Left.Add($_left) >$null
        $Right.Add($_right) >$null
        while(($Left[-1].pos -join '|') -ne ($Right[-1].pos -join '|')) {
            $_left = next $Left[-1]
            $Left.Add($_left)>$null
            $_right = next $Right[-1]
            $Right.Add($_right)>$null
        }
        $Right.Count
        #Part2

        $S=$Junctions.Keys|? {
            $Junctions.$_ -contains $From.($Left[0].from) -and $Junctions.$_ -contains $From.($Right[0].from)
        }
        #$S | Write-Host -ForegroundColor Green

        $_Cycle = $Right+$Left+@(@{pos=$StartPosition;item=$S})
        $Cycle = 0..($Area.Count-1) |% {
            $LineNo = $_
            $_Cycle |? {$LineNo -eq $_.pos[0]} |Sort-Object {$_.pos[1]}
        }
        ($Cycle |% {
            $_.pos -join '|'
        }) -join ' ' | Write-Host -ForegroundColor DarkGray
    }
}

$Demo = @"
7-F7-
.FJ|7
SJLL7
|F--J
LJ.LJ
"@
#$Demo -split '\r\n' | Test-Pipes

$Demo2 = @"
FF7FSF7F7F7F7F7F---7
L|LJ||||||||||||F--J
FL-7LJLJ||||||LJL-77
F--JF--7||LJLJ7F7FJ-
L---JF-JLJ.||-FJLJJ7
|F|F-JF---7F7-L7L|7|
|FFJF7L7F-JF7|JL---7
7-L-JL7||F7|L7F-7F7|
L.L7LFJ|||||FJL7||LJ
L7JLJL-JLJLJL--JLJ.L
"@
$Demo2 -split '\r\n' | Test-Pipes

#Get-Content "$PSScriptRoot\Input-10.txt" | Test-Pipes