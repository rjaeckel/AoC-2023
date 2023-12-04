Function Get-CardPoints {
    [CmdletBinding()]param(
        [Parameter(ValueFromPipeline)]$Card
    )
    begin {
        $SumCards = 0
        $TotalCards = 0
        $Copies=@{}
    }
    process {
        [string]$cardNo,[string]$wins,[string]$numbers = $Card -split '(?:(?:\s*[|:]|Card)\s+)' -ne ''
        $WinSplit = '\s+(?:{0})(?!\d)' -F ($wins -replace'\s+', '|')
        $CountWinning = (" $numbers" -split $WinSplit).Count-1
        $SumCards+=[int][Math]::Pow(2, $CountWinning-1)

        if(-not $Copies.ContainsKey($cardNo)) { $Copies += @{$cardNo=1} }
        $Totalcards+=$Copies.$cardNo

        if ($CountWinning) {
            (1+$cardNo)..($CountWinning+$cardNo) |% {
                if($Copies.ContainsKey("$_")) {
                    $Copies."$_"+=$Copies.$cardNo
                } else {
                    $Copies+=@{"$_"=$Copies.$cardNo+1}
                }
            }
        }
    }
    end { "$SumCards $TotalCards" }
}

$Demo = @"
Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
"@
$Demo -split '\r\n' | Get-CardPoints

Get-Content "$PSScriptRoot\Input-4.txt" | Get-CardPoints
