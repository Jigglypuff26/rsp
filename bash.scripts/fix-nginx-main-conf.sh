#!/bin/bash
# Скрипт для восстановления основного файла /etc/nginx/nginx.conf
# Использование: sudo ./bash.scripts/fix-nginx-main-conf.sh

set -e

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

if [ "$EUID" -ne 0 ]; then 
    error "Пожалуйста, запустите скрипт с правами root (sudo)"
    exit 1
fi

NGINX_MAIN_CONF="/etc/nginx/nginx.conf"
BACKUP_FILE="${NGINX_MAIN_CONF}.backup.$(date +%Y%m%d_%H%M%S)"

info "Восстановление основного файла nginx.conf"

# Создание резервной копии текущего файла
if [ -f "$NGINX_MAIN_CONF" ]; then
    info "Создание резервной копии: $BACKUP_FILE"
    cp "$NGINX_MAIN_CONF" "$BACKUP_FILE"
fi

# Создание правильного основного файла nginx.conf
info "Создание правильного основного файла nginx.conf"

cat > "$NGINX_MAIN_CONF" << 'EOF'
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
    worker_connections 768;
    # multi_accept on;
}

http {
    ##
    # Basic Settings
    ##
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    # server_tokens off;

    # server_names_hash_bucket_size 64;
    # server_name_in_redirect off;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    ##
    # SSL Settings
    ##
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;

    ##
    # Logging Settings
    ##
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;
    error_log /var/log/nginx/error.log;

    ##
    # Gzip Settings
    ##
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml text/javascript application/json application/javascript application/xml+rss application/x-javascript image/svg+xml;

    ##
    # Virtual Host Configs
    ##
    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
EOF

info "Основной файл nginx.conf создан"

# Проверка синтаксиса
info "Проверка синтаксиса..."
if nginx -t; then
    info "Синтаксис корректен"
    info "Перезагрузка nginx..."
    systemctl reload nginx
    info "Nginx перезагружен"
    info "Восстановление завершено успешно!"
else
    error "Ошибка в конфигурации!"
    if [ -f "$BACKUP_FILE" ]; then
        warn "Восстановление из резервной копии..."
        cp "$BACKUP_FILE" "$NGINX_MAIN_CONF"
    fi
    exit 1
fi
