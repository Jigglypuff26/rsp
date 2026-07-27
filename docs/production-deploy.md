# 🚀 Production Deployment Guide

## ⚠️ Важно

В production НЕ используется Vite dev server. Статика раздается через Nginx.

Если вы видите ошибку `Blocked request. This host is not allowed`, это означает, что запущен **dev контейнер** вместо production.

## 🚀 Правильное развертывание на сервере

### 1. Клонирование репозитория

```bash
# На сервере
cd /var/www
git clone https://github.com/Jigglypuff26/rsp.git
cd rsp
```

### 2. Запуск PRODUCTION контейнера

```bash
# ПРАВИЛЬНО - Production с Nginx
docker compose -f docker/docker-compose.prod.yml -p rsp-prod up -d --build

# НЕПРАВИЛЬНО - Development с Vite (не для продакшена!)
# docker compose -f docker/docker-compose.dev.yml -p rsp-dev up -d --build
```

### 3. Проверка запущенного контейнера

```bash
# Проверить, какой контейнер запущен
docker ps

# Должно быть:
# CONTAINER ID   IMAGE          COMMAND                  NAMES
# xxxxxxxxx      rsp-prod       "nginx -g 'daemon of…"   rsp-prod

# НЕ должно быть:
# rsp-dev  или  "npm run dev"
```

### 4. Проверка логов

```bash
# Просмотр логов production контейнера
docker compose -f docker/docker-compose.prod.yml -p rsp-prod logs -f

# Должны видеть логи Nginx, НЕ логи Vite
```

### 5. Настройка Nginx на хосте (reverse proxy)

Готовая конфигурация reverse proxy для `pp-maksim.ru` уже есть в репозитории — [nginx/react.conf](../nginx/react.conf). Не создавайте отдельный файл `/etc/nginx/sites-available/pp-maksim.ru` вручную: если завести второй server-блок с тем же `server_name`, nginx выдаст `conflicting server name` и будет использовать только первый загруженный конфиг — второй молча игнорируется, что приводит к 502 на «правильном» конфиге.

Ставьте конфиг единственным способом — скриптом (он же копирует общие сниппеты в `/etc/nginx/snippets/`, которые `react.conf` подключает через `include`):

```bash
sh ./bash.scripts/deploy.nginx.conf.sh
sudo nginx -t
sudo systemctl reload nginx
```

Подробности и ручная установка — см. [docs/nginx.md](./nginx.md).

## 🔍 Диагностика проблем

### Проблема: "Blocked request. This host is not allowed"

**Причина:** Запущен dev контейнер вместо production.

**Решение:**

```bash
# 1. Остановить все контейнеры
docker compose -f docker/docker-compose.dev.yml -p rsp-dev down
docker compose -f docker/docker-compose.prod.yml -p rsp-prod down

# 2. Запустить ТОЛЬКО production
docker compose -f docker/docker-compose.prod.yml -p rsp-prod up -d --build

# 3. Проверить
docker ps | grep rsp
```

### Проверка, что используется Nginx, а не Vite

```bash
# Войти в контейнер
docker exec -it rsp-prod sh

# Проверить процессы
ps aux

# Должен быть nginx, НЕ должно быть node/vite
# Пример правильного вывода:
# PID   USER     TIME  COMMAND
#   1   root      0:00 nginx: master process nginx -g daemon off;
#   7   nginx     0:00 nginx: worker process
```

### Проверка портов

```bash
# На хосте
netstat -tlnp | grep 3030

# Должно показывать docker-proxy на порту 3030
```

## 📝 Переменные окружения для Production

Создайте файл `.env.production` в корне проекта:

```bash
VITE_API_URL=https://api.pp-maksim.ru
VITE_ENV=production
```

Обновите `docker/docker-compose.prod.yml`:

```yaml
services:
  app:
    build:
      context: ..
      dockerfile: docker/Dockerfile.prod
      target: production
      args:
        - VITE_API_URL=${VITE_API_URL}
        - VITE_ENV=${VITE_ENV}
    env_file:
      - ../.env.production
```

## 🔄 Обновление приложения

```bash
# На сервере
cd /var/www/rsp

# Получить изменения
git pull origin main

# Пересобрать и перезапустить
docker compose -f docker/docker-compose.prod.yml -p rsp-prod up -d --build

# Проверить логи
docker compose -f docker/docker-compose.prod.yml -p rsp-prod logs -f
```

## 🛡️ Security Checklist

- ✅ Используется production Docker Compose файл
- ✅ Nginx раздает статику (НЕ Vite dev server)
- ✅ Порт 3030 привязан только к localhost (127.0.0.1)
- ✅ SSL сертификаты настроены
- ✅ Firewall настроен (только 80, 443 открыты)
- ✅ Docker контейнер перезапускается автоматически (restart: unless-stopped)
- ✅ Health checks настроены
- ✅ Логи пишутся в /var/log

## 📊 Мониторинг

```bash
# Статус контейнера
docker compose -f docker/docker-compose.prod.yml -p rsp-prod ps

# Использование ресурсов
docker stats rsp-prod

# Health check
curl http://localhost:3030/health

# Логи Nginx на хосте
tail -f /var/log/nginx/pp-maksim.ru.access.log
tail -f /var/log/nginx/pp-maksim.ru.error.log

# Логи контейнера
docker compose -f docker/docker-compose.prod.yml -p rsp-prod logs --tail=100 -f
```

## 🆘 Troubleshooting

### Контейнер не запускается

```bash
# Проверить логи
docker compose -f docker/docker-compose.prod.yml -p rsp-prod logs

# Проверить сборку
docker compose -f docker/docker-compose.prod.yml -p rsp-prod build --no-cache

# Проверить образ
docker images | grep rsp
```

### Сайт не открывается

```bash
# 1. Проверить, что контейнер запущен
docker ps | grep rsp-prod

# 2. Проверить порт 3030
curl http://localhost:3030

# 3. Проверить Nginx на хосте
sudo nginx -t
sudo systemctl status nginx

# 4. Проверить логи
docker logs rsp-prod
tail -f /var/log/nginx/error.log
```

## 📞 Поддержка

Если проблемы не решаются, проверьте:
1. Файл используется: `docker/docker-compose.prod.yml` (НЕ .dev.yml)
2. Контейнер: `rsp-prod` (НЕ rsp-dev)
3. Процесс: `nginx` (НЕ node/vite)
4. Порт: `127.0.0.1:3030:8080` (привязка к localhost)
5. Health check: `curl http://localhost:3030/health` возвращает "healthy"
