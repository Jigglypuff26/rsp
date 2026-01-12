# Nginx конфигурации для React приложения

## Файлы конфигурации

- `react.conf.default` - Базовая конфигурация без SSL (используется в Dockerfile по умолчанию)
- `react.conf.docker` - Конфигурация для Docker без SSL (альтернатива default)
- `react.conf` - Конфигурация с SSL для production (домен pp-maksim.ru)
- `react.conf.example` - Пример конфигурации с SSL
- `react.conf.no-ratelimit` - Версия без rate limiting для диагностики

## Использование в Docker

### Без SSL

По умолчанию Dockerfile использует `react.conf.default`. Это работает "из коробки".

Альтернативно можно использовать `react.conf.docker` через volume:
```yaml
volumes:
  - './nginx/react.conf.docker:/etc/nginx/conf.d/default.conf:ro'
```

### С SSL

1. Убедитесь, что SSL сертификаты установлены в `/etc/letsencrypt/live/pp-maksim.ru/`

2. Используйте `react.conf` через volume в docker-compose:
```yaml
volumes:
  - './nginx/react.conf:/etc/nginx/conf.d/default.conf:ro'
  - '/etc/letsencrypt/:/etc/letsencrypt/:ro'
```

## Особенности конфигураций

### react.conf (SSL)
- Настроен для домена pp-maksim.ru
- SSL сертификаты Let's Encrypt
- Редирект HTTP -> HTTPS
- Оптимизация кэширования
- Security headers
- Health check endpoint

### react.conf.default / react.conf.docker (без SSL)
- Работает на порту 80
- Без SSL
- Оптимизация кэширования
- Security headers
- Health check endpoint

## Настройка под свой домен

1. Скопируйте `react.conf.example` в `react.conf`
2. Замените `your-domain.com` на ваш домен
3. Обновите пути к SSL сертификатам
4. Используйте через volume в docker-compose

## Health Check

Все конфигурации включают health check endpoint:
```
GET /health
```

Возвращает: `200 OK` с текстом "healthy"

## Troubleshooting

### Ошибка "zero size shared memory zone"
Используйте `react.conf.no-ratelimit` (без rate limiting)

### SSL сертификаты не найдены
Убедитесь, что:
1. Сертификаты установлены через certbot
2. Volume правильно смонтирован в docker-compose
3. Пути к сертификатам правильные в конфигурации

### 502 Bad Gateway
Проверьте:
1. Контейнер запущен: `docker ps`
2. Health check: `curl http://localhost:8080/health`
3. Логи nginx: `docker logs prod-mod`
