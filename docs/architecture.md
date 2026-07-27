# 🏛️ Архитектура проекта

Проект организован по методологии **Feature-Sliced Design (FSD)** - современному подходу к организации фронтенд-кода.

## 🏗 Структура папок

```
src/
├── app/                    # Слой приложения
│   ├── App.tsx             # Корневой компонент
│   ├── providers/          # Провайдеры (Context, Router и т.д.)
│   └── index.ts            # Публичный API слоя
│
├── pages/                  # Слой страниц
│   ├── main/               # Главная страница
│   │   ├── index.tsx
│   │   ├── styles.css
│   │   └── index.test.tsx
│   └── index.ts            # Публичный API слоя
│
├── widgets/                # Слой виджетов
│   └── index.ts            # Крупные самостоятельные блоки
│
├── features/               # Слой фич
│   └── index.ts            # Функциональность пользователя
│
├── entities/               # Слой сущностей
│   └── index.ts            # Бизнес-сущности
│
└── shared/                 # Слой переиспользования
    ├── ui/                 # UI компоненты
    ├── lib/                # Утилиты и библиотеки
    ├── config/             # Конфигурация
    │   └── styles/         # Глобальные стили
    └── assets/             # Статические ресурсы
```

## 📐 Слои FSD

### 1. **app** - Инициализация приложения
- Настройка провайдеров (Router, Store, Theme и т.д.)
- Инициализация приложения
- Глобальная конфигурация

### 2. **pages** - Страницы приложения
- Композиция виджетов и фич
- Маршрутизация страниц
- Каждая страница - отдельная папка

### 3. **widgets** - Виджеты
- Крупные самостоятельные блоки интерфейса
- Композиция из фич и сущностей
- Примеры: Header, Sidebar, ProductList

### 4. **features** - Фичи
- Функциональность пользователя
- Примеры: авторизация, добавление в корзину, поиск
- Может использовать сущности и shared

### 5. **entities** - Сущности
- Бизнес-сущности приложения
- Примеры: User, Product, Order
- Независимы от бизнес-логики

### 6. **shared** - Переиспользование
- UI компоненты (кнопки, инпуты)
- Утилиты и хелперы
- Конфигурация и константы
- Статические ресурсы

## 🔄 Правила импортов

### Иерархия слоев

Импорты могут идти только **вверх** по слоям:

```
app → pages → widgets → features → entities → shared
```

### Правила

1. ✅ **Можно**: импортировать из нижних слоев
   ```typescript
   // В pages можно импортировать из widgets, features, entities, shared
   import { Button } from '../../shared/ui';
   import { UserCard } from '../../entities/user';
   ```

2. ❌ **Нельзя**: импортировать из верхних слоев
   ```typescript
   // В shared НЕЛЬЗЯ импортировать из app, pages, widgets
   // ❌ Неправильно:
   import { MainPage } from '../../pages/main';
   ```

3. ✅ **Можно**: импортировать внутри одного слоя
   ```typescript
   // В features можно импортировать из других features
   import { AuthFeature } from '../auth';
   ```

### Примеры правильных импортов

```typescript
// ✅ В pages/main/index.tsx
import { Header } from '../../widgets/header';
import { ProductCard } from '../../entities/product';
import { Button } from '../../shared/ui';

// ✅ В widgets/header/index.tsx
import { UserMenu } from '../../features/user-menu';
import { Logo } from '../../shared/ui';

// ✅ В features/user-menu/index.tsx
import { User } from '../../entities/user';
import { Button } from '../../shared/ui';
```

## 📦 Организация модулей

Каждый модуль должен содержать:

```
feature-name/
├── index.tsx          # Основной компонент/логика
├── index.ts           # Публичный API (экспорты)
├── styles.css         # Стили модуля
├── index.test.tsx     # Тесты
└── lib/               # Внутренние утилиты (опционально)
```

### Публичный API

Каждый слой должен экспортировать только необходимые части через `index.ts`:

```typescript
// shared/ui/index.ts
export { Button } from './button';
export { Input } from './input';
// Не экспортируем внутренние утилиты
```

## 🎯 Принципы

1. **Изоляция слоев** - каждый слой знает только о нижних слоях
2. **Публичный API** - экспортируйте только необходимое
3. **Относительные пути** - используйте относительные импорты
4. **Один модуль - одна папка** - вся логика модуля в одной папке

## 📚 Дополнительные ресурсы

- [Официальная документация FSD](https://feature-sliced.design/)
- [Примеры проектов на FSD](https://github.com/feature-sliced/examples)
