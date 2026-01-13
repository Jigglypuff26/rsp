# Документация по Nginx

Проект использует Nginx для раздачи статических файлов в production режиме. Поддерживаются два варианта конфигурации:

1. **Nginx внутри Docker контейнера** - для простого деплоя
2. **Глобальный Nginx на хосте** - для production с reverse proxy и SSL

## 📁 Структура файлов

```
.
├── nginx.docker.conf      # Конфигурация для контейнера (порт 8080)
├── nginx.conf             # Глобальная конфигурация Nginx (основной конфиг)
└── nginx/
    └── react.conf         # Конфигурация reverse proxy для production
```

## 🐳 Nginx в Docker контейнере

### Конфигурация

Файл `nginx.docker.conf` используется внутри Docker контейнера для раздачи статических файлов.

**Основные настройки:**
- Порт: `8080`
- Корневая директория: `/usr/share/nginx/html`
- Gzip сжатие включено
- Security headers настроены
- Кеширование статических файлов (1 год)
- Health check endpoint: `/health`
- Поддержка SPA routing (try_files)

### Использование

Конфигурация автоматически копируется в контейнер при сборке:

```dockerfile
# В Dockerfile
COPY nginx.docker.conf /etc/nginx/conf.d/default.conf
```

### Проверка конфигурации

```bash
# Войти в контейнер
docker exec -it rsp-prod sh

# Проверить конфигурацию
nginx -t

# Просмотр конфигурации
cat /etc/nginx/conf.d/default.conf
```

### Логи

```bash
# Access лог
docker exec -it rsp-prod tail -f /var/log/nginx/access.log

# Error лог
docker exec -it rsp-prod tail -f /var/log/nginx/error.log
```

## 🌐 Глобальный Nginx (Reverse Proxy)

### Назначение

Глобальный Nginx на хосте используется как reverse proxy для:
- SSL/TLS терминации
- Кеширования на уровне nginx
- Rate limiting и защиты от DDoS
- Централизованного управления несколькими приложениями
- HTTP/2 поддержки

### Установка конфигурации

#### Автоматическая установка

```bash
# Из корневой директории проекта
sh ./bash.scripts/deploy.nginx.conf.sh
```

**Внимание:** Скрипт удаляет все конфигурации из `sites-enabled`. Отредактируйте скрипт перед использованием.

#### Ручная установка

```bash
# 1. Копирование конфигурации reverse proxy
sudo cp nginx/react.conf /etc/nginx/sites-available/rsp

# 2. Создание символической ссылки
sudo ln -s /etc/nginx/sites-available/rsp /etc/nginx/sites-enabled/rsp

# 3. (Опционально) Копирование глобального конфига
sudo cp nginx.conf /etc/nginx/nginx.conf

# 4. Редактирование домена (если нужно)
sudo nano /etc/nginx/sites-available/rsp

# 5. Проверка конфигурации
sudo nginx -t

# 6. Перезапуск nginx
sudo systemctl restart nginx
```

### Конфигурация reverse proxy

Файл `nginx/react.conf` содержит конфигурацию для reverse proxy.

#### Основные блоки

**Upstream:**
```nginx
upstream rsp_backend {
    server 127.0.0.1:3030 max_fails=3 fail_timeout=30s;
    keepalive 32;
    keepalive_requests 100;
    keepalive_timeout 60s;
}
```

**HTTP сервер (редирект на HTTPS):**
```nginx
server {
    listen 80;
    server_name pp-maksim.ru www.pp-maksim.ru;
    return 301 https://$server_name$request_uri;
}
```

**HTTPS сервер:**
```nginx
server {
    listen 443 ssl http2;
    server_name pp-maksim.ru www.pp-maksim.ru;
    
    # SSL сертификаты
    ssl_certificate /etc/letsencrypt/live/pp-maksim.ru/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/pp-maksim.ru/privkey.pem;
    
    # Проксирование на контейнер
    location / {
        proxy_pass http://rsp_backend;
        # ... другие настройки
    }
}
```

### Настройка домена

