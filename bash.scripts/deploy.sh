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

# работа с конфигом nginx
./deploy.nginx.conf.sh
# # удаление (опционально) т.к ещё на этом сервере тестируется другое приложение
# sudo  rm -f /etc/nginx/sites-enabled/*

# # удаление старого конфига
# sudo rm -rf /etc/nginx/sites-available/react.conf

# # копирование nginx файла конфигурации
# sudo cp -r nginx/react.conf /etc/nginx/sites-available/
# # создание ссылки на nginx файл конфигурации
# sudo ln -s /etc/nginx/sites-available/react.conf /etc/nginx/sites-enabled/
# # перезапус nginx
# sudo systemctl restart nginx

echo "Все прошло успешно"