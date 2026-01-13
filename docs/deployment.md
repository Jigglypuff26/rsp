# Деплой приложения

Проект поддерживает несколько способов развертывания: Docker, статический хостинг и традиционный сервер с Nginx.

## 🐳 Docker (Рекомендуемый способ)

### Требования

- **Docker** >= 20.x (протестировано с версией 29.1.3)
- **Docker Compose** >= 2.x

### Режим разработки (Development)

Запуск в режиме разработки с hot-reload:

```bash
# Сборка и запуск
docker compose -f docker/docker-compose.dev.yml -p rsp-dev up --build

# Запуск в фоновом режиме
docker compose -f docker/docker-compose.dev.yml -p rsp-dev up -d --build

# Остановка
docker compose -f docker/docker-compose.dev.yml -p rsp-dev down

# Просмотр логов
docker compose -f docker/docker-compose.dev.yml -p rsp-dev logs -f

# Просмотр логов конкретного сервиса
docker compose -f docker/docker-compose.dev.yml -p rsp-dev logs -f app
```

Приложение будет доступно по адресу `http://localhost:3030`

**Особенности dev-режима:**
- ✅ Hot-reload включен (изменения в коде применяются автоматически)
- ✅ Volume монтирование для быстрой синхронизации
- ✅ Polling для работы на Windows/Mac
- ✅ Health check для мониторинга состояния
- ✅ Используется `docker/Dockerfile.dev`

**Переменные окружения для разработки:**
- `NODE_ENV=development`
- `WATCHPACK_POLLING=true` - для работы на Windows/Mac
- `CHOKIDAR_USEPOLLING=true` - для работы на Windows/Mac
- `REACT_APP_ENV=development`

### Продакшен (Production)

Сборка и запуск продакшен версии:

```bash
# Сборка и запуск
docker compose -f docker/docker-compose.prod.yml -p rsp-prod up --build

# Запуск в фоновом режиме
docker compose -f docker/docker-compose.prod.yml -p rsp-prod up -d --build

# Остановка
docker compose -f docker/docker-compose.prod.yml -p rsp-prod down

# Просмотр логов
docker compose -f docker/docker-compose.prod.yml -p rsp-prod logs -f

# Пересборка без кэша
docker compose -f docker/docker-compose.prod.yml -p rsp-prod build --no-cache
```

Приложение будет доступно по адресу `http://localhost:3030` (порт привязан только к localhost для безопасности)

**Примечание:** Если порт 3030 занят другим процессом, можно изменить порт в `docker/docker-compose.prod.yml` (например, на `8080:8080`).

**Особенности prod-режима:**
- ✅ Multi-stage build для оптимизации размера образа
- ✅ Используется nginx для раздачи статических файлов
- ✅ Включено gzip сжатие и кеширование
- ✅ Настроены security headers
- ✅ Health check endpoint на `/health`
- ✅ Ограничения ресурсов (CPU/Memory)
- ✅ Финальный образ основан на `nginx:1.27-alpine` (~25MB)

### Структура Docker файлов

```
.
├── docker/
│   ├── Dockerfile              # Multi-stage build для продакшена
│   ├── Dockerfile.dev          # Образ для разработки
│   ├── docker-compose.dev.yml  # Development compose
│   └── docker-compose.prod.yml # Production compose
├── nginx.docker.conf           # Nginx конфигурация внутри контейнера
└── .dockerignore               # Исключения для Docker build context
```

**Важно:**
- В Docker 29.x используется команда `docker compose` (с пробелом) вместо `docker-compose` (с дефисом)
- Файлы docker-compose не требуют указания версии при использовании Docker Compose v2

### Полезные команды Docker

```bash
# Просмотр используемых ресурсов
docker stats rsp-prod

# Вход в контейнер
docker exec -it rsp-prod sh

# Просмотр информации о контейнере
docker inspect rsp-prod

# Очистка неиспользуемых образов и контейнеров
docker system prune -a

# Просмотр логов с фильтрацией
docker compose -f docker/docker-compose.prod.yml logs -f | grep error

# Перезапуск контейнера
docker compose -f docker/docker-compose.prod.yml restart app
```

### Оптимизация сборки

#### BuildKit

Для использования BuildKit (рекомендуется):

```bash
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
```

Или в `~/.docker/config.json`:
```json
{
  "features": {
    "buildkit": true
  }
}
```

#### Кэширование слоев

Dockerfile оптимизирован для кэширования:
- Зависимости устанавливаются отдельно от кода
- Используется `npm ci` для быстрой установки
- Кэширование npm через BuildKit cache mount

### Troubleshooting

#### Проблемы с hot-reload в dev-режиме

Если изменения не подхватываются автоматически:
1. Проверьте, что volumes правильно смонтированы
2. Убедитесь, что `WATCHPACK_POLLING=true` установлен
3. Перезапустите контейнер: `docker compose -f docker/docker-compose.dev.yml restart`

