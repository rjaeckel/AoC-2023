Function Get-CalibrationValue {
    [CmdletBinding()]param(
        [Parameter(ValueFromPipeline=$true)][String]$Line
    )
    begin {
        $Value = 0
        $Capture = '(\d|one|two|three|four|five|six|seven|eight|nine)'
    }
    process {
        $start = $Line -replace ('.*?{0}.*' -F$Capture), '$1'
        $end = $Line -replace ('.*{0}.*' -F$Capture), '$1'

        $start, $end = $start, $end -replace 'one',   '1' `
                                    -replace 'two',   '2' `
                                    -replace 'three', '3' `
                                    -replace 'four',  '4' `
                                    -replace 'five',  '5' `
                                    -replace 'six',   '6' `
                                    -replace 'seven', '7' `
                                    -replace 'eight', '8' `
                                    -replace 'nine',  '9'
        
        [int]$LineValue="$start$end"
        $Value+=$LineValue
    }
    end { $Value }
}

$Demo = "two1nine|eightwothree|abcone2threexyz|xtwone3four|4nineeightseven2|zoneight234|7pqrstsixteen"
$Demo -split '\|' | Get-CalibrationValue

Get-Content "$PSScriptRoot\Input-1.txt" | Get-CalibrationValue
