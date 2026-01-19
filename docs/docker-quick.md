# Docker - Шпаргалка команд

## ⚡ Быстрый старт

### Development (Разработка)
```bash
# Запуск в фоновом режиме
docker compose -f docker/docker-compose.dev.yml -p rsp-dev up -d --build

# Просмотр логов
docker compose -f docker/docker-compose.dev.yml -p rsp-dev logs -f

# Остановка
docker compose -f docker/docker-compose.dev.yml -p rsp-dev down
```
**URL:** http://localhost:3030

### Production (Продакшен)
```bash
# Запуск в фоновом режиме
docker compose -f docker/docker-compose.prod.yml -p rsp-prod up -d --build

# Просмотр логов
docker compose -f docker/docker-compose.prod.yml -p rsp-prod logs -f

# Остановка
docker compose -f docker/docker-compose.prod.yml -p rsp-prod down
```
**URL:** http://localhost:3030

---

## 📋 Основные команды

### Управление контейнерами

```bash
# Запуск (обычный режим с логами)
docker compose -f docker/docker-compose.dev.yml -p rsp-dev up --build

# Запуск в фоновом режиме (-d = detached)
docker compose -f docker/docker-compose.dev.yml -p rsp-dev up -d --build

# Остановка и удаление контейнеров
docker compose -f docker/docker-compose.dev.yml -p rsp-dev down

# Остановка без удаления
docker compose -f docker/docker-compose.dev.yml -p rsp-dev stop

# Запуск остановленных контейнеров
docker compose -f docker/docker-compose.dev.yml -p rsp-dev start

# Перезапуск
docker compose -f docker/docker-compose.dev.yml -p rsp-dev restart
```

### Просмотр информации

```bash
# Статус контейнеров
docker compose -f docker/docker-compose.dev.yml -p rsp-dev ps

# Логи (follow mode)
docker compose -f docker/docker-compose.dev.yml -p rsp-dev logs -f

# Последние 100 строк логов
docker compose -f docker/docker-compose.dev.yml -p rsp-dev logs --tail=100

# Использование ресурсов
docker stats rsp-dev
```

### Сборка

```bash
# Пересборка образов
docker compose -f docker/docker-compose.dev.yml -p rsp-dev build

# Пересборка без кэша
docker compose -f docker/docker-compose.dev.yml -p rsp-dev build --no-cache

# Запуск с пересборкой
docker compose -f docker/docker-compose.dev.yml -p rsp-dev up --build
```

### Очистка

```bash
# Остановка и удаление контейнеров
docker compose -f docker/docker-compose.dev.yml -p rsp-dev down

# Удаление с volumes
docker compose -f docker/docker-compose.dev.yml -p rsp-dev down -v

# Очистка неиспользуемых образов
docker image prune

# Очистка неиспользуемых контейнеров
docker container prune

# Полная очистка системы (осторожно!)
docker system prune -a
```

### Отладка

```bash
# Войти в контейнер
docker exec -it rsp-dev sh

# Выполнить команду в контейнере
docker exec -it rsp-dev npm run build

# Проверка health check
docker inspect --format='{{.State.Health.Status}}' rsp-dev

# Просмотр логов nginx (production)
docker exec -it rsp-prod cat /var/log/nginx/access.log
```

---

## 📖 Справка по флагам

| Флаг | Описание |
|------|----------|
| `up` | Создать и запустить контейнеры |
| `down` | Остановить и удалить контейнеры |
| `start` | Запустить существующие контейнеры |
| `stop` | Остановить контейнеры |
| `restart` | Перезапустить контейнеры |
| `build` | Собрать образы |
| `ps` | Показать статус контейнеров |
| `logs` | Показать логи |
| `exec` | Выполнить команду в контейнере |
| `-d, --detach` | Фоновый режим |
| `--build` | Пересобрать перед запуском |
| `-f` | Файл docker-compose |
| `-p` | Имя проекта |
| `-v` | Удалить volumes |
| `--no-cache` | Без кэша при сборке |
| `-f` | Follow (для логов) |
| `--tail=N` | Последние N строк |

---

## 💡 Полезные alias (опционально)

Добавьте в ваш `.bashrc` / `.zshrc` / PowerShell profile:

### Bash/Zsh
```bash
# Development
alias dev-up="docker compose -f docker/docker-compose.dev.yml -p rsp-dev up -d --build"
alias dev-down="docker compose -f docker/docker-compose.dev.yml -p rsp-dev down"
alias dev-logs="docker compose -f docker/docker-compose.dev.yml -p rsp-dev logs -f"
alias dev-restart="docker compose -f docker/docker-compose.dev.yml -p rsp-dev restart"

# Production
alias prod-up="docker compose -f docker/docker-compose.prod.yml -p rsp-prod up -d --build"
alias prod-down="docker compose -f docker/docker-compose.prod.yml -p rsp-prod down"
alias prod-logs="docker compose -f docker/docker-compose.prod.yml -p rsp-prod logs -f"
alias prod-restart="docker compose -f docker/docker-compose.prod.yml -p rsp-prod restart"
```

### PowerShell
```powershell
# Development
function dev-up { docker compose -f docker/docker-compose.dev.yml -p rsp-dev up -d --build }
function dev-down { docker compose -f docker/docker-compose.dev.yml -p rsp-dev down }
function dev-logs { docker compose -f docker/docker-compose.dev.yml -p rsp-dev logs -f }
function dev-restart { docker compose -f docker/docker-compose.dev.yml -p rsp-dev restart }

# Production
function prod-up { docker compose -f docker/docker-compose.prod.yml -p rsp-prod up -d --build }
function prod-down { docker compose -f docker/docker-compose.prod.yml -p rsp-prod down }
function prod-logs { docker compose -f docker/docker-compose.prod.yml -p rsp-prod logs -f }
function prod-restart { docker compose -f docker/docker-compose.prod.yml -p rsp-prod restart }
```

---

## 📚 Дополнительная документация

Подробная документация: [docs/docker.md](./docs/docker.md)

### Содержание:
- Структура файлов
- Особенности Development и Production режимов
- Переменные окружения
- Nginx конфигурация
- Оптимизации и best practices
- Troubleshooting
- Особенности работы с Vite

---

**Требования:**
- Docker >= 20.x (рекомендуется 29.x)
- Docker Compose >= 2.x
