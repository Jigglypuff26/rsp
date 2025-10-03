git pull
npm i
npm run build
sudo rm -rf /var/www/rsp/build
sudo cp -r ../build /var/www/rsp/
sudo rm -rf /etc/nginx/sites-available/rsp.conf
sudo cp -r ../nginx/rsp.conf /var/www/rsp/rsp.conf
sudo systemctl restart nginx