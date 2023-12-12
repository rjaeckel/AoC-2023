Function Test-CamelCards {
    [CmdletBinding()]param(
        [Parameter(ValueFromPipeline)]$Hand
    )
    begin {
        $Hands = [System.Collections.ArrayList]@()
        $J=[char]'J'
    }
    process {
        If($Hand -match '^(\w{5})\s+(\d+)$') {
            $Cards, [int]$Bid = $Matches[1,2]
            $enum = $Cards[0..4] |% -Begin { $x = @{"0"=0; $J=0} } -End { $x } {
                #$_.GetType().Name | Write-Host -ForegroundColor Green
                $x.$_=If($x.ContainsKey($_)) {1 + $x.$_ } else { 1 }
            }
            #AKQJT9..2 => SRQPO9..2
            $Values = $Cards -replace 'A','S' -replace 'K','R' -replace 'J','P' -replace 'T','O'
            [int]$Strength = ($enum.Values | Sort-Object -Descending)[0,1] -join ''

            $Values2 = $Values -replace 'P','1'

            $Jokers = $enum[$J]
            $enum.Remove($J)

            $l,$r = ($enum.Values + @(0) | Sort-Object -Descending)[0,1]
            [int]$Strength2 = ($l+$Jokers),$r -join ''

            $Hands.Add([PSCustomObject]@{
                Cards = $Cards
                Bid = $Bid

                Strength = $Strength
                Values = $Values

                Strength2 = $Strength2
                Values2 = $Values2
            }) >$null
        }
    }
    end {
        $rank = $Hands.Count
        $Hands |Sort-Object -Descending Strength,Values |% { ($rank--)*$_.Bid } | Measure-Object -Sum | Select-Object -ExpandProperty Sum
        
        $rank = $Hands.Count
        $Hands |Sort-Object -Descending Strength2,Values2 |% { ($rank--)*$_.Bid } | Measure-Object -Sum | Select-Object -ExpandProperty Sum
    }
}

$Demo = @"
32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483
"@
$Demo -split '\r\n' | Test-CamelCards
<#
@"
AAAAA 2
22222 3
AAAAK 5
22223 7
AAAKK 11
22233 13
AAAKQ 17
22234 19
AAKKQ 23
22334 29
AAKQJ 31
22345 37
AKQJT 41
23456 43
"@ -split '\r\n' | Test-CamelCards
#>

Get-Content "$PSScriptRoot\Input-7.txt" | Test-CamelCards
