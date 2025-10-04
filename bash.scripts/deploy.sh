# cd /home/maksim/rsp
# запуск скрипта  командой  bash полный_адрес_скрипта
# Пример: bash /home/maksim/rsp/build_scripts/deploy.sh

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
bash ./deploy.nginx.conf.sh