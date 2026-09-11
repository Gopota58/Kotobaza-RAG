# ☁️ Деплой Котобазы в Yandex Cloud (Serverless Containers) — $0

Полностью бесплатная схема: **Serverless Container** + **API Gateway**
(free ~1M req/mo), GigaChat (бесплатная квота разработчика), эмбеддинги — через
OpenAI-совместимый endpoint или локально в контейнере. Векторы — в Chroma внутри
контейнера (демо) либо во внешнем **Qdrant Cloud free** (1 GB, см. «Постоянство»).

Образ уже **serverless-ready**: `docker-entrypoint.sh` слушает порт из переменной
`$PORT` (его задаёт Yandex Serverless Containers), а при локальном запуске — `8000`.

## 0. Что подготовить
- Аккаунт Yandex Cloud (физлицо, free-tier).
- Ключ GigaChat: https://developers.sber.ru/gigachat → «Получить ключ»
  (Authorization key, бесплатная квота физлица).
- (опц.) Qdrant Cloud free: https://qdrant.tech/pricing (1 GB).
- Установленный и авторизованный `yc` CLI: `yc init`.

## 1. Сборка образа
```bash
docker build -t kotobaza-rag:latest .
```

> Примечание: дефолтный `requirements.txt` **не** включает стек локальных
> эмбеддингов (`torch`/`sentence-transformers`/`langchain-huggingface`) ради
> размера образа. Если нужен **самодостаточный** контейнер с локальными
> эмбеддингами (без внешнего embedding-API), добавьте эти пакеты в свой образ и
> поставьте `EMBED_PROVIDER=local` (модель подтянется из Hugging Face автоматически
> при первом обращении).

## 2. Push в Yandex Container Registry
```bash
yc container registry create --name kotobaza-registry   # один раз
REGISTRY_ID=$(yc container registry get kotobaza-registry --format=json \
  | python -c "import sys,json;print(json.load(sys.stdin)['id'])")

docker tag kotobaza-rag:latest cr.yandex/$REGISTRY_ID/kotobaza-rag:latest
docker push cr.yandex/$REGISTRY_ID/kotobaza-rag:latest
```

## 3. Serverless Container
```bash
yc serverless container create \
  --name kotobaza \
  --image cr.yandex/$REGISTRY_ID/kotobaza-rag:latest \
  --cores 1 --memory 512Mb --concurrency 1 \
  --environment LLM_PROVIDER=gigachat \
  --environment LLM_API_KEY="<ВАШ_GIGACHAT_KEY>" \
  --environment LLM_MODEL=GigaChat-2 \
  --environment GIGACHAT_BASE_URL=https://api.giga.chat/v1 \
  --environment GIGACHAT_VERIFY_SSL_CERTS=true \
  --environment GIGACHAT_CA_BUNDLE_FILE=/app/certs/Russian_Trusted_Root_CA.cer \
  --environment EMBED_PROVIDER=api \
  --environment EMBED_API_BASE_URL="<OpenAI-совместимый embedding endpoint>" \
  --environment EMBED_API_MODEL="<model>" \
  --environment EMBED_API_KEY="<key>" \
  --environment API_KEY="<сгенерируйте свой, НЕ 88888888>"
```

Получите служебный URL контейнера:
```bash
yc serverless container get kotobaza --format=json \
  | python -c "import sys,json;print(json.load(sys.stdin)['url'])"
```

## 4. API Gateway (публичный URL)
```bash
cat > gateway.yaml <<'EOF'
spec:
  routes:
    - http:
        path: /{proxy+}
        destination:
          containerId: <CONTAINER_ID>
EOF
yc serverless api-gateway create --name kotobaza-api --spec gateway.yaml
```
Публичный URL вида `https://<id>.apigw.yandexcloud.net/` проксирует запросы в
контейнер. Проверка:
```bash
curl https://<id>.apigw.yandexcloud.net/health      # -> {"status":"ok"}
curl -X POST https://<id>.apigw.yandexcloud.net/ask \
  -H "X-API-Key: <API_KEY>" -H "Content-Type: application/json" \
  -d "{\"question\":\"Чем кормить рыжего кота?\"}"
```

## 5. Эмбеддинги в облаке
`EMBED_PROVIDER=api` требует внешнего OpenAI-совместимого embedding-endpoint
(например, размещённая модель вроде `nomic-embed-text` / мультиязычного эмбеддера
на HF Inference или отдельном сервисе). Если не хотите держать отдельный сервис —
используйте локальные эмбеддинги внутри контейнера (`EMBED_PROVIDER=local`, см.
примечание в шаге 1): они лучше понимают русский, чем крошечный MiniLM, и не требуют
внешних вызовов.

## 6. Постоянство векторов (эфемерность)
Serverless Container имеет **эфемерное** файловое хранилище: `chroma_db`, созданный
во время работы, теряется при холодном старте/масштабировании. Для демо достаточно
однократно вызвать `POST /ingest` после деплоя (переиндексация `docs/`). Для
**надёжного** хранения вынесите векторы во внешний бэкенд: **Qdrant Cloud free**
(Гэп 3, `VECTOR_STORE=qdrant`) или примонтируйте Object Storage.

## 7. Безопасность
- Никогда не коммитьте `.env` — он уже в `.gitignore` и `.dockerignore`.
- Обязательно смените `API_KEY` с дефолтного `88888888` на свой.
- `GIGACHAT_CA_BUNDLE_FILE=/app/certs/Russian_Trusted_Root_CA.cer` — файл копируется
  в образ (`certs/` намеренно не исключён из `.dockerignore`); без него SSL GigaChat
  упадёт на Linux (российский root-CA отсутствует в системном хранилище Python).

## 8. Стоимость (free-tier)
- Serverless Containers + API Gateway: бесплатно в рамках квот (~1M запросов/мес).
- GigaChat: бесплатная квота разработчика.
- Qdrant Cloud: 1 GB бесплатно.
- ⚠️ Перед стартом сверьте актуальные квоты: https://yandex.cloud/docs/overview/free-tier
