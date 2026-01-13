#!/bin/bash
# Скрипт для проверки доступности Docker контейнера

echo "Проверка доступности контейнера RSP..."

# Проверка, запущен ли контейнер
if ! docker ps | grep -q "rsp-prod"; then
    echo "❌ ОШИБКА: Контейнер rsp-prod не запущен!"
    echo "Запустите контейнер: docker compose -f docker-compose.prod.yml up -d"
    exit 1
fi

echo "✅ Контейнер запущен"

# Проверка порта на хосте
if curl -s -o /dev/null -w "%{http_code}" http://localhost:3030/health | grep -q "200"; then
    echo "✅ Контейнер доступен на localhost:3030"
else
    echo "❌ ОШИБКА: Контейнер недоступен на localhost:3030"
    echo "Проверьте проброс портов в docker-compose.prod.yml"
    exit 1
fi

# Проверка изнутри контейнера
if docker exec rsp-prod curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/health | grep -q "200"; then
    echo "✅ Nginx внутри контейнера работает на порту 8080"
else
    echo "❌ ОШИБКА: Nginx внутри контейнера не отвечает"
    exit 1
fi

# Проверка подключения nginx к контейнеру
if curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:3030/health | grep -q "200"; then
    echo "✅ Nginx может подключиться к контейнеру через 127.0.0.1:3030"
else
    echo "❌ ОШИБКА: Nginx не может подключиться к контейнеру"
    echo "Проверьте конфигурацию nginx и убедитесь, что порт 3030 проброшен"
    exit 1
fi

echo ""
echo "✅ Все проверки пройдены успешно!"
echo "Контейнер готов к работе с nginx"
