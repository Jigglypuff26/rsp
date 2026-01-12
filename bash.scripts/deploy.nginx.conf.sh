#!/bin/bash

# Скрипт для обновления конфигурации nginx

echo "Обновление конфигурации nginx..."

# Удаление (опционально) т.к ещё на этом сервере тестируется другое приложение
sudo rm -f /etc/nginx/sites-enabled/*

# Удаление старого конфига
sudo rm -rf /etc/nginx/sites-available/react.conf

# Копирование nginx файла конфигурации
sudo cp -r nginx/react.conf /etc/nginx/sites-available/

# Создание ссылки на nginx файл конфигурации
sudo ln -s /etc/nginx/sites-available/react.conf /etc/nginx/sites-enabled/

# Проверка конфигурации перед перезапуском
echo "Проверка конфигурации..."
sudo nginx -t

if [ $? -eq 0 ]; then
    echo "✅ Конфигурация корректна, перезапуск nginx..."
    sudo systemctl restart nginx
    if [ $? -eq 0 ]; then
        echo "✅ NGINX успешно перезапущен"
    else
        echo "❌ Ошибка при перезапуске nginx"
        echo "Проверьте логи: sudo journalctl -xeu nginx.service"
        exit 1
    fi
else
    echo "❌ Ошибка в конфигурации nginx!"
    echo "Исправьте ошибки перед перезапуском"
    exit 1
fi