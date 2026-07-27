# 🧪 Тестирование

Проект использует **React Testing Library** и **Vitest** для тестирования компонентов и логики приложения.

## ⚙️ Настройка

Тестирование настроено через **Vitest**, интегрированный с Vite (см. блок `test` в `vite.config.ts`). Дополнительная настройка не требуется.

### Файлы конфигурации

- `vite.config.ts` - секция `test` (окружение `jsdom`, глобальные API, setup-файл, поддержка CSS)
- `src/setupTests.ts` - подключает матчеры `@testing-library/jest-dom` (библиотека работает и с Vitest, несмотря на название)

## 📝 Написание тестов

### Структура тестов

Тесты должны находиться рядом с тестируемым кодом:

```
component/
├── index.tsx
├── index.test.tsx    # Тесты компонента
└── styles.css
```

Или в папке `__tests__`:

```
component/
├── index.tsx
├── __tests__/
│   └── index.test.tsx
└── styles.css
```

### Базовый пример

Благодаря `globals: true` в конфигурации Vitest, `describe`/`it`/`expect`/`vi` доступны без импорта, но в проекте принято импортировать их явно из `vitest` (см. `src/pages/main/index.test.tsx`):

```typescript
// Button.test.tsx
import { describe, it, expect, vi } from 'vitest';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { Button } from './index';

describe('Button', () => {
  it('renders correctly', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByText('Click me')).toBeInTheDocument();
  });

  it('calls onClick when clicked', async () => {
    const handleClick = vi.fn();
    const user = userEvent.setup();

    render(<Button onClick={handleClick}>Click me</Button>);

    await user.click(screen.getByText('Click me'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });
});
```

## 🎯 Best Practices

### 1. Тестируйте поведение, а не реализацию

```typescript
// ✅ Правильно - тестируем поведение
it('displays error message when validation fails', () => {
  render(<LoginForm />);
  const submitButton = screen.getByRole('button', { name: /submit/i });
  fireEvent.click(submitButton);
  expect(screen.getByText(/email is required/i)).toBeInTheDocument();
});

// ❌ Неправильно - тестируем реализацию
it('sets error state to true', () => {
  const { result } = renderHook(() => useLoginForm());
  act(() => {
    result.current.setError(true);
  });
  expect(result.current.error).toBe(true);
});
```

### 2. Используйте доступные роли и тексты

```typescript
// ✅ Правильно
screen.getByRole('button', { name: /submit/i });
screen.getByLabelText(/email/i);
screen.getByPlaceholderText(/enter email/i);

// ❌ Неправильно
screen.getByTestId('submit-button');
```

### 3. Тестируйте доступность

```typescript
it('has accessible name', () => {
  render(<Button aria-label="Close dialog">×</Button>);
  expect(screen.getByRole('button', { name: /close dialog/i })).toBeInTheDocument();
});
```

### 4. Используйте userEvent вместо fireEvent

```typescript
// ✅ Правильно
const user = userEvent.setup();
await user.click(button);
await user.type(input, 'text');

// ❌ Неправильно
fireEvent.click(button);
fireEvent.change(input, { target: { value: 'text' } });
```

## 🔧 Полезные утилиты

### Рендеринг с провайдерами

```typescript
// test-utils.tsx
import { render } from '@testing-library/react';
import { BrowserRouter } from 'react-router-dom';

const AllTheProviders = ({ children }: { children: React.ReactNode }) => (
  <BrowserRouter>{children}</BrowserRouter>
);

const customRender = (ui: React.ReactElement, options = {}) =>
  render(ui, { wrapper: AllTheProviders, ...options });

export * from '@testing-library/react';
export { customRender as render };
```

### Моки

Vitest использует `vi` вместо глобального `jest`:

```typescript
import { vi } from 'vitest';

// Мок API
vi.mock('../api/user', () => ({
  fetchUser: vi.fn(() => Promise.resolve({ id: 1, name: 'John' })),
}));

// Мок модуля с сохранением остальных экспортов
vi.mock('react-router-dom', async (importOriginal) => ({
  ...(await importOriginal<typeof import('react-router-dom')>()),
  useNavigate: () => vi.fn(),
}));
```

## 📊 Покрытие кода

### Запуск с покрытием

Vitest использует провайдер покрытия `@istanbul` или `@vitest/coverage-v8`, который **не установлен в проекте по умолчанию**. Перед первым запуском добавьте один из них:

```bash
npm install --save-dev @vitest/coverage-v8
```

Затем запустите:

```bash
npx vitest run --coverage
```

### Настройка порогов покрытия

В `vite.config.ts`, в секции `test`:

```typescript
test: {
  globals: true,
  environment: 'jsdom',
  setupFiles: './src/setupTests.ts',
  css: true,
  coverage: {
    provider: 'v8',
    thresholds: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80,
    },
  },
},
```

## 🎭 Типы тестов

### Unit тесты

Тестирование отдельных функций и утилит:

```typescript
// utils.test.ts
import { describe, it, expect } from 'vitest';
import { formatDate, validateEmail } from './utils';

describe('formatDate', () => {
  it('formats date correctly', () => {
    const date = new Date('2024-01-15');
    expect(formatDate(date)).toBe('15 января 2024 г.');
  });
});

describe('validateEmail', () => {
  it('returns true for valid email', () => {
    expect(validateEmail('test@example.com')).toBe(true);
  });

  it('returns false for invalid email', () => {
    expect(validateEmail('invalid-email')).toBe(false);
  });
});
```

### Component тесты

Тестирование React компонентов:

```typescript
// UserCard.test.tsx
import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { UserCard } from './index';

const mockUser = {
  id: 1,
  name: 'John Doe',
  email: 'john@example.com',
};

describe('UserCard', () => {
  it('renders user information', () => {
    render(<UserCard user={mockUser} />);
    expect(screen.getByText('John Doe')).toBeInTheDocument();
    expect(screen.getByText('john@example.com')).toBeInTheDocument();
  });
});
```

### Integration тесты

Тестирование взаимодействия компонентов:

```typescript
// LoginForm.test.tsx
import { describe, it, expect, vi } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { LoginForm } from './index';

describe('LoginForm Integration', () => {
  it('submits form with valid data', async () => {
    const onSubmit = vi.fn();
    const user = userEvent.setup();

    render(<LoginForm onSubmit={onSubmit} />);

    await user.type(screen.getByLabelText(/email/i), 'test@example.com');
    await user.type(screen.getByLabelText(/password/i), 'password123');
    await user.click(screen.getByRole('button', { name: /submit/i }));

    await waitFor(() => {
      expect(onSubmit).toHaveBeenCalledWith({
        email: 'test@example.com',
        password: 'password123',
      });
    });
  });
});
```

## 🐛 Отладка тестов

### Вывод DOM

```typescript
import { screen } from '@testing-library/react';

// Вывести весь DOM
screen.debug();

// Вывести конкретный элемент
screen.debug(screen.getByRole('button'));
```

### UI режим Vitest

Для интерактивной отладки тестов в браузере используйте `@vitest/ui` (уже установлен):

```bash
npx vitest --ui
```

## 📚 Дополнительные ресурсы

- [Vitest Documentation](https://vitest.dev/)
- [React Testing Library Documentation](https://testing-library.com/react)
- [Testing Best Practices](https://kentcdodds.com/blog/common-mistakes-with-react-testing-library)
