#!/bin/bash

# Скрипт для диагностики и исправления проблем с зонами rate limiting

echo "🔍 Диагностика проблемы с зонами rate limiting..."
echo ""

# Проверка синтаксиса
echo "1. Проверка синтаксиса nginx..."
sudo nginx -t 2>&1 | tee /tmp/nginx-test.log

if grep -q "zero size shared memory zone" /tmp/nginx-test.log; then
    echo ""
    echo "❌ Обнаружена проблема с зонами rate limiting"
    echo ""
    echo "📋 Диагностика:"
    echo ""
    
    echo "2. Проверка зон в nginx.conf:"
    if grep -q "limit_req_zone.*zone=general" /etc/nginx/nginx.conf; then
        echo "   ✅ Зона 'general' найдена в nginx.conf"
        grep -n "limit_req_zone.*zone=general" /etc/nginx/nginx.conf
    else
        echo "   ❌ Зона 'general' НЕ найдена в nginx.conf!"
        echo "   Добавьте в блок http:"
        echo "   limit_req_zone \$binary_remote_addr zone=general:10m rate=10r/s;"
    fi
    
    echo ""
    echo "3. Проверка порядка include в nginx.conf:"
    grep -n "include.*sites-enabled" /etc/nginx/nginx.conf
    
    echo ""
    echo "4. Проверка использования зон в react.conf:"
    if [ -f /etc/nginx/sites-available/react.conf ]; then
        grep -n "limit_req\|limit_conn" /etc/nginx/sites-available/react.conf
    else
        echo "   ⚠️  Файл react.conf не найден"
    fi
    
    echo ""
    echo "🔧 Решения:"
    echo ""
    echo "Вариант 1: Убедитесь, что зоны определены ДО include в nginx.conf"
    echo "   Зоны должны быть в блоке http ПЕРЕД строками:"
    echo "   include /etc/nginx/conf.d/*.conf;"
    echo "   include /etc/nginx/sites-enabled/*;"
    echo ""
    echo "Вариант 2: Временно отключите rate limiting"
    echo "   sudo cp nginx/react.conf.no-ratelimit /etc/nginx/sites-available/react.conf"
    echo "   sudo nginx -t && sudo systemctl restart nginx"
    echo ""
    echo "Вариант 3: Проверьте, что используете обновленный nginx.conf"
    echo "   Убедитесь, что на сервере актуальная версия nginx.conf с зонами"
    
    rm -f /tmp/nginx-test.log
    exit 1
fi

echo ""
echo "✅ Конфигурация корректна"
rm -f /tmp/nginx-test.log
