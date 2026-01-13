# Настройка глобального Nginx

Эта директория содержит конфигурацию для глобального Nginx, который работает как reverse proxy для Docker контейнера.

## Установка

### 1. Установка Nginx (если не установлен)

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install nginx
```

**CentOS/RHEL:**
```bash
sudo yum install nginx
# или для новых версий
sudo dnf install nginx
```

**macOS:**
```bash
brew install nginx
```

### 2. Копирование конфигурации

```bash
# Копируем конфигурацию
sudo cp nginx/nginx.conf /etc/nginx/sites-available/rsp

# Создаем симлинк для активации
sudo ln -s /etc/nginx/sites-available/rsp /etc/nginx/sites-enabled/rsp

# Удаляем дефолтную конфигурацию (опционально)
sudo rm /etc/nginx/sites-enabled/default
```

### 3. Настройка домена

Отредактируйте файл `/etc/nginx/sites-available/rsp` и замените:
- `your-domain.com` на ваш домен
- `www.your-domain.com` на ваш домен с www

Для локальной разработки можно оставить `localhost`.

### 4. SSL сертификаты

#### Для продакшена (Let's Encrypt):

```bash
# Установка certbot
sudo apt install certbot python3-certbot-nginx

# Получение сертификата
sudo certbot --nginx -d your-domain.com -d www.your-domain.com

# Certbot автоматически обновит конфигурацию nginx
```

#### Для разработки (самоподписанный сертификат):

```bash
# Создание директории для сертификатов
sudo mkdir -p /etc/nginx/ssl

# Генерация самоподписанного сертификата
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/key.pem \
    -out /etc/nginx/ssl/cert.pem

# Установка прав
sudo chmod 600 /etc/nginx/ssl/key.pem
sudo chmod 644 /etc/nginx/ssl/cert.pem
```

Затем раскомментируйте в конфигурации:
```nginx
ssl_certificate /etc/nginx/ssl/cert.pem;
ssl_certificate_key /etc/nginx/ssl/key.pem;
```

### 5. Проверка и перезапуск

```bash
# Проверка конфигурации
sudo nginx -t

# Перезапуск nginx
sudo systemctl restart nginx

# Проверка статуса
sudo systemctl status nginx

# Автозапуск при загрузке системы
sudo systemctl enable nginx
```

## Проверка работы

После настройки проверьте:

1. **HTTP редирект:**
   ```bash
   curl -I http://your-domain.com
   # Должен вернуть 301 редирект на HTTPS
   ```

2. **HTTPS доступ:**
   ```bash
   curl -I https://your-domain.com
   # Должен вернуть 200 OK
   ```

3. **Health check:**
   ```bash
   curl https://your-domain.com/health
   # Должен вернуть "healthy"
   ```

## Логи

Логи находятся в:
- Access log: `/var/log/nginx/rsp-access.log`
- Error log: `/var/log/nginx/rsp-error.log`

Просмотр логов:
```bash
# Последние записи
sudo tail -f /var/log/nginx/rsp-access.log
sudo tail -f /var/log/nginx/rsp-error.log
```

## Troubleshooting

### Проблема: 502 Bad Gateway

**Причина:** Контейнер не запущен или недоступен на порту 3030

**Решение:**
```bash
# Проверьте, что контейнер запущен
docker ps

# Проверьте, что контейнер слушает на порту 3030
curl http://localhost:3030/health

# Проверьте логи контейнера
docker logs rsp-prod
```

### Проблема: SSL ошибки

**Причина:** Неправильные пути к сертификатам или неверные права доступа

**Решение:**
```bash
# Проверьте права на сертификаты
sudo ls -la /etc/letsencrypt/live/your-domain.com/

# Проверьте конфигурацию nginx
sudo nginx -t
```

### Проблема: 403 Forbidden

**Причина:** Неправильные права доступа к файлам

**Решение:**
```bash
# Проверьте права на директорию nginx
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html
```

## Дополнительные настройки

### Rate limiting

Добавьте в `http` блок `/etc/nginx/nginx.conf`:
```nginx
limit_req_zone $binary_remote_addr zone=rsp_limit:10m rate=10r/s;
```

И в server блок:
```nginx
limit_req zone=rsp_limit burst=20 nodelay;
```

### Кэширование

Для более агрессивного кэширования статики можно добавить в server блок:
```nginx
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=rsp_cache:10m max_size=1g inactive=60m use_temp_path=off;

location / {
    proxy_cache rsp_cache;
    proxy_cache_valid 200 60m;
    proxy_cache_use_stale error timeout updating http_500 http_502 http_503 http_504;
    proxy_cache_background_update on;
    proxy_cache_lock on;
    
    proxy_pass http://rsp_backend;
    # ... остальные настройки
}
```

## Обновление конфигурации

После изменения конфигурации:
```bash
# Проверка
sudo nginx -t

# Перезагрузка (без простоя)
sudo nginx -s reload

# Или полный перезапуск
sudo systemctl restart nginx
```
