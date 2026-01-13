# syntax=docker/dockerfile:1.4

# ============================================
# Stage 1: Build
# ============================================
FROM node:20-alpine AS builder

# Установка рабочей директории
WORKDIR /app

# Копирование файлов зависимостей для кэширования
COPY package.json package-lock.json ./

# Установка зависимостей с кэшированием
RUN --mount=type=cache,target=/root/.npm \
    npm ci --only=production=false

# Копирование исходного кода
COPY . .

# Сборка приложения
RUN npm run build

# ============================================
# Stage 2: Production
# ============================================
FROM nginx:1.27-alpine AS production

# Установка метаданных
LABEL maintainer="Maksim Vekovshinin"
LABEL description="RSP - React Starter Project Production Image"
LABEL version="0.1.0"

# Копирование собранного приложения
COPY --from=builder /app/build /usr/share/nginx/html

# Установка правильных прав для nginx пользователя
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html

# Открытие порта
EXPOSE 8080

# Установка curl для health check
RUN apk add --no-cache curl

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Запуск nginx
CMD ["nginx", "-g", "daemon off;"]
