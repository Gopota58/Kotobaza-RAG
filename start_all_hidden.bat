@echo off
title Kotobaza hidden launcher (server + bot)
setlocal
cd /d %~dp0

REM ---- venv (explicit path, no call activate) ----
set "PY=venv\Scripts\python.exe"
if not exist "%PY%" (
    echo Creating virtualenv...
    python -m venv venv
    set "PY=venv\Scripts\python.exe"
)

REM ---- deps (only if fastapi missing) ----
"%PY%" -c "import fastapi" 2>nul || "%PY%" -m pip install -r requirements.txt

REM ---- NOTE: embedding model download (download_model.py) is SKIPPED here.
REM      This project uses embed_provider=api (LM Studio), so the local
REM      MiniLM model is not needed. If you switch to local embeddings,
REM      run `venv\Scripts\python.exe download_model.py` once manually.

REM ---- start API server (FULLY HIDDEN window) ----
echo Starting API server (hidden)...
powershell -NoProfile -Command "Start-Process -FilePath 'venv\Scripts\python.exe' -ArgumentList '-m','uvicorn','app:app','--host','0.0.0.0','--port','8000' -WindowStyle Hidden -WorkingDirectory '%~dp0'"

REM ---- wait for server to come up ----
timeout /t 6 /nobreak >nul

REM ---- start Telegram bot (FULLY HIDDEN window) ----
echo Starting Telegram bot (hidden)...
powershell -NoProfile -Command "Start-Process -FilePath 'venv\Scripts\python.exe' -ArgumentList 'bot.py' -WindowStyle Hidden -WorkingDirectory '%~dp0'"

echo.
echo Kotobaza started in HIDDEN mode (no taskbar icons).
echo   API:      http://127.0.0.1:8000
echo   Web chat: http://127.0.0.1:8000/static/index.html
echo To stop: run stop_all_hidden.bat
echo.
exit /b
