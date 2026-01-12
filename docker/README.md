# Docker конфигурация для React приложения

## Структура

- `docker/dev/Dockerfile.dev` - Dockerfile для разработки с hot reload
- `docker/prod/Dockerfile.prod` - Dockerfile для production сборки
- `docker-compose.dev.yml` - Docker Compose для разработки
- `docker-compose.prod.yml` - Docker Compose для production

## Разработка

### Запуск dev окружения

```bash
docker compose -f docker-compose.dev.yml -p rsp-dev up --build
```

Приложение будет доступно на `http://localhost:3000`

**Особенности:**
- Hot reload работает через volumes
- Изменения в `src/` и `public/` автоматически применяются
- `node_modules` используется из контейнера

### Остановка

```bash
docker compose -f docker-compose.dev.yml -p rsp-dev down
```

## Production

### Вариант 1: Без SSL (для тестирования)

```bash
docker compose -f docker-compose.prod.no-ssl.yml -p rsp-prod up --build -d
```

Приложение будет доступно на `http://localhost:8080`

### Вариант 2: С SSL (для production)

**Требования:**
- SSL сертификаты Let's Encrypt должны быть установлены в `/etc/letsencrypt/live/pp-maksim.ru/`
- Домен должен указывать на сервер

**Запуск:**

```bash
docker compose -f docker-compose.prod.yml -p rsp-prod up --build -d
```

Приложение будет доступно на:
- HTTP: `http://pp-maksim.ru` (редирект на HTTPS)
- HTTPS: `https://pp-maksim.ru`

**Настройка SSL:**

1. Убедитесь, что SSL сертификаты установлены:
```bash
sudo certbot certonly --standalone -d pp-maksim.ru -d www.pp-maksim.ru
```

2. Проверьте, что сертификаты находятся в `/etc/letsencrypt/live/pp-maksim.ru/`

3. Запустите контейнер (volumes уже настроены в docker-compose.prod.yml)

### Health Check

Health check endpoint доступен по адресу: `http://localhost:8080/health`

### Остановка

```bash
docker compose -f docker-compose.prod.yml -p rsp-prod down
```

## Особенности Production Dockerfile

1. **Multi-stage build** - уменьшает размер финального образа
2. **Автоматическое исправление форматирования** - решает проблемы с CRLF/LF
3. **Отключение ESLint при сборке** - через `.env.production`
4. **Оптимизация размера** - удаление ненужных файлов после сборки
5. **Health check** - встроенная проверка работоспособности

## Troubleshooting

### Порт уже занят

Если порт 80 занят, измените маппинг портов в `docker-compose.prod.yml`:
```yaml
ports:
  - "8080:80"  # измените 8080 на свободный порт
```

### Ошибки сборки

Если сборка падает из-за ESLint/Prettier:
- Dockerfile автоматически исправляет форматирование
- Если проблема сохраняется, проверьте `.eslintrc.json`

### Проблемы с hot reload в dev

Убедитесь, что volumes правильно настроены в `docker-compose.dev.yml`
