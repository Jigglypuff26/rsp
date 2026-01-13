# Troubleshooting: Ошибка 502 Bad Gateway

## Проблема: Nginx возвращает 502 Bad Gateway

Это означает, что nginx не может подключиться к Docker контейнеру на порту 3030.

## Диагностика

### 1. Проверка запуска контейнера

```bash
# Проверьте, запущен ли контейнер
docker ps | grep rsp-prod

# Если контейнер не запущен, запустите его
docker compose -f docker-compose.prod.yml up -d

# Проверьте логи контейнера
docker logs rsp-prod
```

### 2. Проверка доступности порта

```bash
# Проверьте, слушает ли контейнер на порту 3030
curl http://localhost:3030/health

# Или используйте netstat
netstat -tuln | grep 3030

# Или ss
ss -tuln | grep 3030
```

### 3. Проверка изнутри контейнера

```bash
# Войдите в контейнер
docker exec -it rsp-prod sh

# Проверьте, работает ли nginx внутри контейнера
curl http://localhost:8080/health

# Выйдите из контейнера
exit
```

### 4. Использование скрипта проверки

```bash
# Сделайте скрипт исполняемым
chmod +x nginx/check-container.sh

# Запустите проверку
./nginx/check-container.sh
```

## Решения

### Решение 1: Контейнер не запущен

```bash
# Запустите контейнер
docker compose -f docker-compose.prod.yml up -d

# Проверьте статус
docker ps
```

### Решение 2: Порт не проброшен

Убедитесь, что в `docker-compose.prod.yml` правильно указан порт:

```yaml
ports:
  - "3030:8080"
```

Перезапустите контейнер:
```bash
docker compose -f docker-compose.prod.yml down
docker compose -f docker-compose.prod.yml up -d
```

### Решение 3: Порт занят другим процессом

```bash
# Найдите процесс, использующий порт 3030
sudo lsof -i :3030
# или
sudo netstat -tulpn | grep 3030

# Остановите процесс или измените порт в docker-compose.prod.yml
```

### Решение 4: Проблемы с сетью Docker

```bash
# Пересоздайте сеть
docker compose -f docker-compose.prod.yml down
docker network prune
docker compose -f docker-compose.prod.yml up -d
```

### Решение 5: Nginx не может подключиться к localhost

Если nginx работает в контейнере или в другой сети, используйте IP адрес Docker сети:

```bash
# Найдите IP адрес контейнера
docker inspect rsp-prod | grep IPAddress

# Обновите nginx.conf, заменив 127.0.0.1:3030 на IP:3030
# Или используйте имя контейнера, если nginx в той же Docker сети
```

### Решение 6: Проверка конфигурации nginx

```bash
# Проверьте синтаксис конфигурации
sudo nginx -t

# Проверьте, что конфигурация загружена
sudo nginx -T | grep rsp_backend

# Перезагрузите nginx
sudo systemctl reload nginx
```

### Решение 7: Проверка логов

```bash
# Логи nginx
sudo tail -f /var/log/nginx/rsp-error.log

# Логи контейнера
docker logs -f rsp-prod

# Системные логи
sudo journalctl -u nginx -f
```

## Проверка после исправления

```bash
# Проверьте доступность через nginx
curl -I https://pp-maksim.ru/health

# Проверьте напрямую контейнер
curl http://localhost:3030/health

# Проверьте статус nginx
sudo systemctl status nginx
```

## Дополнительные команды

```bash
# Просмотр всех портов контейнера
docker port rsp-prod

# Проверка сетевых подключений контейнера
docker network inspect rsp-prod-network

# Тест подключения из nginx контейнера (если nginx в Docker)
docker run --rm --network host curlimages/curl:latest curl http://127.0.0.1:3030/health
```

## Если ничего не помогает

1. Полностью пересоздайте контейнер:
```bash
docker compose -f docker-compose.prod.yml down -v
docker compose -f docker-compose.prod.yml up --build -d
```

2. Проверьте firewall:
```bash
# Ubuntu/Debian
sudo ufw status
sudo ufw allow 3030/tcp

# CentOS/RHEL
sudo firewall-cmd --list-ports
sudo firewall-cmd --add-port=3030/tcp --permanent
sudo firewall-cmd --reload
```

3. Проверьте SELinux (если используется):
```bash
sudo getenforce
sudo setenforce 0  # временно отключить для теста
```
