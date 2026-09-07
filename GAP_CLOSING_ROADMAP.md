# Дорожная карта закрытия гэпов — копия из HQ (LoreBase)

> Это перенесённый план из «штаба» (`E:\HH`) / базы знаний LoreBase.
> **Место исполнения:** здесь, в `C:\rag_project` (репозиторий `kotobaza-rag`).
> Каноническая версия — в `E:\vault\wiki\projects\career-ai-engineer.md`.

## Рабочая модель
- HQ `E:\HH` = стратегия только. Проектные задачи — здесь.
- Мост = LoreBase `E:\vault`. Каждый шаг гэпа → коммит в этот репозиторий + дайджест в vault.

## Анализ портфолио (Gopota58)
- **kotobaza-rag** (ФЛАГМАН): offline-first RAG, FastAPI+LangChain+Chroma, гибридный ретривер (вектор+BM25/RRF), Telegram-бот, веб-чат, оценка (faithfulness 0.70 / relevancy 0.70 / precision 0.80 / recall 0.55), pytest+CI. Model-agnostic.
- **isp-triage-assistant**: гибрид ML+правила+LLM, TRL3/синтетика.
- **ai-agent-orchestration**: 5-слойная оркестрация субагентов.
- **Revolution** (private): Kaggle Titanic (ML-фундамент).
- **Гэпы:** только локальные LLM/синтетика → нет облачных российских LLM и деплоя в РФ-облака; нет резюме/профиля.

## Дорожная карта (исполнять здесь, шаг за шагом, с подтверждением)
1. **Гэп 1 — GigaChat как провайдер LLM** (приоритет). Добавить `gigachat` в `rag/engine.py` как OpenAI-compatible (`https://gigachat.devices.sberbank.ru/api/v1` + Bearer). Переключатель `LLM_PROVIDER=gigachat` в `.env`. ✅ СДЕЛАНО: интеграция через `langchain-gigachat` (`GigaChat` SDK делает OAuth→token, SSL, retry) в `build_llm()`; базовый URL `https://api.giga.chat/v1`; модель `GigaChat-2` (бесплатный Lite; `GigaChat-Lite` — несуществующий API-id). Живая `/ask` пройдена (2+2=«Четыре»), тесты 11 passed, запушено в GitHub. Приёмка выполнена.
2. **Гэп 2 — бесплатный деплой (Yandex Cloud serverless)**. Serverless Containers + API Gateway (free ~1M req/mo). Векторы → Qdrant Cloud free (1 GB). docs → образ/Object Storage free. Секреты → переменные окружения. Приёмка: внешний URL на GigaChat.
3. **Гэп 3 — Qdrant как альтернативный бэкенд** (опц.). `VECTOR_STORE=qdrant`.
4. **Гэп 4 — case-study isp-triage** для собесов (письменно).
5. **Гэп 5 — резюме + профиль GitHub** (параллельно, тема А).
6. **Гэп 6 — поиск/позиционирование** (параллельно, тема Б).

## Бесплатная схема ($0)
- GigaChat: бесплатная квота разработчика (`developers.sber.ru/gigachat`).
- Yandex Cloud: Serverless Containers + API Gateway (free quota), Object Storage free 1 GB.
- Qdrant Cloud: free tier 1 GB.
- Альтернатива: Oracle Cloud Always Free VM (навсегда).
- ⚠️ Сверить квоты ДО старта: yandex.cloud/docs/overview/free-tier, developers.sber.ru/gigachat, qdrant.tech/pricing.

## Безопасность
GitHub-токен `ghp_…` из чата — отозвать в GitHub Settings → Developer settings → PAT.

## Статус
- [x] Гэп 1 — СДЕЛАНО (live-verified, pushed `ba54db0`)
- [ ] Гэп 2
- [ ] Гэп 3
- [ ] Гэп 4
- [ ] Гэп 5/6
