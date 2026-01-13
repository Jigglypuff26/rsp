# Исправление ошибки: "server directive is not allowed here"

## Проблема

Ошибка возникает, когда блоки `server` попадают в основной файл `/etc/nginx/nginx.conf`. 
Основной файл должен содержать только общую конфигурацию (events, http блоки), а блоки `server` должны быть в отдельных файлах в `sites-available/`.

## Быстрое решение

### Шаг 1: Восстановите основной файл nginx.conf

```bash
sudo ./bash.scripts/fix-nginx-main-conf.sh
```

Или вручную:

```bash
# Создайте резервную копию
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.broken

# Восстановите стандартный файл (Ubuntu/Debian)
sudo apt install --reinstall nginx-common
```

### Шаг 2: Установите правильную конфигурацию сайта

```bash
sudo ./bash.scripts/deploy.nginx.conf.sh
```

## Проверка

```bash
# Проверьте синтаксис
sudo nginx -t

# Должно быть: "syntax is ok" и "test is successful"

# Перезагрузите nginx
sudo systemctl reload nginx
```

## Структура файлов nginx

Правильная структура:

```
/etc/nginx/
├── nginx.conf              # Основной файл (НЕ должен содержать server блоки!)
│   ├── events { ... }
│   └── http {
│       ├── include /etc/nginx/sites-enabled/*;
│       └── ...
│       }
└── sites-available/
    └── rsp                 # Конфигурация вашего сайта (содержит server блоки)
        └── upstream { ... }
        └── server { ... }
└── sites-enabled/
    └── rsp -> ../sites-available/rsp  # Симлинк
```

## Что было неправильно

Старый скрипт копировал `nginx.conf` (с блоком server) в `/etc/nginx/nginx.conf`, что вызывало ошибку.

Новый скрипт:
- ✅ Копирует конфигурацию в `/etc/nginx/sites-available/rsp`
- ✅ Создает симлинк в `/etc/nginx/sites-enabled/rsp`
- ✅ НЕ трогает основной файл `/etc/nginx/nginx.conf`
