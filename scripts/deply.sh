git pull
sudo rm -rf build

# app actions
npm i
npm run build

# copy to dir
sudo rm -rf /var/www/rsp/build
sudo cp -r build /var/www/rsp/

# nginx
sudo rm -rf /etc/nginx/sites-available/rsp.conf
sudo cp -r ~/rsp/nginx/. /etc/nginx/sites-available/
sudo rm -rf /etc/nginx/sites-enabled/rsp.conf
sudo ln -s /etc/nginx/sites-available/rsp.conf /etc/nginx/sites-enabled/
sudo systemctl restart nginx