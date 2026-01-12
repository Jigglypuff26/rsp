# Руководство по разработке

## 🚀 Настройка окружения

### Требования

- **Node.js** >= 16.x
- **npm** >= 8.x (или **yarn** >= 1.22.x)
- **Docker** >= 20.x (опционально, для контейнеризации, протестировано с версией 29.1.3)
- **Docker Compose** >= 2.x (опционально)

### Первоначальная настройка

```bash
# 1. Клонировать репозиторий
git clone https://github.com/Jigglypuff26/rsp.git
cd rsp

# 2. Установить зависимости
npm install

# 3. Запустить в режиме разработки
npm start
```

Приложение будет доступно по адресу `http://localhost:3000`

## 🔧 Рабочий процесс

### Создание нового компонента

1. Определите слой (shared/ui, entities, features, widgets, pages)
2. Создайте папку с именем компонента
3. Создайте файлы:
   ```bash
   component-name/
   ├── index.tsx
   ├── index.ts
   ├── styles.css
   └── index.test.tsx
   ```

### Пример создания компонента

```bash
# Создание UI компонента Button
mkdir -p src/shared/ui/button
touch src/shared/ui/button/index.tsx
touch src/shared/ui/button/styles.css
touch src/shared/ui/button/index.test.tsx
```

```typescript
// src/shared/ui/button/index.tsx
import React from 'react';
import './styles.css';

interface ButtonProps {
  children: React.ReactNode;
  onClick?: () => void;
  variant?: 'primary' | 'secondary';
}

export const Button = ({ children, onClick, variant = 'primary' }: ButtonProps) => (
  <button className={`button button--${variant}`} onClick={onClick}>
    {children}
  </button>
);
```

```typescript
// src/shared/ui/button/index.ts
export { Button } from './index.tsx';
```

### Создание новой страницы

```bash
# Создание страницы About
mkdir -p src/pages/about
touch src/pages/about/index.tsx
touch src/pages/about/styles.css
```

```typescript
// src/pages/about/index.tsx
import React from 'react';
import './styles.css';

export const AboutPage = () => (
  <div className="about-page">
    <h1>О нас</h1>
  </div>
);
```

```typescript
// src/pages/index.ts
export { AboutPage } from './about';
```

## 🧪 Тестирование

### Запуск тестов

```bash
# Запуск всех тестов
npm test

# Запуск тестов в watch режиме
npm test -- --watch

# Запуск тестов с покрытием
npm test -- --coverage
```

### Написание тестов

```typescript
// component.test.tsx
import React from 'react';
import { render, screen } from '@testing-library/react';
import { Button } from './index';

describe('Button', () => {
  it('renders correctly', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByText('Click me')).toBeInTheDocument();
  });
});
```

Подробнее см. [документацию по тестированию](./testing.md).

## 🔍 Проверка кода

### ESLint

```bash
# Проверка кода
npm run lint

# Автоматическое исправление
npm run lint:fix
```

### Prettier

```bash
# Форматирование кода
npm run format

# Проверка форматирования
npm run format:check
```

## 📦 Управление зависимостями

### Добавление новой зависимости

```bash
# Production зависимость
npm install package-name

# Development зависимость
npm install --save-dev package-name
```

### Обновление зависимостей

```bash
# Проверка устаревших пакетов
npm outdated

# Обновление всех зависимостей
npm run update
npm install
```

## 🐛 Отладка

### React DevTools

Установите расширение [React Developer Tools](https://react.dev/learn/react-developer-tools) для браузера.

### Source Maps

Source maps включены по умолчанию в режиме разработки. Для отладки в production:

```bash
npm run build
# Откройте build/static/js/*.map файлы в DevTools
```

### Логирование

```typescript
// В development режиме
console.log('Debug info', data);

// В production используйте специальные утилиты
import { logger } from '../shared/lib/logger';
logger.info('Info message');
```

## 🔄 Git Workflow

### Создание ветки

```bash
# Создать ветку для новой фичи
git checkout -b feature/new-feature

# Создать ветку для исправления бага
git checkout -b fix/bug-description
```

### Коммиты

Используйте [Conventional Commits](https://www.conventionalcommits.org/):

```bash
git commit -m "feat: add user authentication"
git commit -m "fix: resolve button click issue"
git commit -m "docs: update README"
git commit -m "refactor: reorganize components"
```

### Перед коммитом

```bash
# Проверить линтер
npm run lint

# Форматировать код
npm run format

# Запустить тесты
npm test
```

## 🚢 Подготовка к деплою

```bash
# 1. Проверить код
npm run lint
npm run format:check

# 2. Запустить тесты
npm test

# 3. Собрать проект
npm run build

# 4. Проверить сборку локально
npx serve -s build
```

## 📝 Полезные команды

```bash
# Очистка кэша
npm start -- --reset-cache

# Анализ размера бандла
npm run build
npx source-map-explorer 'build/static/js/*.js'

# Проверка типов TypeScript
npx tsc --noEmit
```

## 🆘 Решение проблем

### Проблемы с зависимостями

```bash
# Удалить node_modules и переустановить
rm -rf node_modules package-lock.json
npm install
```

### Проблемы с кэшем

```bash
# Очистить кэш npm
npm cache clean --force

# Очистить кэш React
npm start -- --reset-cache
```

### Проблемы с портами

Если порт 3000 занят:

```bash
# Использовать другой порт
PORT=3001 npm start
```
