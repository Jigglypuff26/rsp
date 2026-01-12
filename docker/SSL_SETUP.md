# Настройка SSL для Docker контейнера

## Предварительные требования

1. Домен должен указывать на ваш сервер (A-запись)
2. Порты 80 и 443 должны быть открыты в firewall
3. Docker контейнер должен быть остановлен перед получением сертификата

## Шаг 1: Установка Certbot

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install certbot

# CentOS/RHEL
sudo yum install certbot

# Или через snap
sudo snap install --classic certbot
```

## Шаг 2: Получение SSL сертификата

### Вариант A: Standalone (рекомендуется для первого раза)

1. **Остановите Docker контейнер:**
```bash
docker compose -f docker-compose.prod.yml -p rsp-prod down
```

2. **Получите сертификат:**
```bash
sudo certbot certonly --standalone \
  -d pp-maksim.ru \
  -d www.pp-maksim.ru \
  --email your-email@example.com \
  --agree-tos \
  --non-interactive
```

3. **Сертификаты будут сохранены в:**
```
/etc/letsencrypt/live/pp-maksim.ru/
├── fullchain.pem
├── privkey.pem
└── ...
```

### Вариант B: Webroot (если nginx уже работает)

```bash
sudo certbot certonly --webroot \
  -w /var/www/html \
  -d pp-maksim.ru \
  -d www.pp-maksim.ru \
  --email your-email@example.com \
  --agree-tos \
  --non-interactive
```

## Шаг 3: Проверка сертификатов

```bash
# Проверить что сертификаты существуют
sudo ls -la /etc/letsencrypt/live/pp-maksim.ru/

# Должны быть файлы:
# - fullchain.pem
# - privkey.pem
```

## Шаг 4: Настройка docker-compose

Убедитесь что в `docker-compose.prod.yml` раскомментированы volumes:

```yaml
volumes:
  - './nginx/react.conf:/etc/nginx/conf.d/default.conf:ro'
  - '/etc/letsencrypt/:/etc/letsencrypt/:ro'
```

## Шаг 5: Запуск контейнера

```bash
docker compose -f docker-compose.prod.yml -p rsp-prod up -d
```

## Шаг 6: Проверка SSL

```bash
# Проверить что HTTPS работает
curl -I https://pp-maksim.ru

# Проверить сертификат
openssl s_client -connect pp-maksim.ru:443 -servername pp-maksim.ru
```

## Автоматическое обновление сертификатов

Certbot сертификаты действительны 90 дней. Настройте автоматическое обновление:

### Создайте скрипт обновления:

```bash
sudo nano /etc/cron.monthly/renew-certbot
```

Содержимое:
```bash
#!/bin/bash
certbot renew --quiet --deploy-hook "docker compose -f /path/to/docker-compose.prod.yml -p rsp-prod restart frontend"
```

Сделайте исполняемым:
```bash
sudo chmod +x /etc/cron.monthly/renew-certbot
```

### Или используйте systemd timer:

Создайте `/etc/systemd/system/certbot-renew.service`:
```ini
[Unit]
Description=Renew Let's Encrypt certificates

[Service]
ExecStart=/usr/bin/certbot renew --quiet --deploy-hook "docker compose -f /path/to/docker-compose.prod.yml -p rsp-prod restart frontend"
```

И `/etc/systemd/system/certbot-renew.timer`:
```ini
[Unit]
Description=Run certbot renewal twice daily

[Timer]
OnCalendar=*-*-* 00,12:00:00
RandomizedDelaySec=3600

[Install]
WantedBy=timers.target
```

Активируйте:
```bash
sudo systemctl enable certbot-renew.timer
sudo systemctl start certbot-renew.timer
```

## Troubleshooting

### Ошибка: "Failed to bind to port 80"

**Причина:** Порт 80 занят другим процессом

**Решение:**
```bash
# Остановите контейнер перед получением сертификата
docker compose -f docker-compose.prod.yml -p rsp-prod down

# Или найдите и остановите процесс на порту 80
sudo lsof -i :80
sudo kill <PID>
```

### Ошибка: "SSL certificate not found"

**Причина:** Сертификаты не смонтированы в контейнер

**Решение:**
1. Проверьте что сертификаты существуют:
```bash
sudo ls -la /etc/letsencrypt/live/pp-maksim.ru/
```

2. Проверьте volumes в docker-compose.prod.yml:
```yaml
volumes:
  - '/etc/letsencrypt/:/etc/letsencrypt/:ro'
```

3. Перезапустите контейнер:
```bash
docker compose -f docker-compose.prod.yml -p rsp-prod restart
```

### Ошибка: "SSL_CTX_use_PrivateKey_file"

**Причина:** Неправильные права доступа к файлам

**Решение:**
```bash
# Проверьте права
sudo ls -la /etc/letsencrypt/live/pp-maksim.ru/

# Должны быть:
# -r--r--r-- fullchain.pem
# -r-------- privkey.pem
```

### Проверка конфигурации nginx

```bash
# Войти в контейнер
docker exec -it prod-mod sh

# Проверить конфигурацию
nginx -t

# Проверить логи
tail -f /var/log/nginx/error.log
```

## Тестирование локально

Если нужно протестировать SSL локально:

1. Используйте самоподписанный сертификат:
```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx/ssl/key.pem \
  -out nginx/ssl/cert.pem
```

2. Обновите `react.conf` для использования локальных сертификатов:
```nginx
ssl_certificate /etc/nginx/ssl/cert.pem;
ssl_certificate_key /etc/nginx/ssl/key.pem;
```

3. Добавьте volume в docker-compose:
```yaml
volumes:
  - './nginx/ssl:/etc/nginx/ssl:ro'
```

## Полезные команды

```bash
# Проверить срок действия сертификата
sudo certbot certificates

# Обновить сертификат вручную
sudo certbot renew

# Удалить сертификат
sudo certbot delete --cert-name pp-maksim.ru

# Проверить конфигурацию nginx в контейнере
docker exec -it prod-mod nginx -t

# Перезагрузить nginx в контейнере
docker exec -it prod-mod nginx -s reload
```
