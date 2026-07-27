# 🎨 Стиль кода

Проект использует **ESLint** с конфигурацией **Airbnb** и **Prettier** для обеспечения единообразного стиля кода.

## 📋 Правила ESLint

### Конфигурация

Конфигурация ESLint находится в файле `.eslintrc.json` в корне проекта.

Проект использует:
- `eslint-config-airbnb` - базовые правила Airbnb
- `eslint-config-airbnb-typescript` - правила для TypeScript
- `eslint-config-prettier` - отключение конфликтующих правил
- `eslint-plugin-prettier` - интеграция Prettier

### Основные правила

#### React

- ✅ Используйте функциональные компоненты с arrow functions
- ✅ Используйте деструктуризацию пропсов
- ✅ Используйте `export` вместо `export default` для именованных экспортов
- ❌ Не используйте `React.FC` (неявная типизация)

```typescript
// ✅ Правильно
interface ButtonProps {
  label: string;
  onClick: () => void;
}

export const Button = ({ label, onClick }: ButtonProps) => (
  <button onClick={onClick}>{label}</button>
);

// ❌ Неправильно
export default function Button(props: any) {
  return <button onClick={props.onClick}>{props.label}</button>;
}
```

#### TypeScript

- ✅ Используйте явные типы для пропсов
- ✅ Используйте `interface` для объектов, `type` для union/intersection
- ✅ Избегайте `any`, используйте `unknown` если тип неизвестен
- ✅ Используйте префикс `_` для неиспользуемых переменных

```typescript
// ✅ Правильно
interface User {
  id: number;
  name: string;
}

const getUser = (id: number): Promise<User> => {
  // ...
};

// ❌ Неправильно
const getUser = (id: any): any => {
  // ...
};
```

#### Импорты

- ✅ Группируйте импорты: внешние → внутренние
- ✅ Используйте относительные пути
- ✅ Сортируйте импорты по алфавиту

```typescript
// ✅ Правильно
import React from 'react';
import { useRouter } from 'react-router-dom';

import { Button } from '../../shared/ui';
import { UserCard } from '../../entities/user';

// ❌ Неправильно
import { Button } from '../../shared/ui';
import React from 'react';
import { UserCard } from '../../entities/user';
```

#### Именование

- ✅ Компоненты: `PascalCase` (UserCard, ProductList)
- ✅ Функции/переменные: `camelCase` (getUser, userName)
- ✅ Константы: `UPPER_SNAKE_CASE` (API_URL, MAX_SIZE)
- ✅ Типы/интерфейсы: `PascalCase` (User, ProductProps)

```typescript
// ✅ Правильно
const MAX_USERS = 100;
const getUserName = (user: User): string => user.name;

interface ProductCardProps {
  product: Product;
}

// ❌ Неправильно
const max_users = 100;
const GetUserName = (User: any) => User.name;
```

## 🎨 Правила Prettier

### Конфигурация

Конфигурация Prettier находится в файле `.prettierrc` в корне проекта:

```json
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 100,
  "tabWidth": 2,
  "useTabs": false,
  "arrowParens": "avoid",
  "endOfLine": "lf",
  "bracketSpacing": true,
  "jsxSingleQuote": false,
  "bracketSameLine": false
}
```

### Основные правила

- ✅ Используйте одинарные кавычки для строк
- ✅ Точка с запятой в конце строк
- ✅ Максимальная длина строки: 100 символов
- ✅ Отступ: 2 пробела
- ✅ Trailing comma для многострочных структур

```typescript
// ✅ Правильно
const user = {
  id: 1,
  name: 'John',
  email: 'john@example.com',
};

// ❌ Неправильно
const user = {id:1,name:"John",email:"john@example.com"}
```

## 🔧 Использование

### Автоматическое исправление

```bash
# Исправить ошибки ESLint
npm run lint:fix

# Форматировать код Prettier
npm run format
```

### Интеграция с IDE

#### VS Code

Добавьте в `.vscode/settings.json`:

```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "eslint.validate": [
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact"
  ]
}
```

#### WebStorm

1. Settings → Languages & Frameworks → JavaScript → Code Quality Tools → ESLint
2. Enable ESLint
3. Settings → Editor → Code Style → TypeScript → Enable EditorConfig support

## 📝 Примеры

### Компонент

```typescript
import React from 'react';

import { Button } from '../../shared/ui';
import './styles.css';

interface UserCardProps {
  user: User;
  onEdit: (id: number) => void;
}

export const UserCard = ({ user, onEdit }: UserCardProps) => (
  <div className="user-card">
    <h3>{user.name}</h3>
    <p>{user.email}</p>
    <Button onClick={() => onEdit(user.id)}>Edit</Button>
  </div>
);
```

### Хук

```typescript
import { useState, useEffect } from 'react';

interface UseUserDataResult {
  user: User | null;
  loading: boolean;
  error: Error | null;
}

export const useUserData = (userId: number): UseUserDataResult => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    // ...
  }, [userId]);

  return { user, loading, error };
};
```

### Утилита

```typescript
export const formatDate = (date: Date): string => {
  return new Intl.DateTimeFormat('ru-RU', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  }).format(date);
};

export const validateEmail = (email: string): boolean => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};
```

## 🚫 Что избегать

- ❌ `any` типы
- ❌ `console.log` в production коде
- ❌ Неиспользуемые импорты
- ❌ Комментарии для очевидного кода
- ❌ Магические числа (используйте константы)
- ❌ Вложенные тернарные операторы
- ❌ Слишком длинные функции (>50 строк)

## 📚 Дополнительные ресурсы

- [Airbnb JavaScript Style Guide](https://github.com/airbnb/javascript)
- [TypeScript Style Guide](https://github.com/basarat/typescript-book/blob/master/docs/styleguide/styleguide.md)
- [Prettier Documentation](https://prettier.io/docs/en/)
