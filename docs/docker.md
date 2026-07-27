# 🐳 Docker Configuration

Проект настроен для работы с Docker версии 29 по современным стандартам.

## ⚡ Быстрые команды

### Development
```bash
# Запуск в фоновом режиме
docker compose -f docker/docker-compose.dev.yml -p rsp-dev up -d --build

# Просмотр логов
docker compose -f docker/docker-compose.dev.yml -p rsp-dev logs -f

# Остановка
docker compose -f docker/docker-compose.dev.yml -p rsp-dev down
```

### Production
```bash
# Запуск в фоновом режиме
docker compose -f docker/docker-compose.prod.yml -p rsp-prod up -d --build

# Просмотр логов
docker compose -f docker/docker-compose.prod.yml -p rsp-prod logs -f

# Остановка
docker compose -f docker/docker-compose.prod.yml -p rsp-prod down
```

**URL:** http://localhost:3030

## 📋 Требования

- **Docker** >= 20.x (рекомендуется 29.x, протестировано с версией 29.x)
- **Docker Compose** >= 2.x

## 🚀 Быстрый старт

### Разработка (Development)

Запуск в режиме разработки с hot-reload:

```bash
# Сборка и запуск
docker compose -f docker/docker-compose.dev.yml -p rsp-dev up --build

# Запуск в фоновом режиме
docker compose -f docker/docker-compose.dev.yml -p rsp-dev up -d --build

# Остановка
docker compose -f docker/docker-compose.dev.yml -p rsp-dev down

# Просмотр логов
docker compose -f docker/docker-compose.dev.yml -p rsp-dev logs -f

# Просмотр логов конкретного сервиса
docker compose -f docker/docker-compose.dev.yml -p rsp-dev logs -f app
```

Приложение будет доступно по адресу: **http://localhost:3030**

### Продакшен (Production)

Сборка и запуск продакшен версии:

```bash
# Сборка и запуск
docker compose -f docker/docker-compose.prod.yml -p rsp-prod up --build

# Запуск в фоновом режиме
docker compose -f docker/docker-compose.prod.yml -p rsp-prod up -d --build

# Остановка
docker compose -f docker/docker-compose.prod.yml -p rsp-prod down

# Просмотр логов
docker compose -f docker/docker-compose.prod.yml -p rsp-prod logs -f

# Пересборка без кэша
docker compose -f docker/docker-compose.prod.yml -p rsp-prod build --no-cache
```

Приложение будет доступно по адресу: **http://localhost:3030** (порт привязан только к localhost для безопасности)

## 📋 Основные команды

### Запуск контейнеров

```bash
# Development - запуск в обычном режиме (с выводом логов)
docker compose -f docker/docker-compose.dev.yml -p rsp-dev up --build

# Development - запуск в фоновом режиме (detached mode)
docker compose -f docker/docker-compose.dev.yml -p rsp-dev up -d --build

# Production - запуск в обычном режиме
docker compose -f docker/docker-compose.prod.yml -p rsp-prod up --build

# Production - запуск в фоновом режиме (detached mode)
docker compose -f docker/docker-compose.prod.yml -p rsp-prod up -d --build
```

### Остановка контейнеров

```bash
# Development - остановка и удаление контейнеров
docker compose -f docker/docker-compose.dev.yml -p rsp-dev down

# Production - остановка и удаление контейнеров
docker compose -f docker/docker-compose.prod.yml -p rsp-prod down

# Остановка с удалением volumes
docker compose -f docker/docker-compose.dev.yml -p rsp-dev down -v

# Остановка контейнера без удаления (можно запустить снова)
docker compose -f docker/docker-compose.dev.yml -p rsp-dev stop

# Запуск остановленного контейнера
docker compose -f docker/docker-compose.dev.yml -p rsp-dev start
```

### Перезапуск контейнеров

```bash
# Development - перезапуск
docker compose -f docker/docker-compose.dev.yml -p rsp-dev restart

# Production - перезапуск
docker compose -f docker/docker-compose.prod.yml -p rsp-prod restart

# Перезапуск конкретного сервиса
docker compose -f docker/docker-compose.dev.yml -p rsp-dev restart app
```

### Просмотр логов

```bash
# Development - просмотр логов (follow mode)
docker compose -f docker/docker-compose.dev.yml -p rsp-dev logs -f

# Production - просмотр логов
docker compose -f docker/docker-compose.prod.yml -p rsp-prod logs -f

# Просмотр последних 100 строк логов
docker compose -f docker/docker-compose.dev.yml -p rsp-dev logs --tail=100

# Просмотр логов конкретного сервиса
docker compose -f docker/docker-compose.dev.yml -p rsp-dev logs -f app
```

