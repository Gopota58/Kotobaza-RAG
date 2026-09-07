# NOTES.md — kotobaza-rag (Котобаза RAG)

## 2026-09-07 — Гэп 1: GigaChat как LLM-провайдер (DONE) + запуск веб/бот

### Сделано (Done)
- **Гэп 1 ЗАКРЫТ.** Провайдер `gigachat` добавлен в `rag/engine.py` (`build_llm`) через
  `langchain-gigachat` (GigaChat SDK сам делает OAuth→access_token, SSL, retry). Переключатель
  `LLM_PROVIDER=gigachat` в `.env`. Запушено в GitHub `kotobaza-rag` (до коммита `4658030`).
- **Живая проверка пройдена:** `/ask` через GigaChat отвечает (2+2=«Четыре»; реальные вопросы
  про котов — связные, обоснованные документами ответы). Тесты pytest: 11 passed (в т.ч. mock-GigaChat).
- **Веб-интерфейс** (`http://127.0.0.1:8000/`) и **Telegram-бот** (`bot.py`) запущены и работали
  параллельно, оба ходят в локальный RAG-сервер (uvicorn :8000) с GigaChat. В конце сессии оба
  фоновых процесса остановлены по команде пользователя (порт 8000 освобождён).
- Индекс `chroma_db` пересобран под MiniLM (384-dim) через `POST /ingest` (20 доков, 393 чанка).
- Все изменения и дайджесты запушены в GitHub + LoreBase.

### Следующие шаги (Next Steps)
- **Гэп 2: бесплатный деплой в Yandex Cloud** (Serverless Containers + API Gateway; векторы →
  Qdrant Cloud free). Нужен аккаунт Yandex Cloud — запросить у пользователя перед стартом.
- (опц.) Поднять качество ответов: GigaChat-3-Pro / Ultra (бесплатны в freemium-квоте) или
  более сильные эмбеддинги (nomic через LM Studio).
- (опц.) Гэп 3: Qdrant как альтернативный векторный бэкенд (`VECTOR_STORE=qdrant`).
- Гэпы 4/5/6 (case-study isp-triage, резюме, поиск) — параллельно.

### Грабли и находки (Gotchas)
- **Секреты из буфера часто обёрнуты в `< >`** → 400 (OAuth) или `InvalidToken` (Telegram).
  Перед вставкой в `.env` снимать угловые скобки. Коснулось и GigaChat-key, и Telegram-токена.
- `GigaChat-Lite` — **не существующий model id** (404). Базовый бесплатный = **`GigaChat-2`**
  (тариф Lite). Валидные id из `get_models()`: GigaChat-2, GigaChat-3-Lightning, GigaChat-2-Pro,
  GigaChat-3-Pro, GigaChat-3-Ultra. «Lite/Pro/Max/Ultra» — это тариф, суффикс модели, не standalone-имя.
- Размерность Chroma: коллекция была 256-dim (HashingEmbeddings), MiniLM даёт 384 → mismatch (500).
  Лечится `POST /ingest` (пересборка под текущий `embeddings`).
- GigaChat OAuth: `Authorization: Basic <key>`, scope `GIGACHAT_API_PERS`; сырой ChatOpenAI не годится (401).
- SSL на Windows: российский root-CA вне доверия Python → `GIGACHAT_CA_BUNDLE_FILE` (certs/russian_trusted_root_ca.crt)
  либо `GIGACHAT_VERIFY_SSL_CERTS=false` (только dev).
- Telegram в РФ заблокирован → боту нужен `TELEGRAM_PROXY` (http://127.0.0.1:7890), иначе не достучится.
- **ЖЁСТКОЕ правило пользователя:** без явной команды ничего не менять и не запускать; спрашивать
  перед КАЖДЫМ шагом. Закреплено в `~/.dsh/AGENTS.md` и `wiki/concepts/standing-rule-ask-first.md`.

### Окружение
- venv Python 3.14.7; установлены `langchain-gigachat==0.5.1`, `gigachat==0.2.3`, `sentence-transformers` (MiniLM).
- `.env` (gitignored) содержит: `LLM_PROVIDER=gigachat`, `LLM_MODEL=GigaChat-2`,
  `GIGACHAT_VERIFY_SSL_CERTS=false`, `TELEGRAM_BOT_TOKEN`, `TELEGRAM_PROXY=http://127.0.0.1:7890`.
- Локальный MiniLM лежит в `models/all-MiniLM-L6-v2` (скачан, переиспользуется без сети).