#### Проблемы с правами доступа

Если возникают проблемы с правами:
```bash
# Проверка прав в контейнере
docker exec -it rsp-prod ls -la /usr/share/nginx/html

# Исправление прав (если нужно)
docker exec -it rsp-prod chown -R nginx:nginx /usr/share/nginx/html
```

#### Проблемы с портами

Если порт занят:
```bash
# Измените порт в docker/docker-compose файле
# ports:
#   - "3001:8080"  # вместо 3030:8080
```

#### Проблемы с памятью

Если сборка падает из-за нехватки памяти:
```bash
# Увеличьте лимит памяти в Docker Desktop
# Или используйте swap файл на Linux
```

## 🌐 Nginx (Reverse Proxy)

Для продакшена рекомендуется использовать глобальный Nginx на хосте как reverse proxy.

### Быстрая настройка

```bash
# Копирование конфигурации
sudo cp nginx/react.conf /etc/nginx/sites-available/rsp
sudo ln -s /etc/nginx/sites-available/rsp /etc/nginx/sites-enabled/rsp

# Копирование глобального конфига (опционально, если нужны дополнительные настройки)
sudo cp nginx.conf /etc/nginx/nginx.conf

# Редактирование домена
sudo nano /etc/nginx/sites-available/rsp

# Проверка конфигурации
sudo nginx -t

# Перезапуск nginx
sudo systemctl restart nginx
```

### Автоматический деплой конфигурации

Используйте скрипт для автоматической установки:

```bash
# Из корневой директории проекта
sh ./bash.scripts/deploy.nginx.conf.sh
```

**Внимание:** Скрипт удаляет все конфигурации из `sites-enabled`. Раскомментируйте строку удаления только если уверены.

### Преимущества использования глобального Nginx

- ✅ SSL/TLS терминация
- ✅ Кэширование на уровне nginx
- ✅ Rate limiting и защита от DDoS
- ✅ Логирование запросов
- ✅ Централизованное управление несколькими приложениями
- ✅ HTTP/2 поддержка

Подробнее см. [документацию по Nginx](./nginx.md).

## 📦 Сборка для продакшена (без Docker)

### Локальная сборка

```bash
# Создать production сборку
npm run build

# Сборка будет в папке build/
```

### Проверка сборки локально

```bash
# Установить serve глобально
npm install -g serve

# Запустить локальный сервер
serve -s build

# Или с указанием порта
serve -s build -l 3000
```

## 🌐 Статический хостинг

### Netlify

1. Подключите репозиторий к Netlify
2. Настройки сборки:
   - **Build command**: `npm run build`
   - **Publish directory**: `build`
3. Добавьте переменные окружения (если нужны)
4. Деплой произойдет автоматически при push в основную ветку

### Vercel

1. Установите Vercel CLI: `npm i -g vercel`
2. Запустите: `vercel`
3. Или подключите репозиторий через веб-интерфейс

### GitHub Pages

1. Установите `gh-pages`: `npm install --save-dev gh-pages`
2. Добавьте в `package.json`:

```json
{
  "scripts": {
    "predeploy": "npm run build",
    "deploy": "gh-pages -d build"
  },
  "homepage": "https://yourusername.github.io/rsp"
}
```

3. Запустите: `npm run deploy`

## 🖥 Традиционный сервер

### Nginx (без Docker)

1. Соберите проект: `npm run build`
2. Скопируйте содержимое `build/` в `/var/www/html/`
3. Настройте Nginx:

```nginx
server {
    listen 80;
    server_name your-domain.com;
    root /var/www/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /static {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

### Apache

1. Соберите проект: `npm run build`
2. Скопируйте содержимое `build/` в `/var/www/html/`
3. Создайте `.htaccess`:

```apache
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteBase /
  RewriteRule ^index\.html$ - [L]
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteRule . /index.html [L]
</IfModule>
```

## 🔐 Переменные окружения

### Создание .env файлов

```bash
# .env.development
REACT_APP_API_URL=http://localhost:3001
REACT_APP_ENV=development

# .env.production
REACT_APP_API_URL=https://api.example.com
REACT_APP_ENV=production
```

### Использование в коде

```typescript
const apiUrl = process.env.REACT_APP_API_URL;
const env = process.env.REACT_APP_ENV;
```

**Важно**: Переменные должны начинаться с `REACT_APP_`

### Переменные в Docker

Для передачи переменных окружения в Docker:

```yaml
# docker/docker-compose.prod.yml
services:
  app:
    environment:
      - REACT_APP_API_URL=https://api.example.com
      - REACT_APP_ENV=production
```

Или через `.env` файл:

```bash
# .env
REACT_APP_API_URL=https://api.example.com
REACT_APP_ENV=production
```

```yaml
# docker/docker-compose.prod.yml
services:
  app:
    env_file:
      - .env
