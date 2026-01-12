# Multi-stage build для production
# Stage 1: Сборка приложения
FROM node:18-alpine AS builder

WORKDIR /app

# Копируем файлы зависимостей
COPY package*.json ./

# Устанавливаем зависимости
RUN npm ci --only=production=false

# Копируем исходный код
COPY . .

# Собираем приложение
RUN npm run build

# Stage 2: Production образ с nginx
FROM nginx:alpine

# Копируем собранное приложение в nginx
COPY --from=builder /app/build /usr/share/nginx/html

# Копируем конфигурацию nginx (если есть)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Открываем порт 80
EXPOSE 80

# Запускаем nginx
CMD ["nginx", "-g", "daemon off;"]
