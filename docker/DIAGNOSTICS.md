# Диагностика проблем с nginx в Docker

## Проверка что контейнер запущен

```bash
docker ps -a | grep prod-mod
```

## Проверка логов контейнера

```bash
docker logs prod-mod
```

## Проверка что nginx работает внутри контейнера

```bash
# Войти в контейнер
docker exec -it prod-mod sh

# Проверить что nginx запущен
ps aux | grep nginx

# Проверить конфигурацию nginx
nginx -t

# Проверить что файлы на месте
ls -la /usr/share/nginx/html/

# Проверить конфигурацию nginx
cat /etc/nginx/conf.d/default.conf
```

## Проверка доступности извне

```bash
# Проверить health check
curl http://localhost:8080/health

# Проверить главную страницу
curl http://localhost:8080/

# Проверить что порты проброшены
docker port prod-mod
```

## Частые проблемы

### 1. Nginx не запускается

**Причина:** Неправильная конфигурация nginx

**Решение:**
```bash
docker exec -it prod-mod nginx -t
```

Если есть ошибки, проверьте конфигурацию в `nginx/react.conf.default`

### 2. 404 Not Found

**Причина:** Файлы не собраны или не скопированы

**Решение:**
```bash
# Проверить что файлы есть
docker exec -it prod-mod ls -la /usr/share/nginx/html/

# Если файлов нет, пересобрать образ
docker compose -f docker-compose.prod.yml -p rsp-prod build --no-cache
docker compose -f docker-compose.prod.yml -p rsp-prod up -d
```

### 3. Порт недоступен

**Причина:** Порты не проброшены или заняты

**Решение:**
```bash
# Проверить что порт занят
netstat -tuln | grep 8080

# Проверить проброс портов
docker port prod-mod
```

### 4. Белая страница

**Причина:** Неправильный путь к файлам или ошибки в консоли браузера

**Решение:**
1. Откройте DevTools (F12)
2. Проверьте вкладку Console на ошибки
3. Проверьте вкладку Network - загружаются ли файлы
4. Проверьте что `index.html` существует:
```bash
docker exec -it prod-mod cat /usr/share/nginx/html/index.html
```

### 5. SPA роутинг не работает

**Причина:** Неправильная конфигурация `try_files`

**Решение:** Убедитесь что в конфигурации есть:
```nginx
location / {
    try_files $uri $uri/ /index.html;
}
```

## Пересборка и перезапуск

```bash
# Остановить и удалить контейнер
docker compose -f docker-compose.prod.yml -p rsp-prod down

# Пересобрать образ
docker compose -f docker-compose.prod.yml -p rsp-prod build --no-cache

# Запустить
docker compose -f docker-compose.prod.yml -p rsp-prod up -d

# Проверить логи
docker logs -f prod-mod
```
