@echo off
title Kotobaza launcher (server + bot)
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

REM ---- start API server in a minimized window ----
echo Starting API server (background)...
start "RAG API" /MIN "%PY%" -m uvicorn app:app --host 0.0.0.0 --port 8000

REM ---- wait for server to come up ----
timeout /t 6 /nobreak >nul

REM ---- start Telegram bot in a minimized window ----
echo Starting Telegram bot (background)...
start "RAG Bot" /MIN "%PY%" bot.py

timeout /t 2 /nobreak >nul

REM ---- open web chat ----
start http://127.0.0.1:8000/

echo.
echo Kotobaza started: server + bot are running in background.
echo   API:      http://127.0.0.1:8000
echo   Web chat: http://127.0.0.1:8000/static/index.html
echo   Docs:     http://127.0.0.1:8000/docs
echo To stop: close the "RAG API" and "RAG Bot" windows, or run stop_all.bat
echo.
exit /b
