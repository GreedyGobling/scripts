@echo off
:: Get URL from clipboard
for /f "usebackq delims=" %%i in (`powershell -command "Get-Clipboard"`) do set URL=%%i

:: Launch Zen Browser in private mode with the copied URL
start "" "C:\Program Files\Zen Browser\zen.exe" -private-window "%URL%"
