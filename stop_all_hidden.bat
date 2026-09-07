@echo off
title Stop Kotobaza (hidden)
echo Stopping server and bot (hidden mode)...
powershell -NoProfile -Command "Get-CimInstance Win32_Process -Filter \"Name='python.exe' AND (CommandLine LIKE '%%uvicorn app:app%%' OR CommandLine LIKE '%%bot.py%%')\" | ForEach-Object { taskkill /F /PID $($_.ProcessId) }"
echo Done. Kotobaza stopped.
exit /b
