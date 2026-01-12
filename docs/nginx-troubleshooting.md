# Устранение проблем с Nginx

## 🔍 Диагностика ошибок

### Проверка статуса службы

```bash
# Статус службы
sudo systemctl status nginx.service

# Детальные логи
sudo journalctl -xeu nginx.service

# Логи ошибок nginx
sudo tail -f /var/log/nginx/error.log
```

### Проверка синтаксиса конфигурации

```bash
# Проверка всей конфигурации
sudo nginx -t

# Проверка с выводом конфигурации
sudo nginx -T

# Проверка конкретного файла
sudo nginx -t -c /etc/nginx/nginx.conf
```

## ❌ Частые ошибки и решения

### 1. "Job for nginx.service failed"

**Причины:**
- Синтаксическая ошибка в конфигурации
- Отсутствуют необходимые файлы/директории
- Конфликт портов
- Проблемы с правами доступа

**Решение:**

```bash
# 1. Проверить синтаксис
sudo nginx -t

# 2. Проверить логи
sudo journalctl -xeu nginx.service | tail -50

# 3. Проверить, не занят ли порт
sudo netstat -tulpn | grep :80
sudo netstat -tulpn | grep :443

# 4. Проверить права доступа
sudo ls -la /etc/nginx/
sudo ls -la /var/log/nginx/
```

### 2. "nginx: [emerg] bind() to 0.0.0.0:80 failed"

**Причина:** Порт 80 или 443 уже занят другим процессом

**Решение:**

```bash
# Найти процесс, использующий порт
sudo lsof -i :80
sudo lsof -i :443

# Остановить процесс или изменить порт в конфигурации
```

### 3. "nginx: [emerg] open() /etc/nginx/... failed (2: No such file or directory)"

**Причина:** Отсутствуют необходимые файлы или директории

**Решение:**

```bash
# Создать недостающие директории
sudo mkdir -p /var/log/nginx
sudo mkdir -p /var/cache/nginx
sudo mkdir -p /etc/nginx/sites-available
sudo mkdir -p /etc/nginx/sites-enabled

# Проверить наличие конфигурационных файлов
sudo ls -la /etc/nginx/sites-available/
sudo ls -la /etc/nginx/sites-enabled/
```

### 4. "nginx: [emerg] SSL_CTX_use_certificate() failed"

**Причина:** Проблемы с SSL сертификатами

**Решение:**

```bash
# Проверить наличие сертификатов
sudo ls -la /etc/letsencrypt/live/your-domain.com/

# Проверить права доступа
sudo chmod 644 /etc/letsencrypt/live/your-domain.com/fullchain.pem
sudo chmod 600 /etc/letsencrypt/live/your-domain.com/privkey.pem

# Обновить сертификаты
sudo certbot renew
```

### 5. "nginx: [emerg] zero size shared memory zone 'general'"

**Причина:** 
- Зоны rate limiting не определены в `nginx.conf`
- Зоны определены после `include` директив
- Используется старая версия `nginx.conf` без зон

**Решение:**

```bash
# 1. Проверьте наличие зон в nginx.conf
sudo grep "limit_req_zone\|limit_conn_zone" /etc/nginx/nginx.conf

# 2. Убедитесь, что зоны определены ДО include
# Порядок должен быть:
#   limit_req_zone ...;
#   limit_conn_zone ...;
#   ...
#   include /etc/nginx/sites-enabled/*;

# 3. Если зон нет, добавьте в блок http ДО include:
limit_req_zone $binary_remote_addr zone=general:10m rate=10r/s;
limit_req_zone $binary_remote_addr zone=api:10m rate=5r/s;
limit_conn_zone $binary_remote_addr zone=conn_limit_per_ip:10m;

# 4. Временно отключите rate limiting в react.conf для диагностики
# Закомментируйте строки:
# limit_req zone=general burst=20 nodelay;
# limit_conn conn_limit_per_ip 10;
```

### 6. "nginx: [emerg] "limit_req_zone" directive is not allowed here"

**Причина:** `limit_req_zone` должен быть в блоке `http`, а не в `server`

**Решение:** Убедитесь, что зоны rate limiting определены в `nginx.conf` в блоке `http` ДО директив `include`

### 7. "nginx: [emerg] "ssl_stapling" requires "resolver" directive"

**Причина:** Для SSL stapling требуется resolver

**Решение:** Добавьте resolver в `nginx.conf`:

```nginx
resolver 8.8.8.8 8.8.4.4 valid=300s;
resolver_timeout 5s;
```

### 7. Вложенные location блоки

**Причина:** Nginx не поддерживает вложенные location блоки в некоторых случаях

**Решение:** Используйте отдельные location блоки:

```nginx
# ❌ Неправильно
location / {
    location = /index.html { ... }
}

# ✅ Правильно
location = /index.html { ... }
location / { ... }
```

## 🔧 Полезные команды

### Перезапуск и перезагрузка

```bash
# Перезапуск службы
sudo systemctl restart nginx

# Перезагрузка конфигурации (без остановки)
sudo nginx -s reload

# Остановка
sudo systemctl stop nginx

# Запуск
sudo systemctl start nginx
```

### Отладка

```bash
# Проверка конфигурации с подробным выводом
sudo nginx -t -c /etc/nginx/nginx.conf

# Просмотр активной конфигурации
sudo nginx -T

# Тестовый запуск в foreground режиме
sudo nginx -t && sudo nginx -g "daemon off;"
```

### Логи

```bash
# Access лог в реальном времени
sudo tail -f /var/log/nginx/access.log

# Error лог в реальном времени
sudo tail -f /var/log/nginx/error.log

# Поиск ошибок в логах
sudo grep -i error /var/log/nginx/error.log
```

## 📝 Чеклист перед деплоем

- [ ] Проверен синтаксис: `sudo nginx -t`
- [ ] Проверены пути к файлам
- [ ] Проверены SSL сертификаты (если используется HTTPS)
- [ ] Проверены права доступа к файлам
- [ ] Проверено, что порты не заняты
- [ ] Проверены зоны rate limiting в nginx.conf
- [ ] Проверен resolver для SSL stapling
- [ ] Нет вложенных location блоков

## 🆘 Если ничего не помогает

1. **Откат к рабочей конфигурации:**
   ```bash
   sudo cp /etc/nginx/nginx.conf.backup /etc/nginx/nginx.conf
   sudo nginx -t && sudo systemctl restart nginx
   ```

2. **Минимальная конфигурация для теста:**
   ```nginx
   server {
       listen 80;
       server_name your-domain.com;
       root /usr/share/nginx/html;
       index index.html;
       
       location / {
           try_files $uri $uri/ /index.html;
       }
   }
   ```

3. **Проверка через Docker:**
   ```bash
   docker run --rm -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro nginx:alpine nginx -t
   ```

## 📚 Дополнительные ресурсы

- [Nginx Error Log](https://nginx.org/en/docs/http/ngx_core_module.html#error_log)
- [Nginx Troubleshooting](https://nginx.org/en/docs/http/ngx_core_module.html#error_log)
