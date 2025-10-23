# scripts/run_task_now.ps1
param(
  [string]$TaskName = "MiniETL Nightly"
)

$task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if (-not $task) {
    Write-Host "Nothing to run: task '$TaskName' not found."
    exit 0
}

Start-ScheduledTask -TaskName $TaskName
Write-Host "Triggered '$TaskName'. Check logs/cron.log."
exit 0