Отредактируйте файл `/etc/nginx/sites-available/rsp`:

```bash
sudo nano /etc/nginx/sites-available/rsp
```

Замените `pp-maksim.ru` на ваш домен:

```nginx
server_name your-domain.com www.your-domain.com;
```

### SSL/TLS сертификаты

#### Let's Encrypt (Certbot)

```bash
# Установка Certbot
sudo apt-get update
sudo apt-get install certbot python3-certbot-nginx

# Получение сертификата
sudo certbot --nginx -d your-domain.com -d www.your-domain.com

# Автоматическое обновление
sudo certbot renew --dry-run
```

Certbot автоматически обновит конфигурацию nginx.

#### Ручная настройка SSL

Если у вас уже есть сертификаты:

```nginx
ssl_certificate /path/to/fullchain.pem;
ssl_certificate_key /path/to/privkey.pem;
ssl_trusted_certificate /path/to/chain.pem;
```

### Глобальная конфигурация

Файл `nginx.conf` содержит глобальные настройки Nginx.

#### Основные настройки

**Производительность:**
```nginx
worker_processes auto;
worker_connections 4096;
worker_cpu_affinity auto;
```

**Защита от DDoS:**
```nginx
limit_req_zone $binary_remote_addr zone=global_req_limit:20m rate=20r/s;
limit_conn_zone $binary_remote_addr zone=global_conn_limit:20m;
```

**Gzip:**
```nginx
gzip on;
gzip_vary on;
gzip_comp_level 6;
gzip_types text/plain text/css application/json application/javascript;
```

**SSL:**
```nginx
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
ssl_prefer_server_ciphers on;
```

### Проверка и тестирование

#### Проверка конфигурации

```bash
# Проверка синтаксиса
sudo nginx -t

# Проверка конфигурации с выводом путей
sudo nginx -T
```

#### Тестирование после изменений

```bash
# Перезагрузка конфигурации без остановки
sudo nginx -s reload

# Или полный перезапуск
sudo systemctl restart nginx
```

#### Проверка работы

```bash
# Проверка HTTP редиректа
curl -I http://your-domain.com

# Проверка HTTPS
curl -I https://your-domain.com

# Проверка health check
curl https://your-domain.com/health
```

## 🔒 Security Headers

Конфигурация включает следующие security headers:

```nginx
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Permissions-Policy "geolocation=(), microphone=(), camera=()" always;
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
```

### Проверка security headers

```bash
# Проверка headers
curl -I https://your-domain.com

# Или используйте онлайн инструменты:
# - https://securityheaders.com/
# - https://observatory.mozilla.org/
```

## 📊 Кеширование

### Статические файлы

Статические файлы кешируются на 1 год:

```nginx
location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot|webp|avif)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
    access_log off;
}
```

### HTML файлы

HTML файлы не кешируются для поддержки актуальной версии:

```nginx
location / {
    try_files $uri $uri/ /index.html;
    add_header Cache-Control "no-cache, no-store, must-revalidate";
    add_header Pragma "no-cache";
    add_header Expires "0";
}
```

## 🚀 Оптимизация производительности

### Gzip сжатие

Включено для следующих типов файлов:
- text/plain, text/css, text/xml, text/javascript
- application/json, application/javascript, application/xml
- image/svg+xml

### HTTP/2

HTTP/2 включен для HTTPS соединений:

```nginx
listen 443 ssl http2;
```

### Keepalive соединения

Настроены keepalive соединения для upstream:

```nginx
upstream rsp_backend {
    keepalive 32;
    keepalive_requests 100;
    keepalive_timeout 60s;
}
```

## 📝 Логирование

### Access лог

```bash
# Просмотр access лога
sudo tail -f /var/log/nginx/rsp-access.log

# Поиск по логу
sudo grep "404" /var/log/nginx/rsp-access.log

# Статистика запросов
sudo awk '{print $1}' /var/log/nginx/rsp-access.log | sort | uniq -c | sort -rn | head -10
```

### Error лог

```bash
# Просмотр error лога
sudo tail -f /var/log/nginx/rsp-error.log

# Поиск ошибок
sudo grep "error" /var/log/nginx/rsp-error.log
```

