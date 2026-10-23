@echo off
rem Double-click this file to put Mimi on a LilyGO T-CameraPlus-S3.
rem It runs flash-mimi.ps1 from the same folder, and downloads that file
rem first when it is missing. No admin rights needed.
setlocal
set "PS1=%~dp0flash-mimi.ps1"
if not exist "%PS1%" (
  echo Downloading the Mimi installer...
  powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072; $ProgressPreference = 'SilentlyContinue'; try { Invoke-WebRequest -UseBasicParsing -Uri 'https://raw.githubusercontent.com/ziadlammouri545-dev/mimi/main/tools/install/flash-mimi.ps1' -OutFile $env:PS1 } catch { }"
)
if not exist "%PS1%" (
  echo.
  echo Could not download the installer. Check that this computer is online,
  echo or download flash-mimi.ps1 from https://github.com/ziadlammouri545-dev/mimi and put it next to this file.
  echo.
  pause
  exit /b 1
)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%PS1%" %*
exit /b %ERRORLEVEL%
