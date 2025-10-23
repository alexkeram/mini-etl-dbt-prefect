# scripts/register_task.ps1
# Registers/updates a Windows Task Scheduler job to run the ETL daily at 02:00
$ErrorActionPreference = "Stop"

# 1) Resolve runner script in the current repo
$ScriptPath = (Resolve-Path "scripts\run_etl.cmd").Path

# 2) Task properties
$TaskName  = "MiniETL Nightly"
$Schedule  = New-ScheduledTaskTrigger -Daily -At 02:00

# Run as the current user while logged on; no password prompt.
# NOTE: RunLevel must be Limited or Highest (valid enum). We'll use Limited.
$User      = "$env:USERDOMAIN\$env:USERNAME"
$Principal = New-ScheduledTaskPrincipal -UserId $User -LogonType Interactive -RunLevel Limited

# 3) Action: run our .cmd
$Action    = New-ScheduledTaskAction -Execute $ScriptPath

# 4) Replace if exists
if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
}

# 5) Register
Register-ScheduledTask -TaskName $TaskName -Trigger $Schedule -Action $Action -Principal $Principal

Write-Host "Task '$TaskName' registered to run daily at 02:00."
Write-Host "User: $User"
Write-Host "Script: $ScriptPath"
