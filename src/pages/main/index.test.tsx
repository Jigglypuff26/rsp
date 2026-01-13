import React from 'react';

import { render, screen } from '@testing-library/react';

import { MainPage } from './index';

test('renders main page', () => {
  render(<MainPage />);
  const textElement = screen.getByText(/правки/i);
  expect(textElement).toBeInTheDocument();
});
