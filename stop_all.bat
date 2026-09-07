@echo off
title Stop Kotobaza
echo Stopping server and bot...
taskkill /F /T /FI "WINDOWTITLE eq RAG API*" >nul 2>&1
taskkill /F /T /FI "WINDOWTITLE eq RAG Bot*" >nul 2>&1
echo Done. Kotobaza stopped.
exit /b
