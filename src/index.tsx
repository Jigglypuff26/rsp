import React from 'react';
import ReactDOM from 'react-dom/client';
import { AppProvider } from './app/providers/AppProvider';
import { App } from './app/App';
import { reportWebVitals } from './shared/lib';
import './shared/config/styles/index.css';

const root = ReactDOM.createRoot(document.getElementById('root') as HTMLElement);
root.render(
  <AppProvider>
    <App />
  </AppProvider>
);

reportWebVitals();
