#!/bin/bash
# Скрипт установки конфигурации Nginx для RSP проекта
# Пример запуска: sh ./bash.scripts/deploy.nginx.conf.sh из корневого каталога проекта

set -e  # Остановка при ошибке

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Проверка прав root
if [ "$EUID" -ne 0 ]; then 
    error "Пожалуйста, запустите скрипт с правами root (sudo)"
    exit 1
fi

info "Начало установки конфигурации Nginx для RSP проекта"

# Имена файлов
SITE_NAME="rsp"
NGINX_CONF_SOURCE="nginx/nginx.conf"
NGINX_AVAILABLE="/etc/nginx/sites-available/${SITE_NAME}"
NGINX_ENABLED="/etc/nginx/sites-enabled/${SITE_NAME}"

# Проверка наличия исходного файла
if [ ! -f "$NGINX_CONF_SOURCE" ]; then
    error "Файл конфигурации не найден: $NGINX_CONF_SOURCE"
    exit 1
fi

# ВНИМАНИЕ: Раскомментируйте следующую строку только если хотите удалить ВСЕ сайты
# Это может сломать другие приложения на сервере!
# sudo rm -f /etc/nginx/sites-enabled/*

# Безопасное удаление только нашего конфига
if [ -L "$NGINX_ENABLED" ]; then
    info "Удаление старого симлинка: $NGINX_ENABLED"
    sudo rm -f "$NGINX_ENABLED"
fi

# Создание резервной копии существующей конфигурации (если есть)
if [ -f "$NGINX_AVAILABLE" ]; then
    BACKUP_FILE="${NGINX_AVAILABLE}.backup.$(date +%Y%m%d_%H%M%S)"
    info "Создание резервной копии: $BACKUP_FILE"
    sudo cp "$NGINX_AVAILABLE" "$BACKUP_FILE"
fi

# Копирование конфигурации
info "Копирование конфигурации в $NGINX_AVAILABLE"
sudo cp "$NGINX_CONF_SOURCE" "$NGINX_AVAILABLE"
sudo chmod 644 "$NGINX_AVAILABLE"
info "Конфигурация скопирована"

# Создание симлинка
info "Создание симлинка в $NGINX_ENABLED"
sudo ln -s "$NGINX_AVAILABLE" "$NGINX_ENABLED"
info "Симлинк создан"

# ВАЖНО: НЕ копируем nginx.conf в основной файл!
# Основной файл /etc/nginx/nginx.conf должен содержать только общую конфигурацию
# Блоки server должны быть в sites-available/

# Проверка синтаксиса конфигурации
info "Проверка синтаксиса конфигурации nginx..."
if sudo nginx -t; then
    info "Синтаксис конфигурации корректен"
else
    error "Ошибка в конфигурации nginx!"
    error "Проверьте файл: $NGINX_AVAILABLE"
    exit 1
fi

# Перезагрузка nginx
info "Перезагрузка nginx..."
sudo systemctl reload nginx
info "Nginx перезагружен"

info "Конфигурация успешно установлена!"
info "Файлы:"
info "  Доступна: $NGINX_AVAILABLE"
info "  Включена: $NGINX_ENABLED"
echo
warn "ВАЖНО: Убедитесь, что:"
echo "  1. Docker контейнер запущен: docker compose -f docker-compose.prod.yml up -d"
echo "  2. Контейнер доступен на порту 3030: curl http://localhost:3030/health"
echo "  3. SSL сертификаты настроены (если используется HTTPS)"