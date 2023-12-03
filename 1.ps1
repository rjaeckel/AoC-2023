Function Get-CalibrationValue {
    [CmdletBinding()]param(
        [Parameter(ValueFromPipeline)][String]$Line,
        [Switch]$FirstPart
    )
    begin {
        $Value = 0
        $Capture = If($FirstPart) { '(\d)' } else { '(\d|one|two|three|four|five|six|seven|eight|nine)' }
        $CaptureLeft='.*?{0}.*' -F$Capture
        $CaptureRight='.*{0}.*' -F$Capture
    }
    process {
        $start = $Line -replace $CaptureLeft, '$1'
        $end = $Line -replace $CaptureRight, '$1'
        if (-not $FirstPart) { 
            $start, $end =
                $start, $end -replace 'one',   '1' `
                             -replace 'two',   '2' `
                             -replace 'three', '3' `
                             -replace 'four',  '4' `
                             -replace 'five',  '5' `
                             -replace 'six',   '6' `
                             -replace 'seven', '7' `
                             -replace 'eight', '8' `
                             -replace 'nine',  '9'
        }
        $Value+=[int]"$start$end"
    }
    end { $Value }
}

$Demo = "two1nine|eightwothree|abcone2threexyz|xtwone3four|4nineeightseven2|zoneight234|7pqrstsixteen"
$Demo -split '\|' | Get-CalibrationValue

Get-Content "$PSScriptRoot\Input-1.txt" | Get-CalibrationValue
