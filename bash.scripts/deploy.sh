# cd /home/maksim/rsp
# запуск скрипта  командой  bash полный_адрес_скрипта
# Пример: bash /home/maksim/rsp/build_scripts/deploy.sh
# или Реомендуется!!!!
# запуск скрипта  командой  bash относниельно места запуска скрипта 
# Пример: sh ./bash.scripts/deploy.sh

# подтягиваем изменения
git pull
# удаляем старую папку build
sudo rm -rf build

# обновляем npm пакеты
npm i
# сборка проекта
npm run build

# удаляем папку build из репозитория куда смотрит nginx
sudo rm -rf /var/www/rsp/build
# копируем папку с собранным проектом в репозитоий куда смотрит nginx
sudo cp -r build /var/www/rsp/

# Работа с конфигом nginx
# Удаление (опционально) т.к ещё на этом сервере тестируется другое приложение
sudo rm -f /etc/nginx/sites-enabled/*

# Удаление старого конфига
sudo rm -rf /etc/nginx/sites-available/react.conf

# Копирование nginx файла конфигурации
sudo cp -r nginx/react.conf /etc/nginx/sites-available/

# Создание ссылки на nginx файл конфигурации
sudo ln -s /etc/nginx/sites-available/react.conf /etc/nginx/sites-enabled/

# Проверка конфигурации перед перезапуском
echo "Проверка конфигурации nginx..."
sudo nginx -t

if [ $? -eq 0 ]; then
    echo "✅ Конфигурация корректна, перезапуск nginx..."
    sudo systemctl restart nginx
    if [ $? -ne 0 ]; then
        echo "❌ Ошибка при перезапуске nginx"
        echo "Проверьте логи: sudo journalctl -xeu nginx.service"
        exit 1
    fi
else
    echo "❌ Ошибка в конфигурации nginx!"
    echo "Исправьте ошибки перед перезапуском"
    exit 1
fi

echo "Все прошло успешно"