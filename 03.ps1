Function Get-EngineParts {
    [CmdletBinding()]param(
        [Parameter(ValueFromPipeline)][String]$Line
    )
    begin {
        $Tokens = New-Object System.Collections.ArrayList
        $Numbers = New-Object System.Collections.ArrayList
    }
    process {
        $left=0;
        $NumbersInLine = $Line -split '([\d]+)|(\.+)|([^\d\.])' -ne '' |% {
            [string]$token = $_
            Switch -Regex ($_) {
                '\d+' { @{
                    line = $Numbers.Count
                    left = $left
                    right = $left + $token.Length -1
                    Number = [int]$token
                }}
                '[^\d.]' { $Tokens.Add(@{
                    top=$Numbers.Count
                    left=$left
                }) }
            }
            $left+=$token.Length
        }
        $Numbers.Add($NumbersInLine) > $null
    }
    end {
        $SumGears = 0
        $SumNumbers = 0
        $Tokens |% {
            $l,$r,$t,$b = ($_.left -1), ($_.left +1), ($_.top -1), ($_.top +1)
            if($t -lt 0) {$t=0}
            if($b -eq $Numbers.Count) {$b-=1}
        
            $GearValue=1
            $NumGears=0;

            $Numbers[$t..$b] | % {$_} |
                ? { ($_.right -le $r -and $_.right -ge $l) -or
                    ($_.left -le $r -and $_.left -ge $l)
                } |
                % {
                    $SumNumbers += $_.Number
                    If(++$NumGears -le 2) {$GearValue *= $_.Number }
                }
            If($NumGears -eq 2) { $SumGears += $GearValue }
        }
        "$SumNumbers $SumGears"
    }
}

$Demo = @"
467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..
"@
$Demo -split '\r\n' | Get-EngineParts

Get-Content "$PSScriptRoot\Input-3.txt" | Get-EngineParts