```

## 🚀 CI/CD

### GitHub Actions

Создайте `.github/workflows/deploy.yml`:

```yaml
name: Deploy

on:
  push:
    branches: [ main ]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run tests
      run: npm test -- --coverage --watchAll=false
    
    - name: Build
      run: npm run build
      env:
        REACT_APP_API_URL: ${{ secrets.API_URL }}
    
    - name: Build Docker image
      run: docker build -t rsp:latest .
    
    - name: Deploy
      run: |
        # Ваша команда деплоя
        # Например, push в registry или деплой на сервер
```

### GitLab CI

Создайте `.gitlab-ci.yml`:

```yaml
stages:
  - test
  - build
  - deploy

test:
  stage: test
  image: node:18
  script:
    - npm ci
    - npm test -- --coverage --watchAll=false

build:
  stage: build
  image: node:18
  script:
    - npm ci
    - npm run build
  artifacts:
    paths:
      - build/

docker-build:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker build -t rsp:latest .
    - docker push registry.example.com/rsp:latest
  only:
    - main

deploy:
  stage: deploy
  script:
    - # Ваша команда деплоя
  only:
    - main
```

## 📊 Мониторинг

### Health Check

Приложение имеет встроенный health check endpoint:

```bash
# Проверка здоровья приложения
curl http://localhost:3030/health

# Ожидаемый ответ: "healthy"
```

### Web Vitals

Проект настроен для отслеживания Web Vitals через `reportWebVitals.ts`.

Для отправки метрик в аналитику:

```typescript
// src/shared/lib/reportWebVitals.ts
import { getCLS, getFID, getFCP, getLCP, getTTFB } from 'web-vitals';

const sendToAnalytics = (metric: Metric) => {
  // Отправка в вашу аналитику
  // Например: Google Analytics, Sentry и т.д.
};

getCLS(sendToAnalytics);
getFID(sendToAnalytics);
getFCP(sendToAnalytics);
getLCP(sendToAnalytics);
getTTFB(sendToAnalytics);
```

### Логирование

#### Docker логи

```bash
# Просмотр логов контейнера
docker compose -f docker/docker-compose.prod.yml logs -f app

# Просмотр последних 100 строк
docker compose -f docker/docker-compose.prod.yml logs --tail=100 app

# Просмотр логов nginx внутри контейнера
docker exec -it rsp-prod tail -f /var/log/nginx/access.log
docker exec -it rsp-prod tail -f /var/log/nginx/error.log
```

#### Nginx логи (глобальный)

```bash
# Access лог
sudo tail -f /var/log/nginx/rsp-access.log

# Error лог
sudo tail -f /var/log/nginx/rsp-error.log

# Общий access лог
sudo tail -f /var/log/nginx/access.log
```

## 🔍 Проверка перед деплоем

### Чеклист

- [ ] Код проходит линтер: `npm run lint`
- [ ] Код отформатирован: `npm run format:check`
- [ ] Все тесты проходят: `npm test`
- [ ] Сборка успешна: `npm run build`
- [ ] Переменные окружения настроены
- [ ] Версия обновлена в `package.json`
- [ ] CHANGELOG обновлен (если есть)
- [ ] Docker образ собирается без ошибок
- [ ] Health check работает: `curl http://localhost:3030/health`
- [ ] Nginx конфигурация валидна: `sudo nginx -t`

## 📚 Дополнительные ресурсы

- [Create React App Deployment](https://create-react-app.dev/docs/deployment)
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Nginx Configuration](https://nginx.org/en/docs/)
- [Feature-Sliced Design](https://feature-sliced.design/)

## 🆘 Решение проблем

### Проблемы с Docker

**Ошибка: "port is already allocated"**
```bash
# Найдите процесс, использующий порт
netstat -ano | findstr :3030  # Windows
lsof -i :3030                  # Linux/Mac

# Измените порт в docker/docker-compose файле
```

**Ошибка: "no space left on device"**
```bash
# Очистите неиспользуемые образы
docker system prune -a

# Проверьте использование диска
docker system df
```

### Проблемы с Nginx

**Ошибка: "nginx: [emerg] bind() to 0.0.0.0:80 failed"**
```bash
# Проверьте, не запущен ли другой веб-сервер
sudo netstat -tulpn | grep :80

# Остановите конфликтующий сервис или измените порт
```

**Ошибка: "502 Bad Gateway"**
```bash
# Проверьте, что контейнер запущен
docker ps | grep rsp-prod

# Проверьте логи контейнера
docker compose -f docker/docker-compose.prod.yml logs app

# Проверьте, что порт 3030 доступен
curl http://localhost:3030/health
```

---

Для получения дополнительной информации см.:
- [Документация по Docker](./docker.md)
- [Документация по Nginx](./nginx.md)
- [Руководство по разработке](./development.md)