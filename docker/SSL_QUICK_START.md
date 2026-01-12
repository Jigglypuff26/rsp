# Быстрый старт: Настройка SSL

## Шаг 1: Получите SSL сертификат

```bash
# Остановите контейнер
docker compose -f docker-compose.prod.yml -p rsp-prod down

# Установите certbot (если не установлен)
sudo apt install certbot  # для Ubuntu/Debian
# или
sudo yum install certbot  # для CentOS/RHEL

# Получите сертификат
sudo certbot certonly --standalone \
  -d pp-maksim.ru \
  -d www.pp-maksim.ru \
  --email your-email@example.com \
  --agree-tos
```

## Шаг 2: Проверьте сертификаты

```bash
sudo ls -la /etc/letsencrypt/live/pp-maksim.ru/
```

Должны быть файлы: `fullchain.pem` и `privkey.pem`

## Шаг 3: Запустите контейнер

```bash
docker compose -f docker-compose.prod.yml -p rsp-prod up -d
```

## Шаг 4: Проверьте работу

```bash
# HTTP должен редиректить на HTTPS
curl -I http://pp-maksim.ru

# HTTPS должен работать
curl -I https://pp-maksim.ru
```

## Готово! 🎉

Ваше приложение доступно по адресу: **https://pp-maksim.ru**

## Если что-то не работает

1. **Проверьте логи:**
```bash
docker logs prod-mod
```

2. **Проверьте конфигурацию nginx:**
```bash
docker exec -it prod-mod nginx -t
```

3. **Проверьте что сертификаты смонтированы:**
```bash
docker exec -it prod-mod ls -la /etc/letsencrypt/live/pp-maksim.ru/
```

Подробная инструкция: см. `docker/SSL_SETUP.md`