### Проверка статуса

```bash
# Просмотр запущенных контейнеров
docker compose -f docker/docker-compose.dev.yml -p rsp-dev ps

# Просмотр использования ресурсов
docker stats rsp-dev
docker stats rsp-prod

# Проверка health check
docker inspect --format='{{.State.Health.Status}}' rsp-dev
docker inspect --format='{{.State.Health.Status}}' rsp-prod
```

### Краткая справка по флагам

| Флаг | Описание |
|------|----------|
| `up` | Создать и запустить контейнеры |
| `down` | Остановить и удалить контейнеры |
| `start` | Запустить существующие контейнеры |
| `stop` | Остановить контейнеры без удаления |
| `restart` | Перезапустить контейнеры |
| `-d, --detach` | Запуск в фоновом режиме |
| `--build` | Пересобрать образы перед запуском |
| `-f` | Указать файл docker-compose |
| `-p` | Имя проекта |
| `-v` | Удалить именованные volumes |
| `--no-cache` | Сборка без использования кэша |
| `logs -f` | Просмотр логов в режиме follow |
| `--tail=N` | Показать последние N строк логов |

## 📁 Структура файлов

```
.
├── docker/
│   ├── Dockerfile              # Multi-stage build для продакшена
│   ├── Dockerfile.dev          # Образ для разработки
│   ├── docker-compose.dev.yml  # Конфигурация для разработки
│   └── docker-compose.prod.yml # Конфигурация для продакшена
├── nginx.docker.conf           # Nginx конфигурация внутри контейнера
├── .dockerignore               # Исключения для Docker build context
└── nginx/
    └── react.conf              # Конфигурация глобального Nginx (reverse proxy)
```

## 🔧 Особенности

### Development режим

- ✅ Vite HMR (Hot Module Replacement) при изменении файлов в `src/` и `public/`
- ✅ Volume монтирование для быстрой синхронизации
- ✅ Polling для работы на Windows/Mac (опционально)
- ✅ Health check для мониторинга состояния
- ✅ Используется `docker/Dockerfile.dev`
- ✅ Порт: `3030:3000`
- ✅ Мгновенный запуск dev сервера благодаря Vite

### Production режим

- ✅ Multi-stage build для оптимизации размера образа
- ✅ Nginx для раздачи статики
- ✅ Gzip compression
- ✅ Security headers
- ✅ Кэширование статических ресурсов
- ✅ Health check endpoint на `/health`
- ✅ Ограничения ресурсов (CPU/Memory)
- ✅ Финальный образ основан на `nginx:1.27-alpine` (~25MB)
- ✅ Порт: `127.0.0.1:3030:8080` (только localhost)

## 🛠 Полезные команды

### Управление контейнерами

```bash
# Просмотр запущенных контейнеров
docker ps

# Просмотр всех контейнеров (включая остановленные)
docker ps -a

# Просмотр используемых ресурсов
docker stats rsp-prod

# Остановка контейнера
docker stop rsp-prod

# Запуск остановленного контейнера
docker start rsp-prod

# Перезапуск контейнера
docker restart rsp-prod

# Удаление контейнера
docker rm rsp-prod
```

### Работа с образами

```bash
# Просмотр образов
docker images

# Удаление образа
docker rmi rsp:latest

# Просмотр истории образа
docker history rsp:latest

# Экспорт образа
docker save rsp:latest > rsp-image.tar

# Импорт образа
docker load < rsp-image.tar
```

### Отладка

```bash
# Вход в контейнер
docker exec -it rsp-prod sh

# Выполнение команды в контейнере
docker exec -it rsp-prod nginx -t

# Просмотр логов контейнера
docker logs rsp-prod

# Просмотр логов с фильтрацией
docker logs rsp-prod 2>&1 | grep error

# Просмотр информации о контейнере
docker inspect rsp-prod

# Просмотр процессов в контейнере
docker top rsp-prod
```

### Очистка

```bash
# Остановка и удаление контейнеров
docker compose -f docker/docker-compose.prod.yml down

# Удаление контейнеров и volumes
docker compose -f docker/docker-compose.prod.yml down -v

# Очистка неиспользуемых образов
docker image prune

# Очистка неиспользуемых контейнеров
docker container prune

# Полная очистка (осторожно!)
docker system prune -a

# Просмотр использования дискового пространства
docker system df
```

