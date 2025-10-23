@echo off
setlocal enabledelayedexpansion
REM --- venv-aware ETL runner that calls MAKE ---

set "SCRIPTDIR=%~dp0"

REM 1) Find repo root
pushd "%SCRIPTDIR%\..\.."
set "REPO_ROOT=%CD%"
popd

REM 2) Ensure logs dir
if not exist "%REPO_ROOT%\logs" mkdir "%REPO_ROOT%\logs"

REM 3) OPTIONAL: ensure make is on PATH (Chocolatey default)
REM If 'make' is not found by Task Scheduler, uncomment the next line:
REM set "PATH=C:\ProgramData\chocolatey\bin;%PATH%"

REM 4) Run FROM repo root so Makefile is visible
pushd "%REPO_ROOT%"

REM 5) Call make run; log both stdout+stderr
make run >> "%REPO_ROOT%\logs\cron.log" 2>&1

popd
endlocal
