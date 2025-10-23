# scripts/unregister_task.ps1
param(
  [string]$TaskName = "MiniETL Nightly"
)

$task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if ($task) {
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
    Write-Host "Task '$TaskName' removed."
} else {
    Write-Host "Task '$TaskName' not found (nothing to remove)."
}
exit 0