### Формат логов

Глобальный конфиг определяет формат логов:

```nginx
log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                '$status $body_bytes_sent "$http_referer" '
                '"$http_user_agent" "$http_x_forwarded_for" '
                'rt=$request_time uct="$upstream_connect_time" uht="$upstream_header_time" urt="$upstream_response_time"';
```

## 🛡️ Защита от DDoS

Глобальная конфигурация включает:

### Rate Limiting

```nginx
limit_req_zone $binary_remote_addr zone=global_req_limit:20m rate=20r/s;
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=100r/s;
limit_req_zone $binary_remote_addr zone=login_limit:10m rate=5r/m;
```

### Connection Limiting

```nginx
limit_conn_zone $binary_remote_addr zone=global_conn_limit:20m;
limit_conn_zone $server_name zone=server_conn_limit:10m;
```

### Блокировка ботов

```nginx
map $http_user_agent $bad_bot {
    default 0;
    ~*(ahrefs|semrush|mj12bot|dotbot|scrapy) 1;
    ~*(nmap|nikto|sqlmap|wget|curl|python) 1;
}
```

## 🔧 Настройка для разных окружений

### Development

Для разработки используйте простую конфигурацию без SSL:

```nginx
server {
    listen 80;
    server_name localhost;
    
    location / {
        proxy_pass http://127.0.0.1:3030;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### Production

Используйте полную конфигурацию с SSL и оптимизациями из `nginx/react.conf`.

### Staging

Используйте production конфигурацию, но с тестовым доменом и сертификатом.

## 🆘 Troubleshooting

### Ошибка: "502 Bad Gateway"

**Причины:**
1. Docker контейнер не запущен
2. Неправильный порт в upstream
3. Контейнер не отвечает на health check

**Решение:**
```bash
# Проверка контейнера
docker ps | grep rsp-prod

# Проверка порта
curl http://127.0.0.1:3030/health

# Проверка логов
docker compose -f docker-compose.prod.yml logs app
sudo tail -f /var/log/nginx/rsp-error.log
```

### Ошибка: "nginx: [emerg] bind() to 0.0.0.0:80 failed"

**Причина:** Порт 80 уже занят другим процессом

**Решение:**
```bash
# Найти процесс
sudo netstat -tulpn | grep :80
sudo lsof -i :80

# Остановить конфликтующий сервис
sudo systemctl stop apache2  # если Apache
```

### Ошибка: "SSL certificate problem"

**Причина:** Неправильный путь к сертификату или истек срок действия

**Решение:**
```bash
# Проверка сертификата
sudo certbot certificates

# Обновление сертификата
sudo certbot renew

# Проверка пути в конфиге
sudo nginx -T | grep ssl_certificate
```

### Проблемы с кешированием

Если изменения не отображаются:

```bash
# Очистка кеша браузера (Ctrl+Shift+Delete)
# Или добавьте версионирование к статическим файлам в build процессе
```

### Проблемы с SPA routing

Убедитесь, что в конфигурации есть:

```nginx
location / {
    try_files $uri $uri/ /index.html;
}
```

## 📚 Дополнительные ресурсы

- [Nginx Official Documentation](https://nginx.org/en/docs/)
- [Nginx Beginner's Guide](https://nginx.org/en/docs/beginners_guide.html)
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)
- [SSL Labs SSL Test](https://www.ssllabs.com/ssltest/)
- [Security Headers Test](https://securityheaders.com/)

## 🔄 Обновление конфигурации

При обновлении конфигурации:

1. Отредактируйте файл конфигурации
2. Проверьте синтаксис: `sudo nginx -t`
3. Перезагрузите конфигурацию: `sudo nginx -s reload`
4. Проверьте работу: `curl -I https://your-domain.com`

**Важно:** Всегда проверяйте конфигурацию перед перезапуском, чтобы не сломать работающий сайт.

---

Для получения дополнительной информации см.:
- [Документация по деплою](./deployment.md)
- [Документация по Docker](./docker.md)
