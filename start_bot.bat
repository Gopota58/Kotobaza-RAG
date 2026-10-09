@echo off
REM Запуск Telegram-бота «Котобаза» в фоновом окне.
REM Бот поддерживает соединение с Telegram через прокси (TELEGRAM_PROXY в .env),
REM если он задан. Логи — в папке logs\.
cd /d %~dp0
start "" /MIN venv\Scripts\python.exe bot.py
echo Bot started. Logs: logs\bot.err.log / logs\bot.out.log. PID: logs\bot.pid
