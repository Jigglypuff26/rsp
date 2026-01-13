# Быстрое решение ошибки 502

## Шаг 1: Проверьте, запущен ли контейнер

```bash
docker ps | grep rsp-prod
```

Если контейнер не запущен:
```bash
docker compose -f docker-compose.prod.yml up -d
```

## Шаг 2: Проверьте доступность порта

```bash
curl http://localhost:3030/health
```

Должен вернуть: `healthy`

Если не работает, проверьте логи:
```bash
docker logs rsp-prod
```

## Шаг 3: Перезапустите контейнер

```bash
docker compose -f docker-compose.prod.yml restart
```

## Шаг 4: Проверьте конфигурацию nginx

```bash
# Проверка синтаксиса
sudo nginx -t

# Перезагрузка конфигурации
sudo nginx -s reload
# или
sudo systemctl reload nginx
```

## Шаг 5: Проверьте логи nginx

```bash
sudo tail -f /var/log/nginx/rsp-error.log
```

## Если все еще не работает

Выполните полную перезагрузку:

```bash
# Остановите контейнер
docker compose -f docker-compose.prod.yml down

# Запустите заново
docker compose -f docker-compose.prod.yml up -d

# Проверьте
curl http://localhost:3030/health

# Перезагрузите nginx
sudo systemctl reload nginx
```

## Проверка финального результата

```bash
# Прямой доступ к контейнеру
curl http://localhost:3030/health

# Через nginx
curl https://pp-maksim.ru/health
```

Оба должны вернуть `healthy`.
