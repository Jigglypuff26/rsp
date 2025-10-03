# cd /home/maksim/rsp
# запуск скрипта  командой  bash полный_адрес_скрипта
# Пример: bash /home/maksim/rsp/build_scripts/deploy.sh
git pull
sudo rm -rf build

npm i
npm run build

sudo rm -rf /var/www/rsp/build
sudo cp -r build /var/www/rsp/

sudo rm -rf /etc/nginx/sites-available/rsp.conf
sudo cp -r nginx/rsp.conf /etc/nginx/sites-available/
sudo rm -rf /etc/nginx/sites-enabled/rsp.conf
sudo ln -s /etc/nginx/sites-available/rsp.conf /etc/nginx/sites-enabled/
sudo systemctl restart nginx