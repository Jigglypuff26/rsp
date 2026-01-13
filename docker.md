# Docker Configuration

Проект настроен для работы с Docker версии 29 по современным стандартам.

## Требования

- Docker >= 20.x (рекомендуется 29.x)
- Docker Compose >= 2.x

## Разработка (Development)

Запуск в режиме разработки с hot-reload:

```bash
# Сборка и запуск
docker compose -f docker-compose.dev.yml up --build

# Запуск в фоновом режиме
docker compose -f docker-compose.dev.yml up -d --build

# Остановка
docker compose -f docker-compose.dev.yml down

# Просмотр логов
docker compose -f docker-compose.dev.yml logs -f
```

Приложение будет доступно по адресу: http://localhost:3030

### Особенности dev-режима:

- Hot-reload при изменении файлов в `src/` и `public/`
- Volume монтирование для быстрой синхронизации
- Polling для работы на Windows/Mac
- Health check для мониторинга состояния

## Продакшен (Production)

Сборка и запуск продакшен версии:

```bash
# Сборка и запуск
docker compose -f docker-compose.prod.yml up --build

# Запуск в фоновом режиме
docker compose -f docker-compose.prod.yml up -d --build

# Остановка
docker compose -f docker-compose.prod.yml down

# Просмотр логов
docker compose -f docker-compose.prod.yml logs -f
```

Приложение будет доступно по адресу: http://localhost:3030

### Особенности prod-режима:

- Multi-stage build для оптимизации размера образа
- Nginx для раздачи статики
- Gzip compression
- Security headers
- Кэширование статических ресурсов
- Health check endpoint на `/health`
- Ограничения ресурсов (CPU/Memory)

## Полезные команды

```bash
# Пересборка без кэша
docker compose -f docker-compose.prod.yml build --no-cache

# Просмотр используемых ресурсов
docker stats rsp-prod

# Вход в контейнер
docker exec -it rsp-prod sh

# Очистка неиспользуемых образов и контейнеров
docker system prune -a
```

## Структура файлов

- `Dockerfile` - Multi-stage build для продакшена
- `Dockerfile.dev` - Образ для разработки
- `docker-compose.dev.yml` - Конфигурация для разработки
- `docker-compose.prod.yml` - Конфигурация для продакшена
- `nginx.conf` - Конфигурация Nginx для продакшена
- `.dockerignore` - Исключения для Docker build context

## Оптимизации

### BuildKit

Для использования BuildKit (рекомендуется):

```bash
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
```

Или в `~/.docker/config.json`:
```json
{
  "features": {
    "buildkit": true
  }
}
```

### Кэширование слоев

Dockerfile оптимизирован для кэширования:
- Зависимости устанавливаются отдельно от кода
- Используется `npm ci` для быстрой установки
- Кэширование npm через BuildKit cache mount

### Размер образа

Продакшен образ использует:
- `node:20-alpine` для сборки (временный)
- `nginx:1.27-alpine` для финального образа (~25MB)

## Переменные окружения

### Development

- `NODE_ENV=development`
- `WATCHPACK_POLLING=true` - для работы на Windows/Mac
- `CHOKIDAR_USEPOLLING=true` - для работы на Windows/Mac
- `REACT_APP_ENV=development`

### Production

Переменные окружения можно добавить через `.env` файл или в `docker-compose.prod.yml`.

## Troubleshooting

### Проблемы с hot-reload в dev-режиме

Если изменения не подхватываются автоматически:
1. Проверьте, что volumes правильно смонтированы
2. Убедитесь, что `WATCHPACK_POLLING=true` установлен
3. Перезапустите контейнер

### Проблемы с правами доступа

Если возникают проблемы с правами:
```bash
# Проверка прав в контейнере
docker exec -it rsp-prod ls -la /usr/share/nginx/html
```

### Проблемы с портами

Если порт занят:
```bash
# Измените порт в docker-compose файле
ports:
  - "3001:3000"  # вместо 3000:3000
```
