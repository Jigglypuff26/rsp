#!/bin/bash

# Скрипт для проверки конфигурации nginx перед применением

echo "Проверка конфигурации nginx..."

# Проверка синтаксиса глобального конфига
echo "1. Проверка nginx.conf..."
sudo nginx -t -c /etc/nginx/nginx.conf

if [ $? -ne 0 ]; then
    echo "❌ Ошибка в nginx.conf"
    exit 1
fi

# Проверка конфигурации приложения
echo "2. Проверка react.conf..."
if [ -f /etc/nginx/sites-available/react.conf ]; then
    # Временная проверка через тестовый запуск
    sudo nginx -t
    if [ $? -ne 0 ]; then
        echo "❌ Ошибка в react.conf"
        echo "Проверьте логи: sudo journalctl -xeu nginx.service"
        exit 1
    fi
else
    echo "⚠️  Файл react.conf не найден в /etc/nginx/sites-available/"
fi

echo "✅ Конфигурация nginx корректна"
