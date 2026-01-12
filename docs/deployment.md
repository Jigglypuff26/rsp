# Деплой приложения

Проект поддерживает несколько способов развертывания: Docker, статический хостинг и традиционный сервер.

## 🐳 Docker

### Требования

- **Docker** >= 20.x (протестировано с версией 29.1.3)
- **Docker Compose** >= 2.x

### Разработка

```bash
# Сборка и запуск
docker compose -f docker-compose.dev.yml -p rsp-dev up --build

# Запуск в фоновом режиме
docker compose -f docker-compose.dev.yml -p rsp-dev up -d

# Остановка
docker compose -f docker-compose.dev.yml -p rsp-dev down

# Просмотр логов
docker compose -f docker-compose.dev.yml -p rsp-dev logs -f
```

Приложение будет доступно по адресу `http://localhost:3000`

**Особенности dev-режима:**
- Hot-reload включен (изменения в коде применяются автоматически)
- Используется `docker/dev/Dockerfile.dev`

### Продакшен

```bash
# Сборка и запуск
docker compose -f docker-compose.prod.yml -p rsp-prod up --build

# Запуск в фоновом режиме
docker compose -f docker-compose.prod.yml -p rsp-prod up -d

# Остановка
docker compose -f docker-compose.prod.yml -p rsp-prod down

# Просмотр логов
docker compose -f docker-compose.prod.yml -p rsp-prod logs -f
```

Приложение будет доступно по адресу `http://localhost` (порт 80)

**Примечание:** Если порт 80 занят другим процессом, можно изменить порт в `docker-compose.prod.yml` (например, на `8080:80` или другой свободный порт).

**Особенности prod-режима:**
- Multi-stage build для оптимизации размера образа
- Используется nginx для раздачи статических файлов
- Включено gzip сжатие и кеширование
- Настроены security headers

### Структура Docker файлов

```
.
├── docker/
│   ├── dev/
│   │   └── Dockerfile.dev    # Development Dockerfile
│   └── prod/
│       └── Dockerfile.prod   # Production Dockerfile (multi-stage)
├── docker-compose.dev.yml    # Development compose
├── docker-compose.prod.yml   # Production compose
├── nginx/
│   └── react.conf            # Nginx конфигурация для production
└── nginx.conf                # Основной конфигурационный файл nginx (опционально)
```

**Примечание:** 
- В Docker 29.x используется команда `docker compose` (с пробелом) вместо `docker-compose` (с дефисом).
- Файлы docker-compose не требуют указания версии при использовании Docker Compose v2.

## 📦 Сборка для продакшена

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

### Nginx

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
    
    - name: Deploy
      run: |
        # Ваша команда деплоя
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

deploy:
  stage: deploy
  script:
    - # Ваша команда деплоя
  only:
    - main
```

## 📊 Мониторинг

### Web Vitals

Проект уже настроен для отслеживания Web Vitals через `reportWebVitals.ts`.

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

## 🔍 Проверка перед деплоем

### Чеклист

- [ ] Код проходит линтер: `npm run lint`
- [ ] Код отформатирован: `npm run format:check`
- [ ] Все тесты проходят: `npm test`
- [ ] Сборка успешна: `npm run build`
- [ ] Переменные окружения настроены
- [ ] Версия обновлена в `package.json`
- [ ] CHANGELOG обновлен (если есть)

## 📚 Дополнительные ресурсы

- [Create React App Deployment](https://create-react-app.dev/docs/deployment)
- [Docker Documentation](https://docs.docker.com/)
- [Nginx Configuration](https://nginx.org/en/docs/)