## ⚡ Оптимизации

### BuildKit

Для использования BuildKit (рекомендуется для ускорения сборки):

```bash
# Временная активация
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# Постоянная активация (Linux/Mac)
echo 'export DOCKER_BUILDKIT=1' >> ~/.bashrc
echo 'export COMPOSE_DOCKER_CLI_BUILD=1' >> ~/.bashrc
source ~/.bashrc
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
- ✅ Зависимости устанавливаются отдельно от кода
- ✅ Используется `npm ci` для быстрой установки
- ✅ Кэширование npm через BuildKit cache mount
- ✅ Multi-stage build для минимизации размера

### Размер образа

**Development образ:**
- Базовый образ: `node:20-alpine`
- Размер: ~200-300MB (включает все зависимости)

**Production образ:**
- Сборка: `node:20-alpine` (временный)
- Финальный: `nginx:1.27-alpine`
- Размер: ~25-30MB (только статические файлы + nginx)

## 🔐 Переменные окружения

### Development

Переменные окружения для разработки (установлены в `docker/docker-compose.dev.yml`):

```yaml
environment:
  - NODE_ENV=development
  - VITE_ENV=development
```

**Примечание:** Vite использует нативные ES модули и HMR, поэтому polling переменные (`WATCHPACK_POLLING`, `CHOKIDAR_USEPOLLING`) больше не требуются в большинстве случаев. Polling включен в `vite.config.ts` при необходимости.

### Production

Переменные окружения можно добавить через:

**1. Файл `.env`:**
```bash
# .env.production
VITE_API_URL=https://api.example.com
VITE_ENV=production
```

**2. В `docker/docker-compose.prod.yml`:**
```yaml
services:
  app:
    build:
      args:
        - VITE_API_URL=https://api.example.com
        - VITE_ENV=production
    env_file:
      - .env.production
```

**Важно:** 
- Переменные должны начинаться с `VITE_` для Vite
- Переменные встраиваются в код на этапе сборки
- Используйте `import.meta.env.VITE_*` для доступа к переменным

## 🌐 Глобальный Nginx (Reverse Proxy)

Для продакшена рекомендуется использовать глобальный Nginx на хосте как reverse proxy.

### Быстрая настройка:

```bash
# Копирование конфигурации
sudo cp nginx/react.conf /etc/nginx/sites-available/rsp
sudo ln -s /etc/nginx/sites-available/rsp /etc/nginx/sites-enabled/rsp

# Редактирование домена
sudo nano /etc/nginx/sites-available/rsp

# Проверка и перезапуск
sudo nginx -t
sudo systemctl restart nginx
```

### Преимущества:

- ✅ SSL/TLS терминация
- ✅ Кэширование на уровне nginx
- ✅ Rate limiting и защита от DDoS
- ✅ Логирование запросов
- ✅ Централизованное управление несколькими приложениями
- ✅ HTTP/2 поддержка

Подробная инструкция в [документации по Nginx](./nginx.md).

## 🏗 Multi-stage Build

Production Dockerfile использует multi-stage build:

**Stage 1: Builder**
- Базовый образ: `node:20-alpine`
- Установка зависимостей
- Сборка приложения
- Результат: собранные статические файлы в `/app/build`

**Stage 2: Production**
- Базовый образ: `nginx:1.27-alpine`
- Копирование статических файлов из builder stage
- Копирование конфигурации nginx
- Установка прав доступа
- Результат: минимальный образ (~25MB)

## 🔍 Health Check

### В Dockerfile

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1
```

### В docker-compose

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
  interval: 30s
  timeout: 3s
  retries: 3
  start_period: 5s
```

### Проверка health check

```bash
# Проверка статуса
docker inspect --format='{{.State.Health.Status}}' rsp-prod

# Просмотр health check логов
docker inspect --format='{{json .State.Health}}' rsp-prod | jq
```

## 📊 Мониторинг ресурсов

### Ограничения ресурсов

В `docker/docker-compose.prod.yml` настроены ограничения:

```yaml
deploy:
  resources:
    limits:
      cpus: '1.0'
      memory: 512M
    reservations:
      cpus: '0.5'
      memory: 256M
```

### Просмотр использования

```bash
# Статистика в реальном времени
docker stats rsp-prod

# Статистика всех контейнеров
docker stats

