import React from 'react';

import ReactDOM from 'react-dom/client';

import { App } from './app/App';
import { AppProvider } from './app/providers/AppProvider';
import './shared/config/styles/index.css';
import { reportWebVitals } from './shared/lib';

const root = ReactDOM.createRoot(document.getElementById('root') as HTMLElement);
root.render(
  <AppProvider>
    <App />
  </AppProvider>
);

reportWebVitals();
