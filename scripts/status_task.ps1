# scripts/status_task.ps1
param(
  [string]$TaskName = "MiniETL Nightly"
)

# Search the task
$task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue

if (-not $task) {
    Write-Host "Status: no scheduled task named '$TaskName' (not configured)."
    exit 0
}


schtasks /Query /TN $TaskName /V /FO LIST
exit 0
