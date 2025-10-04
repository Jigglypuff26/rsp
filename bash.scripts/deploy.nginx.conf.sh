# удаление всех старых ссылок
sudo  rm -f /etc/nginx/sites-enabled/*

# удаление старого конфига
sudo rm -rf /etc/nginx/sites-available/react.conf
# sudo rm -rf /etc/nginx/sites-enabled/react.conf

# копирование nginx файла конфигурации
sudo cp -r nginx/react.conf /etc/nginx/sites-available/
# создание ссылки на nginx файл конфигурации
sudo ln -s /etc/nginx/sites-available/react.conf /etc/nginx/sites-enabled/
# перезапус nginx
sudo systemctl restart nginx