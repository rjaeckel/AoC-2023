Function Test-Games {
    [CmdletBinding()]param(
        [Parameter(ValueFromPipeline=$true)][String]$Game
    )
    Begin {
        $SumValidIDs = 0;
        $SumPowers = 0;
    }
    Process {
        $max = @{ red=0; green=0; blue=0 }
        [int]$GameId,[string[]]$Grabbed = $Game -replace '^Game ','' -split '[:;,]\s'
        $Grabbed | % {
            [int]$Count,[string]$Color = $_ -split ' ';
            if ($Count -gt $max[$Color]) { $max[$Color] = $Count }
        }
        $SumValidIDs += If (($max['red'] -gt 12) -or ($max['green'] -gt 13) -or ($max['blue'] -gt 14)) { 0 } else { $GameId }
        $SumPowers += $max['red']*$max['green']*$max['blue']
    }
    End { "$SumValidIDs $SumPowers" }
}

$Demo = @"
Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
"@
$Demo -split '\r\n' | Test-Games

Get-Content "$PSScriptRoot\Input-2.txt" | Test-Games