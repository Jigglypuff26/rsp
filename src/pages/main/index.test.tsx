import { render, screen } from '@testing-library/react';
import { describe, it, expect } from 'vitest';

import { MainPage } from './index';

describe('MainPage', () => {
  it('renders main page', () => {
    render(<MainPage />);
    const textElement = screen.getByText(/правки/i);
    expect(textElement).toBeInTheDocument();
  });
});
