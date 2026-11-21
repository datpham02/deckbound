param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$RunnerArgs
)

$godotBin = if ($env:GODOT_BIN) { $env:GODOT_BIN } else { "godot" }
$commandArgs = @("--headless", "--path", ".", "--scene", "res://tests/test_runner.tscn", "--")
$commandArgs += $RunnerArgs

$logFile = [System.IO.Path]::GetTempFileName()
& $godotBin @commandArgs *>&1 | Tee-Object -FilePath $logFile | Out-Host
$exitCode = $LASTEXITCODE
$outputText = Get-Content -Path $logFile -Raw
Remove-Item -Path $logFile -Force

if ($exitCode -ne 0 -or $outputText -match "Result: FAILED") {
  exit 1
}

exit 0