# Использование диска
docker system df
```

## 🆘 Troubleshooting

### Проблемы с HMR (Hot Module Replacement) в dev-режиме

Если изменения не подхватываются автоматически:

1. Проверьте, что volumes правильно смонтированы:
   ```bash
   docker inspect rsp-dev | grep -A 10 Mounts
   ```

2. Убедитесь, что Vite слушает на всех интерфейсах:
   ```bash
   docker exec -it rsp-dev npm run dev -- --host 0.0.0.0
   ```
   (уже настроено в `vite.config.ts` и `Dockerfile.dev`)

3. Проверьте, что polling включен в `vite.config.ts`:
   ```typescript
   server: {
     watch: {
       usePolling: true
     }
   }
   ```

4. Перезапустите контейнер:
   ```bash
   docker compose -f docker/docker-compose.dev.yml restart
   ```

5. Проверьте логи:
   ```bash
   docker compose -f docker/docker-compose.dev.yml logs -f app
   ```

### Проблемы с правами доступа

Если возникают проблемы с правами:

```bash
# Проверка прав в контейнере
docker exec -it rsp-prod ls -la /usr/share/nginx/html

# Исправление прав (если нужно)
docker exec -it rsp-prod chown -R nginx:nginx /usr/share/nginx/html
docker exec -it rsp-prod chmod -R 755 /usr/share/nginx/html
```

### Проблемы с портами

Если порт занят:

```bash
# Windows
netstat -ano | findstr :3030

# Linux/Mac
lsof -i :3030

# Измените порт в docker-compose файле
# ports:
#   - "3001:8080"  # вместо 3030:8080
```

### Проблемы с памятью

Если сборка падает из-за нехватки памяти:

1. **Docker Desktop (Windows/Mac):**
   - Settings → Resources → Memory
   - Увеличьте лимит памяти

2. **Linux:**
   ```bash
   # Проверка swap
   free -h
   
   # Создание swap файла (если нужно)
   sudo fallocate -l 2G /swapfile
   sudo chmod 600 /swapfile
   sudo mkswap /swapfile
   sudo swapon /swapfile
   ```

### Проблемы с сетью

```bash
# Просмотр сетей
docker network ls

# Просмотр информации о сети
docker network inspect rsp-prod-network

# Создание новой сети
docker network create rsp-network

# Удаление неиспользуемых сетей
docker network prune
```

### Проблемы со сборкой

```bash
# Сборка без кэша
docker compose -f docker/docker-compose.prod.yml build --no-cache

# Сборка с выводом подробной информации
docker compose -f docker/docker-compose.prod.yml build --progress=plain

# Просмотр логов сборки
docker compose -f docker/docker-compose.prod.yml build 2>&1 | tee build.log
```

## ⚡ Особенности Vite в Docker

### Преимущества Vite в Docker

- ✅ **Мгновенный запуск** - dev сервер стартует за миллисекунды
- ✅ **Быстрый HMR** - изменения применяются мгновенно без полной перезагрузки
- ✅ **Нативные ES модули** - не требуется bundling в dev режиме
- ✅ **Оптимизированная сборка** - используется esbuild для production

### Конфигурация для Docker

В `vite.config.ts` настроено для работы в Docker:

```typescript
server: {
  port: 3000,
  host: true,  // Прослушивание на всех интерфейсах (0.0.0.0)
  open: true,
  watch: {
    usePolling: true  // Для работы в Docker на Windows/Mac
  }
}
```

### Переменные окружения

Vite использует префикс `VITE_` для публичных переменных:

```bash
# Development
VITE_API_URL=http://localhost:3001
VITE_DEBUG=true

# Production
VITE_API_URL=https://api.example.com
VITE_DEBUG=false
```

Доступ в коде:
```typescript
const apiUrl = import.meta.env.VITE_API_URL;
const isDebug = import.meta.env.VITE_DEBUG === 'true';
```

## 📚 Дополнительные ресурсы

- [Docker Official Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Multi-stage Builds](https://docs.docker.com/build/building/multi-stage/)
- [Docker BuildKit](https://docs.docker.com/build/buildkit/)
- [Vite Documentation](https://vitejs.dev/)
- [Vite Docker Guide](https://vitejs.dev/guide/troubleshooting.html#docker)

## 🔗 Связанная документация

- [Документация по деплою](./deployment.md) - полное руководство по развертыванию
- [Документация по Nginx](./nginx.md) - настройка Nginx для production
- [Руководство по разработке](./development.md) - настройка окружения разработки

---

**Примечание:** В Docker 29.x используется команда `docker compose` (с пробелом) вместо `docker-compose` (с дефисом). Файлы docker-compose не требуют указания версии при использовании Docker Compose v2.
