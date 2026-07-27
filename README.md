# ⚛️ RSP - React Starter Project

Современный стартовый проект для разработки на React с TypeScript, организованный по методологии Feature-Sliced Design.

## 🚀 Быстрый старт

### Требования

- Node.js >= 20.19.x
- npm >= 8.x

### Установка

```bash
# Клонировать репозиторий
git clone https://github.com/Jigglypuff26/rsp.git

# Перейти в директорию проекта
cd rsp

# Установить зависимости
npm install
```

### Запуск проекта

```bash
# Запуск в режиме разработки
npm run dev

# Сборка для продакшена
npm run build

# Предпросмотр production сборки
npm run preview

# Запуск тестов
npm run test
```

## 📁 Структура проекта

Проект организован по методологии [Feature-Sliced Design](https://feature-sliced.design/).

```
src/
├── app/           # Инициализация приложения, провайдеры, роутинг
├── pages/         # Страницы приложения
├── widgets/       # Крупные самостоятельные блоки
├── features/      # Функциональность пользователя
├── entities/      # Бизнес-сущности
└── shared/        # Переиспользуемые компоненты, утилиты, UI-кит
```

Подробнее о структуре проекта см. в [документации по архитектуре](./docs/architecture.md).

## 🛠 Технологический стек

- **React** 19.2.8 - UI библиотека
- **TypeScript** 6.0.3 - типизация
- **Vite** 8.1.5 - сборщик и dev сервер
- **Vitest** 4.1.10 - тестирование
- **React Router** 7.18.1 - маршрутизация
- **Zustand** 5.0.14 - управление состоянием
- **ESLint** + **Prettier** - качество кода
- **React Testing Library** - компонентное тестирование

## 📜 Доступные команды

| Команда | Описание |
|---------|----------|
| `npm run dev` | Запуск приложения в режиме разработки (Vite dev server) |
| `npm run build` | Сборка приложения для продакшена |
| `npm run preview` | Предпросмотр production сборки |
| `npm run test` | Запуск тестов в watch режиме (Vitest) |
| `npm run lint` | Проверка кода линтером |
| `npm run lint:fix` | Автоматическое исправление ошибок линтера |
| `npm run format` | Форматирование кода с помощью Prettier |
| `npm run format:check` | Проверка форматирования без изменений |
| `npm run code:check` | Проверка кода линтером и форматированием |
| `npm run code:fix` | Автоматическое исправление ошибок и форматирование |
| `npm run update` | Обновление всех зависимостей до последних версий |
| `npm run docker:dev` | Запуск dev-контейнера (с логами в терминале) |
| `npm run docker:dev:bg` | Запуск dev-контейнера в фоновом режиме |
| `npm run docker:dev:down` | Остановка и удаление dev-контейнера |
| `npm run docker:dev:logs` | Просмотр логов dev-контейнера |
| `npm run docker:prod` | Запуск prod-контейнера (с логами в терминале) |
| `npm run docker:prod:bg` | Запуск prod-контейнера в фоновом режиме |
| `npm run docker:prod:down` | Остановка и удаление prod-контейнера |
| `npm run docker:prod:logs` | Просмотр логов prod-контейнера |

## 📚 Документация

**[Полный список документации](./docs/README.md)**

### Ключевые разделы:

- [Архитектура проекта](./docs/architecture.md) - структура FSD
- [Руководство по разработке](./docs/development.md) - настройка окружения
- [Миграция на Vite](./docs/vite-migration.md) - переход с CRA
- [Production Deployment](./docs/production-deploy.md) - развертывание на сервере
- [Docker - Шпаргалка](./docs/docker-quick.md) - быстрый справочник

## 🐳 Docker

Проект поддерживает запуск в Docker контейнерах.

### Быстрый старт

**Development:**
```bash
docker compose -f docker/docker-compose.dev.yml -p rsp-dev up -d --build
# или короче:
npm run docker:dev:bg
```

**Production:**
```bash
docker compose -f docker/docker-compose.prod.yml -p rsp-prod up -d --build
# или короче:
npm run docker:prod:bg
```

**Документация:**
- [Шпаргалка команд Docker](./docs/docker-quick.md) - быстрый справочник
- [Полная документация Docker](./docs/docker.md) - детальное руководство
- [Production Deployment](./docs/production-deploy.md) - развертывание на сервере

## 📝 Лицензия

ISC

## 👤 Автор

Maksim Vekovshinin

---

Для получения дополнительной информации см. [полную документацию](./docs/).
