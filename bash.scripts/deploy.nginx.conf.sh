# удаление (опционально) т.к ещё на этом сервере тестируется другое приложение
# Пример запуска sh ./bash.scripts/deploy.nginx.conf.sh из корнегоко каталога проекта

# ВНИМАНИЕ: Раскомментируйте следующую строку только если хотите удалить ВСЕ сайты
# Это может сломать другие приложения на сервере!
sudo  rm -f /etc/nginx/sites-enabled/*

# Безопасное удаление только нашего конфига
sudo rm -f /etc/nginx/sites-enabled/next.conf

# удаление старого конфига
sudo rm -rf /etc/nginx/sites-available/next.conf

# копирование nginx файла конфигурации
sudo cp -r nginx/next.conf /etc/nginx/sites-available/
# создание ссылки на nginx файл конфигурации
sudo ln -s /etc/nginx/sites-available/next.conf /etc/nginx/sites-enabled/

# копировние глобального конфига nginx
sudo cp -r ./nginx.conf /etc/nginx/nginx.conf

# перезапус nginx
sudo systemctl restart nginx

echo "NGINX конфигурация для приложения установленна"