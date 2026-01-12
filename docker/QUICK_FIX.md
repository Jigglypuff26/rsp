# Быстрое исправление: nginx не отображает Docker контейнер

## Шаг 1: Пересоберите образ

```bash
docker compose -f docker-compose.prod.yml -p rsp-prod down
docker compose -f docker-compose.prod.yml -p rsp-prod build --no-cache
docker compose -f docker-compose.prod.yml -p rsp-prod up -d
```

## Шаг 2: Проверьте что контейнер запущен

```bash
docker ps | grep prod-mod
```

Должен быть статус "Up" и порты "0.0.0.0:8080->80/tcp"

## Шаг 3: Проверьте логи

```bash
docker logs prod-mod
```

Ищите ошибки nginx или проблемы с файлами.

## Шаг 4: Проверьте доступность

```bash
# Health check
curl http://localhost:8080/health

# Главная страница
curl http://localhost:8080/
```

## Шаг 5: Проверьте файлы внутри контейнера

```bash
# Войти в контейнер
docker exec -it prod-mod sh

# Проверить файлы
ls -la /usr/share/nginx/html/

# Должны быть:
# - index.html
# - static/ (папка с CSS и JS)
# - другие файлы из build/

# Проверить конфигурацию nginx
cat /etc/nginx/conf.d/default.conf

# Проверить что nginx работает
ps aux | grep nginx
```

## Если проблема сохраняется

1. **Проверьте что сборка прошла успешно:**
   ```bash
   docker compose -f docker-compose.prod.yml -p rsp-prod build 2>&1 | tail -20
   ```

2. **Проверьте что файлы собраны:**
   ```bash
   # Локально
   npm run build
   ls -la build/
   
   # В контейнере
   docker exec -it prod-mod ls -la /usr/share/nginx/html/
   ```

3. **Проверьте конфигурацию nginx:**
   ```bash
   docker exec -it prod-mod nginx -t
   ```

4. **Перезапустите nginx внутри контейнера:**
   ```bash
   docker exec -it prod-mod nginx -s reload
   ```

## Если используете внешний nginx на хосте

Если у вас nginx установлен на хосте и вы хотите проксировать запросы к Docker контейнеру, создайте конфигурацию:

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Но обычно это не нужно - nginx уже работает внутри Docker контейнера на порту 8080.
